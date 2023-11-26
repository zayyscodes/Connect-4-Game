INCLUDE Irvine32.inc

.data
    welcome BYTE "Welcome to Connect Four Game!", 0
    rule1 BYTE "RULE #1: Players will take turns one after another.", 0
    rule2 BYTE "RULE #2: Players should make a sequence of 4 of their respective keys (1 or 2)", 0
    rules BYTE " R U L E S :", 0
    begin BYTE "Let the game begin!", 0
    over BYTE "Game Over!", 0
    promptp BYTE "Select a column from 1 to 7:", 0
    selected BYTE "You selected: ", 0
    colFullprompt BYTE "Column is Full !",0
    invalidprompt BYTE "Invalid Move!",0
    drawprompt BYTE "This Game Is A Draw ! ",0
    p1Move BYTE "Player 1: ",0
    p2Move BYTE "Player 2: ",0
    promptname BYTE "WHO'S PLAYING?", 0
    nameget BYTE "Enter name for ", 0
    colons BYTE ": ", 0
    bufferSize DWORD 15
    p1 BYTE 15 DUP(?)
    p2 BYTE 15 DUP(?)
    winner BYTE 15 DUP(?)
    playerinput dword 0
    validMove dword 0
    playerNoMove BYTE 1 
    vs BYTE " vs. ", 0
    colno byte " 1 2 3 4 5 6 7",0
    BELOWLINE byte "---------------",0
    vFlag BYTE 0 
    moves SDWORD 7 dup(-2)
    winnmsg BYTE " wins!", 0
    msg_no_winner db "No winner found.",0
    rows  = 6
    cols = 7
    win = 4

    empty = 0
    board dword rows*cols dup(0)
    copy dword rows*cols dup(0)

.code
main PROC
    mov edx, OFFSET welcome
    CALL writeString
    CALL Crlf
    CALL Crlf
    mov edx, OFFSET promptname
    CALL WriteString
    CALL Crlf
    mov edx, OFFSET nameget
    CALL WriteString
    mov edx, OFFSET p1Move
    CALL WriteString
    mov edx, OFFSET p1
    mov ecx, bufferSize
    CALL readString  ;  get player 1's name
    mov edx, OFFSET nameget
    CALL WriteString
    mov edx, OFFSET p2Move
    CALL WriteString
    mov edx, OFFSET p2
    mov ecx, bufferSize
    CALL readString  ;  get player 2's name

    CALL playGame
main ENDP


Display PROC Uses esi ecx edi ebx eax
    CALL clrscr
    CALL Crlf
    mov edx, OFFSET rules
    CALL writeString
    CALL Crlf
    mov edx, OFFSET rule1
    CALL writeString
    CALL Crlf
    mov edx, OFFSET rule2
    CALL writeString
    CALL Crlf
    CALL Crlf
    mov edx, OFFSET p1
    CALL writeString
    mov edx, OFFSET vs
    CALL writeString
    mov edx, OFFSET p2
    CALL writeString
    CALL Crlf
    CALL Crlf
    mov esi, 0    ;  saving index of rows
    mov ecx, rows
    l1:
    push ecx
    mov edi, 0   ; index of column
    mov al, '|'    ; printing space after each  value
    CALL writechar
    mov ecx, cols
        l2:
            mov eax, cols ;  Index = row * columns + col
            mul esi  
            add eax, edi
            mov ebx, eax  ; index of element
            mov eax, board[4*ebx]    ; print the value the array index holds
            cmp eax, 0
            jne skipp
            mov al, ' '
            CALL writechar
            jmp nextt
            skipp:
            CALL writedec
            nextt:
            mov al, '|'    ; printing space after each  value
            CALL writechar
            inc edi

        loop l2

    CALL Crlf
    inc esi
    pop ecx
    loop l1

    lea edx,BELOWLINE
    CALL writeString
    CALL Crlf
    mov edx, offset colno
    CALL writeString

    ret
Display ENDP


generateMoves PROC uses eax ebx ecx edx esi edi
    mov esi, 140    ;  saving index of rows
    mov ecx, cols
    mov ebx, empty
    mov edi, 0
    c1:
    push ecx
    mov ecx, rows
    mov edx, esi
        c2:
            cmp ebx, board[edx]
            jne continue
            mov moves[edi], edx
            
            jmp nextt
            continue:
            sub edx,28  ; move to previous row if place not empty

        loop c2
    mov moves[edi], -1
    nextt:
    add edi, 4
     ; CALL Crlf
    add esi, 4
    pop ecx
    loop c1
    ret
