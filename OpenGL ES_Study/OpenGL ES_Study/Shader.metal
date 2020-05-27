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
