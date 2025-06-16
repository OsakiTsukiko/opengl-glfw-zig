const std = @import("std");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

const vertex_shader_source = @embedFile("./vert.glsl");
const fragment_shader_source = @embedFile("./frag.glsl");

const t_vertices = @import("./teapot.zig").t_vertices;

const vertices = &[_]f32{
    0.5, 0.5, 0.0, // top right
    0.5, -0.5, 0.0, // bottom right
    -0.5, -0.5, 0.0, // bottom left
    -0.5, 0.5, 0.0, // top left
};

const indices = &[_]c_uint{
    0, 1, 3,
    1, 2, 3,
};

pub fn main() !void {
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

    const vertex_shader: c_uint = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vertex_shader, 1, @ptrCast(&vertex_shader_source), 0);
    gl.compileShader(vertex_shader);
    var vs_comp_success: c_int = undefined;
    var vs_comp_log: [512]u8 = undefined;
    gl.getShaderiv(vertex_shader, gl.COMPILE_STATUS, &vs_comp_success);
    if (vs_comp_success != 1) {
        gl.getShaderInfoLog(vertex_shader, 512, null, &vs_comp_log);
        std.debug.print("VERTEX SHADER COMPLATION ERROR: {s} ({d})\n", .{ vs_comp_log, vs_comp_log.len });
    }

    const fragment_shader: c_uint = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fragment_shader, 1, @ptrCast(&fragment_shader_source), 0);
    gl.compileShader(fragment_shader);
    var fs_comp_success: c_int = undefined;
    var fs_comp_log: [512]u8 = undefined;
    gl.getShaderiv(fragment_shader, gl.COMPILE_STATUS, &fs_comp_success);
    if (fs_comp_success != 1) {
        gl.getShaderInfoLog(fragment_shader, 512, null, &fs_comp_log);
        std.debug.print("FRAGMENT SHADER COMPILATION ERROR: {s} ({d})\n", .{ fs_comp_log, fs_comp_log.len });
    }

    const shader_program: c_uint = gl.createProgram();
    gl.attachShader(shader_program, vertex_shader);
    gl.attachShader(shader_program, fragment_shader);
    gl.linkProgram(shader_program);
    var sp_link_success: c_int = undefined;
    var sp_link_log: [512]u8 = undefined;
    gl.getProgramiv(shader_program, gl.LINK_STATUS, &sp_link_success);
    if (sp_link_success != 1) {
        gl.getProgramInfoLog(shader_program, 512, null, &sp_link_log);
        std.debug.print("SHADER PROGRAM LINKING ERROR: {s} ({d})\n", .{ sp_link_log, sp_link_log.len });
    }
    gl.deleteShader(vertex_shader);
    gl.deleteShader(fragment_shader);

    var vao: c_uint = undefined;
    gl.genVertexArrays(1, &vao);

    var vbo: c_uint = undefined;
    gl.genBuffers(1, &vbo);

    var ebo: c_uint = undefined;
    gl.genBuffers(1, &ebo);

    gl.bindVertexArray(vao);

    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, t_vertices.len * @sizeOf(f32), t_vertices, gl.STATIC_DRAW);

    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices.len * @bitSizeOf(c_uint), indices, gl.STATIC_DRAW);

    gl.bindVertexArray(0);
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);

    while (!win.shouldClose()) {
        processInput(win);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
        gl.useProgram(shader_program);
        gl.bindVertexArray(vao);
        gl.drawArrays(gl.TRIANGLES, 0, 3488 * 3);
        // gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, null);
        gl.bindVertexArray(0);
        gl.polygonMode(gl.FRONT_AND_BACK, gl.FILL);

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
