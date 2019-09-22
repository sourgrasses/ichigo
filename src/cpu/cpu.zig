const std = @import("std");

const Allocator = std.mem.Allocator;
const Bus = @import("../bus.zig").Bus;
const Cart = @import("../cart.zig").Cart;
const DEBUG_INST_TABLE = @import("ops.zig").DEBUG_INST_TABLE;
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
                //               🌯🌯🌯🌯🌯🌯🌯🌯🌯
                Reg(0),          Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
                Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe), Reg(0xf00dbabe),
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

            const debug = true;

            if (debug) {
                std.debug.warn("0x{x:08}\t{x:04}\t", self.pc, halfword);
                DEBUG_INST_TABLE[opcode](self, halfword);
            }
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
            6 => &self.pir,
            7 => &self.tkcw,
            24 => &self.chcw,
            25 => &self.adtre,
            else => unreachable,
        };

        return reg_ptr;
    }

    fn set_interrupt_disable(self: *Cpu) void {
        self.psw |= 0x00001000;
    }

    fn clear_interrupt_disable(self: *Cpu) void {
        self.psw |= 0xffffefff;
    }

    fn cy(self: *Cpu) u1 {
        return @intCast(u1, ((self.psw & 0x00000008) >> 3));
    }

    fn ov(self: *Cpu) u1 {
        return @intCast(u1, ((self.psw & 0x00000004) >> 2));
    }

    fn s(self: *Cpu) u1 {
        return @intCast(u1, ((self.psw & 0x00000002) >> 1));
    }

    fn z(self: *Cpu) u1 {
        return @intCast(u1, (self.psw & 0x00000001));
    }

    fn set_cy(self: *Cpu) void {
        self.psw |= 0x00000008;
    }

    fn set_ov(self: *Cpu) void {
        self.psw |= 0x00000004;
    }

    fn set_s(self: *Cpu) void {
        self.psw |= 0x00000002;
    }

    fn set_z(self: *Cpu) void {
        self.psw |= 0x00000001;
    }

    fn clear_cy(self: *Cpu) void {
        self.psw &= 0xfffffff7;
    }

    fn clear_ov(self: *Cpu) void {
        self.psw &= 0xfffffffb;
    }

    fn clear_s(self: *Cpu) void {
        self.psw &= 0xfffffffd;
    }

    fn clear_z(self: *Cpu) void {
        self.psw &= 0xfffffffe;
    }

    fn set_flags(self: *Cpu, res: u32, old: u32) void {
        if (res < old) {
            self.set_cy();
        } else {
            self.clear_cy();
        }
        if ((res & 0x10000000) != (old & 0x10000000)) {
            self.set_ov();
        } else {
            self.clear_ov();
        }
        if (@bitCast(i32, res) < 0) {
            self.set_s();
        } else {
            self.clear_s();
        }
        if (res == 0) {
            self.set_z();
        } else {
            self.clear_z();
        }
    }
};

pub fn sign_extend(val: u16) u32 {
    if (@bitCast(i16, val) < 0) {
        return @intCast(u32, val) | 0xffff0000;
    } else {
        return @intCast(u32, val);
    }
}

pub fn sign_extend5(val: u5) u32 {
    if (@bitCast(i5, val) < 0) {
        return @intCast(u32, val) | 0xffffffe0;
    } else {
        return @intCast(u32, val);
    }
}

pub fn sign_extend8(val: u8) u32 {
    if (@bitCast(i8, val) < 0) {
        return @intCast(u32, val) | 0xffffff00;
    } else {
        return @intCast(u32, val);
    }
}

pub fn sign_extend26(val: u26) u32 {
    if (@bitCast(i26, val) < 0) {
        return @intCast(u32, val) | 0xfc000000;
    } else {
        return @intCast(u32, val);
    }
}

pub fn illegal(cpu: *Cpu, halfword: u16) void {
    std.process.exit(1);
}

// move register
pub fn mov(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);

    cpu.regs[r2] = cpu.regs[r1];
    cpu.pc += 2;
}

// add register
pub fn add(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);

    const res = cpu.regs[r2] +% cpu.regs[r1];
    cpu.set_flags(res, cpu.regs[r2]);
    cpu.regs[r2] = res;

    cpu.pc += 2;
}

