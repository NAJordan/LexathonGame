# ===========================================================================
# Name: Michael Hollister
# Class: CS 3340.501
# Description: This file implements commonly used macros used for assignments and projects
# Dependencies: None
# Notes: Return value registers are NOT saved prior to macro invocation. The caller is responsible to save those registers if the value is to be retained.
#	 Search for the tilde character �~� to easily search for macro implementation.
#
# Macro list: Some macros contain variations to accept different types of parameters
#
# - push_stack
# - push_stackf
# - pop_stack
# - pop_stackf
# - increment
# - decrement
# - return
# - call
# - for
# - clearArray
# - arrayIndex
# ===========================================================================

# ===========================================================================
# Macro~: push_stack
# Description: Pushes listed registers onto the stack
# Parameters: 
#	$reg0: Register to push onto the stack 
#	[$reg1 - $reg9]: Additional registers to push onto the stack
# ===========================================================================
		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7, $reg8, $reg9)
		sub		$sp, $sp, 40
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		sw		$reg5, 20($sp)
		sw		$reg6, 24($sp)
		sw		$reg7, 28($sp)
		sw		$reg8, 32($sp)	
		sw		$reg9, 36($sp)			
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7, $reg8)
		sub		$sp, $sp, 36
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		sw		$reg5, 20($sp)
		sw		$reg6, 24($sp)
		sw		$reg7, 28($sp)
		sw		$reg8, 32($sp)	
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7)
		sub		$sp, $sp, 32
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		sw		$reg5, 20($sp)
		sw		$reg6, 24($sp)
		sw		$reg7, 28($sp)
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6)
		sub		$sp, $sp, 28
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		sw		$reg5, 20($sp)
		sw		$reg6, 24($sp)
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5)
		sub		$sp, $sp, 24
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		sw		$reg5, 20($sp)
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3, $reg4)
		sub		$sp, $sp, 20
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		sw		$reg4, 16($sp)
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2, $reg3)
		sub		$sp, $sp, 16
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		sw		$reg3, 12($sp)
		.end_macro

		.macro push_stack($reg0, $reg1, $reg2)
		sub		$sp, $sp, 12
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		sw		$reg2, 8($sp)
		.end_macro		

		.macro push_stack($reg0, $reg1)
		sub		$sp, $sp, 8
		sw		$reg0, ($sp)
		sw		$reg1, 4($sp)
		.end_macro

		.macro push_stack($reg0)
		sub		$sp, $sp, 4
		sw		$reg0, ($sp)
		.end_macro


# ===========================================================================
# Macro~: push_stackf
# Description: Pushes listed floating point registers onto the stack
# Parameters: 
#	$reg0: Register to push onto the stack 
#	[$reg1 - $reg3]: Additional registers to push onto the stack
# ===========================================================================
		.macro push_stackf($reg0, $reg1, $reg2, $reg3)
		sub		$sp, $sp, 16
		swc1		$reg0, ($sp)
		swc1		$reg1, 4($sp)
		swc1		$reg2, 8($sp)
		swc1		$reg3, 12($sp)
		.end_macro

		.macro push_stackf($reg0, $reg1, $reg2)
		sub		$sp, $sp, 12
		swc1		$reg0, ($sp)
		swc1		$reg1, 4($sp)
		swc1		$reg2, 8($sp)
		.end_macro		

		.macro push_stackf($reg0, $reg1)
		sub		$sp, $sp, 8
		swc1		$reg0, ($sp)
		swc1		$reg1, 4($sp)
		.end_macro

		.macro push_stackf($reg0)
		sub		$sp, $sp, 4
		swc1		$reg0, ($sp)
		.end_macro

# ===========================================================================
# Macro~: pop_stack
# Description: Pops listed registers from the stack
# Parameters: 
#	$reg0: Register to pop from the stack
#	[$reg1 - $reg9]: Additional registers to pop from the stack
# ===========================================================================		
		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7, $reg8, $reg9)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		lw		$reg5, 20($sp)
		lw		$reg6, 24($sp)
		lw		$reg7, 28($sp)
		lw		$reg8, 32($sp)
		lw		$reg9, 36($sp)
		add		$sp, $sp, 40
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7, $reg8)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		lw		$reg5, 20($sp)
		lw		$reg6, 24($sp)
		lw		$reg7, 28($sp)
		lw		$reg8, 32($sp)
		add		$sp, $sp, 36
		.end_macro
		
		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6, $reg7)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		lw		$reg5, 20($sp)
		lw		$reg6, 24($sp)
		lw		$reg7, 28($sp)
		add		$sp, $sp, 32
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5, $reg6)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		lw		$reg5, 20($sp)
		lw		$reg6, 24($sp)
		add		$sp, $sp, 28
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4, $reg5)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		lw		$reg5, 20($sp)
		add		$sp, $sp, 24
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2, $reg3, $reg4)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		lw		$reg4, 16($sp)
		add		$sp, $sp, 20
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2, $reg3)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		lw		$reg3, 12($sp)
		add		$sp, $sp, 16
		.end_macro

		.macro pop_stack($reg0, $reg1, $reg2)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		lw		$reg2, 8($sp)
		add		$sp, $sp, 12
		.end_macro		

		.macro pop_stack($reg0, $reg1)
		lw		$reg0, ($sp)
		lw		$reg1, 4($sp)
		add		$sp, $sp, 8
		.end_macro

		.macro pop_stack($reg0)
		lw		$reg0, ($sp)
		add		$sp, $sp, 4
		.end_macro