generateMoves ENDP
    
playGame PROC
    CALL Display
    XX:  ; infine loop for player inputs 
    CALL playermove
    CALL Display
    mov ebx, 1
    CALL checkVerticalWin
    CALL checkHorizontalWin
    CALL checkRightDiagonalWin
    CALL checkLeftDiagonalWin
    CALL isDraw
    CALL player2move
    CALL Display
    mov ebx, 2
    CALL checkVerticalWin
    CALL checkHorizontalWin
    CALL checkRightDiagonalWin
    CALL checkLeftDiagonalWin
    CALL isDraw
    jmp XX
    ret
PlayGame ENDP


isDraw PROC uses eax edx ecx ebx esi edi
    mov ebx,0  ; works for index 
    mov esi,-1
    mov ecx , 7  ;  run loop till length of moves array 
    drawLoop:
    cmp moves[ebx],esi   ; compare each value in moves array with -1 (if true means its a draw)
    jne notdraw   ; if value founnd doesnt equal to -1 then its not a draw 
    add ebx,4  ; else if val == -1 then iterate to next index 
    loop drawLoop
    draw:   ; if complete array is traversed and equals to -1 , its a draw 
    CALL Crlf 
    CALL Display
    lea edx,drawprompt
    CALL Crlf 
    CALL writeString
    exit 
    notdraw:   ; not a draw , as moves can be made .So just carry on
    ret
isDraw ENDP


playermove PROC uses eax edx ecx ebx esi edi
    mov eax,0
    takeinput:  ; take infinite input incase (to deal with wrong input )
    mov playerNoMove,1   ; variable states that its player 1 move 
    CALL Crlf
    mov validMove,0
    lea edx, promptp  ; player move prompt
    CALL writeString
    CALL Crlf 
    CALL Crlf
    lea edx, p1
    CALL writeString
    lea edx, colons
    CALL writeString
    mov eax,0  ;  intialize eax
    CALL Readdec   ; taking player input
    mov playerinput, eax  ; store player input in variable
    CALL checkColumn  ; check where to insert move 
    CALL isDraw         
    cmp validMove,1  ; if the move made by player was valid, stop infinte input else take input again
    je outsideloop
    jmp takeinput

    outsideloop:
    ret
playermove ENDP
 

player2move PROC 
    mov eax,0
    takeinput2:  ; take infinite input incase (to deal with wrong input )
    mov playerNoMove,2
    CALL Crlf
    mov validMove,0
    lea edx, promptp  ; player move prompt
    CALL writeString
    CALL Crlf 
    CALL Crlf
    lea edx, p2
    CALL writeString
    lea edx, colons
    CALL writeString
    mov eax,0  ;  intialize eax
    CALL Readdec   ; taking player input
    mov playerinput, eax  ; store player input in variable
    CALL checkColumn
    CALL isDraw
    cmp validMove,1  ; if the move made by player was valid, stop infinte input else take input again
    je outsideloop2
    jmp takeinput2

    outsideloop2:
    ret
player2move ENDP


