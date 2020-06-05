//
//  CommonHeader.h
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/5/27.
//  Copyright © 2020 whatever. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

#include <simd/simd.h>

typedef struct {
    vector_float4 position;// 顶点坐标（x、y、z、w），w表示范围，一般为1.0，表示【-1，1】
    vector_float2 textureCoordinate;// 纹理坐标
} GKVertex;

//C++ requires a type specifier for all declarations
//typedef NS_ENUM(NSUInteger, GKFragmentTextureIndex) {
//    GKFragmentTextureIndexTextureSource = 0,
//    GKFragmentTextureIndexTextureDest = 1
//};

typedef enum GKFragmentTextureIndex {
    GKFragmentTextureIndexTextureSource = 0,
    GKFragmentTextureIndexTextureDest = 1
} GKFragmentTextureIndex;

typedef struct {
    matrix_float3x3 matrix;
    vector_float3 offset;
} GKConverMatrix;

typedef enum GKFragmentYUVTextureIndex {
    GKFragmentYUVTextureIndexY = 0,
    GKFragmentYUVTextureIndexUV = 1,
} GKFragmentYUVTextureIndex;

#endif /* CommonHeader_h */
