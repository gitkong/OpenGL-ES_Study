//
//  MetalVideoRenderViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/6/5.
//  Copyright © 2020 whatever. All rights reserved.
//

@import MetalKit;
@import CoreMedia;
#import "MetalVideoRenderViewController.h"
#import "CommonHeader.h"
#import "LYAssetReader.h"

@interface MetalVideoRenderViewController ()<MTKViewDelegate>


/// video
@property (nonatomic, strong) LYAssetReader *reader;

/// metal view
@property (nonatomic, strong) MTKView *mtkView;

/// 视口显示区域
@property (nonatomic, assign) vector_uint2 viewpointSize;

/// 渲染管道状态
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;

/// 计算管道状态
@property (nonatomic, strong) id<MTLComputePipelineState> computePipelineState;

/// 渲染指令队列
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

/// 顶点数据
@property (nonatomic, strong) id<MTLBuffer> vertices;

/// 顶点数量
@property (nonatomic, assign) NSUInteger numVertices;

/// 矩阵转换数据
@property (nonatomic, strong) id<MTLBuffer> convertMatrix;

/// coreVideo metal cache texture
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@end

@implementation MetalVideoRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
    self.reader = [[LYAssetReader alloc] initWithUrl:url];
    
    [self setup];
}

#pragma mark - MTKViewDelegate Method - Begin

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewpointSize = (vector_uint2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPasDes = view.currentRenderPassDescriptor;
    CMSampleBufferRef sampleBuffer = [self.reader readBuffer]; // 从LYAssetReader中读取图像数据
    if (renderPasDes && sampleBuffer) {
        renderPasDes.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0);
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPasDes];
        MTLViewport viewpoint = {0, 0, self.viewpointSize.x, self.viewpointSize.y, -1.0, 1.0};
        [renderEncoder setViewport:viewpoint];
        
        [renderEncoder setRenderPipelineState:self.renderPipelineState];
        
        [renderEncoder setVertexBuffer:self.vertices offset:0 atIndex:0];
        
        // 设置片元纹理
        [self setupTextureWithEncoder:renderEncoder buffer:sampleBuffer];
        
        [renderEncoder setFragmentBuffer:self.convertMatrix offset:0 atIndex:0];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        
    }
    [commandBuffer commit];
}

#pragma mark MTKViewDelegate Method - End

- (void)setup {
    // 设置mtkview
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    [self.view addSubview:self.mtkView];
    // 创建textureCache
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
    
    self.viewpointSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    [self setupRenderPipeline];
    [self setupVertex];
    [self setupMatrix];
}

- (void)setupRenderPipeline {
    // 设置渲染管道
    id<MTLLibrary> library = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFuc = [library newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fregmentFunc = [library newFunctionWithName:@"samplingShader1"];
    
    MTLRenderPipelineDescriptor *renderDesp = [[MTLRenderPipelineDescriptor alloc] init];
    renderDesp.vertexFunction = vertexFuc;
    renderDesp.fragmentFunction = fregmentFunc;
    renderDesp.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.renderPipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:renderDesp error:NULL];
    
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setupVertex {
    static const GKVertex quadVertices[] =
    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 1.f } },
        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
        
        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  1.0,  1.0, 0.0, 1.0 },  { 1.f, 0.f } },
    };
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
    
    self.numVertices = sizeof(quadVertices) / sizeof(GKVertex);
    
}

- (void)setupMatrix {
    matrix_float3x3 kColorConversion601FullRangeMatrix = (matrix_float3x3) {
        (simd_float3){1.0, 1.0, 1.0},
        (simd_float3){0.0, -0.343, 1.765},
        (simd_float3){1.4, -0.711, 0.0},
    };
    vector_float3 kColorConversion601FullRangeOffset = (vector_float3){-(16 / 255.0), -0.5, -0.5};
    
    GKConverMatrix matrix;
    matrix.matrix = kColorConversion601FullRangeMatrix;
    matrix.offset = kColorConversion601FullRangeOffset;
    
    self.convertMatrix = [self.mtkView.device newBufferWithBytes:&matrix length:sizeof(matrix) options:MTLResourceStorageModeShared];
}

- (void)setupTextureWithEncoder:(id<MTLRenderCommandEncoder>)encoder buffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 获取y、uv纹理
    id<MTLTexture> textureY = nil;
    id<MTLTexture> textureUV = nil;
    
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm;// 8 bit
        // CoreVideo的metal纹理
        CVMetalTextureRef texture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, self.textureCache, pixelBuffer, NULL, pixelFormat, width, height, 0, &texture);
        if (status == kCVReturnSuccess) {
            // 转换成Metal用得纹理
            textureY = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        }
    }
    
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm; // 16bit
        
        CVMetalTextureRef texture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, self.textureCache, pixelBuffer, NULL, pixelFormat, width, height, 1, &texture);
        
        if (status == kCVReturnSuccess) {
            textureUV = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        }
    }
    
    if (textureY && textureUV) {
        [encoder setFragmentTexture:textureY atIndex:GKFragmentYUVTextureIndexY];
        
        [encoder setFragmentTexture:textureUV atIndex:GKFragmentYUVTextureIndexUV];
    }
    CFRelease(sampleBuffer);
}

@end
