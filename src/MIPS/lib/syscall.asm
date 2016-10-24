# ===========================================================================
# Name: Michael Hollister
# Class: CS 3340.501
# Description: This file implements commonly used macros used for assignments and projects
# Dependencies: macros.asm
# Notes: Return value registers are NOT saved prior to macro invocation. The caller is responsible to save those registers if the value is to be retained.
#	 Search for the tilde character ‘~’ to easily search for macro implementation.
#
# Macro list: Some macros contain variations to accept different types of parameters
# * = Not implemented yet
#
# Printing Services:
# - print_int
# - print_intu
# - print_intHex
# - print_intBin
# - print_float*
# - print_double*
# - print_str
# - print_char
#
# Reading Services:
# - read_int
# - read_float*
# - read_double*
# - read_str
# - read_char
#
# File Services:
# - file_open
# - file_read*
# - file_write*
# - file_close
#
# Random Number Generation Services:
# - random_init
# - random_setSeed
# - random_int
# - random_intRange
# - random_float*
# - random_double*
#
# Miscellaneous Services:
# - midi_out*
# - midi_outSync*
# - time
# - sleep
# - sbrk
# - exit
#
# Heper Macros:

#
# ===========================================================================

# ***************************************************************************
# Printing Services
# ***************************************************************************

# ===========================================================================
# Macro~: print_int
# Description: Prints an integer value to the console
# Parameters: 
#	$register: The value that will be outputted as an integer
# ===========================================================================		
		.macro print_int($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 1)	
		.end_macro

# ===========================================================================
# Macro~: print_intu
# Description: Prints the unsigned integer value to the console
# Parameters: 
#	$register: The value that will be outputted to the console
# ===========================================================================		
		.macro print_intu($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 36)	
		.end_macro

# ===========================================================================
# Macro~: print_intHex
# Description: Prints the hexadecimal representation of an integer value to the console
# Parameters: 
#	$register: The value that will be outputted to the console
# ===========================================================================		
		.macro print_intHex($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 34)	
		.end_macro

# ===========================================================================
# Macro~: print_Bin
# Description: Prints the binary representation of an iinteger value to the console
# Parameters: 
#	$register: The value that will be outputted to the console
# ===========================================================================		
		.macro print_intBin($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 35)	
		.end_macro																
																	
# ===========================================================================
# Macro~: print_str
# Description: Prints a string to the console
# print_str - Parameters: 
#	$register: The adderss of the string
# print_stra - Parameters:
#	$label: A label to the address of the string
# print_strl - Parameters: 
#	$str: A doubled quoted string to be outputted. Registers are not valid parameters.
# ===========================================================================
		.macro print_str($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 4)
		.end_macro

		.macro print_stra($label)
		push_stack($a0)	
		la		$a0, $label
		li 		$v0, 4
		syscall
		pop_stack($a0)
		.end_macro

		.macro print_strl($str)
		.data
ps_str:		.asciiz		$str
		.text
		
		print_stra(ps_str)	
		.end_macro

# ===========================================================================
# Macro~: print_char
# Description: Prints a character to the console
# Parameters: 
#	$char: A register that contains the ASCII value to print
# ===========================================================================
		.macro print_char($char)
		SYSCALL_PRIVATE_InvokeSyscall($char, $a0, 11)
		.end_macro

# ***************************************************************************
# Reading Services
# ***************************************************************************

# ===========================================================================
# Macro~: read_int
# Description: Reads an integer from the console
# Parameters: 
#	$register: The register to store the read value
# ===========================================================================	
		.macro read_int($register)
		li 		$v0, 5
		syscall
		move		$register, $v0
		.end_macro

# ===========================================================================
# Macro~: read_str
# Description: Reads a string from the console
# Parameters: 
#	$address: The register that contains the address of the buffer
#	$maxCharsRead: The register that contains the value of the maximum number of characters to be read
# ===========================================================================	
		.macro read_str($address, $maxCharsRead)
		SYSCALL_PRIVATE_InvokeSyscall($address, $maxCharsRead, $a0, $a1, 8)
		.end_macro

# ===========================================================================
# Macro~: read_char
# Description: Reads an integer from the console
# Parameters: 
#	$register: The register to store the read value
# ===========================================================================	
		.macro read_char($register)
		li 		$v0, 12
		syscall
		move		$register, $v0
		.end_macro

# ***************************************************************************
# File Services
# ***************************************************************************

# ===========================================================================
# Macro~: file_open
# Description: Opens a file for reading or writing
# file_open - Parameters: 
#	$filename: A register that contains the address to a string that contains the path to the file
#	$mode: A register value value of 0 (read), 1 (write), or 9 (append)
# file_openli - Parameters: 
#	$filename: A label to of the string that contains the path to the file
#	$mode: An immediate value of 0 (read), 1 (write), or 9 (append)
# Return Value: The file descriptor in $v0
# ===========================================================================
		.macro file_open($filename, $mode)
		SYSCALL_PRIVATE_InvokeSyscall($filename, $mode, $a0, $a1, 13)	 # $a2 is ignored		
		.end_macro

		.macro file_openli($filename, $mode)
		.data
fopenli_file:	.asciiz		$filename
		.text
		
		push_stack($t0, $t1)
		la		$t0, fopenli_file
		li		$t1, $mode
		file_open($t0, $t1)
		pop_stack($t0, $t1)	
		.end_macro
		

