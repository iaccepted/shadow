#extension GL_OES_standard_derivatives : require
void main()
{
    lowp float depth = gl_FragCoord.z;
    lowp float depth2 = depth * depth;
    
    highp float dx = dFdx(depth);
    highp float dy = dFdy(depth);
    depth2 += 0.25 * (dx * dx + dy * dy);
    
    gl_FragColor = vec4(depth, depth2, 0.0, 0.0);
}