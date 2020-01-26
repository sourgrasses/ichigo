const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const MemError = @import("../mem.zig").MemError;

const c = @cImport(@cInclude("SDL2/SDL.h"));

const VRAM_SIZE = 64 * 1024;

const Display = struct {
    renderer: ?*c.SDL_Renderer,
    win: ?*c.SDL_Window,
    pixels: [224][384]u8,

    fn new() Display {
        const pixels = [_][384]u8{[_]u8{0} ** 384} ** 224;

        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            std.debug.warn("Unable to initialize SDL video\n");
            std.process.exit(1);
        }
        defer c.SDL_Quit();

        const win = c.SDL_CreateWindow(c"ichigo", 100, 100, 384, 224, c.SDL_WINDOW_SHOWN);
        const renderer = c.SDL_CreateRenderer(win, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC);

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderFillRect(renderer, null);
        _ = c.SDL_RenderPresent(renderer);

        return Display{
            .renderer = renderer,
            .win = win,
            .pixels = pixels,
        };
    }

    fn clear(self: *Display) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderFillRect(self.renderer, null);
        _ = c.SDL_RenderPresent(self.renderer);
    }

    fn render(self: *Display) void {
        _ = c.SDL_RenderPresent(self.renderer);
    }
};

pub const Vip = struct {
    display: Display,
    vram: []u8,

    pub fn new(allocator: *Allocator) !Vip {
        var vram = try allocator.alloc(u8, VRAM_SIZE);
        mem.set(u8, vram, 0);

        return Vip{
            .display = Display.new(),
            .vram = vram,
        };
    }

    pub fn clear(self: *Vip) void {
        self.display.clear();
    }

    pub fn render(self: *Vip) void {
        self.display.render();
    }

    fn interrupt_pending(self: *Vip) u16 {
        return self.vram[0x0005f800];
    }

    fn interrupt_enable(self: *Vip) u16 {
        return self.vram[0x0005f802];
    }

    fn interrupt_clear(self: *Vip) u16 {
        return self.vram[0x0005f804];
    }

    fn display_status(self: *Vip) u16 {
        return self.vram[0x0005f820];
    }

    fn display_control(self: *Vip) u16 {
        return self.vram[0x0005f822];
    }

    fn led_brightness1(self: *Vip) u16 {
        return self.vram[0x0005f824];
    }

    fn led_brightness2(self: *Vip) u16 {
        return self.vram[0x0005f826];
    }

    fn led_brightness3(self: *Vip) u16 {
        return self.vram[0x0005f828];
    }

    fn led_brightness_idle(self: *Vip) u16 {
        return self.vram[0x0005f82a];
    }

    fn frame_repeat(self: *Vip) u16 {
        return self.vram[0x0005f82e];
    }

    fn column_table_address(self: *Vip) u16 {
        return self.vram[0x0005f830];
    }

    fn drawing_status(self: *Vip) u16 {
        return self.vram[0x0005f840];
    }

    fn drawing_control(self: *Vip) u16 {
        return self.vram[0x0005f842];
    }

    fn version(self: *Vip) u16 {
        return self.vram[0x0005f844];
    }

    fn obj_group0_pointer(self: *Vip) u16 {
        return self.vram[0x0005f848];
    }

    fn obj_group1_pointer(self: *Vip) u16 {
        return self.vram[0x0005f84a];
    }

    fn obj_group2_pointer(self: *Vip) u16 {
        return self.vram[0x0005f84c];
    }

    fn obj_group3_pointer(self: *Vip) u16 {
        return self.vram[0x0005f84e];
    }

    fn bg_palette0(self: *Vip) u16 {
        return self.vram[0x0005f860];
    }

    fn bg_palette1(self: *Vip) u16 {
        return self.vram[0x0005f862];
    }

    fn bg_palette2(self: *Vip) u16 {
        return self.vram[0x0005f864];
    }

    fn bg_palette3(self: *Vip) u16 {
        return self.vram[0x0005f866];
    }

    fn obj_palette0(self: *Vip) u16 {
        return self.vram[0x0005f868];
    }

    fn obj_palette1(self: *Vip) u16 {
        return self.vram[0x0005f86a];
    }

    fn obj_palette2(self: *Vip) u16 {
        return self.vram[0x0005f86c];
    }

    fn obj_palette3(self: *Vip) u16 {
        return self.vram[0x0005f86e];
    }

    fn clear_color(self: *Vip) u16 {
        return self.vram[0x0005f870];
    }
};
