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
    // vertexBufferID 变 量 保 存 了 用于盛放本例中用到的顶点数据的缓存的 OpenGL ES 标识符，缓存标识符实际上是无符号整型。0 值表示没有缓存
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
    
    // 设置背景颜色，glClearColor() 函数设置当前 OpenGL ES 的上下文的“清除颜色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    // step1：缓存生成（Generate）,glGenBuffers() 函数的第一个参数用于指定要生成的缓存标识符的数 量，第二个参数是一个指针，指向生成的标识符的内存保存位置
    /*
     可以声明一个GLuint变量，然后使用glGenBuffers后，它就会把缓冲对象保存在vbo里，当然也可以声明一个数组类型，那么创建的3个缓冲对象的名称会依次保存在数组里。
     GLuint vbo;
     glGenBuffers(1,&vbo);
     GLuint vbo[3];
     glGenBuffers(3,vbo);
     */
    glGenBuffers(1, &vertexBufferId);
    
    // step2：绑定（Bind），glBindBuffer() 函数绑定用于指定标识符的缓存到当前缓存，第一个参数是一个常量，用于指定要绑定哪一种类型的缓存，第二个参数是要绑定的缓存的标识符
    /*
     使用该函数将缓冲对象绑定到OpenGL上下文环境中以便使用。如果把target绑定到一个已经创建好的缓冲对象，那么这个缓冲对象将为当前target的激活对象；但是如果绑定的buffer值为0，那么OpenGL将不再对当前target使用任何缓存对象。
     
     OpenGL ES 2.0对于glBindBuffer()的实现只支持两种类型的缓存，GL_ARRAY_ BUFFER 和 GL_ELEMENT_ARRAY_BUFFER，GL_ARRAY_BUFFER 类型用于指定一个顶点属性数组
     */
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
    
    // step3：缓存数据（Buffer Data）,参数1：缓冲类型，参数2：缓存数据的大小，参数3：缓存指针，参数4：缓存的使用类型
    /*
     glBufferData() 的第一个参数用于指定要更新当前上下文中所绑定的是哪一个缓 存。第二个参数指定要复制进这个缓存的字节的数量。第三个参数是要复制的字节的地 址。最后，第 4 个参数提示了缓存在未来的运算中可能将会被怎样使用。GL_STATIC_ DRAW 提示会告诉上下文，缓存中的内容适合复制到 GPU 控制的内存，因为很少对其 进行修改。这个信息可以帮助 OpenGL ES 优化内存使用。使用 GL_DYNAMIC_DRAW 作为提示会告诉上下文，缓存内的数据会频繁改变，同时提示 OpenGL ES 以不同的方 式来处理缓存的存储。
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
}
// GLKViewDelegate 代理回调
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 每当一个 GLKView 实例需要被重绘时，它都会让保存在视图的上下文属性中的 OpenGL ES 的上下文成为当前上下文
    
    // 告诉 baseEffect 准备好当前 OpenGL ES 的上下文，以便为 使用 baseEffect 生成的属性和 Shading Language 程序的绘图做好准备
    [self.baseEffect prepareToDraw];
    
    // 调用 OpenGL ES 的 glClear() 函数来设置当前绑定的帧缓存的像素颜色渲染缓存中的每一个 像素的颜色为前面使用 glClearColor() 函数设定的值
    glClear(GL_COLOR_BUFFER_BIT);
    
    // step4：启动顶点缓存渲染操作
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // step5：设置指针，在这个例子中，第一个参 数指示当前绑定的缓存包含每个顶点的位置信息。第二个参数指示每个位置有 3 个部 分。第三个参数告诉 OpenGL ES 每个部分都保存为一个浮点类型的值。第四个参数告 诉 OpenGL ES 小数点固定数据是否可以被改变，第五个参数叫做“步幅”，它指定了每个顶点的保存需要多少个字节。换句话说， 步幅指定了 GPU 从一个顶点的内存开始位置转到下一个顶点的内存开始位置需要跳过 多少字节，最后一个参数是 NULL，这告诉 OpenGL ES 可以从当前 绑定的顶点缓存的开始位置访问顶点数据
    // glVertextAttribPointer() 函数会告诉 OpenGL ES 顶点数据在哪里，以 及怎么解释为每个顶点保存的数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    
    // step6：绘图，glDrawArrays() 的第一个参数 会告诉 GPU 怎么处理在绑定的顶点缓存内的顶点数据，第二个参数和第三个参数分别指定缓存内的需要渲染的 第一个顶点的位置和需要渲染的顶点的数量
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)dealloc {
    // step7：删除
    glDeleteBuffers(1, &vertexBufferId);
    vertexBufferId = 0;
    
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end
