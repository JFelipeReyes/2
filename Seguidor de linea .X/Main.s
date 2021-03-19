PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

PSECT code

INISYS:
    BCF STATUS,6 ;BK1
    BSF STATUS,5

    BSF TRISC, 1 ;PORT (C1) S2 ENTRADA
    BSF TRISC, 2 ;PORT (C2) S3 ENTRADA
    BSF TRISC, 3 ;PORT (C3) S1 ENTRADA
    BSF TRISC, 4 ;PORT (C4) S4 ENTRADA
    BSF TRISC, 5 ;PORT (C5) S0 ENTRADA
    BCF TRISD, 0 ;PORT Testeo
    BCF TRISD, 1 ;PORT (D1) MI SALIDA
    BCF TRISD, 2 ;PORT (D2) MD SALIDA
    BCF TRISD, 3 ;PORT (D3) RI SALIDA
    BCF TRISD, 4 ;PORT (D4) RD SALIDA
    BCF TRISD, 5 ;PORT (D5) RIGHT SALIDA
    BCF TRISD, 6 ;PORT (D6) STOP SALIDA
    BCF TRISD, 7 ;PORT (D7) LEFT SALIDA
    ;*************************
    BCF STATUS, 5 ; BK0
    CLRF PORTD

   MAIN:
    ; TESTEO
    BSF TRISD, 0
    ;
    MOVF PORTC,0    ;PORTC >>> W
    MOVWF 0x25    ;PORTC >>> R25

    ;R21[0] = S2 (RC1)
    ANDLW 0b00000010 ; Resultado esta en W
    MOVWF 0x26
    RRF 0x26,1 ; R26 = 0000 000(RC1)

    ;R27 = !S2
    MOVF 0x26,0    ;R26 >>> W
    MOVWF 0x27    ;W >>> R27
    COMF  0x27,0    ;W ! R27
    ANDLW 0b00000001
    MOVWF 0x27

    ;R28[0] = S3
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00000100
    MOVWF 0x28
    RRF 0x28,1
    RRF 0x28,1    ;R28 = 0000 000(RC2)

    ;R29[0] = !S3
    MOVF 0x28,0    ;R28 >>> W
    MOVWF 0x29    ;W >>> R29
    COMF  0x29,0    ;W ! R27
    ANDLW 0b00000001
    MOVWF 0x29

    ;R30[0] = S1
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00001000
    MOVWF 0x30
    RRF 0x30,1
    RRF 0x30,1
    RRF 0x30,1    ;R30 = 0000 000(RC3)

    ;R31[0] = !S1
    MOVF 0x30,0    ;R30 >>> W
    MOVWF 0x31    ;W >>> R31
    COMF  0x31,0    ;W ! R31
    ANDLW 0b00000001
    MOVWF 0x31

    ;R32[0] = S4
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00010000
    MOVWF 0x32
    RRF 0x32,1
    RRF 0x32,1
    RRF 0x32,1
    RRF 0x32,1    ;R32 = 0000 000(RC4)

    ;R33[0] = !S4
    MOVF 0x33,0    ;R33 >>> W
    MOVWF 0x33    ;W >>> R33
    COMF  0x33,0    ;W ! R33
    ANDLW 0b00000001
    MOVWF 0x33

    ;R34[0] = S0
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00100000
    MOVWF 0x34
    RRF 0x34,1
    RRF 0x34,1
    RRF 0x34,1
    RRF 0x34,1
    RRF 0x34,1    ;R34 = 0000 000(RC5)

    ;R35[0] = !S0
    MOVF 0x34,0    ;R34 >>> W
    MOVWF 0x35    ;W >>> R35
    COMF  0x35,0    ;W ! R35
    ANDLW 0b00000001
    MOVWF 0x35

    ; OPERACIONES AND PARA SALIDA MI=!S1.S2 + !S1.S3 + !S0.s4
    ; S1 = 30
    ; !S1= 31
    ; S2 = 26
    ; !S2 = 27
   
    ; OPERATION R36 = !S1 * S2
    MOVF 0x31,0 ;W=R31  
    ANDWF 0x26,0
    MOVWF 0x36

    ; OPERATION R37 = !S1 * S3
    MOVF 0x31,0
    ANDWF 0x28,0
    MOVWF 0x37

    ; OPERATION R38 = !S0 * S4
    MOVF 0x35,0
    ANDWF 0x32,0
    MOVF 0x38

    ;OPERACIONES OR PARA MI

    ;OPERATION R69 = !S1 *S2 + !S1 * S3
    MOVF 0x36,0
    IORWF 0x37,0
    IORWF 0x38,0
    MOVWF 0x39
   
    ;///////////////////////////////////////////////////////////////////////////////
   
    ; OPERACIONES AND PARA SALIDA MD = S0.S4' + S1.S3' + S1'.S3'.S2
   
    ; OPERATION R40 = S0.S4'
    MOVF 0x34,0  
    ANDWF 0x33,0
    MOVWF 0x40
   
    ; OPERATION R41 = S1.S3'
    MOVF 0x30,0  
    ANDWF 0x29,0
    MOVWF 0x41
   
    ; OPERATION R42 = S1'.S3'
    MOVF 0x31,0  
    ANDWF 0x29,0
    MOVWF 0x42
   
    ; OPERATION R43 = S1'.S3'.S2
    MOVF 0x42,0  
    ANDWF 0x26,0
    MOVWF 0x43
   
    ;OPERACIONES OR PARA MD

    ;OPERATION R44 = S0.S4' + S1.S3' + S1'.S3'.S2
    MOVF 0x40,0
    IORWF 0x41,0
    IORWF 0x43,0
    MOVWF 0x44
   
    ;///////////////////////////////////////////////////////////////////////////////

    ;OPERACIONES AND PARA SALIDA RI =  S0.S4' + S4.S2'  
   
    ; OPERATION R45 = S4'.S2'
    MOVF 0x33,0  
    ANDWF 0x27,0
    MOVWF 0x45
   
    ;OPERACIONES OR PARA RI

    ;OPERATION R46 = S0.S4' + S4'.S2'
    MOVF 0x40,0
    IORWF 0x45,0
    MOVWF 0x46
   
    ;///////////////////////////////////////////////////////////////////////////////

    ;OPERACIONES AND PARA SALIDA RD = S0'.S2' + S0'.S4
   
    ; OPERATION R47 = S0'.S2'
    MOVF 0x35,0  
    ANDWF 0x27,0
    MOVWF 0x47
   
    ;OPERACIONES OR PARA RD

    ;OPERATION R71 = S0'.S2' + S0'.S4
    MOVF 0x47,0
    IORWF 0x38,0
    MOVWF 0x71
   
    ;///////////////////////////////////////////////////////////////////////////////
   
    ;OPERACIONES AND PARA SALIDA LEFT = S4'.S1.S3' + S0'.S4'.S1'.S3'.S2 + S0.S4'.S1'.S3'.S2'
   
    ; OPERATION R48 = S4'.S1
    MOVF 0x33,0  
    ANDWF 0x30,0
    MOVWF 0x48
   
    ;OPERATION R49 = S4'.S1.S3'
    MOVF 0x48,0  
    ANDWF 0x29,0
    MOVWF 0x49
   
   ;OPERATION R50 = S0'.S4'
    MOVF 0x35,0  
    ANDWF 0x33,0
    MOVWF 0x50
   
    ;OPERATION R51 = S0'.S4'.S1'
    MOVF 0x50,0  
    ANDWF 0x31,0
    MOVWF 0x51
   
    ;OPERATION R52 = S0'.S4'.S1'.S3'
    MOVF 0x51,0  
    ANDWF 0x29,0
    MOVWF 0x52
   
    ;OPERATION R53 = S0'.S4'.S1'.S3'.S2
    MOVF 0x52,0  
    ANDWF 0x26,0
    MOVWF 0x53
   
    ;OPERATION R54 = S0.S4'
    MOVF 0x34,0  
    ANDWF 0x33,0
    MOVWF 0x54
   
    ;OPERATION R55 = S0.S4'.S1'
    MOVF 0x54,0  
    ANDWF 0x31,0
    MOVWF 0x55
   
    ;OPERATION R56 = S0.S4'.S1'.S3'
    MOVF 0x55,0  
    ANDWF 0x29,0
    MOVWF 0x56
   
    ;OPERATION R57 = S0.S4'.S1'.S3'.S2'
    MOVF 0x56,0  
    ANDWF 0x27,0
    MOVWF 0x57
   
    ;OPERACIONES OR PARA LEFT

    ;OPERATION R58 = S4'.S1.S3' + S0'.S4'.S1'.S3'.S2 + S0.S4'.S1'.S3'.S2'
    MOVF 0x49,0
    IORWF 0x53,0
    IORWF 0x57,0
    MOVWF 0x58
    ;///////////////////////////////////////////////////////////////////////////////
   
    ;OPERACIONES AND PARA SALIDA STOP = S0'.S4'.S1'.S3'.S2' + S0.S4.S1.S3.S2
   
    ;OPERATION R59 = S0'.S4'.S1'.S3'.S2'
    MOVF 0x52,0  
    ANDWF 0x27,0
    MOVWF 0x59
   
    ;OPERATION R60 = S0.S4
    MOVF 0x34,0  
    ANDWF 0x32,0
    MOVWF 0x60
   
    ;OPERATION R61 = S0.S4.S1
    MOVF 0x60,0  
    ANDWF 0x30,0
    MOVWF 0x61
   
    ;OPERATION R62 = S0.S4.S1.S3
    MOVF 0x61,0  
    ANDWF 0x28,0
    MOVWF 0x62
   
    ;OPERATION R63 = S0.S4.S1.S3.S2
    MOVF 0x62,0  
    ANDWF 0x26,0
    MOVWF 0x63
   
    ;OPERACIONES OR PARA STOP

    ;OPERATION R58 = S0'.S4'.S1'.S3'.S2' + S0.S4.S1.S3.S2
    MOVF 0x59,0
    IORWF 0x63,0
    MOVWF 0x64
    ;///////////////////////////////////////////////////////////////////////////////
   
