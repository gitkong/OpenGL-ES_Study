//
//  CommonHeader.h
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/5/27.
//  Copyright © 2020 whatever. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

typedef struct {
    vector_float4 position;// 顶点坐标（x、y、z、w），w表示范围，一般为1.0，表示【-1，1】
    vector_float2 textureCoordinate;// 纹理坐标
} GKVertex;

#endif /* CommonHeader_h */
