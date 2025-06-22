const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

const Shader = @import("shader.zig").Shader;

// const vertex_shader_source = @embedFile("./vert.glsl");
// const fragment_shader_source = @embedFile("./frag.glsl");

const vertices = &[_]f32{
    0.5, 0.5, 0.0, 1.0, 0.0, 0.0, // top right
    0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, // bottom left
    -0.5, 0.5, 0.0, 1.0, 0.0, 1.0, // top left
};

const indices = &[_]c_uint{
    0, 1, 3,
    1, 2, 3,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try glfw.init();
    defer glfw.terminate();

    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    const win = try glfw.Window.create(500, 500, "HE HE", null);
    defer win.destroy();

    glfw.makeContextCurrent(win);
    _ = win.setFramebufferSizeCallback(framebuffer_size_callback);

    try zopengl.loadCoreProfile(glfw.getProcAddress, 3, 3);
    const gl = zopengl.bindings;

    const shader = try Shader.new("./src/vert.glsl", "./src/frag.glsl", allocator);

    var vao: c_uint = undefined;
    gl.genVertexArrays(1, &vao);

    var vbo: c_uint = undefined;
    gl.genBuffers(1, &vbo);

    var ebo: c_uint = undefined;
    gl.genBuffers(1, &ebo);

    gl.bindVertexArray(vao);

    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(f32), vertices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices.len * @bitSizeOf(c_uint), indices, gl.STATIC_DRAW);

    // position attribute
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);
    // color attribute
    gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));
    gl.enableVertexAttribArray(1);

    gl.bindVertexArray(0);
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);

    // const colorUniformLocation = gl.getUniformLocation(shader_program, "testColor");

    while (!win.shouldClose()) {
        processInput(win);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);

        const time_val = glfw.getTime();
        const green_val = std.math.sin(time_val) / 2.0 + 0.5;
        // gl.useProgram(shader_program);
        // gl.uniform3f(colorUniformLocation, 0.0, @floatCast(green_val), 0.0);
        shader.use();
        shader.setFloat3("testColor", 0.0, @floatCast(green_val), 0.0);
        gl.bindVertexArray(vao);
        // gl.drawArrays(gl.TRIANGLES, 0, 3);
        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, null);
        gl.bindVertexArray(0);

        // gl.polygonMode(gl.FRONT_AND_BACK, gl.FILL);

        glfw.pollEvents();
        win.swapBuffers();
        // gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.2, 0.6, 0.4, 1.0 });
    }
}

fn framebuffer_size_callback(window: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    _ = window;
    const gl = zopengl.bindings;
    gl.viewport(0, 0, width, height);
}

fn processInput(window: *glfw.Window) void {
    if (window.getKey(.escape) == .press) {
        window.setShouldClose(true);
    }
}
