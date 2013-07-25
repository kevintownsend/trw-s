#author: Kevin Townsend
	.file	"cpSequencialBeliefPropagation.s"
	.ctext


#call sequencial belief propagation
    .globl bps
    .type bps. @function
    .signature pdk=65169
bps:
    mov.ae0 %a8, $0, %aeg
    caep00 $0
    rtn

    .cend
