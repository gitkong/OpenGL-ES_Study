# OpenGL-ES_Study
OpenGL ES 、Metal 学习

最佳实践：https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Drawables.html#//apple_ref/doc/uid/TP40016642-CH2-SW1

官方文档：https://developer.apple.com/documentation/metal

Metal Programming Guide：https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221

落影：https://www.jianshu.com/nb/26273087


Metal Question：


0、渲染流程

1、MTLResourceStorageModeShared

In iOS and tvOS, the Shared mode defines system memory accessible to both the CPU and the GPU, whereas the Private mode defines system memory accessible only to the GPU.
The Shared mode is usually the correct choice for iOS and tvOS resources. Choose the Private mode only if the CPU never accesses your resource.

https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/ResourceOptions.html#//apple_ref/doc/uid/TP40016642-CH17-SW1  2、MTLPixelFormatRGBA8Unorm

3、MTLRenderPassDescriptor和GL的frameBuffer

4、MTLPrimitiveTypeTriangle 绘制

5、presentDrawable 和 commit
