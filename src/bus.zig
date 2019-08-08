const std = @import("std");
const mem = std.mem;

const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

const Cart = @import("cart.zig").Cart;
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

    pub fn new(allocator: *Allocator) Bus {
        var regions = ArrayList(MemRegion).init(allocator);
        defer regions.deinit();

        return Bus{
            .regions = regions,
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

    fn map_io(self: *Bus, dsio: *ds.Io) void {}

    pub fn get_slice(self: *Bus, offset: usize) ![]u8 {
        const moffset = offset & MIRROR_MASK;

        for (self.regions.toSlice()) |region| {
            if (moffset >= region.lower_bound and moffset < region.upper_bound) {
                return region.slice;
            }
        }

        return MemError.RegionNotFound;
    }

    fn read_word(self: *Bus, offset: usize) !u32 {
        const s = try self.get_slice(offset);
        // use a mask to get the relative offset within the memory region
        const mask = s.len - 1;
        const moffset = offset & mask;
        return std.mem.readIntSliceLittle(u32, s[moffset .. moffset + 4]);
    }

    fn read_halfword(self: *Bus, offset: usize) !u16 {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        const moffset = offset & mask;
        return std.mem.readIntSliceLittle(u16, s[moffset .. moffset + 2]);
    }

    fn read_byte(self: *Bus, offset: usize) !u8 {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        const moffset = offset & mask;
        return s[moffset];
    }

    fn write_word(self: *Bus, offset: usize, val: u32) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        const moffset = offset & mask;
        std.mem.writeIntLittle(u32, s[moffset .. moffset + 4], val);
    }

    fn write_halfword(self: *Bus, offset: usize, val: u16) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        const moffset = offset & mask;
        mem.writeIntLittle(u32, s[moffset .. moffset + 2], val);
    }

    fn write_byte(self: *Bus, offset: usize, val: u8) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        const moffset = offset & mask;
        s[moffset] = val;
    }
};
