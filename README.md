# 🍓 ichigo
Virtual Boy emulator in Zig.

## Status
- reaches a point in games where the game begins checking for the "display is ready" bit in the display status "register" of the vip to be set
- 
- starting to implement display sdl stuff in `src/vb.zig`

## TODO
### basic functionality
- [x] opcodes table
- [ ] implement all opcodes
- [x] basic sdl
- [ ] render sdl from vip
- [ ] vip
- [ ] vsu

### disassembler
- [ ] correct disassembly for all opcodes
- [x] break disassembler out from regular cpu functions
- [ ] interactive debugger tbh

### memory map routing/bus
- [x] basic bus functionality
- [ ] map all the io bits
- [ ] radix tree/other data structure

## References
- [Ferris Makes Emulators](https://www.youtube.com/watch?v=IfYp4xke5i8&list=PL-sXmdrqqYYdjH56jYTyQoQl6k2uSWUxa), of course
- [Virtual Boy Specifications/VB Sacred Scroll](https://www.planetvb.com/content/downloads/documents/stsvb.html)
