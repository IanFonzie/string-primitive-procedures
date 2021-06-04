TITLE Program Template     (Proj6_fonbergi.asm)

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


MAX_DIGITS = 12

.data

firstAttempt    BYTE    "Please enter a signed number: ",0
secondAttempt   BYTE    "Please try again: ",0
emptyMsg        BYTE    "ERROR: a value is required.",13,10,0
errorMsg        BYTE    "ERROR: You did not enter a signed number or your number was too big.",13,10,0
rawNumString    BYTE    MAX_DIGITS DUP(0)
bytesRead       DWORD   ?
validNum        SDWORD  ?

.code
main PROC

    PUSH    OFFSET firstAttempt
    PUSH    OFFSET emptyMsg
    PUSH    OFFSET errorMsg
    PUSH    OFFSET secondAttempt
    PUSH    OFFSET rawNumString
    PUSH    OFFSET bytesRead
    PUSH    OFFSET validNum
    CALL    ReadVal

    PUSH    validNum
    CALL    WriteVal

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
;   [EBP+32]    = input, offset of first attempt prompt
;   [EBP+28]    = input, offset of empty error message
;   [EBP+24]    = input, offset of invalid error message
;   [EBP+20]    = input, offset of second attempt prompt
;   [EBP+16]    = output, offset of user input string
;   [EBP+12]    = output, offset of number of bytes read
;   [EBP+8]     = output, offset of number storage
;
; Returns: [EBP+8] = validated number
; ---------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX ECX EDX ESI
    LOCAL valid:BYTE, numInt:SDWORD, sign:SDWORD

; -------------------------
; Get Integer Digits.
; -------------------------
    MOV     valid, 1                                    ; Initialize valid to true.
; Display initial prompt for signed number.
    mGetString [EBP+32], MAX_DIGITS, [EBP+16], [EBP+12]

_validateDigits:
    MOV     numInt, 0                                   ; Initialize integer aggregator to 0.
    MOV     sign, 1                                     ; Value is unsigned.

    CMP     valid, 0
    JNE     _endTryAgain

; Prompt for new signed integer.
    mGetString [EBP+20], MAX_DIGITS, [EBP+16], [EBP+12]

_endTryAgain:
    MOV     ECX, bytesRead                              ; Initialize counter.
    INC     ECX

; -------------------------
; Assert input is non-empty.
; -------------------------
; Assert a value was read.
    CMP     bytesRead, 0
    JNE     _notEmpty

; Set error state.
    MOV     valid, 0                                    ; Valid is false.
    MOV     EDX, [EBP+28]
    CALL    WriteString
    JMP     _validateDigits
_notEmpty:
    MOV     ESI, [EBP+16]                               ; Move user input to ESI.
 
; -------------------------
; Assert sign is either first character or absent.
; -------------------------
    CLD
    LODSB
    DEC     ECX                                         ; Load first character and adjust counter position.

    CMP     AL, 45                                      ; is the character a '-' sign?
    JE      _setNegative
    CMP     AL, 43                                      ; is the character a '+' sign?
    JE      _checkLength
    JMP     _aggregateNum                               ; Proceed with calculation.

_setNegative:
    MOV     sign, -1
_checkLength:
    CMP     bytesRead, 1                                ; Assert sign is not the only component.
    JNE     _loadNext
; Set error state.
    MOV     valid, 0                                    ; Valid is false.
    MOV     EDX, [EBP+24]
    CALL    WriteString
    JMP     _validateDigits

_loadNext:
    LODSB
    DEC     ECX                                         ; Load second character and adjust counter position.
_aggregateNum:
   
    ; -------------------------
    ; Aggregate digits into integer.
    ; -------------------------
    _readDigit:
        CMP     AL, 48
        JB      _notDigitOrTooLarge
        CMP      AL, 57
        JA      _notDigitOrTooLarge
        
    ; ASCII value - 48 will result in an integer between 0 and 9, inclusive.
        MOVZX   EBX, AL
        SUB     EBX, 48
        IMUL    EBX, sign                               ; Calculated signed amount to add to total.

    ; Multiply 10x current numInt.
        MOV     EAX, 10
        IMUL    numInt
        JO      _notDigitOrTooLarge                     ; Invalid if overflow.

    ; Add both to get current integer value.
        ADD     EAX, EBX
        JO      _notDigitOrTooLarge                     ; Invalid if overflow.

        MOV     numInt, EAX

        JMP     _continueRead
    _notDigitOrTooLarge:
        MOV     valid, 0                                ; Valid is false.
        MOV     EDX, [EBP+24]
        CALL    WriteString
        JMP     _validateDigits
    _continueRead:
        LODSB
        LOOP    _readDigit

; -------------------------
; Store number.
; -------------------------
    MOV     EDI, [EBP+8]
    MOV     EAX, numInt
    MOV     [EDI], EAX

    RET     24
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
WriteVal PROC USES EAX EBX ECX EDX EDI ESI
    LOCAL signed:BYTE, digits[MAX_DIGITS]:BYTE, strNum[MAX_DIGITS]:BYTE
    
    MOV     signed, 0
    LEA     EDI, digits
    MOV     ECX, 0                  ; Counter for string length
    CLD

; -------------------------
; Check sign.
; -------------------------
    MOV     EAX, [EBP+8]
    CMP     EAX, 0
    JGE     _storeDigits
    MOV     signed, 1               ; Number is signed.
    NEG     EAX                     ; Use the absolute value of the number.

; -------------------------
; Store digits in reverse order
; -------------------------
_storeDigits:
    MOV     EDX, 0
    MOV     EBX, 10
    DIV     EBX

    MOV     EBX, EAX                ; Store current quotient

    MOV     AL, DL
    ADD     AL, 48                  ; Add 48 to remainder to get ASCII character value.
    STOSB
    INC     ECX
    MOV     EAX, EBX                ; Restore quotient
    CMP     EAX, 0
    JNE     _storeDigits

; Append sign if number is signed.
    CMP     signed, 1
    JNE     _terminateDigits
    MOV     AL, '-'
    STOSB
    INC     ECX

; Null terminate the string.
_terminateDigits:
    MOV     EBX, 0
    MOV     [EDI], EBX 

; -------------------------
; Reverse stored digits
; -------------------------
    MOV     ESI, EDI                ; EDI currently points to end of digits which is now our source.
    DEC     ESI
    LEA     EDI, strNum

_reverseDigits:
    STD
    LODSB                           ; Move backwards through digit and store result in AL
    CLD
    STOSB                           ; Move forwards through strNum and store the result from AL
    LOOP _reverseDigits

; Null terminate the string.
    MOV     EBX, 0
    MOV     [EDI], EBX 

; Display string.
    LEA     EBX, strNum
    mDisplayString EBX

    RET     4
WriteVal ENDP


END main
