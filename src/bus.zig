const std = @import("std");
const hw = @import("hw/hw.zig");
const mem = std.mem;

const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

const Cart = @import("cart.zig").Cart;
const Reg = @import("cpu/regs.zig").Reg;
const Vip = @import("hw/vip.zig").Vip;
const Vsu = @import("hw/vsu.zig").Vsu;

const MIRROR_MASK = 0x07ffffff;

pub const MemError = error{
    Bounds,
    RegionNotFound,
};

pub const MemRegion = struct {
    lower_bound: u32,
    upper_bound: u32,
    slice: []u8,

    fn new(lower_bound: u32, upper_bound: u32, slice: []u8) MemRegion {
        return MemRegion{
            .lower_bound = lower_bound,
            .upper_bound = upper_bound,
            .slice = slice,
        };
    }
};

pub const Bus = struct {
    // let's do this as a list we have to traverse for every memory read for
    // now to get things working, but we'll almost definitely need to replace
    // this with a more sped-efficient data structure once we're trying
    // to run things ~at speed~
    regions: ArrayList(MemRegion),
    com: hw.Com,
    game_pad: hw.GamePad,
    timer: hw.Timer,

    pub fn new(allocator: *Allocator) Bus {
        var regions = ArrayList(MemRegion).init(allocator);
        defer regions.deinit();

        return Bus{
            .regions = regions,
            .com = hw.Com.new(),
            .game_pad = hw.GamePad.new(),
            .timer = hw.Timer.new(),
        };
    }

    pub fn init(self: *Bus, vip: *Vip, vsu: *Vsu, wram: []u8, cart: *Cart) void {
        // a lot of this isn't *quite* correct atm, because we're not routing to
        // registers and dealing with io shit, but let's get things up and
        // running before fiddling with all that
        self.map_region(0x00000000, 0x00ffffff, vip.vram) catch unreachable;
        self.map_region(0x01000000, 0x01ffffff, vsu.dummy_ram) catch unreachable;
        self.map_region(0x04000000, 0x05ffffff, cart.exp_ram) catch unreachable;
        self.map_region(0x05000000, 0x05ffffff, wram) catch unreachable;
        self.map_region(0x06000000, 0x06ffffff, cart.sram) catch unreachable;
        self.map_region(0x07000000, 0x07ffffff, cart.rom) catch unreachable;
    }

    fn map_region(self: *Bus, lower_bound: u32, upper_bound: u32, mem_region: []u8) !void {
        const region = MemRegion.new(lower_bound, upper_bound, mem_region);
        try self.regions.append(region);
    }

    fn get_slice(self: *Bus, offset: usize) ![]u8 {
        const moffset = offset & MIRROR_MASK;

        for (self.regions.toSlice()) |region| {
            if (moffset >= region.lower_bound and moffset < region.upper_bound) {
                return region.slice;
            }
        }

        return MemError.RegionNotFound;
    }

    fn get_hw_ctrl_reg(self: *Bus, offset: usize) !*Reg {
        return switch (offset) {
            0x02000000 => &self.com.link_control,
            0x02000004 => &self.com.auxiliary_link,
            0x02000008 => &self.com.link_transmit,
            0x0200000C => &self.com.link_receive,
            0x02000010 => &self.game_pad.input_high,
            0x02000014 => &self.game_pad.input_low,
            0x02000018 => &self.timer.tcr,
            0x0200001C => &self.timer.tcr_reload_low,
            0x02000020 => &self.timer.tcr_reload_high,
            0x02000024 => &self.timer.wcr,
            0x02000028 => &self.game_pad.input_control,
            else => MemError.RegionNotFound,
        };
    }

    fn read_word(self: *Bus, offset: usize) !u32 {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const res = try self.get_hw_ctrl_reg(offset);
            return res.*;
        } else {
            const s = try self.get_slice(offset);
            // use a mask to get the relative offset within the memory region
            const mask = s.len - 1;
            const moffset = offset & mask;
            return std.mem.readIntSliceLittle(u32, s[moffset .. moffset + 4]);
        }
    }

    fn read_halfword(self: *Bus, offset: usize) !u16 {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const reg = try self.get_hw_ctrl_reg(offset);
            return @intCast(u16, reg.* & 0x00ff);
        } else {
            const s = try self.get_slice(offset);
            const mask = s.len - 1;
            const moffset = offset & mask;
            return std.mem.readIntSliceLittle(u16, s[moffset .. moffset + 2]);
        }
    }

    fn read_byte(self: *Bus, offset: usize) !u8 {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const reg = try self.get_hw_ctrl_reg(offset);
            return @intCast(u8, reg.* & 0x000f);
        } else {
            const s = try self.get_slice(offset);
            const mask = s.len - 1;
            const moffset = offset & mask;
            return s[moffset];
        }
    }

    fn write_word(self: *Bus, offset: usize, val: u32) !void {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const reg = try self.get_hw_ctrl_reg(offset);
            reg.* = val;
        } else {
            const s = try self.get_slice(offset);
            const mask = s.len - 1;
            const moffset = offset & mask;

            var word = [4]u8{ s[moffset], s[moffset + 1], s[moffset + 2], s[moffset + 3] };
            mem.writeIntLittle(u32, &word, val);
        }
    }

    fn write_halfword(self: *Bus, offset: usize, val: u16) !void {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const reg = try self.get_hw_ctrl_reg(offset);
            reg.* = @intCast(u32, val);
        } else {
            const s = try self.get_slice(offset);
            const mask = s.len - 1;
            const moffset = offset & mask;

            var halfword = [2]u8{ s[moffset], s[moffset + 1] };
            mem.writeIntLittle(u16, &halfword, val);
        }
    }

    fn write_byte(self: *Bus, offset: usize, val: u8) !void {
        if (offset >= 0x02000000 and offset <= 0x02ffffff) {
            const reg = try self.get_hw_ctrl_reg(offset);
            reg.* = @intCast(u32, val);
        } else {
            const s = try self.get_slice(offset);
            const mask = s.len - 1;
            const moffset = offset & mask;
            s[moffset] = val;
        }
    }
};
