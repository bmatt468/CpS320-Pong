; Program: PONG - Graphics mode.
; Author: Benjamin Matthews
; Date: 12/9/2011
; Runs in real mode. Uses Irvine Library
; Bugs that are known to me: (hope you're ready for this Dr. Lovegrove)
; 1) Code is extremely complex to most. I usually tend to stick to
;    methods in higher languages, so I tried to incorporate that here.
;
; 2) When ball is moving across the screen, it is extremely laggy. Spent a
;    fair amount of time trying to figure it out to no avail.

; 3) When pressing "f" or "s" too rapidly, the program freezes.
;
; 4) When ball is missed, sometimes the circle is drawn above or below the ball rather than around.

.model small
.stack 100h

.data
color WORD 2h
losercolor WORD 4h
key BYTE ?
newgame BYTE 0
.code
main proc
    mov ax,@data                    ; Gain access to data segment
    mov ds,ax

    call prep                       ; Sets game to graphics mode

    cmp [newgame], 0
    je printscreen

    awaywego:
    mov [newgame], 1
    mov [row], 0                    ; Preps cursor
    mov [column],0                  ; Preps cursor
    mov [ballrow], 13               ; Preps ball
    mov [ballcolumn], 40            ; Preps ball
    call setcursor                  ; Sets cursor
    call gameboard                  ; Draws gameboard
    call scoreboard
    call printpaddles               ; Prints paddles

    play:                           ; Start of game loop
    call printball
    call delay
    call scoreboard
    jmp play                        ; Continue playing

    printscreen:
    call splashscreen
    jmp awaywego
main endp

;---------------------------
prep proc
; Sets video mode and hides cursor
; Requires: Nothing
; Returns: Video mode
;---------------------------
    mov ah, 0
    mov al, 3
    int 10h

    ; The following lines of code are borrowed from
    ; Irvine's "HideCursor PROC" (page 504). I claim no
    ; credit for the following 5 lines.
    mov ah, 3
    int 10h
    or ch, 30h
    mov ah,1
    int 10h
ret
prep endp

;---------------------------------------
gameboard proc
; Draws a gameboard on the screen
; Receives: Nothing
; Returns: Gameboard on screen
; Requires: Nothing
;---------------------------------------
push ax                             ; Avoid register tampering
push bx
push cx
push dx

; Begin top left corner
mov ah, 9                           ; Set INT10h function to write
mov bx, [color]                     ; Set color of text
mov cx, 1                           ; Only need one
mov al, 0C9h                        ; Declare which ASCII character to use
int 10h

inc [column]                        ; Prep for rest of board
call setcursor

; Begin top bar
mov al, 0CDh                        ; Get ASCII character
mov cx, 78                          ; Repeat for entire length of gameboard
int 10h

; Begin top right corner
mov [column], 79                    ; Set column spot
call setcursor
mov al, 0BBh                        ; Get character
mov cx, 1                           ; Only need one
int 10h

; Begin left side
mov cx, 20                          ; Set loop counter for 23 rows
mov [row], 1                        ; Set starting row
mov [column], 0                     ; Set column
mov al, 0BAh                        ; Set character
call setcursor

ls:
push cx                             ; Push CX so INT10h doesn't improperly repeat
mov cx, 1                           ; Need one
int 10h
inc [row]                           ; Increase row and reset cursor
call setcursor
pop cx
loop ls

; Begin right side
mov cx, 20                          ; Set loop counter for 23 rows
mov [row], 1                        ; Set starting row
mov [column], 79                    ; Set column
mov al, 0BAh                        ; Set character
call setcursor

rs:
push cx                             ; Push CX so INT10h doesn't improperly repeat
mov cx, 1                           ; Need one
int 10h
inc [row]                           ; Increase row and reset cursor
call setcursor
pop cx
loop rs

; Begin bottom left corner
mov [row], 20                       ; Set starting row
mov [column], 0                     ; Set column
call setcursor
mov cx, 1                           ; Only need one
mov al, 0C8h                        ; Declare which ASCII character to use
int 10h

; Begin bottom bar
inc [column]
call setcursor
mov al, 0CDh                        ; Get ASCII character
mov cx, 78                          ; Repeat for entire length of gameboard
int 10h

