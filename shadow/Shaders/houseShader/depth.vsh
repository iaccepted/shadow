attribute highp vec3 vposition;
attribute vec3 vnormal;
attribute vec2 textcoord;

uniform highp mat4 shadowMVP;

void main()
{
    gl_Position = shadowMVP * vec4(vposition, 1.0);
}