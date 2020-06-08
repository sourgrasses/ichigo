const Reg = @import("../cpu/regs.zig").Reg;

pub const Com = struct {
    link_control: Reg,
    auxiliary_link: Reg,
    link_transmit: Reg,
    link_receive: Reg,

    pub fn new() Com {
        return Com{
            .link_control = 0,
            .auxiliary_link = 0,
            .link_transmit = 0,
            .link_receive = 0,
        };
    }
};

pub const GamePad = struct {
    input_high: Reg,
    input_low: Reg,
    input_control: Reg,

    pub fn new() GamePad {
        return GamePad{
            .input_high = 0,
            .input_low = 0,
            .input_control = 0,
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
            .tcr = 0,
            .tcr_reload_low = 0,
            .tcr_reload_high = 0,
            .wcr = 0,
        };
    }
};