; Begin bottom right corner
mov [column], 79                    ; Set column spot
call setcursor
mov al, 0BCh                        ; Get character
mov cx, 1                           ; Only need one
int 10h

pop dx                              ; Restore data
pop cx
pop bx
pop ax

ret
gameboard endp

;------------------
splashscreen proc
; Draws splash screen on gameboard
;-----------------
.data
Intro BYTE "PONG! successfully written by Allan Alcorn in 1972."
Intro2 BYTE "Successfully mutilated and alltogether destroyed by Benjamin Matthews in 2011."
Intro3 BYTE "Mr. Matthews would like to apologize to Mr. Alcorn for the disgrace"
Intro4 BYTE "that he has made of his game."
Controls BYTE "Controls:"
LeftPaddle BYTE "Left paddle: Q & A"
RightPaddle BYTE "Right paddle: P & L"
BallSpeed BYTE "Control ball speed: F & S"
Startthegame BYTE "Press any key to begin."
.code
mov ax, SEG Intro                   ; set ES setment
mov es, ax
mov dh, 5                           ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Intro
mov bp, OFFSET Intro                ; Get offset
int 10h

mov ax, SEG Intro2                  ; set ES setment
mov es, ax
mov dh, 6                           ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Intro2
mov bp, OFFSET Intro2               ; Get offset
int 10h

mov ax, SEG Intro3                  ; set ES setment
mov es, ax
mov dh, 7                           ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Intro3
mov bp, OFFSET Intro3               ; Get offset
int 10h

mov ax, SEG Intro4                  ; set ES setment
mov es, ax
mov dh, 8                           ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Intro4
mov bp, OFFSET Intro4               ; Get offset
int 10h

mov ax, SEG Controls                ; set ES setment
mov es, ax
mov dh, 10                          ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Controls
mov bp, OFFSET Controls             ; Get offset
int 10h

mov ax, SEG LeftPaddle                  ; set ES setment
mov es, ax
mov dh, 11                          ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF LeftPaddle
mov bp, OFFSET LeftPaddle               ; Get offset
int 10h

mov ax, SEG RightPaddle                 ; set ES setment
mov es, ax
mov dh, 12                          ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF RightPaddle
mov bp, OFFSET RightPaddle              ; Get offset
int 10h

mov ax, SEG BallSpeed                   ; set ES setment
mov es, ax
mov dh, 13                          ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF BallSpeed
mov bp, OFFSET BallSpeed            ; Get offset
int 10h

mov ax, SEG Startthegame            ; set ES setment
mov es, ax
mov dh, 15                          ; Set row num
mov dl, 2                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, SIZEOF Startthegame
mov bp, OFFSET Startthegame             ; Get offset
int 10h

mov ah, 1
int 21h
mov [row], 5                        ; Set cursor at beginning of splash screen
mov [column], 2
call setcursor
mov cx, 11
erase:                              ; Erase intro
mov ah, 0AH
mov al, 20h
push cx                             ; Save loop counter
mov cx, 80                          ; Set repetitions
int 10h
pop cx                              ; Restore loop counter
inc [row]
mov [column], 1
call setcursor
loop erase
ret
splashscreen endp

;------------------
scoreboard proc
; Draws scoreboard at bottom of screen
; Receives data from variables
; Returns scoreboard on screen
;------------------
.data
player1score BYTE 0
player2score BYTE 0
p1 BYTE "Player 1: "
p2 BYTE "Player 2: "
.code
; The following lines of code were adapted from
; Irvine's sameple INT 10h Function 13h (p. 509)
mov ax, SEG p1                      ; set ES setment
mov es, ax
mov dh, 23                          ; Set row num
mov dl, 1                           ; Set column number
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, (SIZEOF p1)
mov bp, OFFSET p1                   ; Get offset
int 10h

mov ah, 9                           ; Print left score
mov al, [player1score]
or al, 30h                          ; Convert to ASCII
mov cx, 1
int 10h


mov ax, SEG p2                      ; Same as code above
mov es, ax
mov dh, 23
mov dl, 65
mov al, 1
mov ah, 13h
mov bx, [color]
mov cx, (SIZEOF p2)
mov bp, OFFSET p2
int 10h