# ===========================================================================
# Macro~: pop_stackf
# Description: Pops listed floating point registers from the stack
# Parameters: 
#	$reg0: Register to pop from the stack
#	[$reg1 - $reg9]: Additional registers to pop from the stack
# ===========================================================================		
		.macro pop_stackf($reg0, $reg1, $reg2, $reg3)
		lwc1		$reg0, ($sp)
		lwc1		$reg1, 4($sp)
		lwc1		$reg2, 8($sp)
		lwc1		$reg3, 12($sp)
		add		$sp, $sp, 16
		.end_macro

		.macro pop_stackf($reg0, $reg1, $reg2)
		lwc1		$reg0, ($sp)
		lwc1		$reg1, 4($sp)
		lwc1		$reg2, 8($sp)
		add		$sp, $sp, 12
		.end_macro		

		.macro pop_stackf($reg0, $reg1)
		lwc1		$reg0, ($sp)
		lwc1		$reg1, 4($sp)
		add		$sp, $sp, 8
		.end_macro

		.macro pop_stackf($reg0)
		lwc1		$reg0, ($sp)
		add		$sp, $sp, 4
		.end_macro

# ===========================================================================
# Macro~: increment
# Description: Increments the register by the specified amount.
# Parameters: 
#	$register: Register to increment
# 	[$amount]: The amount to add to $register. If not specified, the default value is 1.
# ===========================================================================
		.macro increment($register, $amount)
		add		$register, $register, $amount
		.end_macro

		.macro increment($register)
		increment($register, 1)
		.end_macro

# ===========================================================================
# Macro~: decrement
# Description: Decrements the register by the specified amount.
# Parameters: 
#	$register: Register to decrement
# 	[$amount]: The amount to subtract from the $register. If not specified, the default value is 1.
# ===========================================================================
		.macro decrement($register, $amount)
		sub		$register, $register, $amount
		.end_macro

		.macro decrement($register)
		decrement($register, 1)
		.end_macro

# ===========================================================================
# Macro~: return
# Description: Returns the value to the caller
# return - Parameters: 
#	$register: Register value to return
# returni - Parameters: 
#	$value: The immediate value to return
# ===========================================================================
		.macro return($register)
		move		$v0, $register
		jr 		$ra
		.end_macro
		
		.macro returni($value)
		li		$v0, $value
		jr		$ra
		.end_macro

# ===========================================================================
# Macro~: call
# Description: Invokes an assembly function
# Parameters: 
#	$name: A label that defines the function
#	[$arg0 - $arg3]: Registers that contian the function arguments
# ===========================================================================
		.macro call($name, $arg0, $arg1, $arg2, $arg3)
		push_stack($ra, $arg0, $arg1, $arg2, $arg3)
		jal		$name
		pop_stack($ra, $arg0, $arg1, $arg2, $arg3)
		.end_macro
		
		.macro call($name, $arg0, $arg1, $arg2)
		call($name, $arg0, $arg1, $arg2, $zero)
		.end_macro

		.macro call($name, $arg0, $arg1)
		call($name, $arg0, $arg1, $zero, $zero)
		.end_macro
		
		.macro call($name, $arg0)
		call($name, $arg0, $zero, $zero, $zero)
		.end_macro
		
		.macro call($name)
		call($name, $zero, $zero, $zero, $zero)
		.end_macro

# ===========================================================================
# Macro~: for
# Description: Calls an assembly function for the specified number of times
# Parameters: 
#	$iterator: A register that will be the loop counter
#	$from: A register or immediate value that is the starting value of the loop counter
#	$to: A register or immediate value that is the ending value of the loop counter
#	$body: A label that defines the start of the loop
#	$bodyEnd: A label that closes the body of the loop
# ===========================================================================
		.macro for($iterator, $from, $to, $body, $bodyEnd)
		push_stack($iterator)
		add		$iterator, $zero, $from
		
loop:
		call($body)
		increment($iterator)
		ble		$iterator, $to, loop
		
		pop_stack($iterator)
		j		$bodyEnd
		.end_macro

# ===========================================================================
# Macro~: clearArray
# Description: Sets all the array enteries to zero
# clearArray - Parameters: 
#	$array: A label tthat stores the address of an array
#	$size: A register that stores the size of the array in bytes
# clearArrayi - Parameters:
#	$size: An immediate value that is the size of the array
# ===========================================================================
		.macro clearArray($array, $size)
		.eqv		MACROS_clearArray_iterator $t0
		push_stack(MACROS_clearArray_iterator)
		li		MACROS_clearArray_iterator, 0		
		
		for(MACROS_clearArray_iterator, 0, $size, body, bodyEnd)
body:
		sb		$zero, $array(MACROS_clearArray_iterator)
		jr		$ra
		
bodyEnd:
		pop_stack(MACROS_clearArray_iterator)
		.end_macro

		.macro clearArrayi($array, $size)
		push_stack($a0)
		li		$a0, $size
		clearArray($array, $a0)
		pop_stack($a0)
		.end_macro

# ===========================================================================
# Macro~: arrayIndex
# Description: Returns the contents of an array at the specified index
# clearArray - Parameters: 
#	$array: A label that stores the address of an array
#	$index: An immediate value of contents of the index to access
# Return Value: The contents of the array in $v0
# ===========================================================================
		.macro arrayIndex($array, $index)
		push_stack($t0)
		
		la		$t0, $array
		add		$t0, $t0, $index
		la		$v0, ($t0)
		
		pop_stack($t0)
		.end_macro


		