checkColumn  PROC uses eax edx ecx ebx esi edi
    mov ebx,0
    mov eax, playerinput  ; register holds input
   
    cmp eax ,1  ;  checking if input lies in column 1 range and so on  (0-6)
    je col1
    cmp eax ,2  ;  checking if input lies in column 1 range and so on  (0-6)
    je col2
    cmp eax ,3  ;  checking if input lies in column 1 range and so on  (0-6)
    je col3
    cmp eax ,4  ;  checking if input lies in column 1 range and so on  (0-6)
    je col4
    cmp eax ,5  ;  checking if input lies in column 1 range and so on  (0-6)
    je col5
    cmp eax ,6  ;  checking if input lies in column 1 range and so on  (0-6)
    je col6
    cmp eax ,7  ;  checking if input lies in column 1 range and so on  (0-6)
    je col7

    lea edx,invalidprompt  ;  if no input was made btw 1-7 , inform player about invalid input
    CALL writeString
    ret

    col1:
    mov ebx,140  ; index for column
    jmp outt

    col2:
    mov ebx,144  ; index for column
    jmp outt

    col3:
    mov ebx,148  ; index for column
    jmp outt

    col4:
    mov ebx,152  ; index for column
    jmp outt

    col5:
    mov ebx,156  ; index for column
    jmp outt

    col6:
    mov ebx,160 ; index for column
    jmp outt

    col7:
    mov ebx,164 ; index for column
    jmp outt
   
    outt:
    mov ecx,6  ;  iterate on every row
    columncheckloop:
    mov edx , board[ebx]  ; index value move  
    cmp edx, empty  ; cmp with 0
    je markmove   ; mark respective players move if empty space is found 
    jne nexttt   ; carry on if space is not empty 
    markmove:
    cmp playerNoMove,1  ; check if its player 1 move 
    je m1  ; jump to m1 if its true 
    cmp playerNoMove,2  ;  check for 2nd player 
    je m2 
    m1:
    CALL MarkPlayer1Move
    CALL generateMoves
    ret  ; return after making move 
    m2:
    CALL MarkPlayer2Move
    CALL generateMoves
    ret      ; ret after making move 
    nexttt:
    sub ebx,28  ; move to previous row if place not empty
    loop columncheckloop
    CALL Crlf
    lea edx,colFullprompt  ; if column is full already , inform the player
    CALL writeString
 
    ret
checkColumn  ENDP


MarkPlayer1Move PROC 
    mov validMove,1  ; marking that move made was legal
    mov edx , 1
    mov board[ebx],edx  ; mark the move  with 1
    ret
MarkPlayer1Move ENDP


MarkPlayer2Move PROC 
    mov validMove,1  ; marking that move made was legal
    mov edx , 2
    mov board[ebx],edx  ; mark the move  with 2
    ret
MarkPlayer2Move ENDP


checkVerticalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,7  ; looping for all columns 

    mov edx,140  ; start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx  ;  preserving edx value 
    changeColumnLoop:

        mov ebx,ecx  ; save ecx val for nested loop 
        mov ecx , 3  ; loop 3 times 

        verticalcheck:  ;  loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player  ; check fill condition
        je checkmore   ; if value is 1 , look for 3 more 1s above it
        jmp nextIter
        checkmore:
        mov eax,board[edx-28] ; check 1 above 
        cmp eax,c_player
        je oneclear  ;  we need to clear 2 more for win
        jmp nextIter
        oneclear:
            mov eax,board[edx-56] ; check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp nextIter
                twoclear:
                mov eax,board[edx-84] ; check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp nextIter
                    winnerfound:
                        CALL Crlf 
                        CALL Crlf 
                        cmp c_player, 2
                        je p2wins
                        mov edx, OFFSET p1
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

                        p2wins:
                        mov edx, OFFSET p2
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

        nextIter:
        sub edx,28
        loop verticalcheck
        add esi,4  ; go to next column if no win in the previous column 
        mov edx,esi  ;  give that value to edx for upcoming iterations 
        mov ecx,ebx   ; maintaning outer loop value 
    dec ebx
    mov ecx, ebx
    cmp ecx, 0
    je exitfunc
    jmp changeColumnLoop

exitfunc:
    ret
checkVerticalWin ENDP


checkHorizontalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,6  ; looping for all rows 

    mov edx,140  ; start checking right  from last row of 1st col  (at first we start from here )
    mov esi,edx  ;  preserving edx value 
    changeRowLoop:

        mov ebx,ecx  ; save ecx val for nested loop 
        mov ecx , 4  ; loop 4 times 

        horizontalcheck:  ;  loop to traverse horizontally and check win condition 
        mov eax,board[edx]
        cmp eax,c_player  ; check fill condition (p1 or p2 move )
        je checkmore   ; if value is 1 , look for 3 more 1s to the right of it
        jmp nextIter
        checkmore:
        mov eax,board[edx+4] ; check 1 to the right  
        cmp eax,c_player
        je oneclear  ;  we need to clear 2 more for win
        jmp nextIter
        oneclear:
            mov eax,board[edx+8] ; check 2 to the right  
            cmp eax,c_player
            je twoclear 
            jmp nextIter
                twoclear:
                mov eax,board[edx+12] ; check 3 to the right  
                cmp eax,c_player
                je winnerfound
                jmp nextIter
                    winnerfound:
                        CALL Crlf 
                        CALL Crlf 
                        cmp c_player, 2
                        je p2wins
                        mov edx, OFFSET p1
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

                        p2wins:
                        mov edx, OFFSET p2
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

        nextIter:
        add edx,4  ; if condition fail , start assesing from its adjacent node
        loop horizontalcheck
        sub esi,28  ; go to above column if no win in the below column 
        mov edx,esi  ;  give that value to edx for upcoming iterations 
        XCHG ecx,ebx   ; maintaning outer loop value 
    dec ecx
    cmp ecx, 0
    je exitfunc
    jmp changeRowLoop

