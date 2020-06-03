//
//  MetalCaptureViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/6/2.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "MetalCaptureViewController.h"
@import MetalKit;
@import AVFoundation;
@import CoreMedia;
@import MetalPerformanceShaders;

@interface MetalCaptureViewController ()<MTKViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

/// metal view
@property (nonatomic, strong) MTKView *mtkView;

/// 渲染纹理
@property (nonatomic, strong) id<MTLTexture> texture;

/// 编码队列
@property (nonatomic, strong) id<MTLCommandQueue> cmdQueue;

/// 摄像头
@property (nonatomic, strong) AVCaptureSession *captureSession;

/// 采集串行队列
@property (nonatomic, strong) dispatch_queue_t processQueue;

/// 采集输入
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;

/// 采集输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;

/// metal 纹理输出缓存
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@end

@implementation MetalCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMetalView];
    [self setupCaptureSession];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Method - Begin

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (kCVReturnSuccess == status) {
        self.mtkView.drawableSize = CGSizeMake(width, height);
        self.texture = CVMetalTextureGetTexture(tmpTexture);
        CFRelease(tmpTexture);
    }
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate Method - End

#pragma mark - MTKViewDelegate Method - Begin

- (void)drawInMTKView:(MTKView *)view {
    if (self.texture) {
        // 创建指令缓存
        id<MTLCommandBuffer> cmdBuffer = [self.cmdQueue commandBuffer];
        // 把mtkView作为目标输出纹理
        id<MTLTexture> drawingTexture = view.currentDrawable.texture;
        
        MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:view.device sigma:1];
        [filter encodeToCommandBuffer:cmdBuffer sourceTexture:self.texture destinationTexture:drawingTexture];
        
        [cmdBuffer presentDrawable:view.currentDrawable];
        [cmdBuffer commit];
        
        self.texture = NULL;
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}


#pragma mark MTKViewDelegate Method - End

#pragma mark - Private Method - Begin

- (void)setupMetalView {
    self.mtkView = [[MTKView alloc] initWithFrame:CGRectMake(0, 200, 300, 300) device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    self.mtkView.framebufferOnly = NO;
    [self.view addSubview:self.mtkView];
    
    self.cmdQueue = [self.mtkView.device newCommandQueue];
    // 输出纹理缓存
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
}

- (void)setupCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    self.processQueue = dispatch_queue_create("Process_Queue", DISPATCH_QUEUE_SERIAL);
    // 设置后置
    AVCaptureDevice *inputCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//    AVCaptureDevice *inputCamera = nil;
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for (AVCaptureDevice *device in devices) {
//        if ([device position] == AVCaptureDevicePositionBack) {
//            inputCamera = device;
//        }
//    }
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:NULL];
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
    // 设置颜色空间
    [self.captureVideoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)}];
    [self.captureVideoDataOutput setSampleBufferDelegate:self queue:self.processQueue];
    if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession addOutput:self.captureVideoDataOutput];
    }
    AVCaptureConnection *connection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [self.captureSession startRunning];
    
}

#pragma mark Private Method - End



@end