mov ah, 9                           ; Print right score
mov al, [player2score]
or al, 30h                          ; Convert to ASCII
mov cx, 1
int 10h

ret
scoreboard endp

;--------------
playtime proc
; Plays the game
;--------------

push dx                         ; Avoid any chance of tampering with registers
push ax
mov ax, 0                       ; Prep AX for INT21h function. (AH is function & AL is character)
mov ah, 6                       ; Set INT21h function
mov dl, 0FFh                    ; Set AH 6 function to no-wait read
int 21h
mov [key], al
pop ax
pop dx
ret
playtime endp

;------------------------
setcursor proc
; Set the cursor position on the screen
; Receives: [row] and [column]
; Returns: Cursor spot
; Requires: Nothing
;------------------------

.data
row BYTE ?
column BYTE ?
.code
push dx                             ; Save register
push ax
    mov dh, [row]                   ; Move into dh new row number
    mov dl, [column]                ; Move into dl new column number
    mov ah, 2                       ; Set INT10h function
    int 10h
pop ax                              ; Restore data
pop dx
ret
setcursor endp

;----------------------------
printpaddles proc
; Just a shortcut to quick print paddles. Nothing special here
;----------------------------
    call plp
    call prp
    ret
printpaddles endp

;----------------------------
plp proc
; Prints left paddle on screen
; Uses [lprow] and [lpcolumn] for spot on screen to print
;----------------------------
.data
lprow BYTE 2
lpbrow BYTE 7
lpcolumn BYTE 2
.code
    push cx
    mov cl, [lprow]

    push dx                         ; Data save
    mov dh, [lprow]                 ; Since can't do mem, mem moves, pass it thru DX
    mov dl, [lpcolumn]
    mov [row], dh
    mov [column], dl
    pop dx                          ; Restore
    call setcursor

    dothis:
    push ax                         ; Save
    mov ah, 9                       ; Set function
    mov al, 0DEh                    ; Set character
    mov bx, [color]                 ; Set color
    push cx                         ; Save for repeats
    mov cx, 1                       ; Only need one
    int 10h
    pop cx                          ; Restore
    pop ax
    inc cl
    cmp cl, [lpbrow]                ; If current row drawn does not equal bottom row
    jne dothisfirst                 ; Then continue to draw.
    je done

    dothisfirst:                    ; Sets next row for drawing
    inc [row]
    call setcursor
    jmp dothis

done:
pop cx
ret
plp endp

;---------------------------
elp proc
; Erases the left paddle from the screen
; Receives nothing
; Returns new paddle spot
;---------------------------
    mov cx, 5                       ; Set loop counter

    mov dh, [lprow]                 ; Set cursor to top row of paddle
    mov dl, [lpcolumn]
    mov [row], dh
    mov [column], dl
    call setcursor

    eraseleft:                      ; Erases old paddle by inserting space
    push cx
    mov ah, 0Ah
    mov al, 20h
    mov bh, 0
    mov cx, 1
    int 10h
    inc [row]                       ; Moves to next row to erase
    call setcursor
    pop cx
    loop eraseleft
ret
elp endp

;----------------------------
prp proc
; This procedure prints the right paddle
; Receives: data from its variables
; Returns paddle on screen
;----------------------------
.data
rprow BYTE 2
rpbrow BYTE 7
rpcolumn BYTE 77
.code

    push cx                         ; Data save
    mov cl, [rprow]                 ; Move into CL top row of paddle. CL will be used to
                                    ; Compare to bottom of paddle later in procedure.
    push dx                         ; Data save
    mov dh, [rprow]                 ; Following lines set the cursor to where paddle will be printed
    mov dl, [rpcolumn]
    mov [row], dh
    mov [column], dl
    pop dx
    call setcursor

    dothisagain:
    push ax                         ; Data save
    mov ah, 9                       ; Prep INT 10h function (Write character and attribute)
    mov al, 0DDh                    ; Set character
    mov bx, [color]
    push cx                         ; Save counter to set repetition number
    mov cx, 1
    int 10h
    pop cx                          ; Restore counter
    pop ax                          ; Restore data
    inc cl                          ; Increment counter
    cmp cl, [rpbrow]                ; If counter equals bottom row, drawing is complete
    jne dothisfirstagain
    je rpdone

    dothisfirstagain:               ; Set cursor on next row to draw
    inc [row]
    call setcursor
    jmp dothisagain

