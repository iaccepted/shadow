//
//  blur.fsh
//  shadow
//
//  Created by iaccepted on 15/6/8.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//
varying highp vec2 uv;

uniform sampler2D colorTexture;
uniform highp vec2 textSize;//width and height

#define FXAA_REDUCE_MIN   (1.0 / 128.0)
#define FXAA_REDUCE_MUL   (1.0 / 8.0)
#define FXAA_SPAN_MAX      8.0



void main()
{
    highp vec2 rate = 1.0 / textSize;
    
    highp vec4 color;
    highp vec3 rgbNW = texture2D(colorTexture, uv + (vec2(-1.0, -1.0) * rate)).xyz;
    highp vec3 rgbNE = texture2D(colorTexture, uv + (vec2(1.0, -1.0) * rate)).xyz;
    highp vec3 rgbSW = texture2D(colorTexture, uv + (vec2(-1.0, 1.0) * rate)).xyz;
    highp vec3 rgbSE = texture2D(colorTexture, uv + (vec2(1.0, 1.0) * rate)).xyz;
    highp vec4 textColor = texture2D(colorTexture, uv);
    highp vec3 rgbM = textColor.xyz;
    highp float alpha = textColor.w;
    
    highp vec3 luma = vec3(0.299, 0.587, 0.114);
    highp float lumaNW = dot(rgbNW, luma);
    highp float lumaNE = dot(rgbNE, luma);
    highp float lumaSW = dot(rgbSW, luma);
    highp float lumaSE = dot(rgbSE, luma);
    highp float lumaM = dot(rgbM, luma);
    highp float lumaMin = min(lumaM, min(min(lumaNE, lumaNW), min(lumaSE, lumaSW)));
    highp float lumaMax = max(lumaM, max(max(lumaNE, lumaNW), max(lumaSE, lumaSW)));
    
    mediump vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y = ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    highp float dirReduce = max((lumaNW + lumaNE + lumaSE + lumaSW) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    highp float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    
    dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) / textSize;
    
    highp vec3 rgbA = 0.5 * (texture2D(colorTexture, uv + dir * (1.0 / 3.0 - 0.5)).xyz +
                       texture2D(colorTexture, uv + dir * (2.0 / 3.0 - 0.5)).xyz);
    
    highp vec3 rgbB = rgbA * 0.5 + 0.25 * (texture2D(colorTexture, uv + dir * (0.0 / 3.0 - 0.5)).xyz +
                                     texture2D(colorTexture, uv + dir * (3.0 / 3.0 - 0.5)).xyz);
    
    highp float lumaB = dot(rgbB, luma);
    
    if ((lumaB < lumaMin) || (lumaB > lumaMax))
    {
        color = vec4(rgbA, alpha);
    }
    else{
        color = vec4(rgbB, alpha);
    }
    gl_FragColor = color;
    //    gl_FragColor = vec4(factor, factor, factor, 1.0);
}