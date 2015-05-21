//
//  Shader.fsh
//  ddfs
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

uniform sampler2D shadowMap;

varying lowp vec2 ftextcoord;

void main()
{
    highp float r = texture2D(shadowMap, ftextcoord).r;
    gl_FragColor = vec4(r, r, r, 1.0);
}
