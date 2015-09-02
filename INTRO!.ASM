MODEL   SMALL           ;sup/\ c001 my 1-st intro on PC!
IDEAL
P386
        ASSUME CS:@CODE
CODESEG
START:
        PUSH CS
        PUSH CS
        POP DS
        POP ES

        MOV AH,9
        MOV DX,OFFSET PRIKOL
        INT 21H

        XOR AH,AH
        INT 16H

        MOV AH,9
        MOV DX,OFFSET PRIKOL1
        INT 21H

        XOR AH,AH
        INT 16H

        CALL MAKE_STARS         ;H“   -‚€…“, “„“ ‚‘… 300
        PUSH 0A000H             ;‚›„“›‚€’ —’‹? ;-E~~
        POP ES
        XOR DI,DI

        MOV AX,13H
        INT 10H

WAIT_ESC:
        CALL BMP_DMA_OUT
        CALL STARS
        CALL ZIGZAG
        CALL ROTAT
        CALL ZIGZA1
        CALL JUMP
        CALL PWMETC_OUT
        CALL PWMETC1OUT
        PUSH SI
        CALL SCROLL
        CALL COUNT

        CALL MASTER
        CALL GREETS
        CALL CURSOR

        CALL WAIT_RETRACE
        CALL CLEAR
        POP SI
        CALL PWMETC2OUT

        IN AL,60H
        DEC AL
        JNZ WAIT_ESC

        MOV AX,3H
        INT 10H
        MOV AX,4C00H
        INT 21H                 ;END OF PROGRAM


;=============================================================================

PWMETC2OUT:
        PUSH SI
        MOV SI,40H
        ADD SI,2
        AND SI,0FFH

        MOV [CS:OFFSET PWMETC2OUT+2],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,320/2-40
        MOV DI,AX

PWM2Y:
        MOV SI,0
        ADD SI,2
        AND SI,255
        MOV [CS:OFFSET PWM2Y+1],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,64
        MOV DX,320
        MUL DX
        ADD DI,AX

        POP SI
        MOV CX,15               ;VERT
PWM12:
        PUSH CX
        MOV CX,75               ;HORIZON
PWM22:
        LODSB
        CMP AL,0FBH
        JZ NO2PUT

        MOV [ES:DI],AL

NO2PUT:
        INC DI
        LOOP PWM22
        POP CX
        INC SI
        ADD DI,320-75
        LOOP PWM12
        RET

;=============================================================================

PWMETC1OUT:
        PUSH SI
        MOV SI,0
        ADD SI,2
        AND SI,0FFH
        MOV [CS:OFFSET PWMETC1OUT+2],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,64
        MOV DI,AX

PWM1Y:
        MOV SI,0
        INC SI
        AND SI,255
        MOV [CS:OFFSET PWM1Y+1],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,200-64-15
        MOV DX,320
        MUL DX
        ADD DI,AX

        POP SI
        MOV CX,15               ;VERT
PWM11:
        PUSH CX
        MOV CX,75               ;HORIZON
PWM21:
        LODSB
        CMP AL,0FBH
        JZ NO1PUT

        MOV [ES:DI],AL

NO1PUT:
        INC DI
        LOOP PWM21
        POP CX
        INC SI
        ADD DI,320-75
        LOOP PWM11
        RET

;=============================================================================

PWMETC_OUT:
        MOV SI,130
        INC SI
        AND SI,0FFH
        MOV [CS:OFFSET PWMETC_OUT+1],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,320-75-64
        MOV DI,AX

PWM_Y:
        MOV SI,130
        ADD SI,2
        AND SI,255
        MOV [CS:OFFSET PWM_Y+1],SI
        ADD SI,OFFSET SINUS
        XOR EAX,EAX
        LODSB
        ADD AL,200-64-15
        MOV DX,320
        MUL DX
        ADD DI,AX

        MOV SI,OFFSET PWMETC-(45*76)
        MOV CX,15               ;VERT
PWM1:
        PUSH CX
        MOV CX,75               ;HORIZON
PWM2:
        LODSB
        CMP AL,0FBH
        JZ NO_PUT

        MOV [ES:DI],AL

NO_PUT:
        INC DI
        LOOP PWM2
        POP CX
        INC SI
        ADD DI,320-75
        LOOP PWM1
        RET

;=============================================================================

STARS:
        MOV SI,OFFSET STARS_DATA
        MOV CX,3

STARS_1:
        PUSH CX
        MOV BX,CX
        MOV CX,111

STARS_2:
        LODSW
        SUB AX,BX
        CMP AX,320
        JC STAR_OK

        MOV AX,319

