# ===========================================================================
# Name: Michael Hollister
# Class: CS 3340.501
# Description: This file implements functionality from the c standard library using a macro interface
# Dependencies: macros.asm
# Notes: Return value registers are NOT saved prior to macro invocation. The caller is responsible to save those registers if the value is to be retained.
#	 Search for the tilde character �~� to easily search for macro implementation.
#
# Macro list: Some macros contain variations to accept different types of parameters
#
# - strcmp
# - strlen
# - strstr

# ===========================================================================

# ===========================================================================
# Macro~: strcmp
# Description: Compares the str1 to str2
# Parameters: 
#	$str1, $str2: A register that contains the address of the string that is to be compaired
# Return Value: The comparison result stored in $v0. 0 if strings are equal, 1 if str1 lexical order is greater than str2, and -1 if str1 lexical order is less than str2
# ===========================================================================
		.macro strcmp($str1, $str2)
		.eqv		CLIB_strcmp_strAddress1 $a0
		.eqv		CLIB_strcmp_strAddress2 $a1
		.eqv		CLIB_strcmp_char1 $t0
		.eqv		CLIB_strcmp_char2 $t1
		push_stack(CLIB_strcmp_strAddress1, CLIB_strcmp_strAddress2, CLIB_strcmp_char1, CLIB_strcmp_char2, $t2)
		
		move 		CLIB_strcmp_strAddress1, $str1
		move 		CLIB_strcmp_strAddress2, $str2
		lb		CLIB_strcmp_char1, (CLIB_strcmp_strAddress1)
		lb		CLIB_strcmp_char2, (CLIB_strcmp_strAddress2)
		
strcmp_loop:
		beqz		CLIB_strcmp_char1, strcmp_equal
		bne		CLIB_strcmp_char1, CLIB_strcmp_char2, strcmp_compare
		increment(CLIB_strcmp_strAddress1)
		increment(CLIB_strcmp_strAddress2)
		lb		CLIB_strcmp_char1, (CLIB_strcmp_strAddress1)
		lb		CLIB_strcmp_char2, (CLIB_strcmp_strAddress2)
		j 		strcmp_loop	

strcmp_equal:
		bne		CLIB_strcmp_char1, CLIB_strcmp_char2, strcmp_less
		li		$v0, 0
		j		strcmp_exit

strcmp_compare:	# $str1 > $str2
		slt		$t2, CLIB_strcmp_char1, CLIB_strcmp_char2
		bnez		$t2, strcmp_less
		li		$v0, 1
		j		strcmp_exit

strcmp_less:	# $str1 < $str2
		li		$v0, -1
		j		strcmp_exit

strcmp_exit:
		pop_stack(CLIB_strcmp_strAddress1, CLIB_strcmp_strAddress2, CLIB_strcmp_char1, CLIB_strcmp_char2, $t2)
		.end_macro
		

# ===========================================================================
# Macro~: strlen
# Description: Computes the length of the string up to, but not including the terminating null character
# strlen - Parameters: 
#	$str: A register that contains the address of the string whose length is to be computed
# strlenl - Parameters: 
#	$str: A label to the address of the string whose length is to be computed
# Return Value: The length of the string stored in $v0
# ===========================================================================
		.macro strlen($str)
		.eqv		CLIB_strlen_strAddress $a0
		.eqv 		CLIB_strlen_counter $t0
		.eqv		CLIB_strlen_char $t1
		push_stack(CLIB_strlen_strAddress, CLIB_strlen_counter, CLIB_strlen_char)
		
		move 		CLIB_strlen_strAddress, $str
		li		CLIB_strlen_counter, 0
		lb 		CLIB_strlen_char, (CLIB_strlen_strAddress)
		
strlen_loop:
		beqz		CLIB_strlen_char, strlen_exit
		increment(CLIB_strlen_counter)
		increment(CLIB_strlen_strAddress)
		lb		CLIB_strlen_char, (CLIB_strlen_strAddress)
		j 		strlen_loop
strlen_exit:
		move $v0, CLIB_strlen_counter
		pop_stack(CLIB_strlen_strAddress, CLIB_strlen_counter, CLIB_strlen_char)		
		.end_macro

		.macro strlenl($str)
		push_stack($t0)
		la		$t0, $str
		strlen($t0)
		pop_stack($t0)	
		.end_macro
		
# ===========================================================================
# Macro~: strstr****************
# Description: Computes the length of the string up to, but not including the terminating null character
# strlen - Parameters: 
#	$str: A register that contains the address of the string whose length is to be computed
# strlenl - Parameters: 
#	$str: A label to the address of the string whose length is to be computed
# Return Value: The length of the string stored in $v0
# ===========================================================================
		.macro strstr($str1, $str2)
		.eqv		CLIB_strcmp_strAddress1 $a0
		.eqv		CLIB_strcmp_strAddress2 $a1
		.eqv		CLIB_strcmp_char1 $t0
		.eqv		CLIB_strcmp_char2 $t1
		.eqv		CLIB_strcmp_strLen1 $t2
		.eqv		CLIB_strcmp_strLen2 $t3
		
		push_stack(CLIB_strcmp_strAddress1, CLIB_strcmp_strAddress2, CLIB_strcmp_char1, CLIB_strcmp_char2)
		
		
		
		# if len(str2) > len(str1) : false
		# if len(str2) == len(str1) : strcmp
		# if len(str2) < len(str2) : save ending char, set to null, move str1 pointer from start to end and strcmp
		
		
		pop_stack(CLIB_strcmp_strAddress1, CLIB_strcmp_strAddress2, CLIB_strcmp_char1, CLIB_strcmp_char2)
		.end_macro

