const std = @import("std");

const Allocator = std.mem.Allocator;
const Bus = @import("../bus.zig").Bus;
const Cart = @import("../cart.zig").Cart;
const INST_TABLE = @import("ops.zig").INST_TABLE;
const Reg = @import("regs.zig").Reg;
const Vip = @import("../hw/vip.zig").Vip;
const Vsu = @import("../hw/vsu.zig").Vsu;

pub const Cpu = struct {
    bus: Bus,

    regs: [32]Reg,

    pc: Reg,

    psw: Reg, // program status word
    eipc: Reg, // exception/interrupt pc
    eipsw: Reg, // exception/interrup psw
    fepc: Reg, // fatal duplexed exception pc
    fepsw: Reg, // duplexed exception psw
    ecr: Reg, // exception cause register
    adtre: Reg, // address trap register for execution
    chcw: Reg, // cache control word
    tkcw: Reg, // task control word
    pir: Reg, // Processor ID Register

    pub fn new(allocator: *Allocator, cart: *Cart) Cpu {
        var bus = Bus.new(allocator);

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

    pub fn boot(self: *Cpu, vip: *Vip, vsu: *Vsu, wram: []u8, cart: *Cart) void {
        self.bus.init(vip, vsu, wram, cart);
    }

    pub fn run(self: *Cpu) void {
        while (true) {
            const word = self.bus.read_halfword(self.pc) catch unreachable;
            const opcode = (word & 0xfc00) >> 10;

            std.debug.warn("0x{x}\t{x}\t", self.pc, word);
            INST_TABLE[opcode](self, word);
        }
    }
};

pub fn illegal(cpu: *Cpu, word: u32) void {
    std.debug.warn("Illegal opcode: 0x{x}\n", word);
    std.process.exit(1);
}

// move register
pub fn mov(cpu: *Cpu, word: u32) void {
    std.debug.warn("mov 0x{x}\n", word);
    cpu.pc += 2;
}

// add register
pub fn add(cpu: *Cpu, word: u32) void {
    std.debug.warn("add 0x{x}\n", word);
    cpu.pc += 2;
}

// subtract
pub fn sub(cpu: *Cpu, word: u32) void {
    std.debug.warn("sub 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn cmp(cpu: *Cpu, word: u32) void {
    std.debug.warn("cmp 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn shl(cpu: *Cpu, word: u32) void {
    std.debug.warn("sl 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn shr(cpu: *Cpu, word: u32) void {
    std.debug.warn("shr 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn jmp(cpu: *Cpu, word: u32) void {
    std.debug.warn("jmp 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn sar(cpu: *Cpu, word: u32) void {
    std.debug.warn("sar 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn mul(cpu: *Cpu, word: u32) void {
    std.debug.warn("mul 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn div(cpu: *Cpu, word: u32) void {
    std.debug.warn("div 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn mulu(cpu: *Cpu, word: u32) void {
    std.debug.warn("mulu 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn divu(cpu: *Cpu, word: u32) void {
    std.debug.warn("divu 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn orop(cpu: *Cpu, word: u32) void {
    std.debug.warn("or 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn andop(cpu: *Cpu, word: u32) void {
    std.debug.warn("and 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn xor(cpu: *Cpu, word: u32) void {
    std.debug.warn("xor 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn not(cpu: *Cpu, word: u32) void {
    std.debug.warn("not 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn movi(cpu: *Cpu, word: u32) void {
    std.debug.warn("movi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn cmpi(cpu: *Cpu, word: u32) void {
    std.debug.warn("cmpi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn shli(cpu: *Cpu, word: u32) void {
    std.debug.warn("shli 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn shri(cpu: *Cpu, word: u32) void {
    std.debug.warn("shri 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn cli(cpu: *Cpu, word: u32) void {
    std.debug.warn("cli 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn sari(cpu: *Cpu, word: u32) void {
    std.debug.warn("sari 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn setf(cpu: *Cpu, word: u32) void {
    std.debug.warn("setf 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn trap(cpu: *Cpu, word: u32) void {
    std.debug.warn("trap 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn reti(cpu: *Cpu, word: u32) void {
    std.debug.warn("reti 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn halt(cpu: *Cpu, word: u32) void {
    std.debug.warn("halt 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn ldsr(cpu: *Cpu, word: u32) void {
    std.debug.warn("ldr 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn stsr(cpu: *Cpu, word: u32) void {
    std.debug.warn("stsr 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn sei(cpu: *Cpu, word: u32) void {
    std.debug.warn("sei 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn bit_string(cpu: *Cpu, word: u32) void {
    std.debug.warn("bit_string 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn bcond(cpu: *Cpu, word: u32) void {
    std.debug.warn("bcond 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn movea(cpu: *Cpu, word: u32) void {
    std.debug.warn("movea 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn addi(cpu: *Cpu, word: u32) void {
    std.debug.warn("addi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn jr(cpu: *Cpu, word: u32) void {
    std.debug.warn("jr 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn jal(cpu: *Cpu, word: u32) void {
    std.debug.warn("jal 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn ori(cpu: *Cpu, word: u32) void {
    std.debug.warn("ori 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn andi(cpu: *Cpu, word: u32) void {
    std.debug.warn("andi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn xori(cpu: *Cpu, word: u32) void {
    std.debug.warn("xori 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn movhi(cpu: *Cpu, word: u32) void {
    std.debug.warn("movhi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn ldb(cpu: *Cpu, word: u32) void {
    std.debug.warn("ldb 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn ldh(cpu: *Cpu, word: u32) void {
    std.debug.warn("ldh 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn ldw(cpu: *Cpu, word: u32) void {
    std.debug.warn("ldw 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn stb(cpu: *Cpu, word: u32) void {
    std.debug.warn("stb 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn sth(cpu: *Cpu, word: u32) void {
    std.debug.warn("sth 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn stw(cpu: *Cpu, word: u32) void {
    std.debug.warn("stw 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn inb(cpu: *Cpu, word: u32) void {
    std.debug.warn("inb 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn inh(cpu: *Cpu, word: u32) void {
    std.debug.warn("inh 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn caxi(cpu: *Cpu, word: u32) void {
    std.debug.warn("caxi 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn inw(cpu: *Cpu, word: u32) void {
    std.debug.warn("inw 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn outb(cpu: *Cpu, word: u32) void {
    std.debug.warn("outb 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn outh(cpu: *Cpu, word: u32) void {
    std.debug.warn("outh 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn float(cpu: *Cpu, word: u32) void {
    std.debug.warn("float 0x{x}\n", word);
    cpu.pc += 2;
}

pub fn outw(cpu: *Cpu, word: u32) void {
    std.debug.warn("outw 0x{x}\n", word);
    cpu.pc += 2;
}
