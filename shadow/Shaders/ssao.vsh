attribute highp vec2 screenPosXY;

varying highp vec2 uv;

void main()
{
    uv = (screenPosXY + vec2(1.0, 1.0)) * 0.5;
    gl_Position = vec4(screenPosXY, 0.0, 1.0);
}