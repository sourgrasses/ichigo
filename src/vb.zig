const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const Bus = @import("bus.zig").Bus;
const Cart = @import("cart.zig").Cart;
const Cpu = @import("cpu.zig").Cpu;
const Vip = @import("vip.zig").Vip;
const Vsu = @import("vsu.zig").Vsu;

pub const Vb = struct {
    allocator: *Allocator,

    bus: Bus,
    cpu: Cpu,
    vip: Vip,
    vsu: Vsu,
    wram: []u8,

    cart: Cart,

    pub fn new(allocator: *Allocator, rom_path: []const u8) !Vb {
        var cart = try Cart.new(allocator, rom_path);

        var wram = try allocator.alloc(u8, 64 * 1024);
        mem.set(u8, wram, 0);

        var bus = Bus.new(allocator, &cart, wram);

        return Vb{
            .allocator = allocator,
            .bus = bus,
            .cpu = Cpu.new(&bus),
            .vip = Vip.new(),
            .vsu = Vsu.new(),
            .wram = wram,
            .cart = cart,
        };
    }

    pub fn run(self: *Vb) void {
        std.debug.warn("{}\n", self.cart.title());
    }
};
