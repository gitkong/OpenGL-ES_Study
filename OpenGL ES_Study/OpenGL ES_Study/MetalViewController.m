//
//  MetalViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/5/26.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "MetalViewController.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "CommonHeader.h"


@interface MetalViewController ()<MTKViewDelegate>

/// 初始化view，用来显示metal的绘制
@property (nonatomic, strong) MTKView *mtkView;

/// 记录渲染管道状态
@property (nonatomic, strong) id <MTLRenderPipelineState>  pipelineState;

/// 渲染指令队列
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;

/// 顶点缓存数据
@property (nonatomic, strong) id <MTLBuffer> vertices;

/// 顶点缓存个数
@property (nonatomic, assign) int  numVertices;

/// 纹理
@property (nonatomic, strong) id<MTLTexture> texture;

/// viewpoint 显示区域
@property (nonatomic, assign) vector_uint2 viewPointSize;

@end

@implementation MetalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

#pragma mark - Private Method - Begin

- (void)setup {
    [self setupMTKView];
    [self setupPipeline];
    [self setupVertex];
    [self setupTexture];
}

/// 初始化显示渲染结果的view
- (void)setupMTKView {
    // device表示GPU
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    
    // 缓存viewpoint显示区域
    self.viewPointSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    [self.view addSubview:self.mtkView];
}


/// 初始化渲染管道
- (void)setupPipeline {
    // .metal
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    // 顶点shader，vertexShader是函数名
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    // 片元shader，samplingShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
    
    // 创建渲染管道描述，设置顶点处理函数、片元处理函数以及颜色格式等
    MTLRenderPipelineDescriptor *pipelineStateDescripter = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescripter.vertexFunction = vertexFunction;// 设置顶点shader
    pipelineStateDescripter.fragmentFunction = fragmentFunction;// 设置片元shader
    pipelineStateDescripter.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    // 创建图像渲染管道，耗性能操作不宜频繁调用
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescripter error:NULL];
    // commandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
    self.commandQueue = [self.mtkView.device newCommandQueue];
    
}

/// 初始化顶点数据-包括顶点坐标、纹理坐标
- (void)setupVertex {
    // 顶点坐标、纹理坐标
    static const GKVertex quadVertex[] = {
        {{ 0.5, -0.5, 0.0, 1.0}, {1.f, 1.f}},
        {{-0.5, -0.5, 0.0, 1.0}, {0.f, 1.f}},
        {{-0.5,  0.5, 0.0, 1.0}, {0.f, 0.f}},
        
        {{ 0.5, -0.5, 0.0, 1.0}, {1.f, 1.f}},
        {{-0.5,  0.5, 0.0, 1.0}, {0.f, 0.f}},
        {{ 0.5,  0.5, 0.0, 1.0}, {1.f, 0.f}},
    };
    // 创建顶点缓存MTLResourceStorageModeShared，类似OpenGL ES的glGenBuffer创建的缓存。
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertex length:sizeof(quadVertex) options:MTLResourceStorageModeShared];
    // 获取顶点个数
    self.numVertices = sizeof(quadVertex) / sizeof(GKVertex);
//    MTLVertexDescriptor
}

/// 初始化纹理数据
- (void)setupTexture {
    UIImage *image = [UIImage imageNamed:@"abc"];
    // 设置纹理描述，可以设置像素的颜色格式、图像宽高等，用于创建纹理
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = image.size.width;
    textureDescriptor.height = image.size.height;
    // 创建纹理
    // 可利用贴纸加载器MTKTextureLoader加载贴纸
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:self.mtkView.device];
    self.texture = [loader newTextureWithCGImage:image.CGImage options:@{MTKTextureLoaderOptionSRGB : @YES,MTKTextureLoaderOptionGenerateMipmaps : @YES} error:NULL];
//    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
//    // 设置纹理上传的范围(xyz,whd)，类似UIKit的frame，用于表明纹理数据的存放区域
//    MTLRegion region = {{0, 0, 0}, {image.size.width, image.size.height, 1}};
//    Byte *imageBytes = [self loadImage:image];
//    if (imageBytes) {
//        // 上传纹理数据
//        [self.texture replaceRegion:region mipmapLevel:0 withBytes:imageBytes bytesPerRow:image.size.width * 4];
//        free(imageBytes);
//        imageBytes = NULL;
//    }
    
}

- (Byte *)loadImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    Byte *byteData = (Byte *)calloc(width * height * 4, sizeof(Byte));
    CGContextRef context = CGBitmapContextCreate(byteData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(context);
    return byteData;
}

#pragma mark Private Method - End



#pragma mark - MTKViewDelegate Method - Begin

/*!
 @method mtkView:drawableSizeWillChange:
 @abstract Called whenever the drawableSize of the view will change
 @discussion Delegate can recompute view and projection matricies or regenerate any buffers to be compatible with the new view size or resolution
 @param view MTKView which called this method
 @param size New drawable size in pixels
 */
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

/*!
 @method drawInMTKView:
 @abstract Called on the delegate when it is asked to render into the view
 @discussion Called on the delegate when it is asked to render into the view，整个绘制的过程与OpenGL ES一致，先设置窗口大小，然后设置顶点数据和纹理，最后绘制
 */
- (void)drawInMTKView:(nonnull MTKView *)view {
    // 每次单独渲染都要通过渲染指令队列创建一个commandBuffer，渲染指令
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    // 创建渲染指令编码-需要利用MTLRenderPassDescriptor，描述一系列attachments的值，类似GL的frameBuffer
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        // 设置默认颜色
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0f);
        // 创建编码encoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        // 设置显示区域
        MTLViewport viewPoint = {0, 0, self.viewPointSize.x, self.viewPointSize.y, -1.0, 1.0};
        [renderEncoder setViewport:viewPoint];
        // 设置渲染管道，保证顶点和片元两个shader会被调用
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        // 设置顶点缓存
        [renderEncoder setVertexBuffer:self.vertices offset:0 atIndex:0];
        
        // 设置纹理
        [renderEncoder setFragmentTexture:self.texture atIndex:0];
//        CAMetalLayer
//        UIScreen
//        MTLStoreAction
//        MTLBuffer
//        MTLDrawPrimitivesIndirectArguments
        // 绘制
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        
        // 结束编码
        [renderEncoder endEncoding];
        
        // 显示,The currentDrawable property is automatically updated at the end of every frame.
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    // 提交,A drawable’s presentation is registered by calling a command buffer’s presentDrawable: method before calling its commit method.
    [commandBuffer commit];
}

#pragma mark MTKViewDelegate Method - End

@end
