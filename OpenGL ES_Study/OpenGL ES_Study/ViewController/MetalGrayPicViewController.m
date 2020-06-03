//
//  MetalGrayPicViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/6/3.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "MetalGrayPicViewController.h"
@import MetalKit;

@interface MetalGrayPicViewController ()

/// metal view
@property (nonatomic, strong) MTKView *mtkView;

@end

@implementation MetalGrayPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

#pragma mark - Private Method - Begin

- (void)setup {
    [self setupMTKView];
    [self setupPipeline];
}

- (void)setupMTKView {
    <#funcBody#>
}

- (void)setupPipeline {
    <#funcBody#>
}

- (void)setupVertex {
    <#funcBody#>
}

- (void)setupTexture {
    <#funcBody#>
}

- (void)setupThreadGroup {
    <#funcBody#>
}

#pragma mark Private Method - End

@end
