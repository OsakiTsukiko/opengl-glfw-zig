#version 330 core
out vec4 FragColor;

in vec3 vColor;

uniform vec3 testColor;

void main()
{
    FragColor = vec4(testColor, 1.0f);
    FragColor = vec4(vColor, 1.0f);
}