rpdone:
pop cx                              ; Data restore
ret
prp endp

;--------------------------------
erp proc
; Erases right paddle from the screen
; Receives data from [rprow] and [rpbrow]
; Returns erased paddle
;--------------------------------
    mov cx, 5

    mov dh, [rprow]                 ; Set cursor to the top of paddle
    mov dl, [rpcolumn]
    mov [row], dh
    mov [column], dl
    call setcursor

    eraseright:
    mov ah, 0Ah                     ; Fill the paddle with spaces
    mov al, 20h
    mov bh, 0
    push cx
    mov cx, 1
    int 10h
    inc [row]
    call setcursor
    pop cx
    loop eraseright
ret
erp endp

;--------------------------------
printball proc
; Erases and Prints the game ball on the screen
; Reveives: cursor posion
; Returns ball on screen
;--------------------------------
.data
ballrow BYTE ?
ballcolumn BYTE ?
.code

mov dh, [ballrow]               ; Following lines move data from the ball
mov dl, [ballcolumn]            ; position variable to the SetCursor procedure's
mov [row], dh                   ; vairables. After the move, the cursor is set to
mov [column], dl                ; Where the ball needs to be printed.
call setcursor

call moveball                   ; Moves the ball to its next location

mov ah, 9                       ; Prints the ball at new location via INT 10h function
mov al, 2h
mov bx, [color]
mov cx, 1
int 10h

mov [row], dh                   ; Sets cursor at old ball posiition
mov [column], dl
call setcursor

mov ah, 9                       ; Erases old ball
mov al, 20h                     ; (Note: The reason for erasing after printing was
mov bx, 0                       ; to help with the lagginess. Though there is still
mov cx, 1                       ; a substantial amount of lag, its not as bad as it
int 10h                         ; was otherwise)

ret
printball endp

;--------------------------
moveball proc
; Moves gameball around the screen
; Revieves nothing
; Returns new cursor location to print ball
;--------------------------
.data
updown BYTE 1
leftright BYTE 1
restart BYTE "Press any key to continue...."
.code

cmp [updown], 1                 ; Determines which direction the ball needs to head
jne up

down:
mov [updown], 1                 ; Set updown variable to 1 to pass above test.
cmp [ballrow], 19               ; Checks to see if ball is at the bottom of playing field
je up                           ; If so then reverses direction.
inc [ballrow]                   ; Otherwise contines to move in the same direction.
push dx
mov dh, [ballrow]
mov [row], dh
call setcursor
pop dx
jmp lr                          ; After updown cursor is set, move to leftright

up:
mov [updown], 0                 ; Move 0 to updown in order to fail compare at top of procedure
cmp [ballrow], 1                ; If hit top of gamescreen the reverse
je down
dec [ballrow]                   ; Move row cursor to row above
push dx
mov dh, [ballrow]
mov [row], dh
call setcursor
pop dx


lr:
cmp [leftright], 1              ; Initial test to see if moving left or right
jne left

right:
mov [leftright], 1
cmp [ballcolumn], 76            ; If at far right of screen check to see if paddle is there
je rphitcheck
inc [ballcolumn]                ; Move cursor right
push dx
mov dl, [ballcolumn]
mov [column], dl
call setcursor
pop dx
jmp procend

left:
mov [leftright], 0
cmp [ballcolumn], 3             ; If at far left of screen, check for paddle
je lphitcheck
dec [ballcolumn]                ; Move cursor left
push dx
mov dl, [ballcolumn]
mov [column], dl
call setcursor
pop dx
jmp procend

lphitcheck:                     ; Checks to see if ball hit paddle
push ax
mov al, [lprow]
cmp [ballrow], al               ; Check to see if ball is below top of paddle.
jb gameendleft                  ; If not missed

mov al, [lpbrow]                ; Checks to see if ball is above bottom of paddle.
cmp [ballrow], al               ; If not then missed
ja gameendleft
pop ax
jmp right                       ; If so then contact made

