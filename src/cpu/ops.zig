const cpu = @import("cpu.zig");

pub const Instruction = fn (cpu: *Cpu, word: u32) void;

pub const INST_TABLE = [64]Instruction{
    // 000000 - 001111
    cpu.mov,   cpu.add,   cpu.sub,     cpu.cmp,
    cpu.shl,   cpu.shr,   cpu.jmp,     cpu.sar,
    cpu.mul,   cpu.div,   cpu.mulu,    cpu.divu,
    cpu.orop,  cpu.andop, cpu.xor,     cpu.not,

    // 010000 - 011111
    cpu.mov,   cpu.add,   cpu.setf,    cpu.cmp,
    cpu.shl,   cpu.shr,   cpu.cli,     cpu.sar,
    cpu.trap,  cpu.reti,  cpu.halt,    cpu.illegal,
    cpu.ldsr,  cpu.stsr,  cpu.sei,     cpu.bit_string,

    // 100000 - 101111
    cpu.bcond, cpu.bcond, cpu.bcond,   cpu.bcond,
    cpu.bcond, cpu.bcond, cpu.bcond,   cpu.bcond,
    cpu.movea, cpu.addi,  cpu.jr,      cpu.jal,
    cpu.ori,   cpu.andi,  cpu.xori,    cpu.movhi,

    // 110000 - 111111
    cpu.ldb,   cpu.ldh,   cpu.illegal, cpu.ldw,
    cpu.stb,   cpu.sth,   cpu.illegal, cpu.stw,
    cpu.inb,   cpu.inh,   cpu.caxi,    cpu.inw,
    cpu.outb,  cpu.outh,  cpu.float,   cpu.outw,
};

// bit string instructions - opcode = 011111
// 00000  sch0bsu   search bit 0 upward                  search upward for a 0
// 00001  sch0bsd   search bit 0 downward                search downward for a 0
// 00010  sch1bsu   search bit 1 upward                  search upward for a 1
// 00011  sch1bsd   search bit 1 downward                search downward for a 1
// 00100-00111      == illegal opcode ==
// 01000  orbsu     or bit string upward                 dest = dest or src
// 01001  andbsu    and bit string upward                dest = dest and src
// 01010  xorbsu    exclusive or bit string upward       dest = dest xor src
// 01011  movbsu    move bit string upward               dest = source
// 01100  ornbsu    or not bit string upward             dest = dest or (not src)
// 01101  andnbsu   and not bit string upward            dest = dest and (not src)
// 01110  xornbsu   exclusive or not bit string upward   dest = dest xor (not src)
// 01111  notbsu    not bit string upward                dest = not src
// 10000-11111      == illegal opcode ==

// floating-point and nintendo instructions - opcode = 111110
// 000000  cmpf.s    compare floating short            result = reg2 - reg1
// 000001            == illegal opcode ==
// 000010  cvt.ws    convert word to floating short    reg2 = float reg1
// 000011  cvt.sw    convert floating short to word    reg2 = convert reg1
// 000100  addf.s    add floating short                reg2 = reg2 + reg1
// 000101  subf.s    subtract floating short           reg2 = reg2 - reg1
// 000110  mulf.s    multiply floating short           reg2 = reg2 * reg1
// 000111  divf.s    divide floating short             reg2 = reg2 / reg1
// 001000  xb        swap low bytes                    reg2 bytes zyxw = zywx
// 001001  xh        swap halfwords                    reg2 bytes zyxw = xwzy
// 001010  rev       reverse bits                      reg2 = bit_reverse reg1
// 001011  trnc.sw   truncate floating short to word   reg2 = truncate reg1
// 001100  mpyhw     multiply halfword signed          reg2 = reg2 * reg1
// 001101-111111     == illegal opcode ==
