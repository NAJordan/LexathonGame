# ===========================================================================
# Name: Michael Hollister
# Class: CS 3340.501
# Description: This file implements functionality from the c standard library using a macro interface
# Dependencies: macros.asm
# Notes: Return value registers are NOT saved prior to macro invocation. The caller is responsible to save those registers if the value is to be retained.
#	 Search for the tilde character '~' to easily search for macro implementation.
#
# Macro list: Some macros contain variations to accept different types of parameters
#
# - printf

# ===========================================================================

		.eqv		ASCII_NULL	0x00
		.eqv 		ASCII_PERCENT 	0x25
		.eqv		ASCII_LF      	0x0A
		.eqv		ASCII_A		0x61
		.eqv		ASCII_D		0x64
		.eqv		ASCII_E		0x65
		.eqv		ASCII_I 	0x69
		.eqv		ASCII_C 	0x63
		.eqv		ASCII_F 	0x66
		.eqv		ASCII_O		0x6F
		.eqv		ASCII_S 	0x73
		.eqv		ASCII_U 	0x75		
		
# ===========================================================================
# Macro~: printf
# Description: To be written. Currently does not fully implement printf.
# Remarks: Supported flags %, c, d, i, s
# strlen - Parameters: 
#	$format: A label to a string that specifies how to interpret the data
#	$arg0 - $arg3: Register arguments
# ===========================================================================
		.macro printf($format, $arg0, $arg1, $arg2, $arg3)
		.data
pf_format:	.asciiz		$format
		.text
		
		.eqv		CLIB_printf_counter $t0
		.eqv		CLIB_printf_char $t1
		.eqv		CLIB_printf_foundToken $t2
		.eqv		CLIB_printf_argumentPointer $t3
		
		push_stack($a0, $a1, $a2, $a3, CLIB_printf_counter, CLIB_printf_char, CLIB_printf_foundToken, CLIB_printf_argumentPointer)
		#push_stackf($f12)
		move		$a0, $arg0
		move		$a1, $arg1
		move		$a2, $arg2
		move		$a3, $arg3

		li		CLIB_printf_counter, 0
		li		CLIB_printf_foundToken, 0
		li		CLIB_printf_argumentPointer, 0
		lb		CLIB_printf_char, pf_format
		
pf_loop:
		beqz		CLIB_printf_char, pf_exit
		bnez		CLIB_printf_foundToken, pf_token_process
		bne		CLIB_printf_char, ASCII_PERCENT, pf_loop_print
		li		CLIB_printf_foundToken, 1
		j 		pf_loop_increment
		
pf_token_process:
		beq		CLIB_printf_char, ASCII_PERCENT, pf_loop_print 		# Print %% as a single percent literal (just %) 
		beq		CLIB_printf_char, ASCII_D, pf_loop_printInt
		beq		CLIB_printf_char, ASCII_I, pf_loop_printInt
		beq		CLIB_printf_char, ASCII_C, pf_loop_printChar
		beq		CLIB_printf_char, ASCII_S, pf_loop_printStr
		beq		CLIB_printf_char, ASCII_U, pf_loop_printUInt
		#beq		CLIB_printf_char, ASCII_F, pf_loop_printFloat
		
		
		# If conversion specifier is not understood, just print out the character
		li		CLIB_printf_foundToken, 0
		j 		pf_loop_print


# ---------------------------------------------------------------------------
# %d / %i format flag
# ---------------------------------------------------------------------------
pf_loop_printInt:
		beq		CLIB_printf_argumentPointer, 1, pf_loop_printInt1
		beq		CLIB_printf_argumentPointer, 2, pf_loop_printInt2
		beq		CLIB_printf_argumentPointer, 3, pf_loop_printInt3
		
		print_int($a0)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

pf_loop_printInt1:
		print_int($a1)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printInt2:		
		print_int($a2)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printInt3:
		print_int($a3)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment


# ---------------------------------------------------------------------------
# %u format flag
# ---------------------------------------------------------------------------
pf_loop_printUInt:
		beq		CLIB_printf_argumentPointer, 1, pf_loop_printUInt1
		beq		CLIB_printf_argumentPointer, 2, pf_loop_printUInt2
		beq		CLIB_printf_argumentPointer, 3, pf_loop_printUInt3
		
		print_intu($a0)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

pf_loop_printUInt1:
		print_intu($a1)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printUInt2:		
		print_intu($a2)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printUInt3:
		print_intu($a3)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment


# ---------------------------------------------------------------------------
# %c format flag
# ---------------------------------------------------------------------------
pf_loop_printChar:
		beq		CLIB_printf_argumentPointer, 1, pf_loop_printChar1
		beq		CLIB_printf_argumentPointer, 2, pf_loop_printChar2
		beq		CLIB_printf_argumentPointer, 3, pf_loop_printChar3
		
		print_char($a0)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

pf_loop_printChar1:
		print_char($a1)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printChar2:		
		print_char($a2)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printChar3:
		print_char($a3)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

# ---------------------------------------------------------------------------
# %s format flag
# ---------------------------------------------------------------------------
pf_loop_printStr:
		beq		CLIB_printf_argumentPointer, 1, pf_loop_printStr1
		beq		CLIB_printf_argumentPointer, 2, pf_loop_printStr2
		beq		CLIB_printf_argumentPointer, 3, pf_loop_printStr3
		
		print_str($a0)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

pf_loop_printStr1:
		print_str($a1)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printStr2:		
		print_str($a2)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment
pf_loop_printStr3:
		print_str($a3)
		increment(CLIB_printf_argumentPointer)
		li		CLIB_printf_foundToken, 0
		j		pf_loop_increment

# ---------------------------------------------------------------------------
# Literal printing
# ---------------------------------------------------------------------------

pf_loop_print:
		print_char(CLIB_printf_char)
		
pf_loop_increment:
		increment(CLIB_printf_counter)
		lb		CLIB_printf_char, pf_format(CLIB_printf_counter)
		j pf_loop

pf_exit:
		#pop_stackf($f12)
		pop_stack($a0, $a1, $a2, $a3, CLIB_printf_counter, CLIB_printf_char, CLIB_printf_foundToken, CLIB_printf_argumentPointer)
		.end_macro

		.macro printf($format, $arg0, $arg1, $arg2)
		printf($format, $arg0, $arg1, $arg2, $zero)
		.end_macro

		.macro printf($format, $arg0, $arg1)
		printf($format, $arg0, $arg1, $zero, $zero)
		.end_macro
		
		.macro printf($format, $arg0)
		printf($format, $arg0, $zero, $zero, $zero)
		.end_macro
		
		.macro printf($format)
		printf($format, $zero, $zero, $zero, $zero)
		.end_macro

