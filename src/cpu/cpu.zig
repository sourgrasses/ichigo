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

            .pc = Reg(0xfffffff0),

            .psw = Reg(0x00008000),
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
            const halfword = self.bus.read_halfword(self.pc) catch unreachable;
            const opcode = (halfword & 0xfc00) >> 10;

            std.debug.warn("0x{x}\t{X}\t", self.pc, halfword);
            INST_TABLE[opcode](self, halfword);
        }
    }

    fn get_sysreg_ptr(self: *Cpu, imm: u5) *Reg {
        const reg_ptr = switch (imm) {
            0 => &self.eipc,
            1 => &self.eipsw,
            2 => &self.fepc,
            3 => &self.fepsw,
            4 => &self.ecr,
            5 => &self.eipc,
            6 => &self.eipc,
            7 => &self.eipc,
            24 => &self.eipc,
            25 => &self.eipc,
            else => unreachable,
        };

        return reg_ptr;
    }

    fn status_set_cy(self: *Cpu) void {
        self.psw |= 0x00000008;
    }

    fn status_set_ov(self: *Cpu) void {
        self.psw |= 0x00000004;
    }

    fn status_set_s(self: *Cpu) void {
        self.psw |= 0x00000002;
    }

    fn status_set_z(self: *Cpu) void {
        self.psw |= 0x00000001;
    }

    fn status_clear_cy(self: *Cpu) void {
        self.psw &= 0xfffffff7;
    }

    fn status_clear_ov(self: *Cpu) void {
        self.psw &= 0xfffffffb;
    }

    fn status_clear_s(self: *Cpu) void {
        self.psw &= 0xfffffffd;
    }

    fn status_clear_z(self: *Cpu) void {
        self.psw &= 0xfffffffe;
    }
};

fn sign_extend(val: u16) u32 {
    if (@bitCast(i16, val) < 0) {
        return @intCast(u32, val) | 0xffff0000;
    } else {
        return @intCast(u32, val);
    }
}

pub fn illegal(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("Illegal opcode: 0x{x}\n", halfword);
    std.process.exit(1);
}

// move register
pub fn mov(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("mov 0x{x}\n", halfword);
    cpu.pc += 2;
}

// add register
pub fn add(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("add 0x{x}\n", halfword);
    cpu.pc += 2;
}

// subtract
pub fn sub(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sub 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn cmp(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cmp 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn shl(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sl 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn shr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shr 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn jmp(cpu: *Cpu, halfword: u16) void {
    const r1 = @intCast(usize, halfword & 0x000f);
    cpu.pc = cpu.regs[r1] & 0xfffffffe;

    std.debug.warn("jmp r{}\n", r1);
}

pub fn sar(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sar 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn mul(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("mul 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn div(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("div 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn mulu(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("mulu 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn divu(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("divu 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn orop(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("or 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn andop(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("and 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn xor(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("xor 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn not(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("not 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn movi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("movi 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn cmpi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cmpi 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn shli(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shli 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn shri(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shri 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn cli(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cli 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn sari(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sari 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn setf(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("setf 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn trap(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("trap 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn reti(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("reti 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn halt(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("halt 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn ldsr(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @intCast(u5, halfword & 0x001f);

    const reg = cpu.get_sysreg_ptr(imm);
    reg.* = cpu.regs[r2];

    std.debug.warn("ldsr 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn stsr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("stsr 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn sei(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sei 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn bit_string(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("bit_string 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn bcond(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("bcond 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn movea(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const val = sign_extend(imm);
    cpu.regs[r2] = cpu.regs[r1] +% val;

    std.debug.warn("movea {x}, r{}, r{}\n", imm, r1, r2);
    cpu.pc += 2;
}

pub fn addi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    cpu.regs[r2] = cpu.regs[r1] +% sign_extend(imm);

    // TODO: flags

    std.debug.warn("addi 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn jr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("jr 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn jal(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("jal 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn ori(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ori 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn andi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("andi 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn xori(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("xori 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn movhi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    cpu.regs[r2] = cpu.regs[r1] +% @intCast(u32, imm) << 16;

    std.debug.warn("movhi {x}, r{} r{}\n", imm, r1, r2);
    cpu.pc += 2;
}

pub fn ldb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldb 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn ldh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldh 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn ldw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldw 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn stb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("stb 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn sth(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sth 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn stw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("stw 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn inb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inb 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn inh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inh 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn caxi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("caxi 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn inw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inw 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn outb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outb 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn outh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outh 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn float(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("float 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn outw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outw 0x{x}\n", halfword);
    cpu.pc += 2;
}
