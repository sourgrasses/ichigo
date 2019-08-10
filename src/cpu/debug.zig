const std = @import("std");

const Cpu = @import("cpu.zig").Cpu;
const Reg = @import("regs.zig").Reg;

pub fn illegal(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("Illegal opcode: 0x{x}\n", halfword);
}

// move register
pub fn mov(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);

    std.debug.warn("mov r{}, r{}\n", r1, r2);
}

// add register
pub fn add(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("add 0x{x}\n", halfword);
}

// subtract
pub fn sub(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sub 0x{x}\n", halfword);
}

pub fn cmp(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cmp 0x{x}\n", halfword);
}

pub fn shl(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sl 0x{x}\n", halfword);
}

pub fn shr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shr 0x{x}\n", halfword);
}

pub fn jmp(cpu: *Cpu, halfword: u16) void {
    const r1 = @intCast(usize, halfword & 0x000f);
    std.debug.warn("jmp [r{}]\n", r1);
}

pub fn sar(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sar 0x{x}\n", halfword);
}

pub fn mul(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("mul 0x{x}\n", halfword);
}

pub fn div(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("div 0x{x}\n", halfword);
}

pub fn mulu(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("mulu 0x{x}\n", halfword);
}

pub fn divu(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("divu 0x{x}\n", halfword);
}

pub fn orop(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("or 0x{x}\n", halfword);
}

pub fn andop(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("and 0x{x}\n", halfword);
}

pub fn xor(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("xor 0x{x}\n", halfword);
}

pub fn not(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("not 0x{x}\n", halfword);
}

pub fn mov2(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @bitCast(i5, @intCast(u5, halfword & 0x001f));

    std.debug.warn("mov {}, r{}\n", imm, r2);
}

pub fn add2(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @bitCast(i5, @intCast(u5, halfword & 0x001f));

    std.debug.warn("add {}, r{}\n", imm, r2);
}

pub fn cmp2(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cmp2 0x{x}\n", halfword);
}

pub fn shl2(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shl2 0x{x}\n", halfword);
}

pub fn shr2(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("shr2 0x{x}\n", halfword);
}

// Nintendo-specific
pub fn cli(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("cli 0x{x}\n", halfword);
}

pub fn sar2(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sar2 0x{x}\n", halfword);
}

pub fn setf(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("setf 0x{x}\n", halfword);
}

pub fn trap(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("trap 0x{x}\n", halfword);
}

pub fn reti(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("reti 0x{x}\n", halfword);
}

pub fn halt(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("halt 0x{x}\n", halfword);
}

pub fn ldsr(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @intCast(u5, halfword & 0x001f);

    std.debug.warn("ldsr r{}, {}\n", r2, imm);
}

pub fn stsr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("stsr 0x{x}\n", halfword);
}

// Nintendo-specific
pub fn sei(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("sei\n");
}

pub fn bit_string(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("bit_string 0x{x}\n", halfword);
    cpu.pc += 2;
}

pub fn bcond(cpu: *Cpu, halfword: u16) void {
    const cond = @intCast(u4, (halfword & 0x1e00) >> 9);
    const disp = halfword & 0x01ff;

    switch (cond) {
        0x0 => {
            std.debug.warn("bv 0x{x}\n", disp);
        },
        0x1 => {
            std.debug.warn("bl 0x{x}\n", disp);
        },
        0x2 => {
            std.debug.warn("bz 0x{x}\n", disp);
        },
        0x3 => {
            std.debug.warn("bnh 0x{x}\n", disp);
        },
        0x4 => {
            std.debug.warn("bn 0x{x}\n", disp);
        },
        0x5 => {
            std.debug.warn("br 0x{x}\n", disp);
        },
        0x6 => {
            std.debug.warn("blt 0x{x}\n", disp);
        },
        0x7 => {
            std.debug.warn("ble 0x{x}\n", disp);
        },
        0x8 => {
            std.debug.warn("bnv 0x{x}\n", disp);
        },
        0x9 => {
            std.debug.warn("bnc 0x{x}\n", disp);
        },
        0xa => {
            std.debug.warn("bnz 0x{x}\n", disp);
        },
        0xb => {
            std.debug.warn("bh 0x{x}\n", disp);
        },
        0xc => {
            std.debug.warn("bp 0x{x}\n", disp);
        },
        0xd => {
            std.debug.warn("nop 0x{x}\n", disp);
        },
        0xe => {
            std.debug.warn("bge 0x{x}\n", disp);
        },
        0xf => {
            std.debug.warn("bgt 0x{x}\n", disp);
        },
    }
}

pub fn movea(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("movea 0x{x}, r{}, r{}\n", imm, r1, r2);
}

pub fn addi(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("addi {}, r{}, r{}\n", @bitCast(i16, imm), r1, r2);
}

pub fn jr(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("jr 0x{x}\n", halfword);
}

pub fn jal(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("jal 0x{x}\n", halfword);
}

pub fn ori(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ori 0x{x}\n", halfword);
}

pub fn andi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("andi 0x{x}\n", halfword);
}

pub fn xori(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("xori 0x{x}\n", halfword);
}

pub fn movhi(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("movhi 0x{x}, r{}, r{}\n", imm, r1, r2);
}

pub fn ldb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldb 0x{x}\n", halfword);
}

pub fn ldh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldh 0x{x}\n", halfword);
}

pub fn ldw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("ldw 0x{x}\n", halfword);
}

pub fn stb(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("st.b r{}, {}[r{}]\n", r2, imm, r1);
}

pub fn sth(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("st.h r{}, {}[r{}]\n", r2, imm, r1);
}

pub fn stw(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc + 2) catch unreachable;

    std.debug.warn("st.w r{}, {}[r{}]\n", r2, imm, r1);
}

pub fn inb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inb 0x{x}\n", halfword);
}

pub fn inh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inh 0x{x}\n", halfword);
}

pub fn caxi(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("caxi 0x{x}\n", halfword);
}

pub fn inw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("inw 0x{x}\n", halfword);
}

pub fn outb(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outb 0x{x}\n", halfword);
}

pub fn outh(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outh 0x{x}\n", halfword);
}

pub fn float(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("float 0x{x}\n", halfword);
}

pub fn outw(cpu: *Cpu, halfword: u16) void {
    std.debug.warn("outw 0x{x}\n", halfword);
}
