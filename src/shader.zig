const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const Shader = struct {
    id: c_uint,
    allocator: std.mem.Allocator,

    pub fn new(vertex_path: []const u8, fragment_path: []const u8, allocator: std.mem.Allocator) !Shader {
        const vertex_file = try std.fs.cwd().openFile(vertex_path, .{});
        defer vertex_file.close();
        const fragment_file = try std.fs.cwd().openFile(fragment_path, .{});
        defer fragment_file.close();

        const vertex_shader_source = try vertex_file.readToEndAlloc(allocator, 1024 * 1024 * 1024);
        defer allocator.free(vertex_shader_source);
        const fragment_shader_source = try fragment_file.readToEndAlloc(allocator, 1024 * 1024 * 1024);
        defer allocator.free(fragment_shader_source);

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

        return Shader{
            .id = shader_program,
            .allocator = allocator,
        };
    }

    pub fn use(self: *const Shader) void {
        gl.useProgram(self.id);
    }

    pub fn setInt(self: *const Shader, name: [*:0]const u8, value: c_int) void {
        gl.uniform1i(gl.getUniformLocation(self.id, name), value);
    }

    pub fn setFloat(self: *const Shader, name: [*:0]const u8, value: f32) void {
        gl.uniform1f(gl.getUniformLocation(self.id, name), value);
    }

    pub fn setFloat3(self: *const Shader, name: [*:0]const u8, x: f32, y: f32, z: f32) void {
        gl.uniform3f(gl.getUniformLocation(self.id, name), x, y, z);
    }

    pub fn setBool(self: *const Shader, name: [*:0]const u8, value: bool) void {
        if (value) self.setInt(name, 1) else self.setInt(name, 0);
    }
};