# ===========================================================================
# Macro~: file_close
# Description: Closes the file descriptor accociated with the file
# fclose - Parameters: 
#	$fd: A register that contains the file descriptor
# ===========================================================================
		.macro file_close($fd)
		SYSCALL_PRIVATE_InvokeSyscall($stream, $a0, 16)	
		.end_macro


# ***************************************************************************
# Random Number Generation Services
# ***************************************************************************

# ===========================================================================
# Macro~: random_init
# Description: Sets up a random number generator by setting the seed to a random value
# Parameters: 
#	$id: The register that stores the id of the pseudorandom number generator
# ===========================================================================	
		.macro random_init($id)
		time()
		random_setSeed($id, $v0)
		.end_macro

		.macro random_initl($id)
		push_stack($a0)
		la		$a0, $id
		time()
		random_setSeed($a0, $v0)
		pop_stack($a0)
		.end_macro

# ===========================================================================
# Macro~: random_setSeed
# Description: Sets the random number generator's seed value
# Parameters:
#	$id: The register that stores the id of the pseudorandom number generator 
#	$register: The register that stores the seed value
# ===========================================================================	
		.macro random_setSeed($id, $seed)
		SYSCALL_PRIVATE_InvokeSyscall($id, $seed, $a0, $a1, 40)
		.end_macro

# ===========================================================================
# Macro~: random_int
# Description: Generates a random interger value
# Parameters: 
#	$id: The register that stores the id of the pseudorandom number generator
# Return Value: A random number in $v0
# ===========================================================================	
		.macro random_int($id)
		push_stack($a0)
		move		$a0, $id
		li 		$v0, 41
		syscall
		move		$v0, $a0
		pop_stack($a0)
		.end_macro

# ===========================================================================
# Macro~: random_intRange
# Description: Generates a random integer value within a specified range
# random_intRange - Parameters: 
#	$id: The register that stores the id of the pseudorandom number generator
#	$upperBound: The register that stores the upper limit (exclusive) of the value generated
# random_intRangeli - Parameters: 
#	$id: The label that points to the id of the pseudorandom number generator
#	$upperBound: An immediate value that is the upper limit (exclusive) of the value generated
# Return Value: A random number between 0 and upperBound - 1 in $v0
# ===========================================================================	
		.macro random_intRange($id, $upperBound)
		push_stack($a0, $a1)
		move		$a0, $id
		move		$a1, $upperBound
		li 		$v0, 42
		syscall
		move		$v0, $a0
		pop_stack($a0, $a1)
		.end_macro

		.macro random_intRangeli($id, $upperBound)
		push_stack($a0, $a1)
		la		$a0, $id
		li		$a1, $upperBound
		random_intRange($a0, $a1)
		pop_stack($a0, $a1)
		.end_macro


# ***************************************************************************
# Miscellaneous Services
# ***************************************************************************

# ===========================================================================
# Macro~: time
# Description: Gets the current system time
# Return Value: The low order 32 bits in $v0 and high order 32 bits in $v1
# ===========================================================================		
		.macro time()
		push_stack($a0, $a1)
		li 		$v0, 30
		syscall
		move		$v0, $a0
		move		$v1, $a1
		pop_stack($a0, $a1)
		.end_macro

# ===========================================================================
# Macro~: sleep
# Description: Causes MARS to sleep
# sleep - Parameters: 
#	$register: Number of milliseconds to sleep
# sleepi - Parameters:
#	$register: Number of milliseconds to sleep
# ===========================================================================
		.macro sleepi($value)
		push_stack($a0)	
		li		$a0, $value
		li 		$v0, 32
		syscall
		pop_stack($a0)		
		.end_macro
		
		.macro sleep($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 32)	
		.end_macro

# ===========================================================================
# Macro~: sbrk
# Description: Allocates heap memory
# Parameters: 
#	$register: Number of bytes to allocate
# ===========================================================================		
		.macro sbrk($register)
		SYSCALL_PRIVATE_InvokeSyscall($register, $a0, 9)	
		.end_macro

# ===========================================================================
# Macro~: exit
# Description: Terminates the application
# exit - Parameters: 
#	$status: A register that contains the status value to be returned to the parent
# exiti - Parameters: 
#	$status: An immediate status value to be returned to the parent
# ===========================================================================
		.macro exiti($status)
		# Registers are not saved since program is about to terminate
		li		$a0, $status
		li 		$v0, 17
		syscall
		.end_macro

		.macro exit($status)
		# Registers are not saved since program is about to terminate
		move		$a0, $status
		li 		$v0, 17
		syscall
		.end_macro
						
		.macro exit()
		exit($zero)
		.end_macro


# ===========================================================================
# Private macros used by the syscall.asm library
# ===========================================================================
		.macro SYSCALL_PRIVATE_InvokeSyscall($argument, $syscallArgument, $syscallCode)
		SYSCALL_PRIVATE_InvokeSyscall($argument, $zero, $syscallArgument, $zero, $syscallCode)	
		.end_macro
		
		.macro SYSCALL_PRIVATE_InvokeSyscall($arg0, $arg1, $syscallArg0, $syscallArg1, $syscallCode)
		push_stack($syscallArg0, $syscallArg1)	
		move		$syscallArg0, $arg0
		move		$syscallArg1, $arg1
		li 		$v0, $syscallCode
		syscall
		pop_stack($syscallArg0, $syscallArg1)	
		.end_macro
