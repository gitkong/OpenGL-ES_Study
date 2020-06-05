//
//  Shader.metal
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/5/27.
//  Copyright © 2020 whatever. All rights reserved.
//

#include <metal_stdlib>
#import "CommonHeader.h"

using namespace metal;


typedef struct {
    float4 clipSpacePosition [[position]];// position的修饰 符号表示这个是顶点
    float2 textureCoordinate;// 纹理坐标，会做插值处理
} RasterizeData;

vertex RasterizeData vertexShader(uint vertexID [[ vertex_id ]], constant GKVertex *vertexArray [[ buffer(0) ]]) {
    RasterizeData output;
    output.clipSpacePosition = vertexArray[vertexID].position;
    output.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return output;
}

fragment float4 samplingShader(RasterizeData input [[stage_in]], texture2d<half> colorTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    half4 colorSample = colorTexture.sample(textureSampler, input.textureCoordinate);
    return float4(colorSample);
}

fragment float4 samplingShader1(RasterizeData input [[stage_in]],
                                texture2d<float> textureY [[texture(GKFragmentYUVTextureIndexY)]],
                                texture2d<float> textureUV [[texture(GKFragmentYUVTextureIndexUV)]],
                                constant GKConverMatrix *convertMatrix [[buffer(0)]]) {
    constexpr sampler textureSample(mag_filter::linear, min_filter::linear);
    
    float3 yuv = float3(textureY.sample(textureSample, input.textureCoordinate).r,
                        textureUV.sample(textureSample, input.textureCoordinate).rg);
    
    float3 rgb = convertMatrix->matrix * (yuv + convertMatrix->offset);
    
    return float4(rgb, 1.0);
}

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel void grayKernel(texture2d<half, access::read> sourceTexture [[texture(GKFragmentTextureIndexTextureSource)]],
                       texture2d<half, metal::access::write> destTexture [[texture(GKFragmentTextureIndexTextureDest)]],
                       uint2 grid [[thread_position_in_grid]]) {
    // 边界保护
    if(grid.x <= destTexture.get_width() && grid.y <= destTexture.get_height()) {
        // 初始化颜色
        half4 color = sourceTexture.read(grid);
        // 转换成亮度
        half gray = dot(color.rgb, kRec709Luma);
        // 写回对应的输出纹理
        destTexture.write(half4(gray, gray, gray, 1.0), grid);
    }
}
