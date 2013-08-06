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
    mov.ae0 %a9, $7, %aeg
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
    .globl belief_up
    .type belief_up. @function
    .signature pdk=65169
belief_up:
    caep03.ae0 $0
    rtn

#call sequencial belief propagation
    .globl store_down
    .type store_down. @function
    .signature pdk=65169
store_down:
    caep04.ae0 $0
    rtn

#call sequencial belief propagation
    .globl store_up
    .type store_up. @function
    .signature pdk=65169
store_up:
    caep05.ae0 $0
    rtn

#return aeg value
    .globl get_aeg
    .type get_aeg. @function
    .signature pdk=65169
get_aeg:
    mov.ae0 %aeg, %a8, %s8
    mov %s8, %a8
    rtn

#call sequencial belief propagation
    .globl loadAeg0All
    .type loadAeg0All. @function
    .signature pdk=65169
loadAeg0All:
    mov.ae0 %a8, $0, %aeg
    mov.ae1 %a9, $0, %aeg
    mov.ae2 %a10, $0, %aeg
    mov.ae3 %a11, $0, %aeg
    rtn

#call sequencial belief propagation
    .globl bpsAll
    .type bpsAll. @function
    .signature pdk=65169
bpsAll:
    mov.ae0 %a8, $0, %aeg
    mov.ae0 %a9, $7, %aeg
    caep00.ae0 $0
    rtn

#call sequencial belief propagation
    .globl custom0All
    .type custom0. @function
    .signature pdk=65169
custom0All:
    caep00 $0
    rtn

#call sequencial belief propagation
    .globl load_dataAll
    .type load_dataAll. @function
    .signature pdk=65169
load_dataAll:
    caep01 $0
    rtn

#call sequencial belief propagation
    .globl belief_downAll
    .type belief_downAll. @function
    .signature pdk=65169
belief_downAll:
    caep02 $0
    rtn

#call sequencial belief propagation
    .globl belief_upAll
    .type belief_upAll. @function
    .signature pdk=65169
belief_upAll:
    caep03 $0
    rtn

#call sequencial belief propagation
    .globl belief_down_upAll
    .type belief_down_upAll. @function
    .signature pdk=65169
belief_down_upAll:
    cmp.uq %a8, $0, %ac0
    br %AC0.eq, endLoop
    caep02 $0
    caep03 $0
    sub.uq %A8, $1, %A8
    br belief_down_upAll
endLoop:
    rtn

#call sequencial belief propagation
    .globl store_downAll
    .type store_downAll. @function
    .signature pdk=65169
store_downAll:
    caep04 $0
    rtn

#call sequencial belief propagation
    .globl store_upAll
    .type store_upAll. @function
    .signature pdk=65169
store_upAll:
    caep05 $0
    rtn
    
    .cend

