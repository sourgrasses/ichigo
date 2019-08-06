const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const Bus = @import("bus.zig").Bus;
const Cart = @import("cart.zig").Cart;
const Cpu = @import("cpu/cpu.zig").Cpu;
const Vip = @import("hw/vip.zig").Vip;
const Vsu = @import("hw/vsu.zig").Vsu;

const WRAM_SIZE = 64 * 1024;

pub const Vb = struct {
    allocator: *Allocator,

    cpu: Cpu,
    vip: Vip,
    vsu: Vsu,
    wram: []u8,

    cart: Cart,

    pub fn new(allocator: *Allocator, rom_path: []const u8) !Vb {
        var cart = try Cart.new(allocator, rom_path);

        var vip = try Vip.new(allocator);
        var vsu = Vsu.new();

        var wram = try allocator.alloc(u8, WRAM_SIZE);
        mem.set(u8, wram, 0);

        var cpu = Cpu.new(allocator, &cart, wram);

        return Vb{
            .allocator = allocator,
            .cpu = cpu,
            .vip = vip,
            .vsu = vsu,
            .wram = wram,
            .cart = cart,
        };
    }

    pub fn run(self: *Vb) void {
        std.debug.warn("{}\n", self.cart.title());
    }
};