STAR_OK:
        MOV [CS:SI-2],AX
        MOV DI,AX
        XOR AH,AH
        LODSB
        MOV DX,320
        MUL DX
        ADD DI,AX
        MOV AL,BL
        STOSB
        LOOP STARS_2
        POP CX
        LOOP STARS_1
        RET

;=============================================================================

MAKE_STARS:
        MOV DI,OFFSET STARS_DATA
        MOV CX,333               ;•… •… 300 ‡‚π‡„›...
MAKE_1:
        MOV AX,320              ;X
        CALL RANDOM
        STOSW
        MOV AX,200              ;Y
        CALL RANDOM
        STOSB
        LOOP MAKE_1
        RET

;=============================================================================

BMP_DMA_OUT:
        MOV SI,OFFSET FONT-33

        MOV DI,320*190-30
        MOV CX,10
DMA_OUT1:
        PUSH CX
        MOV CX,30
        REP MOVSB
        POP CX
        ADD DI,320-30
        SUB SI,62               ;—…“?! 8-[    ]
        LOOP DMA_OUT1

        MOV AL,[CS:OFFSET INTS]
        AND AL,111B
        CMP AL,100B           ;ONLY ON EVERY 8 INT
        JZ $+3

        RET

COUNT_BMP:
        MOV AL,3
        DEC AL
        AND AL,AL
        JNZ $+7

        MOV AL,3
        MOV SI,OFFSET FONT-33

        MOV [CS:OFFSET COUNT_BMP+1],AL
        MOV [CS:OFFSET BMP_DMA_OUT+1],SI
        RET

;=============================================================================

MASTER:
        CALL COUNTER            ;    :) I MADE IT FOR EASY MIND OF MINE ;))
        CALL MAIN
        RET

;=============================================================================

MAIN:
        MOV BX,00H           ;BL = ό LETTERS, BH = COMPLETE
        MOV AL,[CS:OFFSET INTS]
        MOV CL,BH
        AND AL,111B
        CMP AL,100B           ;ONLY ON EVERY 8 INT
        JZ $+3

        RET

        AND CL,CL
        JNZ NOT_BEGIN

        MOV AL,1
        MOV [CS:OFFSET DIRECT+1],AL
        MOV [CS:OFFSET COUNTER+1],AL

NOT_BEGIN:
        DEC BL
        CMP BL,BH
        JNZ DIRECT

PAUSE_FOR_EOL:
        MOV AL,9
        AND AL,AL
        JZ PAUSE_END

        DEC AL
        MOV [CS:OFFSET PAUSE_FOR_EOL+1],AL
        RET

PAUSE_END:
        MOV AL,9
        MOV [CS:OFFSET PAUSE_FOR_EOL+1],AL
        MOV AL,255
        MOV [CS:OFFSET DIRECT+1],AL

DIRECT:
        MOV AL,1                ;INDICATOR OF DIRECTION: 1 - RIGHT, FF-LEFT
        ADD CL,AL
        MOV [CS:OFFSET MAIN+2],CL
        RET

;=============================================================================

COUNTER:
        MOV AL,1                ;INDICATOR IF NEED TO MAKE ANOTHER LINE
        MOV SI,OFFSET ENDGRTS-2
        AND AL,AL
        JNZ $+3

        RET

        PUSH SI
        XOR CL,CL
        LODSB
        DEC SI
        CMP AL,0FFH
        JNZ COUNT_N_LET1

        MOV SI,OFFSET GREETS_TXT

COUNT_N_LET1:
        MOV [CS:OFFSET GREETS+1],SI

COUNT_N_LETTERS:
        LODSB
        INC CL
        AND AL,AL
        JNZ COUNT_N_LETTERS     ;CX = ό LETTERS
        MOV [CS:OFFSET MAIN+1],CL
        XOR AL,AL
        MOV [CS:OFFSET COUNTER+1],AL
        MOV [CS:OFFSET COUNTER+3],SI
        POP SI                  ;SI = BEGIN OF TXT
        RET

;=============================================================================

CURSOR:
        MOV AL,[CS:OFFSET INTS]
        AND AL,8
        JNZ $+3

        RET

        ADD DI,320*5
        MOV EAX,0F0F0F0FH
        STOSD
        RET

;=============================================================================

COUNT:
        MOV AL,0
INTS    EQU COUNT+1
        INC AL
        MOV [CS:OFFSET COUNT+1],AL
        RET

;=============================================================================

GREETS:
        MOV SI,OFFSET GREETS_TXT
        MOV DI,320*194
        AND CL,CL
        JNZ $+3

        RET

        XOR EAX,EAX
