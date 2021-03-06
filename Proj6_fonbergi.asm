TITLE String Primitives and Macros     (Proj6_fonbergi.asm)

; Author: Ian Fonberg
; Last Modified: 6/4/2021
; OSU email address: fonbergi@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 6/6/2021
; Description: Implements the macros mGetString and mDisplayString to get user
;   input strings and display strings using Irvine procedures ReadString and
;   WriteString, respectively. These macros are used to write the low-level
;   procedures ReadVal and WriteVal. ReadVal prompts the user for a signed
;   integer, validates it, and stores it as an SDWORD. WriteVal takes a stored
;   SDWORD and converts it to a string that is displayed to output. All of
;   these macros and procedures are used to write a test script within main
;   that greets the user, gets 10 signed integers from the user calculating the
;   sum and displaying a subtotal along the way. Next, it displays the numbers
;   back to the user along with the final sum and average of the numbers.
;   Finally, the test script says goodbye to the user and exits.

INCLUDE Irvine32.inc


; ---------------------------------------------------------------------------------
; Name: mGetString
; 
; Display prompt and get the user's input into a memory location.
;
; Preconditions: Do not use EAX, ECX, EDX, or EDI as arguments
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
    mDisplayString getPrompt
    
; Store Raw Input
    MOV     ECX, getLength                              ; Max limit of readable characters.
    MOV     EDX, getDest

    CALL    ReadString

    MOV     EDI, getBytes
    MOV     [EDI], EAX                                  ; Store bytes read.

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
ARRAY_SIZE = 10

.data

firstAttempt    BYTE    ". Please enter a signed number: ",0
secondAttempt   BYTE    ". Please try again: ",0
emptyMsg        BYTE    "ERROR: a value is required.",13,10,0
errorMsg        BYTE    "ERROR: You did not enter a signed number or your number was too big.",13,10,0
rawNumString    BYTE    MAX_DIGITS DUP(0)
validNum        SDWORD  ?
intro1          BYTE    "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,
                        "Written by: Ian Fonberg",13,10,
                        "**EC: Number each line of user input and display a running subtotal of the user's valid numbers.",13,10,13,10,
                        "Please provide ",0
intro2          BYTE    " signed decimal integers.",13,10,
                        "Each number needs to be small enough to fit inside a 32 bit register. After you have ",
                        "finished inputting the raw numbers I will display a list of the integers, their sum, ",
                        "and their average value.",13,10,13,10,0
testArr         SDWORD  ARRAY_SIZE DUP(?)
subtotal        BYTE    "Subtotal: ",0
numsEntered     BYTE    "You entered the following numbers: ",13,10,0
comma           BYTE    ", ",0
sumNums         BYTE    "The sum of these numbers is: ",0
avgNums         BYTE    "The rounded average is: ",0
goodbye         BYTE    "Thanks for playing!",0
lineNo          BYTE    1

.code
main PROC

; -------------------------
; Test Script
; -------------------------
; Introduce test script.
    mDisplayString OFFSET intro1

    PUSH    ARRAY_SIZE
    CALL    WriteVal

    mDisplayString OFFSET intro2

; -------------------------
; Add user input to array.
; -------------------------
    MOV     EAX, 0                                      ; Initialize sum.
    MOV     ECX, ARRAY_SIZE                             ; Initialize counter to ARRAY_SIZE.
    MOV     EDI, OFFSET testArr
_readLoop:
    PUSH    OFFSET lineNo
    PUSH    OFFSET firstAttempt
    PUSH    OFFSET emptyMsg
    PUSH    OFFSET errorMsg
    PUSH    OFFSET secondAttempt
    PUSH    OFFSET rawNumString
    PUSH    OFFSET validNum
    CALL    ReadVal

; Insert signed integer using register indirect addressing.
    MOV     EBX, validNum
    MOV     [EDI], EBX

; -------------------------
; Display Subtotal.
; -------------------------
    ADD     EAX, EBX                                    ; Add valid number to total.
    mDisplayString OFFSET subtotal
    PUSH    EAX
    CALL    WriteVal
    CALL    CrLf

    ADD     EDI, TYPE testArr                           ; Move to next element.

    LOOP    _readLoop
    CALL    CrLf

; -------------------------
; Display numbers entered.
; -------------------------
    mDisplayString OFFSET numsEntered

    MOV     ESI, OFFSET testArr
    MOV     ECX, ARRAY_SIZE
    
    PUSH    [ESI]
    CALL    WriteVal                                    ; Display first number

    DEC     ECX                                         ; Decrement counter.

