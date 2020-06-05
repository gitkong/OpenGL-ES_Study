//
//  MetalGrayPicViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/6/3.
//  Copyright © 2020 whatever. All rights reserved.
//

@import MetalKit;
#import "MetalGrayPicViewController.h"
#import "CommonHeader.h"


@interface MetalGrayPicViewController ()<MTKViewDelegate>

/// metal view
@property (nonatomic, strong) MTKView *mtkView;

/// viewpoint 渲染视口
@property (nonatomic, assign) CGSize viewpointSize;

/// 渲染管道状态
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPilelineState;

/// 计算管道状态
@property (nonatomic, strong) id<MTLComputePipelineState> computePipelineState;

/// 编码队列
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

/// 源纹理
@property (nonatomic, strong) id<MTLTexture> sourceTexture;

/// 目标纹理
@property (nonatomic, strong) id<MTLTexture> destTexture;

/// 顶点数据
@property (nonatomic, strong) id<MTLBuffer> vertices;

/// 顶点数量
@property (nonatomic, assign) NSUInteger numVertices;

/// groupSize
@property (nonatomic, assign) MTLSize groupSize;

/// groupCount
@property (nonatomic, assign) MTLSize groupCount;

@end

@implementation MetalGrayPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

#pragma mark - MTKViewDelegate Method - Begin

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewpointSize = size;
}

- (void)drawInMTKView:(MTKView *)view {
    // 创建命令buffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    // 计算编码
    id<MTLComputeCommandEncoder> computeCmdEncoder = [commandBuffer computeCommandEncoder];
    // 设置计算管道
    [computeCmdEncoder setComputePipelineState:self.computePipelineState];
    // 设置输入纹理
    [computeCmdEncoder setTexture:self.sourceTexture atIndex:GKFragmentTextureIndexTextureSource];
    // 设置输出纹理
    [computeCmdEncoder setTexture:self.destTexture atIndex:GKFragmentTextureIndexTextureDest];
    // 计算区域
    [computeCmdEncoder dispatchThreadgroups:self.groupCount threadsPerThreadgroup:self.groupSize];
    // 释放计算encoder，才能创建下一个
    [computeCmdEncoder endEncoding];
    
    // 创建渲染编码
    MTLRenderPassDescriptor *renderPassDesp = view.currentRenderPassDescriptor;
    if (renderPassDesp) {
        renderPassDesp.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1);
        id<MTLRenderCommandEncoder> renderCmdEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDesp];
        
        // 设置绘制视口
        [renderCmdEncoder setViewport:(MTLViewport){0, 0, self.viewpointSize.width, self.viewpointSize.height, -1.0, 1.0}];
        // 设置渲染管道
        [renderCmdEncoder setRenderPipelineState:self.renderPilelineState];
        // 设置顶点缓存
        [renderCmdEncoder setVertexBuffer:self.vertices offset:0 atIndex:0];
        // 设置输出纹理
        [renderCmdEncoder setFragmentTexture:self.destTexture atIndex:0];
        // 绘制
        [renderCmdEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        // 编码结束
        [renderCmdEncoder endEncoding];
        // 显示
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

#pragma mark MTKViewDelegate Method - End

#pragma mark - Private Method - Begin

- (void)setup {
    [self setupMTKView];
    [self setupPipeline];
    [self setupVertex];
    [self setupTexture];
    [self setupThreadGroup];
}

- (void)setupMTKView {
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    self.viewpointSize = CGSizeMake(self.mtkView.drawableSize.width, self.mtkView.drawableSize.height);
    [self.view addSubview:self.mtkView];
}

- (void)setupPipeline {
    
    id<MTLLibrary> library = [self.mtkView.device newDefaultLibrary];
    // 设置顶点着色函数、片元着色函数、计算函数
    id<MTLFunction> verticesFunc = [library newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"samplingShader"];
    id<MTLFunction> kernelFunc = [library newFunctionWithName:@"grayKernel"];
    
    // 设置渲染管道和计算管道
    self.computePipelineState = [self.mtkView.device newComputePipelineStateWithFunction:kernelFunc error:NULL];
    
    MTLRenderPipelineDescriptor *renderPipelineDesp = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDesp.vertexFunction = verticesFunc;
    renderPipelineDesp.fragmentFunction = fragmentFunc;
    renderPipelineDesp.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.renderPilelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:renderPipelineDesp error:NULL];
    
    // 设置编码队列
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setupVertex {
    static const GKVertex quadVertex[] = {
        {{ 0.5, -0.5, 0.0, 1.0}, {1.f, 1.f}},
        {{-0.5, -0.5, 0.0, 1.0}, {0.f, 1.f}},
        {{-0.5,  0.5, 0.0, 1.0}, {0.f, 0.f}},
        
        {{ 0.5, -0.5, 0.0, 1.0}, {1.f, 1.f}},
        {{-0.5,  0.5, 0.0, 1.0}, {0.f, 0.f}},
        {{ 0.5,  0.5, 0.0, 1.0}, {1.f, 0.f}},
    };
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertex length:sizeof(quadVertex) options:MTLResourceStorageModeShared];
    self.numVertices = sizeof(quadVertex) / sizeof(GKVertex);
}

- (void)setupTexture {
    UIImage *image = [UIImage imageNamed:@"abc"];
    MTLTextureDescriptor *textureDesp = [[MTLTextureDescriptor alloc] init];
    textureDesp.pixelFormat = MTLPixelFormatBGRA8Unorm;
    textureDesp.width = image.size.width;
    textureDesp.height = image.size.height;
    // 原图只需要读取，不需要修改
    textureDesp.usage = MTLTextureUsageShaderRead;
    // 创建源纹理
    self.sourceTexture = [self.mtkView.device newTextureWithDescriptor:textureDesp];
    // 设置纹理数据
    MTLRegion region = MTLRegionMake3D(0, 0, 0, image.size.width, image.size.height, 1);
    Byte *imageBytes = [self loadImage:image];
    if (imageBytes) {
        [self.sourceTexture replaceRegion:region mipmapLevel:0 withBytes:imageBytes bytesPerRow:4 * image.size.width];
        free(imageBytes);
        imageBytes = NULL;
    }
    
    // 创建目标纹理,目标纹理需要计算，因此可读写
    textureDesp.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    self.destTexture = [self.mtkView.device newTextureWithDescriptor:textureDesp];
    
}

- (void)setupThreadGroup {
    // 在 Compute encoder 中，为了提高计算的效率，每个图片都会分为一个小的单元送到 GPU 进行并行处理，分多少组和每个组的单元大小都是由 Encder 来配置的。
    /*为了最大化提高GPU的计算性能，可以按以下配置
     
     NSUInteger width = self.computePipelineState.threadExecutionWidth;
     NSUInteger height = self.computePipelineState.maxTotalThreadsPerThreadgroup / width;
     self.groupSize = MTLSizeMake(width, height, 1);
     self.groupCount = MTLSizeMake((self.sourceTexture.width + width - 1) / width, (self.sourceTexture.height + height - 1) / height, 1);
     */
    
    self.groupSize = MTLSizeMake(16, 16, 1);
    _groupCount.width = (self.sourceTexture.width + self.groupSize.width - 1) / self.groupSize.width;
    _groupCount.height = (self.sourceTexture.height + self.groupSize.height - 1) / self.groupSize.height;
    // 只处理2D纹理，因此depth设置深度为1
    _groupCount.depth = 1;
}

- (Byte *)loadImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    Byte *spriteData = (Byte *)calloc(width * height * 4, sizeof(Byte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    return spriteData;
}

#pragma mark Private Method - End

@end
