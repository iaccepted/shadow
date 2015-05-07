/*
 shader.vsh
 opengl
 
 Created by iaccepted on 15/4/9.
 Copyright (c) 2015年 iaccepted. All rights reserved.
 */
#extension GL_EXT_shadow_samplers : require
attribute vec3 vposition;
attribute vec3 vnormal;
attribute vec2 textcoord;

uniform sampler2D texture;

varying vec4 fcolor;

struct Light
{
    vec3 direction;
    vec3 color;
};

struct Material
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
    float alph;
};

uniform mat4 MVP;
uniform mat4 normalMatrix;

uniform mat4 shadowMVP;

uniform Light light;
uniform Material material;

uniform sampler2DShadow shadowMap;
const lowp float kShadowAmount = 0.4;

void main()
{
    gl_Position = MVP * vec4(vposition, 1.0);
    vec4 textColor = texture2D(texture, textcoord);
    
    vec4 shadowCoord = shadowMVP * vec4(vposition, 1.0);
    
    vec3 eyeNormal = vec3(normalize(normalMatrix * vec4(vnormal, 1.0)));
    vec3 lightDirection = normalize(light.direction);
    float diff = max(dot(lightDirection, eyeNormal), 0.0);
    vec3 ambient;
    vec3 diffuse;
    if (textColor[0] < 0.001 && textColor[1] < 0.001 && textColor[2] < 0.001) {
        //ambient
        ambient = material.ambient * light.color;
        //diffuse
        diffuse = diff * material.diffuse * light.color;
    }
    else
    {
        //ambient
        ambient = vec3(textColor * vec4(material.ambient * light.color, 1.0));
        //diffuse
        diffuse = vec3(textColor * diff * vec4(material.diffuse * light.color, 1.0));
    }
    
    //specular
    vec3 viewDirection = normalize(vposition);
    vec3 reflectDirection = normalize(reflect(-light.direction, eyeNormal));
    float spec = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);
    vec3 specular = spec * material.specular * light.color;
    vec3 ds = diffuse + specular;
    ds = ds * ((1.0 - kShadowAmount) + kShadowAmount * shadow2DProjEXT(shadowMap, shadowCoord));
    
    fcolor = vec4(ambient + ds, material.alph);
}


