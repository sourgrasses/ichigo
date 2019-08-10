const Reg = @import("../cpu/regs.zig").Reg;

pub const Com = struct {
    link_control: Reg,
    auxiliary_link: Reg,
    link_transmit: Reg,
    link_receive: Reg,

    pub fn new() Com {
        return Com{
            .link_control = Reg(0),
            .auxiliary_link = Reg(0),
            .link_transmit = Reg(0),
            .link_receive = Reg(0),
        };
    }
};

pub const GamePad = struct {
    input_high: Reg,
    input_low: Reg,
    input_control: Reg,

    pub fn new() GamePad {
        return GamePad{
            .input_high = Reg(0),
            .input_low = Reg(0),
            .input_control = Reg(0),
        };
    }
};

pub const Timer = struct {
    tcr: Reg,
    tcr_reload_low: Reg,
    tcr_reload_high: Reg,
    wcr: Reg,

    pub fn new() Timer {
        return Timer{
            .tcr = Reg(0),
            .tcr_reload_low = Reg(0),
            .tcr_reload_high = Reg(0),
            .wcr = Reg(0),
        };
    }
};
