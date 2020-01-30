const std = @import("std");
const mem = std.mem;

const sdl = @import("../main.zig").sdl;

const Allocator = std.mem.Allocator;
const MemError = @import("../mem.zig").MemError;

const VRAM_SIZE = 64 * 1024;

pub const Vip = struct {
    disp_pixels: [224][384]u8,
    vram: []u8,

    pub fn new(allocator: *Allocator) !Vip {
        var vram = try allocator.alloc(u8, VRAM_SIZE);
        mem.set(u8, vram, 0);

        return Vip{
            .disp_pixels = [_][384]u8{[_]u8{0} ** 384} ** 224,
            .vram = vram,
        };
    }

    pub fn display_vram(self: *Vip, surface: *sdl.SDL_Surface) void {
        _ = sdl.SDL_FillRect(surface, null, sdl.SDL_MapRGB(surface.format, 0, 0, 0));

        for (self.vram[0x8000..0xdfff]) |byte, i| {
            if (byte != 0x00) {
                const j = @intCast(c_int, i - 23552);
                const x = j & 0x00ff;
                const y = (j & 0xff00) >> 2;

                const pixel = sdl.SDL_Rect{
                    .x = x,
                    .y = y,
                    .w = 2,
                    .h = 2,
                };
                _ = sdl.SDL_FillRect(surface, &pixel, sdl.SDL_MapRGB(surface.format, byte, 0, 0));
            }
        }
    }

    pub fn cycle(self: *Vip) void {
        const disp_ctrl = self.display_control();
        if ((disp_ctrl & 0x0200) == 0x0200) {
            self.vram[0xf820] |= 0x02;
            // set display procedure beginning
            self.vram[0xf820] |= 0x40;
        }

        return;
    }

    fn update_display_status(self: *Vip) void {
        const halfword = self.display_control();
        if ((halfword & 0x0200) == 0x0200) {
            self.vram[0xf820] |= 0x02;
        }
    }

    fn frame_buffer_to_pixels(self: *Vip) void {
        for (self.vram[0x00000000..0x00005fff]) |pixel, i| {}
    }

    fn interrupt_pending(self: *Vip) u16 {
        return self.vram[0xf800];
    }

    fn interrupt_enable(self: *Vip) u16 {
        return self.vram[0xf802];
    }

    fn interrupt_clear(self: *Vip) u16 {
        return self.vram[0xf804];
    }

    fn display_status(self: *Vip) u16 {
        const b = self.vram[0xf820];
        const a = self.vram[0xf821];

        return (@intCast(u16, a) << 8) | b;
    }

    fn display_control(self: *Vip) u16 {
        const b = self.vram[0xf822];
        const a = self.vram[0xf823];

        return (@intCast(u16, a) << 8) | b;
    }

    fn led_brightness1(self: *Vip) u16 {
        return self.vram[0xf824];
    }

    fn led_brightness2(self: *Vip) u16 {
        return self.vram[0xf826];
    }

    fn led_brightness3(self: *Vip) u16 {
        return self.vram[0xf828];
    }

    fn led_brightness_idle(self: *Vip) u16 {
        return self.vram[0xf82a];
    }

    fn frame_repeat(self: *Vip) u16 {
        return self.vram[0xf82e];
    }

    fn column_table_address(self: *Vip) u16 {
        return self.vram[0xf830];
    }

    fn drawing_status(self: *Vip) u16 {
        return self.vram[0xf840];
    }

    fn drawing_control(self: *Vip) u16 {
        return self.vram[0xf842];
    }

    fn version(self: *Vip) u16 {
        return self.vram[0xf844];
    }

    fn obj_group0_pointer(self: *Vip) u16 {
        return self.vram[0xf848];
    }

    fn obj_group1_pointer(self: *Vip) u16 {
        return self.vram[0xf84a];
    }

    fn obj_group2_pointer(self: *Vip) u16 {
        return self.vram[0xf84c];
    }

    fn obj_group3_pointer(self: *Vip) u16 {
        return self.vram[0xf84e];
    }

    fn bg_palette0(self: *Vip) u16 {
        return self.vram[0xf860];
    }

    fn bg_palette1(self: *Vip) u16 {
        return self.vram[0xf862];
    }

    fn bg_palette2(self: *Vip) u16 {
        return self.vram[0xf864];
    }

    fn bg_palette3(self: *Vip) u16 {
        return self.vram[0xf866];
    }

    fn obj_palette0(self: *Vip) u16 {
        return self.vram[0xf868];
    }

    fn obj_palette1(self: *Vip) u16 {
        return self.vram[0xf86a];
    }

    fn obj_palette2(self: *Vip) u16 {
        return self.vram[0xf86c];
    }

    fn obj_palette3(self: *Vip) u16 {
        return self.vram[0xf86e];
    }

    fn clear_color(self: *Vip) u16 {
        return self.vram[0xf870];
    }
};
