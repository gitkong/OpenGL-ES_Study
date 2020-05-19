//
//  ViewController.m
//  OpenGL ES_Study
//
//  Created by whatever on 2020/5/19.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "ViewController.h"

// GLKBaseEffect在iOS 12会提示警告废弃，可以在项目中配置 GLES_SILENCE_DEPRECATION忽略

// 定义了一个 C 结构体 SceneVertex，用来保存一个 GLKVector3 类型的成员 positionCoords。
typedef struct {
    // 顶点位置可以用一个起始于坐标系原点的矢量来表示。GLKit 的 GLKVector3 类型保存 了 3 个坐标:X、Y 和 Z。
    GLKVector3 positionCoords;
} SceneVertex;

// vertices 变量是一个用顶点数据初始化的普通 C 数组，这个变量用来定义一个三角形,默认的用于一个 OpenGL 上下文的可 见坐标系是分别沿着 X、Y、Z 轴从 –1.0 延伸到 1.0 的
static const SceneVertex vertices[] = {
    {-0.5f, -0.5f, 0.0f},
    { 0.5f, -0.5f, 0.0f},
    {-0.5f,  0.5f, 0.0f},
};

@interface ViewController (){
    // vertexBufferID 变 量 保 存 了 用于盛放本例中用到的顶点数据的缓存的 OpenGL ES 标识符
    GLuint vertexBufferId;
}
//GLKBaseEffect 是 GLKit 提供的另一个内建类。GLKBaseEffect 的存在是为了简 化 OpenGL ES 的很多常用操作。GLKBaseEffect 隐藏了 iOS 设备支持的多个 OpenGL ES 版本之间的差异。在应用中使用 GLKBaseEffect 能减少需要编写的代码量。在 OpenGLES_Ch2_1ViewController 的实现中详细解释了 GLKBaseEffect。
@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 获取glkView
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"VC.view is not a GLKView");
    
    // 生成并设置当前上下文
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    // 生成视觉处理视图控制
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);//RGBA
    
    // 设置背景颜色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    // step1：缓存生成（Generate）,第一个参数是要生成的缓冲对象的数量，第二个是要输入用来存储缓冲对象名称的数组
    /*
     可以声明一个GLuint变量，然后使用glGenBuffers后，它就会把缓冲对象保存在vbo里，当然也可以声明一个数组类型，那么创建的3个缓冲对象的名称会依次保存在数组里。
     GLuint vbo;
     glGenBuffers(1,&vbo);
     GLuint vbo[3];
     glGenBuffers(3,vbo);
     */
    glGenBuffers(1, &vertexBufferId);
    
    // step2：绑定（Bind）需要使用的缓存，第一个就是缓冲对象的类型，第二个参数就是要绑定的缓冲对象的名称
    // 使用该函数将缓冲对象绑定到OpenGL上下文环境中以便使用。如果把target绑定到一个已经创建好的缓冲对象，那么这个缓冲对象将为当前target的激活对象；但是如果绑定的buffer值为0，那么OpenGL将不再对当前target使用任何缓存对象。
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
    
    // step3：缓存数据（Buffer Data）,参数1：缓冲类型，
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
}


@end
