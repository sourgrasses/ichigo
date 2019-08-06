const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const MemError = @import("../mem.zig").MemError;

const VRAM_SIZE = 64 * 1024;

pub const Reg = u16;

pub const Vip = struct {
    vram: []u8,

    interrupt_pending: Reg,
    interrupt_enable: Reg,
    interrupt_clear: Reg,
    display_status: Reg,
    display_control: Reg,
    led_brightness1: Reg,
    led_brightness2: Reg,
    led_brightness3: Reg,
    led_brightness_idle: Reg,
    frame_repeat: Reg,
    column_table_address: Reg,
    drawing_status: Reg,
    drawing_control: Reg,
    version: Reg,
    obj_group0_pointer: Reg,
    obj_group1_pointer: Reg,
    obj_group2_pointer: Reg,
    obj_group3_pointer: Reg,
    bg_palette0: Reg,
    bg_palette1: Reg,
    bg_palette2: Reg,
    bg_palette3: Reg,
    obj_palette0: Reg,
    obj_palette1: Reg,
    obj_palette2: Reg,
    obj_palette3: Reg,
    clear_color: Reg,

    pub fn new(allocator: *Allocator) !Vip {
        var vram = try allocator.alloc(u8, VRAM_SIZE);
        mem.set(u8, vram, 0);

        return Vip{
            .vram = vram,

            .interrupt_pending = 0,
            .interrupt_enable = 0,
            .interrupt_clear = 0,
            .display_status = 0,
            .display_control = 0,
            .led_brightness1 = 0,
            .led_brightness2 = 0,
            .led_brightness3 = 0,
            .led_brightness_idle = 0,
            .frame_repeat = 0,
            .column_table_address = 0,
            .drawing_status = 0,
            .drawing_control = 0,
            .version = 0,
            .obj_group0_pointer = 0,
            .obj_group1_pointer = 0,
            .obj_group2_pointer = 0,
            .obj_group3_pointer = 0,
            .bg_palette0 = 0,
            .bg_palette1 = 0,
            .bg_palette2 = 0,
            .bg_palette3 = 0,
            .obj_palette0 = 0,
            .obj_palette1 = 0,
            .obj_palette2 = 0,
            .obj_palette3 = 0,
            .clear_color = 0,
        };
    }

    pub fn read_halfword(self: *Vip, offset: usize) !u16 {
        return switch (offset) {
            0x0005f800 => self.interrupt_pending,
            0x0005f802 => self.interrupt_enable,
            0x0005f804 => self.interrupt_clear,
            0x0005f820 => self.display_status,
            0x0005f822 => self.display_control,
            0x0005f824 => self.led_brightness1,
            0x0005f826 => self.led_brightness2,
            0x0005f828 => self.led_brightness3,
            0x0005f82a => self.led_brightness_idle,
            0x0005f82e => self.frame_repeat,
            0x0005f830 => self.column_table_address,
            0x0005f840 => self.drawing_status,
            0x0005f842 => self.drawing_control,
            0x0005f844 => self.version,
            0x0005f848 => self.obj_group0_pointer,
            0x0005f84a => self.obj_group1_pointer,
            0x0005f84c => self.obj_group2_pointer,
            0x0005f84e => self.obj_group3_pointer,
            0x0005f860 => self.bg_palette0,
            0x0005f862 => self.bg_palette1,
            0x0005f864 => self.bg_palette2,
            0x0005f866 => self.bg_palette3,
            0x0005f868 => self.obj_palette0,
            0x0005f86a => self.obj_palette1,
            0x0005f86c => self.obj_palette2,
            0x0005f86e => self.obj_palette3,
            0x0005f870 => self.clear_color,
            else => MemError.RegionNotFound,
        };
    }
};
