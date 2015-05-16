/*
 shader.vsh
 opengl
 
 Created by iaccepted on 15/4/9.
 Copyright (c) 2015年 iaccepted. All rights reserved.
 */

attribute vec3 vposition;
attribute vec3 vnormal;
attribute vec2 textcoord;

uniform mat4 MVP;
uniform mat4 normalMatrix;
uniform mat4 shadowMVP;


varying vec4 fcolor;
varying highp vec3 fposition;
varying highp vec2 ftextcoord;
varying highp vec4 fshadowCoord;
varying highp vec3 feyeNormal;


void main()
{
    gl_Position = MVP * vec4(vposition, 1.0);
    fposition = vposition;
    fshadowCoord = shadowMVP * vec4(vposition, 1.0);
    feyeNormal = vec3(normalize(normalMatrix * vec4(vnormal, 1.0)));
    ftextcoord = textcoord;
}


