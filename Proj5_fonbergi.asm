TITLE Program Template     (Proj5_fonbergi.asm)

; Author: Ian Fonberg
; Last Modified: 5/31/2021
; OSU email address: fonbergi@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 6/6/2021
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc


; ---------------------------------------------------------------------------------
; Name: mGetString
; 
; Display prompt and get the user's input into a memory location.
;
; Preconditions: Do not use EAX, ECX, or EDX as arguments
;
; Postconditions: none
;
; Receives:
;   getPrompt   = input, offset of prompt to display
;   getLength   = input, value of maximum length of user input string
;   getDest     = output, offset of user input string
;   getBytes    = output, offset of number of bytes read
;
; Returns:
;   getDest     = raw user input
;   getBytes    = bytes written
; ---------------------------------------------------------------------------------
mGetString MACRO getPrompt:REQ, getLength:REQ, getDest:REQ, getBytes:REQ
    PUSH    EAX
    PUSH    ECX
    PUSH    EDX
    PUSH    EDI

; Display Prompt.
    MOV     EDX, getPrompt
    CALL    WriteString
    
; Store Raw Input
    MOV     ECX, getLength      ; Max limit of readable characters.
    MOV     EDX, getDest
    
    CALL    ReadString

    MOV     EDI, getBytes
    MOV     [EDI], EAX       ; Store bytes read.

    POP     EDI
    POP     EDX
    POP     ECX
    POP     EAX
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
; 
; Print the string which is stored in a specified memory location.
;
; Preconditions: Do not use EDX as an argument.
;
; Postconditions: none
;
; Receives:
;   displayStr  = input, offset of string to display
;
; Returns: none
; ---------------------------------------------------------------------------------
mDisplayString MACRO displayStr:REQ
    PUSH    EDX

; Display stored string.
    MOV     EDX, displayStr
    CALL    WriteString

    POP     EDX
ENDM


MAX_INPUT = 12

.data

firstAttempt    BYTE    "Please enter an signed number: ",0
rawNumString    BYTE    MAX_INPUT DUP(0)
bytesRead       DWORD   ?
validNum        DWORD   ?

.code
main PROC

    PUSH    OFFSET firstAttempt
    PUSH    OFFSET rawNumString
    PUSH    OFFSET bytesRead
    PUSH    validNum
    CALL    ReadVal

    MOV     EDX, OFFSET rawNumString
    CALL    WriteString
    MOV     EAX, bytesRead
    CALL    WriteDec

    PUSH    OFFSET firstAttempt
    PUSH    OFFSET rawNumString
    PUSH    OFFSET bytesRead
    PUSH    validNum
    CALL    ReadVal

    MOV     EDX, OFFSET rawNumString
    CALL    WriteString
    MOV     EAX, bytesRead
    CALL    WriteDec

    Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
; 
; Gets user input in the form of a string of digits, then attempts to convert the
;   string of ASCII digits to its numeric value representation. If the input is
;   invalid, the user is prompted to try again with an appropriate value, otherwise
;   the value is stored in memory.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives:
;   [EBP+20]    = input, offset of first attemnpt prompt
;   [EBP+16]    = output, offset of user input string
;   [EBP+12]    = output, offset of number of bytes read
;   [EBP+8]     = output, offset of number storage
;
; Returns: [EBP+8] = validated number
; ---------------------------------------------------------------------------------
ReadVal PROC
    PUSH    EBP
    MOV     EBP, ESP

    mGetString [EBP+20], MAX_INPUT, [EBP+16], [EBP+12]

    POP     EBP
    RET
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
; 
; Convert a numeric SDWORD value to a string of ASCII digits and displays it to
;   the user.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives:
;   [EBP+8]     = input, numeric SDWORD value
;
; Returns: none
; ---------------------------------------------------------------------------------
WriteVal PROC
    RET
WriteVal ENDP


END main
