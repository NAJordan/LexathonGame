# ===========================================================================
# Name: Michael Hollister
# Class: CS 3340.501
# Description: This file implements additional general purpose macros that have dependencies on other macro libraries.
# Dependencies: c-library.asm
# Notes: Return value registers are NOT saved prior to macro invocation ($v0, $v1, $f0, $f1). The caller is responsible to save those registers if the value is to be retained.
#	 Search for the tilde character '~' to easily search for macro implementation.
#
# Macro list: Some macros contain variations to accept different types of parameters
#
# - debug_printf
# - printCharArray
# ===========================================================================

# ===========================================================================
# Macro~: debug_printf
# Description: Conditionally outputs a message depending on the debug status
# Parameters: 
#	$status: A label that contians the debug status
#	$format: A string literal that specifies how to interpret the data
#	$[arg0 - $arg3]: Register arguments
# ===========================================================================
		.macro debug_printf($status, $format, $arg0, $arg1, $arg2, $arg3)
		push_stack($a0)
		lb		$a0, $status
		beqz		$a0, debugFalse
		printf($format, $arg0, $arg1, $arg2, $arg3)
debugFalse:
		pop_stack($a0)
		.end_macro
		
		.macro debug_printf($status, $format, $arg0, $arg1, $arg2)
		debug_printf($status, $format, $arg0, $arg1, $arg2, $zero)
		.end_macro

		.macro debug_printf($status, $format, $arg0, $arg1)
		debug_printf($status, $format, $arg0, $arg1, $zero, $zero)
		.end_macro
		
		.macro debug_printf($status, $format, $arg0)
		debug_printf($status, $format, $arg0, $zero, $zero, $zero)
		.end_macro
		
		.macro debug_printf($status, $format)
		debug_printf($status, $format, $zero, $zero, $zero, $zero)
		.end_macro
		
# ===========================================================================
# Macro~: printCharArray
# Description: Prints out the contents of a char array
# Parameters: 
#	$array: A label that stores the address of an array
#	$size: An immediate value of the size of the array
# ===========================================================================
		.macro printCharArray($array, $size)
		push_stack($a0, $a1)
		printf("[ ")
		
		for($a0, 0, $size, body, bodyEnd)
body:
		lb		$a1, $array($a0)
		print_char($a1)
		printf(", ")
		jr		$ra
bodyEnd:
		printf("]")
		pop_stack($a0, $a1)
		.end_macro
		