attribute highp vec2 textcoord;

varying highp vec2 uv;

void main()
{
    uv = (textcoord + vec2(1.0, 1.0)) * 0.5;
    gl_Position = vec4(textcoord, 0.0, 1.0);
}