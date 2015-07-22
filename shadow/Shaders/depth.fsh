#extension GL_OES_standard_derivatives : require
void main()
{
    highp float depth = gl_FragCoord.z;
    highp float depth2 = depth * depth;
    
    highp float dx = dFdx(depth);
    highp float dy = dFdy(depth);
    depth2 += 0.25 * (dx * dx + dy * dy);
    
    gl_FragColor = vec4(depth, depth2, 0.0, 1.0);
}