rphitcheck:                     ; Same logic as code directly above.
push ax
mov al, [rprow]
cmp [ballrow], al
jb gameendright

mov al, [rpbrow]
cmp [ballrow], al
ja gameendright
pop ax
jmp left


gameendright: ; Sets the game ending for the right side
push bx       ; Prevent override of important data
push cx

inc [column] ; Moves ball to far right of screen
call setcursor
mov ah, 9
mov al, 2
mov bx, [losercolor]
mov cx, 1
int 10h

dec [row]       ; Following lines draw a red circle (well square..) around the game ball.
call setcursor
int 10h

dec [row]
call setcursor
int 10h

dec [column]
call setcursor
int 10h

dec [column]
call setcursor
int 10h

inc [row]
call setcursor
int 10h

inc [row]
call setcursor
int 10h

inc [column]
call setcursor
int 10h

inc [player1score]

pop cx
pop bx
pop ax                      ; Pop AX back from push in rphitcheck

jmp gamerestart

gameendleft: ; Sets the game ending for the left side
push bx       ; Prevent override of important data
push cx

inc [column] ; Moves ball to far right of screen
call setcursor
mov ah, 9
mov al, 2
mov bx, [losercolor]
mov cx, 1
int 10h

inc [row]       ; Following lines draw a red circle (well square..) around the game ball.
call setcursor
int 10h

inc [row]
call setcursor
int 10h

dec [column]
call setcursor
int 10h

dec [column]
call setcursor
int 10h

dec [row]
call setcursor
int 10h

dec [row]
call setcursor
int 10h

inc [column]
call setcursor
int 10h

inc [player2score]

pop cx
pop bx
pop ax                      ; Pop AX back from push in lphitcheck

gamerestart:
mov ax, SEG restart                 ; set ES setment
mov es, ax
mov dh, 15                          ; Set row num
mov dl, 30                          ; Set column number
mov al, 1
mov ah, 13h
mov bx, [losercolor]
mov cx, (SIZEOF restart)
mov bp, OFFSET restart              ; Get offset
int 10h

mov ah, 1
int 21h
call main                           ; Restart program

procend:
ret
moveball endp

;--------------------------------
delay proc
; Creates a loop to delay the program so user
; can actually see whats going on.
; Recieves nothing
; Returns nothing
;--------------------------------
.data
delaytime WORD 30
.code
push cx
mov cx, [delaytime]         ; Set loop iterations (can be set by user)
delaytop:
push cx
mov cx, 1FFFh
innerloop:
call playtime               ; Allows for paddle to move even during ball delay
call keycheck
loop innerloop
pop cx
loop delaytop

pop cx
ret
delay endp

;--------------------------------
keycheck proc
; Determins whether or not a key is a valid command
; If so, executes that command
; Receives key from [key]
; Returns variety of commands
; Requires nothing
;-------------------------------
    mov al, [key]

    cmp al, 1Bh
    je quit

    or al, 20h

    cmp al, "a"
    je lpd

    cmp al, "q"
    je lpu

    cmp al, "l"
    je rpd

    cmp al, "p"
    je rpu

    cmp al, "f"
    je faster

    cmp al, "s"
    je slower
    jne cont

    lpd:                    ; Left paddle down
    cmp [lpbrow], 20
    je cont
    call elp
    inc [lprow]
    inc [lpbrow]
    call plp
    jmp cont

    lpu:                    ; Left paddle up
    cmp [lprow], 1
    je cont
    call elp
    dec [lprow]
    dec [lpbrow]
    call plp
    jmp cont

    rpd:                    ; Right paddle down
    cmp [rpbrow], 20
    je cont
    call erp
    inc [rprow]
    inc [rpbrow]
    call prp
    jmp cont

    rpu:                    ; Right paddle down
    cmp [rprow], 1
    je cont
    call erp
    dec [rprow]
    dec [rpbrow]
    call prp
    jmp cont

    faster:                 ; Faster
    sub [delaytime], 2
    jmp cont

    slower:                 ; Slower
    add [delaytime], 2
    jmp cont

quit:
.exit

cont:
ret
keycheck endp
End main
