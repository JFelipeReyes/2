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
    BCF TRISD, 1 ;PORT (D1) MA1 SALIDA
    BCF TRISD, 2 ;PORT (D2) MA2 SALIDA
    BCF TRISD, 3 ;PORT (D3) MB1 SALIDA
    BCF TRISD, 4 ;PORT (D4) MB2 SALIDA
    BCF TRISD, 5 ;PORT (D5) LAI SALIDA
    BCF TRISD, 6 ;PORT (D6) LAD SALIDA
    BCF TRISD, 7 ;PORT (D7) LRSTP SALIDA
    ;*************************
    BCF STATUS, 5 ; BK0
    CLRF PORTD

   MAIN:
    ; TESTEO
    BSF TRISD, 0
    ;
    MOVF PORTC,0    ;PORTC >>> W
    MOVWF 0x25	    ;PORTC >>> R25

    ;R21[0] = S2 (RC1)
    ANDLW 0b00000010 ; Resultado esta en W
    MOVWF 0x26
    RRF 0x26,1		; R26 = 0000 000(RC1)

    ;R27 = !S2
    MOVF 0x26,0	    ;R26 >>> W
    MOVWF 0x27	    ;W >>> R27
    COMF  0x27,0    ;W ! R27
    ANDLW 0b00000001
    MOVWF 0x27

    ;R28[0] = S3
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00000100
    MOVWF 0x28
    RRF 0x28,1
    RRF 0x28,1	    ;R28 = 0000 000(RC2)

    ;R29[0] = !S3
    MOVF 0x28,0	    ;R28 >>> W
    MOVWF 0x29	    ;W >>> R29
    COMF  0x29,0    ;W ! R27
    ANDLW 0b00000001
    MOVWF 0x29

    ;R30[0] = S1
    MOVF PORTC,0    ;PORTC >>> W
    ANDLW 0b00001000
    MOVWF 0x30
    RRF 0x30,1
    RRF 0x30,1
    RRF 0x30,1	    ;R30 = 0000 000(RC3)

    ;R31[0] = !S1
    MOVF 0x30,0	    ;R30 >>> W
    MOVWF 0x31	    ;W >>> R31
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
    RRF 0x32,1	    ;R32 = 0000 000(RC4)

    ;R33[0] = !S4
    MOVF 0x33,0	    ;R33 >>> W
    MOVWF 0x33	    ;W >>> R33
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
    RRF 0x34,1	    ;R34 = 0000 000(RC5)

    ;R35[0] = !S0
    MOVF 0x34,0	    ;R34 >>> W
    MOVWF 0x35	    ;W >>> R35
    COMF  0x35,0    ;W ! R35
    ANDLW 0b00000001
    MOVWF 0x35

    ; OPERACIONES AND PARA SALIDA MI=!S1.S2 + !S1.S3 + !S0.s4
    ; S1 = 30
    ; !S1= 31
    ; S2 = 26
    ; !S2 = 27
    
    ; OPERATION R36 = !S1 * S2
    MOVF 0x31,0		;W=R31  
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
    BTFSC 0x72,0
    GOTO ONMD
    GOTO OFFMD

    ONMD:
    BSF PORTD,2
    GOTO RI

    OFFMD:
    BSF PORTD,2
    GOTO RI

    ;RI:
    RI:
    BTFSC 0x73,0
    GOTO ONRI
    GOTO OFFRI

    ONRI:
    BSF PORTD,3
    GOTO BKR

    OFFRI:
    BSF PORTD,3
    GOTO BKR

    ;RD
    BKR:
    BTFSC 0x74,0
    GOTO ONRD
    GOTO OFFRD

    ONRD:
    BSF PORTD,4
    GOTO RIGHT

    OFFRD:
    BSF PORTD,4
    GOTO RIGHT


    ;RIGHT
    RIGHT:
    BTFSC 0x79,0
    GOTO ONRIGHT
    GOTO OFFRIGHT

    ONRIGHT:
    BSF PORTD,5
    GOTO STOP

    OFFRIGHT:
    BSF PORTD,5
    GOTO STOP

    ;STOP:
    STOP:
    BTFSC 0x77,0
    GOTO ONSTOP
    GOTO OFFSTOP

    ONSTOP:
    BSF PORTD,6
    GOTO LEFT

    OFFSTOP:
    BSF PORTD,6
    GOTO LEFT

    ;LEFT
    LEFT:
    BTFSC 0x76,0
    GOTO ONLEFT
    GOTO OFFLEFT

    ONLEFT:
    BSF PORTD,7
    GOTO MAIN

    OFFLEFT:
    BSF PORTD,7
    GOTO MAIN

    END resetVec