GREET1:
        XOR AH,AH
        LODSB
        CMP AL,20H
        JNZ NOT_SPACE

        ADD DI,4
        DEC CL
        JNZ $+3

        RET

        JMP GREET1

NOT_SPACE:

        PUSH CX
        PUSH DI
        PUSH SI
        SUB AL,'A'              ;DI = DEST, AL=SYMB
        ROL AL,3
        ADD AX,OFFSET SMALLF

        MOV SI,AX
        MOV CX,5
        LODSB
        MOV BL,AL
        MOV BH,0

PRN1:   PUSH CX
        PUSH DI
        LODSB
        MOV CX,BX

PRN2:   RCL AL,1
        JNC NO_BIT

        MOV AH,15
        MOV [ES:DI],AH

NO_BIT:
        INC DI
        LOOP PRN2

        POP DI
        POP CX
        ADD DI,320
        LOOP PRN1
        POP SI
        POP DI
        ADD DI,BX
        POP CX
        LOOP GREET1
        RET

;=============================================================================

ZIGZAG:
        MOV BX,0
        MOV CX,312
        DEC BL                  ;SPEED OF ZIGZAG
        MOV [CS:OFFSET ZIGZAG+1],BL
        MOV SI,OFFSET LINE_BUFFER

ZIG2:
        PUSH CX
        PUSH BX
        PUSH SI
        ADD BX,OFFSET SINUS
        XOR EAX,EAX
        MOV AL,[CS:BX]
        ADD AL,90
        MOV BX,320
        MUL BX
        ADD AX,312
        SUB AX,CX
        MOV CX,8
        MOV BX,319
        MOV DI,AX
        MOV AL,02
        STOSB
        ADD DI,BX
        XOR AL,AL
        STOSB

ZIG1:
        MOVSB
        ADD DI,BX
        DEC SI
        MOVSB
        sub DI,BX

        ADD DI,BX
        ADD SI,BX
        LOOP ZIG1

        DEC DI                  ;WHY?! 8-|
        MOV AL,2
        STOSB
        ADD DI,BX
        XOR AL,AL
        STOSB

        POP SI
        POP BX
        POP CX
        INC BL                  ;SPEED OF SINUS
        INC SI
        LOOP ZIG2
        RET

;=============================================================================

ZIGZA1:
        MOV BX,0
        MOV CX,320
        INC BL                  ;SPEED OF ZIGZAG
        INC BL
        MOV [CS:OFFSET ZIGZA1+1],BL
        MOV SI,OFFSET LINE_BUFFER

ZI12:
        PUSH CX
        PUSH BX
        PUSH SI
        ADD BX,OFFSET SINUS
        XOR EAX,EAX
        MOV AL,[CS:BX]
        ADD AL,90
        MOV BX,320
        MUL BX
        ADD AX,320
        SUB AX,CX
        MOV CX,8
        MOV BX,319
        MOV DI,AX
        MOV AL,02
        STOSB
        ADD DI,BX
        XOR AL,AL
        STOSB
        DEC DI

ZI11:
        MOVSB
        ADD DI,BX
        DEC SI
        MOVSB

        ADD DI,BX
        ADD SI,BX
        LOOP ZI11

        DEC DI                  ;WHY?! 8-|
        MOV AL,2
        STOSB
        ADD DI,BX
        XOR AL,AL
        STOSB

        POP SI
        POP BX
        POP CX
        INC BL                  ;SPEED OF SINUS
        INC SI
        LOOP ZI12
        RET

;=============================================================================

ROTAT:
        MOV BX,254                     ;rOTATIN'
        INC BL
        INC BL
        MOV [CS:OFFSET ROTAT+1],BL
        ADD BX,OFFSET SINUS
        XOR EAX,EAX
        MOV AL,[CS:BX]
        ADD AL,100
        MOV BX,320
        MUL BX
        MOV DI,AX
        JMP PTBL

;=============================================================================

JUMP:
        MOV BX,0FFH                     ;jUMPIN'
        INC BL
        AND BL,7FH
        MOV [CS:OFFSET JUMP+1],BL
        ADD BX,OFFSET SINUS
        XOR EAX,EAX
        MOV AL,[CS:BX]
        NEG AL
        MOV BL,2
        IMUL BL
        ADD AX,164
        MOV BX,320
        MUL BX
        MOV DI,AX

PTBL:
        MOV CX,320/4
        MOV EAX,02020202H
        REP STOSD
        MOV CX,320/4
        XOR EAX,EAX
        REP STOSD

        MOV SI,OFFSET LINE_BUFFER
        MOV CX,320*8/4
        REP MOVSD
        MOV CX,320/4
        XOR EAX,EAX
        REP STOSD

        MOV CX,320/4
        MOV EAX,02020202H
        REP STOSD
        RET

