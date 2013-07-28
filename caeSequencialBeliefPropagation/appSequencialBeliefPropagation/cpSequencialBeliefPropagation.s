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

#call sequencial belief propagation
    .globl load_data
    .type load_data. @function
    .signature pdk=65169
load_data:
    caep01.ae0 $0
    rtn

#call sequencial belief propagation
    .globl belief_down
    .type belief_down. @function
    .signature pdk=65169
belief_down:
    caep02.ae0 $0
    rtn

#call sequencial belief propagation
    .globl store_down
    .type store_down. @function
    .signature pdk=65169
store_down:
    caep04.ae0 $0
    rtn

#return aeg value
    .globl get_aeg
    .type get_aeg. @function
    .signature pdk=65169
get_aeg:
    mov.ae0 %aeg, %a8, %s8
    mov %s8, %a8
    rtn


    .cend