;OPERACIONES AND PARA SALIDA RIGHT = S0'.S1'.S3 + S0'.S4'.S1'.S3'.S2 + S0'.S4.S1'.S3'.S2'
   
    ;OPERATION R65 = S0'.S1'
    MOVF 0x35,0  
    ANDWF 0x31,0
    MOVWF 0x65
   
    ;OPERATION R66 = S0'.S1'.S3
    MOVF 0x65,0  
    ANDWF 0x28,0
    MOVWF 0x66
   
    ;OPERATION R67 = S0'.S4.S1'
    MOVF 0x38,0  
    ANDWF 0x31,0
    MOVWF 0x67
   
    ;OPERATION R68 = S0'.S4.S1'.S3'
    MOVF 0x67,0  
    ANDWF 0x29,0
    MOVWF 0x68
   
    ;OPERATION R69 = S0'.S4.S1'.S3'.S2
    MOVF 0x68,0  
    ANDWF 0x26,0
    MOVWF 0x69
   
    ;OPERACIONES OR PARA RIGHT

    ;OPERATION R70 = S0'.S1'.S3 + S0'.S4'.S1'.S3'.S2 + S0'.S4.S1'.S3'.S2'
    MOVF 0x66,0
    IORWF 0x53,0
    IORWF 0x69,0
    MOVWF 0x70

    ;ASIGNACION DE SALIDAS
    ; TESTEO
    BCF TRISD, 0
    ;

    ;MI:
    BTFSC 0x39,0
    GOTO ONMI
    GOTO OFFMI

    ONMI:
    BSF PORTD,1
    GOTO MD

    OFFMI:
    BCF PORTD,1
    GOTO MD

    ;MD:
    MD:
    BTFSC 0x44,0
    GOTO ONMD
    GOTO OFFMD

    ONMD:
    BSF PORTD,2
    GOTO RI

    OFFMD:
    BCF PORTD,2
    GOTO RI

    ;RI:
    RI:
    BTFSC 0x46,0
    GOTO ONRI
    GOTO OFFRI

    ONRI:
    BSF PORTD,3
    GOTO BKR

    OFFRI:
    BCF PORTD,3
    GOTO BKR

    ;RD
    BKR:
    BTFSC 0x71,0
    GOTO ONRD
    GOTO OFFRD

    ONRD:
    BSF PORTD,4
    GOTO RIGHT

    OFFRD:
    BCF PORTD,4
    GOTO RIGHT


    ;RIGHT
    RIGHT:
    BTFSC 0x70,0
    GOTO ONRIGHT
    GOTO OFFRIGHT

    ONRIGHT:
    BSF PORTD,5
    GOTO STOP

    OFFRIGHT:
    BCF PORTD,5
    GOTO STOP

    ;STOP:
    STOP:
    BTFSC 0x64,0
    GOTO ONSTOP
    GOTO OFFSTOP

    ONSTOP:
    BSF PORTD,6
    GOTO LEFT

    OFFSTOP:
    BCF PORTD,6
    GOTO LEFT

    ;LEFT
    LEFT:
    BTFSC 0x58,0
    GOTO ONLEFT
    GOTO OFFLEFT

    ONLEFT:
    BSF PORTD,7
    GOTO MAIN

    OFFLEFT:
    BCF PORTD,7
    GOTO MAIN

    END resetVec