exitfunc:
    ret
checkHorizontalWin ENDP


checkRightDiagonalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,4  ; looping for all columns 

    mov edx,140  ; start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx  ;  preserving edx value 
    changeColumnLoop:
        push ecx
         ;  mov ebx,ecx  ; save ecx val for nested loop 
        mov ecx , 3  ; loop 3 times 

        Diagonalcheck:  ;  loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player  ; check fill condition
        je checkmore   ; if value is 1 , look for 3 more 1s above it
        jmp nextIter
        checkmore:
        mov eax,board[edx-24] ; check 1 above and 1 right
        cmp eax,c_player
        je oneclear  ;  we need to clear 2 more for win
        jmp nextIter
        oneclear:
            mov eax,board[edx-48] ; check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp nextIter
                twoclear:
                mov eax,board[edx-72] ; check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp nextIter
                    winnerfound:
                        CALL Crlf 
                        CALL Crlf 
                        cmp c_player, 2
                        je p2wins
                        mov edx, OFFSET p1
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

                        p2wins:
                        mov edx, OFFSET p2
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

        nextIter:
        sub edx,28
        loop Diagonalcheck
        add esi,4  ; go to next column if no win in the previous column 
        mov edx,esi  ;  give that value to edx for upcoming iterations 
         ;  mov ecx,ebx   ; maintaning outer loop value 
        pop ecx
    dec ebx
    mov ecx, ebx
    cmp ecx, 0
    je exitfunc
    jmp changeColumnLoop

exitfunc:
    ret
checkRightDiagonalWin ENDP


checkLeftDiagonalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,4  ; looping for all columns 

    mov edx,152  ; start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx  ;  preserving edx value 
    changeColumnLoop:
        push ecx
         ;  mov ebx,ecx  ; save ecx val for nested loop 
        mov ecx , 3  ; loop 3 times 

        Diagonalcheck:  ;  loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player  ; check fill condition
        je checkmore   ; if value is 1 , look for 3 more 1s above it
        jmp nextIter
        checkmore:
        mov eax,board[edx-32] ; check 1 above and 1 right
        cmp eax,c_player
        je oneclear  ;  we need to clear 2 more for win
        jmp nextIter
        oneclear:
            mov eax,board[edx-64] ; check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp nextIter
                twoclear:
                mov eax,board[edx-96] ; check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp nextIter
                    winnerfound:
                        CALL Crlf 
                        CALL Crlf 
                        cmp c_player, 2
                        je p2wins
                        mov edx, OFFSET p1
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

                        p2wins:
                        mov edx, OFFSET p2
                        CALL writeString
                        mov edx, OFFSET winnmsg
                        CALL writeString
                        exit

        nextIter:
        sub edx,28
        loop Diagonalcheck
        add esi,4  ; go to next column if no win in the previous column 
        mov edx,esi  ;  give that value to edx for upcoming iterations 
         ;  mov ecx,ebx   ; maintaning outer loop value 
        pop ecx
        dec ecx
    cmp ecx, 0
    je exitfunc
    jmp changeColumnLoop

exitfunc:
    ret
checkLeftDiagonalWin ENDP


store_winner PROC
    mov esi, edx   ;  Store the source address (winner's name)
    mov edi, OFFSET winner   ;  Destination address (where winner's name will be stored)

     ;  Copy the winner's name byte by byte until a null terminator (0) is found
    copy_loop:
        mov al, [esi]   ;  Load a byte from the source
        mov [edi], al   ;  Store the byte in the destination
        inc esi         ;  Move to the next byte in the source
        inc edi         ;  Move to the next byte in the destination
        cmp al, 0       ;  Check if the byte is the null terminator
        jne copy_loop   ;  If not, continue copying
ret
store_winner ENDP

END main