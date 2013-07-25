#author: Kevin Townsend
	.file	"cpSequencialBeliefPropagation.s"
	.ctext

#call sequencial belief propagation
    .globl loadAeg0
    .type loadAeg0. @function
    .signature pdk=65169
loadAeg0:
    mov.ae0 %a8, $0, %aeg
    rtn

#call sequencial belief propagation
    .globl bps
    .type bps. @function
    .signature pdk=65169
bps:
    mov.ae0 %a8, $0, %aeg
    caep00.ae0 $0
    rtn

#call sequencial belief propagation
    .globl custom0
    .type custom0. @function
    .signature pdk=65169
custom0:
    caep00.ae0 $0
    rtn
    .cend
