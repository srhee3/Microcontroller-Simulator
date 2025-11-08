//Appendix (Copied From Simulator)

// Inputs and Outputs for BnB Game.
// GP0, GP1, GP2, GP5 represent outputs of values
// GP3, GP4 represent inputs
// Standard constants
$w 0
$f 1
$ONE_ROLL 1
$TWO_ROLLS 2
$RESULT_W 0
$RESULT_F 1
// Standard Variables
@ROLL_COUNT 0x0B
@store 0x0C
@lfsr 0x0A
:origin
movlw 00011000b
tris 6
clrf GPIO // this clears the field to start the game
:GP3_button // GP3 functions as the button needed to start the roll
btfss GPIO, GP3
btfsc GPIO, GP3
goto GP3_button // this is a loop created
:GP4_rolls // GP4 functions as the type of roll that will be played
btfss GPIO, GP4
movlw TWO_ROLLS
btfsc GPIO, GP4
movlw ONE_ROLL
movwf ROLL_COUNT
//ECS 050 Code Copied from LAB
// Implements an 8-bit linear feedback shift register that can be used to generate a
// pseudo random binary number sequence. The output sequence can be viewed in
// the register lfsr.
// Copied ECS 050 Code
:rand_generator
// Load seed value into lfsr
movlw 0x79 // any non-zero value will work
movwf lfsr
// imported from ECS 050 Code
:lfsr_galois
// GP5 and GP1 flash on and off when rolling
bsf GPIO, GP5
bsf GPIO, GP1
clrf GPIO
// First clear the carry so that we know that it is zero. Now, shift the lfsr right
// putting the LSB in carry and copying the lfsr into the working register for more processing
bcf STATUS,C
rrf lfsr, RESULT_W
// If the carry (LSB) is set we want to
// xor the lfsr with our xor taps 8,6,5,4 (0,2,3,4)
btfsc STATUS, C
xorlw 10111000b
movwf lfsr // save the new lfsr
btfss GPIO, GP3
goto lfsr_galois
// end of ECS 050 Code Copied
:Button_Pressed
btfss GPIO, GP4
btfsc GPIO, GP4
goto single_dice
call store_random_number
btfsc ROLL_COUNT, 0
goto lfsr_galois
goto two_die
:store_random_number
movf lfsr, w
movwf store
retlw 1
:two_die
movlw 00000111b
andwf lfsr, f
movlw 00000111b
andwf store, f
movf store, w
addwf lfsr, f
goto Display_LED
:single_dice
movlw 00001111b
andwf lfsr, f
:Display_LED
clrf GPIO
btfsc lfsr, 0
bsf GPIO, GP0
btfsc lfsr, 1
bsf GPIO, GP1
btfsc lfsr, 2
bsf GPIO, GP2
btfsc lfsr, 3
bsf GPIO, GP5
@stack_ptr 0x0F
@stack_start 0x10
@stack_end 0x1F
$stack_size 0x10
:Circular_buffer //saves the last 16 rolls in locations 10h to 1fx.
// Derived from example 6
movlw stack_start
addwf stack_ptr, w
movwf FSR
movf lfsr, w
movwf INDF
incf stack_ptr, f
movlw 00001111b
andwf stack_ptr, f
goto GP3_button
