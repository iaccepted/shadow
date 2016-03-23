//
//  blur.fsh
//  shadow
//
//  Created by iaccepted on 15/6/8.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//
varying highp vec2 uv;

uniform sampler2D aoTexture;
uniform sampler2D colorTexture;
uniform int blurSize;
uniform highp vec2 textSize;//width and height



void main()
{
    highp vec2 rate = 1.0 / textSize;
    highp vec2 baseCenter = vec2(float(-blurSize / 2));
    highp float result = 0.0;

    
    for (int i = 0; i < blurSize; ++i) {
        for (int j = 0; j < blurSize; ++j) {
            highp vec2 offset = (baseCenter + vec2(float(i), float(j))) * rate;
            result += texture2D(aoTexture, uv + offset).r;
        }
    }
    highp float factor = result / float(blurSize * blurSize);
    
    gl_FragColor = factor * texture2D(colorTexture, uv);
//    gl_FragColor = vec4(factor, factor, factor, 1.0);
}