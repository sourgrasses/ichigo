const std = @import("std");
const mem = std.mem;

const sdl = @import("main.zig").sdl;

const Allocator = std.mem.Allocator;

const Bus = @import("bus.zig").Bus;
const Cart = @import("cart.zig").Cart;
const Cpu = @import("cpu/cpu.zig").Cpu;
const Vip = @import("hw/vip.zig").Vip;
const Vsu = @import("hw/vsu.zig").Vsu;

const WRAM_SIZE = comptime 64 * 1024;

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
        var vsu = try Vsu.new(allocator);

        var wram = try allocator.alloc(u8, WRAM_SIZE);
        mem.set(u8, wram, 0);

        const debug_mode = true;
        var cpu = Cpu.new(allocator, &cart, debug_mode);

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
        self.cpu.boot(self.wram[0..], &self.cart, &self.vip, &self.vsu);

        var window: ?*sdl.SDL_Window = null;
        var surface: ?*sdl.SDL_Surface = null;
        const disp_width = 768;
        const disp_height = 448;

        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
            std.debug.warn("Error initializing SDL: {}", sdl.SDL_GetError());
            std.process.exit(1);
        } else {
            window = sdl.SDL_CreateWindow(c"ichigo", 200, 200, disp_width, disp_height, sdl.SDL_WINDOW_SHOWN);

            if (window == null) {
                std.debug.warn("Error creating SDL window: {}", sdl.SDL_GetError());
                std.process.exit(1);
            } else {
                surface = sdl.SDL_GetWindowSurface(window);
            }
        }

        _ = sdl.SDL_FillRect(surface, null, sdl.SDL_MapRGB(surface.?.format, 0, 0, 0));

        var i: u16 = 0;
        while (true) {
            // if we're using the debugger, check to see if we should quit and then clean up
            if (self.cpu.debug_state) |debug_state| {
                if (debug_state.quit) {
                    sdl.SDL_DestroyWindow(window);
                    sdl.SDL_Quit();
                    std.process.exit(0);
                }

                if (i == 499) {
                    if (self.vip.vram[0xf820] & 0x40 == 0x40) {
                        self.vip.display_vram(surface.?);
                        _ = sdl.SDL_UpdateWindowSurface(window);
                    }

                    i = 0;
                } else {
                    i += 1;
                }
            }

            self.cpu.cycle();
            self.vip.cycle();
            //_ = sdl.SDL_FillRect(surface.?, null, sdl.SDL_MapRGB(surface.?.format, 0, 0, 0));
        }
    }
};