;=============================================================================

LINE_BUFFER:
        DB 320*8 DUP (?)

;=============================================================================

SCROLL:
        MOV SI,OFFSET TEXT-1    ;LETTER NUMBER
        MOV BL,9                ;OFFSET TO PIXEL
        INC BL
        CMP BL,9
        JC NOT_END_OF_SYMB

        MOV BL,1                ;END OF SYMB
        INC SI

NOT_END_OF_SYMB:
        XOR EAX,EAX
        LODSB
        DEC SI

        AND AL,AL
        JNZ NOT_END_OF_LINE

        MOV SI,OFFSET TEXT      ;END OF LINE
        MOV AL,[CS:SI]          ;’…‘’ „‹†…H ›’! 8-|

NOT_END_OF_LINE:
        MOV [CS:OFFSET SCROLL+1],SI
        MOV [CS:OFFSET SCROLL+4],BL
        ROL AX,3                ;AX * 8
        ADD AX,OFFSET FONT      ;NOW AX = NUMB OF FIRST LETTER BYTE
        MOV SI,AX

        PUSH ES
        PUSH CS
        POP ES
        MOV CX,8
        MOV DI,OFFSET LINE_BUFFER

LETTER:
        PUSH CX
        CALL SCR_TXT_LF
        LODSB
        MOV CL,BL
        RCL AL,CL
        MOV AL,13               ;INK
        JC PRESENT

        XOR AL,AL               ;NOT PRESENT

PRESENT:
        STOSB
        POP CX
        LOOP LETTER
        POP ES
        RET

;=============================================================================
SCR_TXT_LF:
        PUSH SI
        MOV SI,DI
        INC SI
        MOV CX,320/4
        REP MOVSD
        POP SI
        DEC DI
        RET                     ;NOW DI=LAST BYTE OF 320

;=============================================================================
WAIT_RETRACE:
    mov     dx,3dah
Vrt:
    in      al,dx
    test    al,8
    jnz     VRT                 ; Wait until Verticle Retrace starts
NoVrt:
    in      al,dx
    test    al,8
    jz      NoVRT               ; Wait until Verticle Retrace ends
    ret                         ; Return to main program

;=============================================================================
CLEAR:
        PUSHA
        XOR DI,DI
        MOV CX,320*200/4
        XOR EAX,EAX
        REP STOSD
        POPA
        RET

;=============================================================================
; In:  AX - Range
; Out: AX - Value within 0 through AX-1
; Destroys: All ?X and ?I registers
RANDSEED:
                DD 0

RANDOM:
                PUSH CX
                PUSH DI
                mov      cx,ax          ; save limit
                mov      ax,[cs:OFFSET RandSeed+2]
                mov      bx,[cs:OFFSET RandSeed]
                mov      si,ax
                mov      di,bx
                mov      dl,ah
                mov      ah,al
                mov      al,bh
                mov      bh,bl
                xor      bl,bl
                rcr      dl,1
                rcr      ax,1
                rcr      bx,1
                add      bx,di
                adc      ax,si
                add      bx,62e9h
                adc      ax,3619h
                mov      [cs:OFFSET RandSeed],bx
                mov      [cs:OFFSET RandSeed+2],ax
                xor      dx,dx
                div      cx
                mov      ax,dx                  ; return modulus
                POP DI
                POP CX
                ret

;=============================================================================

TEXT:
        INCLUDE 'TEXT.INC'
        DB 0

GREETS_TXT:
        INCLUDE 'GREETS.INC'
ENDGRTS:
        DB 0FFH

        INCLUDE 'DMABMP.INC'

FONT:
        INCLUDE 'DEMOFNT.INC'
SINUS:
        INCLUDE 'SINTABLE.INC'
SMALLF:
        INCLUDE 'SMALL2.INC'

        INCLUDE 'PWMETC.INC'
PWMETC:

PRIKOL:
        DB 'Runtime error at 1827:2648',0Dh,0Ah,'This program requires Microsoft Windows 98.'
        DB 0DH,0AH,0DH,0AH,'C:\>','$'
PRIKOL1:
        DB 'ƒλλλλ ¨α―y£ «¨αμ? ;-)$'

STARS_DATA:
        DW 333 DUP (?)   ;‘ H€“—“‘ ‘€ ‘‡„€‚€’ ‹€‘’ €’ „
        DB 333 DUP (?)   ;‘‚ H“†„›

STACK   200H
END START
