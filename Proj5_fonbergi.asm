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
; Preconditions: Do not use EAX, ECX, EDX or EDI as arguments
;
; Postconditions: none
;
; Receives:
;   getPrompt   = input, offset of prompt to display
;   getLength   = input, value of maximum length of user input string
;   getDest     = output, offset of user input string
;   getBytes    = output, value of number of bytes written
;
; Returns:
;   getDest     = raw user input
;   getBytes    = bytes written
; ---------------------------------------------------------------------------------
mGetString MACRO getPrompt:REQ, getLength:REQ, getDest:REQ, getBytes:REQ
    ; stuff
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
    ; stuff
ENDM

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

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
;   [EBP+8]     = output, offset of number storage
;
; Returns: [EBP+8] = validated number
; ---------------------------------------------------------------------------------
ReadVal PROC
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
ReadVal PROC
    RET
ReadVal ENDP


END main