_writeLoop:
; Comma separate the numbers
    mDisplayString OFFSET comma

    ADD     ESI, TYPE testArr                           ; Access next number using register indirect addressing.

    PUSH    [ESI]
    CALL    WriteVal                                    ; Display the current number.
    
    LOOP    _writeLoop
    CALL    CrLf

; -------------------------
; Display sum of numbers entered.
; -------------------------
    mDisplayString OFFSET sumNums

    PUSH    EAX                                         ; EAX holds final sum.
    CALL    WriteVal
    CALL    CrLf

; -------------------------
; Calculate and display average of numbers entered.
; -------------------------
    MOV     EBX, ARRAY_SIZE
    CDQ
    IDIV    EBX

; Floor negative numbers with remainders.
    CMP     EDX, 0
    JGE     _alreadyFloored
    DEC     EAX

_alreadyFloored:
    mDisplayString OFFSET avgNums
    
    PUSH     EAX                                        ; EAX contains floored average.
    CALL    WriteVal

    CALL    CrLf
    CALL    CrLf

; Say goodbye to user.
    mDisplayString OFFSET goodbye

    Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
; 
; Gets user input in the form of a string of digits, then attempts to convert the
;   string of ASCII digits to its numeric value representation. If the input is
;   invalid, the user is prompted to try again with an appropriate value, otherwise
;   the value is stored in memory. Numbers the prompt with the current number
;   of valid guesses.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives:
;   [EBP+32]    = input/output, offset of current number of valid guesses.
;   [EBP+28]    = input, offset of first attempt prompt
;   [EBP+24]    = input, offset of empty error message
;   [EBP+20]    = input, offset of invalid error message
;   [EBP+16]    = input, offset of second attempt prompt
;   [EBP+12]    = output, offset of user input string
;   [EBP+8]     = output, offset of number storage
;
; Returns:
;   [EBP+32]    = Incremented by one.
;   [EBP+8]     = validated number
; ---------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX ECX EDI ESI
    LOCAL valid:BYTE, numInt:SDWORD, sign:SDWORD, bytesRead:DWORD

; -------------------------
; Get Integer Digits.
; -------------------------
    MOV     valid, 1                                    ; Initialize valid to true.

; Display initial prompt for signed number.
    MOV     ESI, [EBP+32]
    PUSH    [ESI]
    CALL    WriteVal                                    ; Display line number.
    LEA     EBX, bytesRead
    mGetString [EBP+28], MAX_DIGITS, [EBP+12], EBX

_validateDigits:
    MOV     numInt, 0                                   ; Initialize integer aggregator to 0.
    MOV     sign, 1                                     ; Value is unsigned.

    CMP     valid, 0
    JNE     _endTryAgain

; Prompt for new signed integer.
    MOV     ESI, [EBP+32]
    PUSH    [ESI]
    CALL    WriteVal                                    ; Display line number.
    LEA     EBX, bytesRead
    mGetString [EBP+16], MAX_DIGITS, [EBP+12], EBX

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
    mDisplayString [EBP+24]
    JMP     _validateDigits
_notEmpty:
    MOV     ESI, [EBP+12]                               ; Move user input to ESI.
 
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
    mDisplayString [EBP+20]
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
        mDisplayString [EBP+20]
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

; Increment line number.
    MOV     ESI, [EBP+32]
    INC     BYTE PTR [ESI]

    RET     28
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
    MOV     ECX, 0                                      ; Counter for string length
    CLD

; -------------------------
; Check sign.
; -------------------------
    MOV     EAX, [EBP+8]
    CMP     EAX, 0
    JGE     _storeDigits
    MOV     signed, 1                                   ; Number is signed.
    NEG     EAX                                         ; Use the absolute value of the number.

; -------------------------
; Store digits in reverse order
; -------------------------
_storeDigits:
    MOV     EDX, 0
    MOV     EBX, 10
    DIV     EBX

    MOV     EBX, EAX                                    ; Store current quotient

    MOV     AL, DL
    ADD     AL, 48                                      ; Add 48 to remainder to get ASCII character value.
    STOSB
    INC     ECX
    MOV     EAX, EBX                                    ; Restore quotient
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
    MOV     ESI, EDI                                    ; EDI currently points to end of digits which is now our source.
    DEC     ESI
    LEA     EDI, strNum

_reverseDigits:
    STD
    LODSB                                               ; Move backwards through digit and load result in AL
    CLD
    STOSB                                               ; Move forwards through strNum and store the result from AL
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
