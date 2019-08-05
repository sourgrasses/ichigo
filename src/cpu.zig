const std = @import("std");

const Bus = @import("bus.zig").Bus;
const Reg = @import("regs.zig").Reg;

pub const Cpu = struct {
    bus: *Bus,

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

    pub fn new(bus: *Bus) Cpu {
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
            .ecr = Reg(0),
            .adtre = Reg(0),
            .chcw = Reg(0),
            .tkcw = Reg(0),
            .pir = Reg(0),
        };
    }
};
