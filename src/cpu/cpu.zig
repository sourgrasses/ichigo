const std = @import("std");

const Allocator = std.mem.Allocator;
const Bus = @import("../bus.zig").Bus;
const Cart = @import("../cart.zig").Cart;
const Reg = @import("regs.zig").Reg;

pub const Cpu = struct {
    bus: Bus,

    regs: [32]Reg,

    pc: Reg,

    psw: Reg,
    eipc: Reg,
    eipsw: Reg,
    fepc: Reg,
    fepsw: Reg,
    ecr: Reg,
    adtre: Reg,
    chcw: Reg,
    tkcw: Reg,
    pir: Reg,

    pub fn new(allocator: *Allocator, cart: *Cart, wram: []u8) Cpu {
        var bus = Bus.new(allocator, cart, wram);

        return Cpu{
            .bus = bus,

            .regs = [32]Reg{
                Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0),
                Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0),
                Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0),
                Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0), Reg(0),
            },

            .pc = Reg(0xFFFFFFF0),

            .psw = Reg(0),
            .eipc = Reg(0),
            .eipsw = Reg(0),
            .fepc = Reg(0),
            .fepsw = Reg(0),
            .ecr = Reg(0x0000fff0),
            .adtre = Reg(0),
            .chcw = Reg(0),
            .tkcw = Reg(0),
            .pir = Reg(0),
        };
    }
};

fn illegal(cpu: *Cpu, word: u32) void {
    std.debug.warn("Illegal opcode: 0x{x}\n", word);
}

fn mov(cpu: *Cpu, word: u32) void {}

fn add(cpu: *Cpu, word: u32) void {}

fn sub(cpu: *Cpu, word: u32) void {}

fn cmp(cpu: *Cpu, word: u32) void {}

fn shl(cpu: *Cpu, word: u32) void {}

fn shr(cpu: *Cpu, word: u32) void {}

fn jmp(cpu: *Cpu, word: u32) void {}

fn sar(cpu: *Cpu, word: u32) void {}

fn mul(cpu: *Cpu, word: u32) void {}

fn div(cpu: *Cpu, word: u32) void {}

fn mulu(cpu: *Cpu, word: u32) void {}

fn divu(cpu: *Cpu, word: u32) void {}

fn orop(cpu: *Cpu, word: u32) void {}

fn andop(cpu: *Cpu, word: u32) void {}

fn xor(cpu: *Cpu, word: u32) void {}

fn not(cpu: *Cpu, word: u32) void {}

fn setf(cpu: *Cpu, word: u32) void {}

fn cli(cpu: *Cpu, word: u32) void {}

fn trap(cpu: *Cpu, word: u32) void {}

fn reti(cpu: *Cpu, word: u32) void {}

fn halt(cpu: *Cpu, word: u32) void {}

fn ldsr(cpu: *Cpu, word: u32) void {}

fn stsr(cpu: *Cpu, word: u32) void {}

fn sei(cpu: *Cpu, word: u32) void {}

fn bit_string(cpu: *Cpu, word: u32) void {}

fn bcond(cpu: *Cpu, word: u32) void {}

fn movea(cpu: *Cpu, word: u32) void {}

fn addi(cpu: *Cpu, word: u32) void {}

fn jr(cpu: *Cpu, word: u32) void {}

fn jal(cpu: *Cpu, word: u32) void {}

fn ori(cpu: *Cpu, word: u32) void {}

fn andi(cpu: *Cpu, word: u32) void {}

fn xori(cpu: *Cpu, word: u32) void {}

fn movhi(cpu: *Cpu, word: u32) void {}

fn ldb(cpu: *Cpu, word: u32) void {}

fn ldh(cpu: *Cpu, word: u32) void {}

fn ldw(cpu: *Cpu, word: u32) void {}

fn stb(cpu: *Cpu, word: u32) void {}

fn sth(cpu: *Cpu, word: u32) void {}

fn stw(cpu: *Cpu, word: u32) void {}

fn inb(cpu: *Cpu, word: u32) void {}

fn inh(cpu: *Cpu, word: u32) void {}

fn caxi(cpu: *Cpu, word: u32) void {}

fn inw(cpu: *Cpu, word: u32) void {}

fn outb(cpu: *Cpu, word: u32) void {}

fn outh(cpu: *Cpu, word: u32) void {}

fn float(cpu: *Cpu, word: u32) void {}

fn outw(cpu: *Cpu, word: u32) void {}