// TODO
// subtract
pub fn sub(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn cmp(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);

    const res = cpu.regs[r2] -% cpu.regs[r1];
    cpu.set_flags(res, cpu.regs[r2]);

    cpu.pc += 2;
}

// TODO
pub fn shl(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn shr(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn jmp(cpu: *Cpu, halfword: u16) void {
    const r1 = @intCast(usize, halfword & 0x001f);
    cpu.pc = cpu.regs[r1] & 0xfffffffe;
}

// TODO
pub fn sar(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn mul(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn div(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn mulu(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn divu(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn orop(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn andop(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn xor(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn not(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn mov2(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @intCast(u5, halfword & 0x001f);

    cpu.regs[r2] = sign_extend5(imm);
    cpu.pc += 2;
}

pub fn add2(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @bitCast(i5, @intCast(u5, halfword & 0x001f));

    const old = cpu.regs[r2];
    if (imm < 0) {
        cpu.regs[r2] = cpu.regs[r2] -% @intCast(u32, imm * -1);
    } else {
        cpu.regs[r2] = cpu.regs[r2] +% @intCast(u32, imm);
    }

    if (cpu.regs[r2] < old) {
        cpu.set_cy();
    }
    if ((cpu.regs[r2] & 0x10000000) != (old & 0x10000000)) {
        cpu.set_ov();
    }
    if (@bitCast(i32, cpu.regs[r2]) < 0) {
        cpu.set_s();
    }
    if (cpu.regs[r2] == 0) {
        cpu.set_z();
    }

    cpu.pc += 2;
}

// TODO
pub fn cmp2(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn shl2(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn shr2(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
// Nintendo-specific
pub fn cli(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn sar2(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn setf(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn trap(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn reti(cpu: *Cpu, halfword: u16) void {
    cpu.pc = cpu.regs[31];
}

// TODO
pub fn halt(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn ldsr(cpu: *Cpu, halfword: u16) void {
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const imm = @intCast(u5, halfword & 0x001f);

    const reg = cpu.get_sysreg_ptr(imm);
    //if (imm == 5) {
    //    cpu.regs[r2] = cpu.psw;
    //}
    reg.* = cpu.regs[r2];

    cpu.pc += 2;
}

// TODO
pub fn stsr(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// Nintendo-specific
pub fn sei(cpu: *Cpu, halfword: u16) void {
    cpu.set_interrupt_disable();
    cpu.pc += 2;
}

// TODO
pub fn bit_string(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn bcond(cpu: *Cpu, halfword: u16) void {
    const cond = @intCast(u4, (halfword & 0x1e00) >> 9);
    const disp = halfword & 0x01ff;

    var cond_true = false;
    switch (cond) {
        0x0 => {
            if (cpu.ov() == 1) {
                cond_true = true;
            }
        },
        0x1 => {
            if (cpu.cy() == 1) {
                cond_true = true;
            }
        },
        0x2 => {
            if (cpu.z() == 1) {
                cond_true = true;
            }
        },
        0x3 => {
            if (cpu.cy() | cpu.z() == 1) {
                cond_true = true;
            }
        },
        0x4 => {
            if (cpu.s() == 1) {
                cond_true = true;
            }
        },
        0x5 => {
            cond_true = true;
        },
        0x6 => {
            if (cpu.s() ^ cpu.ov() == 1) {
                cond_true = true;
            }
        },
        0x7 => {
            if ((cpu.s() ^ cpu.ov()) | cpu.z() == 1) {
                cond_true = true;
            }
        },
        0x8 => {
            if (cpu.ov() == 0) {
                cond_true = true;
            }
        },
        0x9 => {
            if (cpu.cy() == 0) {
                cond_true = true;
            }
        },
        0xa => {
            if (cpu.z() == 0) {
                cond_true = true;
            }
        },
        0xb => {
            if (cpu.cy() | cpu.z() == 0) {
                cond_true = true;
            }
        },
        0xc => {
            if (cpu.s() == 0) {
                cond_true = true;
            }
        },
        0xd => {
            cpu.pc += 2;
            return;
        },
        0xe => {
            if (cpu.s() ^ cpu.ov() == 0) {
                cond_true = true;
            }
        },
        0xf => {
            if ((cpu.s() ^ cpu.ov()) | cpu.z() == 0) {
                cond_true = true;
            }
        },
    }

    if (cond_true) {
        if (@bitCast(i9, @intCast(u9, disp & 0x01ff)) < 0) {
            const offset = (@intCast(u32, disp) | 0xfffffe00) & 0xfffffffe;
            cpu.pc = cpu.pc +% @intCast(u32, offset);
        } else {
            const offset = @intCast(u32, disp) & 0xfffffffe;
            cpu.pc = cpu.pc +% @intCast(u32, offset);
        }
    } else {
        cpu.pc += 2;
    }
}

pub fn movea(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const val = sign_extend(imm);
    cpu.regs[r2] = cpu.regs[r1] +% val;

    cpu.pc += 2;
}

pub fn addi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const old = cpu.regs[r2];
    cpu.regs[r2] = cpu.regs[r1] +% sign_extend(imm);

    cpu.set_flags(cpu.regs[r2], old);

    cpu.pc += 2;
}

pub fn jr(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const upper = @intCast(u32, halfword & 0x00ff) << 16;
    const lower = @intCast(u32, cpu.bus.read_halfword(cpu.pc) catch unreachable);
    const disp = sign_extend26(@intCast(u26, (upper | lower)));

    cpu.pc = cpu.pc +% disp & 0xfffffffe;
}

pub fn jal(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const upper = @intCast(u32, halfword & 0x00ff) << 16;
    const lower = @intCast(u32, cpu.bus.read_halfword(cpu.pc) catch unreachable);
    const disp = sign_extend26(@intCast(u26, (upper | lower)));

    cpu.regs[31] = cpu.pc + 2;
    cpu.pc = cpu.pc +% disp & 0xfffffffe;
}

// TODO
pub fn ori(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn andi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn xori(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn movhi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const imm = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    cpu.regs[r2] = cpu.regs[r1] +% (@intCast(u32, imm) << 16);
    cpu.pc += 2;
}

pub fn ldb(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    cpu.regs[r2] = sign_extend8(cpu.bus.read_byte(addr) catch unreachable);

    cpu.pc += 2;
}

pub fn ldh(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    cpu.regs[r2] = sign_extend(cpu.bus.read_halfword(addr) catch unreachable);

    cpu.pc += 2;
}

pub fn ldw(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    cpu.regs[r2] = cpu.bus.read_word(addr) catch unreachable;
    std.debug.warn("0x{x:08}: 0x{x:08}\n", cpu.regs[r1], cpu.bus.read_word(addr) catch unreachable);

    cpu.pc += 2;
}

pub fn stb(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    const byte = @intCast(u8, cpu.regs[r2] & 0x000000ff);
    cpu.bus.write_byte(addr, byte) catch unreachable;
    cpu.pc += 2;
}

pub fn sth(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    const whalfword = @intCast(u16, cpu.regs[r2] & 0x0000ffff);
    cpu.bus.write_halfword(addr, whalfword) catch unreachable;
    cpu.pc += 2;
}

pub fn stw(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
    const r2 = @intCast(usize, (halfword & 0x03e0) >> 5);
    const r1 = @intCast(usize, halfword & 0x001f);
    const disp = cpu.bus.read_halfword(cpu.pc) catch unreachable;

    const addr = (cpu.regs[r1] +% sign_extend(disp)) & 0xfffffffe;
    cpu.bus.write_word(addr, cpu.regs[r2]) catch unreachable;
    cpu.pc += 2;
}

// TODO
pub fn inb(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn inh(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn caxi(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

// TODO
pub fn inw(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn outb(cpu: *Cpu, halfword: u16) void {
    stb(cpu, halfword);
}

pub fn outh(cpu: *Cpu, halfword: u16) void {
    sth(cpu, halfword);
}

// TODO
pub fn float(cpu: *Cpu, halfword: u16) void {
    cpu.pc += 2;
}

pub fn outw(cpu: *Cpu, halfword: u16) void {
    stw(cpu, halfword);
}
