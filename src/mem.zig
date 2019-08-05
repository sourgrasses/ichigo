const std = @import("std");

pub const MemError = error{
    Bounds,
    RegionNotFound,
};

pub fn read_word(mem: []u8, offset: usize) u32 {
    const aligned = offset & 0xfffffffc;
    return std.mem.readIntSliceLittle(u32, mem[aligned .. aligned + 4]);
}

pub fn read_halfword(mem: []u8, offset: usize) u16 {
    const aligned = offset & 0xfffffffc;
    return std.mem.readIntSliceLittle(u16, mem[aligned .. aligned + 2]);
}

pub fn read_byte(mem: []u8, offset: usize) u8 {
    const aligned = offset & 0xfffffffc;
    return mem[aligned];
}

pub fn write_word(mem: []u8, offset: usize, val: u32) void {
    const aligned = offset & 0xfffffffc;
    std.mem.writeIntLittle(u32, mem[aligned .. aligned + 4], val);
}

pub fn write_halfword(mem: []u8, offset: usize, val: u16) void {
    const aligned = offset & 0xfffffffc;
    std.mem.writeIntLittle(u32, mem[aligned .. aligned + 2], val);
}

pub fn write_byte(mem: []u8, offset: usize, val: u8) void {
    const aligned = offset & 0xfffffffc;
    mem[aligned] = val;
}
