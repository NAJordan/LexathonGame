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
# stdio.h
# - printf
#
# string.h
# - strcmp
# - strlen

# ===========================================================================
		.include	"c-library/stdio.asm"
		.include	"c-library/string.asm"
