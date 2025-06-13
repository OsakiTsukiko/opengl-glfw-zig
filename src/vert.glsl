#version 330 core
layout(location = 0) in vec3 aPos;

out vec3 vColor;

void main()
{
    gl_Position = vec4(aPos / 3.0 / 1.2, 1.0);
    gl_Position.y -= 0.5;
    vColor = (aPos + 1.0) / 2.0;
}
