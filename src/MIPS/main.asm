# ===========================================================================
# =====                           Lexathon                              =====
# ===========================================================================
#
# Lexathon is a game which players are given a 3x3 grid of letters and must create
# as many valid words as possible within the time allotted using the middle letter
# and at least three other letters. Words must contain the middle letter exactly
# once and the other letters no more than once. The game timer starts with 60
# seconds, and 20 seconds are added after every correct word. The game is over
# whenever time runs out or the player gives up. Scoring is determined by the
# number of words found, word length, and time taken to find each word.
#
# -------------------------
# How to run the program
# -------------------------
# After loading the MARS jar distributed with this program, you assemble main.asm and run the program to play Lexathon.
#
# Notes:
# * If there are issues locating the dictionary file (e.g. Linux), replace the 'dictionaryPath' variable value to an absolute path to the dictionary
# * After re-running the program multiple times in MARS, occasionally Lexathon will dramatically slow down for loading a new game. This can be fixed
#   by exiting MARS and reloading the program.
# 
# -------------------------
# How to play
# -------------------------
# Your goal is to find as many words you can with the given letters in the time 
# allotted. Words must contain the middle letter exactly and at least three other
# letters no more than once. The game ends when times runs out or when you give up.
# 
# Commands:
# 	#: Shuffles the game board
# 	new!: Starts a new game
# 	time!: Shows current time remaining
# 	quit!: Exit from the game
# 	help!: Displays this message
#
# -------------------------
# Frys Electoronics Team
# -------------------------
# * Brian
# * Nick
# * Yusuf
# * Michael
#
# -------------------------
# Github Repository: https://github.com/NAJordan/LexathonGame
# -------------------------
# ===========================================================================
		.include 	"lib/macros.asm"
		.include 	"lib/syscall.asm"
		.include 	"lib/c-library.asm"
		.include 	"lib/macros_ex.asm"
		.globl 		main
		.data

# ***************************************************************************
# Arrays
# ***************************************************************************
qualWords:	.space		2000
		.eqv		qualWords_size 2000

foundWords:	.space		2000
		.eqv		foundWords_size 2000

letters:	.space		9
		.eqv		letters_size 9		

# https://en.oxforddictionaries.com/explore/which-letters-are-used-most
# ASCII values
letterFrequencyOrder:	.byte	0x65, 0x61, 0x72, 0x69, 0x6F, 0x74, 0x6E, 0x73, 0x6C, 0x63, 0x75, 0x64, 0x70, 0x6D, 0x68, 0x67, 0x62, 0x66, 0x79, 0x77, 0x6B, 0x76, 0x78, 0x7A, 0x6A, 0x71

# Probability
letterFrequency: 	.float	0.111607, 0.084966, 0.075809, 0.075448, 0.071635, 0.069509, 0.066544, 0.057351, 0.054893, 0.045388, 0.036308, 0.033844, 0.031671, 0.030129, 0.030034, 0.024705, 0.020720, 0.018121, 0.017779, 0.012899, 0.011016, 0.010074, 0.002902, 0.002722, 0.001965, 0.001962

# ***************************************************************************
# Global Variables
# ***************************************************************************
		.align		2
dictionaryPtr:	.space		4
		.eqv		dictionary_size 1773977

randomNumberGen: 	.word	0
qualWordsAmount: 	.word	0
foundWordsAmount: 	.word	0
gameTimer:		.word	60
gameTime:		.word	0
gameScore:		.float	0.0

# ***************************************************************************
# Constants
# ***************************************************************************

# Message same as 'How to play', but with a header
helpMessage: 	.asciiz 	"\n=======================================================\n=====            Lexathon - How to Play           =====\n=======================================================\n\nYour goal is to find as many words you can with the given letters in the time\nallotted. Words must contain the middle letter exactly and at least three other\nletters no more than once. The game ends when times runs out or when you give up.\n\nCommands:\n\t#    : Shuffles the game board\n\tnew! : Starts a new game\n\ttime!: Shows current time remaining\n\tquit!: Exit from the game\n\thelp!: Displays this message\n=======================================================\n"

# Note: If using relative path, it is relative to the MARS jar file. Otherwise if problems occur, use the absolute path.
dictionaryPath: .asciiz		"dictionary.txt"

string_quit:	.asciiz		"quit!\n"
string_pound:	.asciiz		"#\n"
string_newGame: .asciiz		"new!\n"
string_time:	.asciiz		"time!\n"
string_help:	.asciiz		"help!\n"

debug:		.byte		0
		.text
main:
		printf("Lexathon is starting up, please wait...\n")
		random_initl(randomNumberGen)
		call(loadDictionary)
		call(newGame)
		call(gameLoop)
		exit()


# ***************************************************************************
# Subroutines
# ***************************************************************************

# ===========================================================================
loadDictionary: # Loads a word dictionary from a file into the heap
# ===========================================================================
		.eqv		newGame_fileDescriptor $t0
		file_openai(dictionaryPath, 0)
		move		newGame_fileDescriptor, $v0
		
		bgez		$v0, readDictionary
		printf("ERROR: The dictionary could not be found at the specified path. Please see 'How to run the program' section in main.asm\n")
		exiti(-1)
		
readDictionary:
		# Not enough memory in the static data section to hold 1.7MB
		sbrki(dictionary_size)
		sw		$v0, dictionaryPtr
		file_readi(newGame_fileDescriptor, $v0, dictionary_size) 
		
		file_close(newGame_fileDescriptor)
		debug_printf(debug, "Finished loading dictionary\n")
		jr		$ra

# ===========================================================================
newGame: # Picks 9 random letters and stores all possible words that can that can be formed with those letters 
# ===========================================================================
		setWord(qualWordsAmount, 0)
		setWord(foundWordsAmount, 0)
		setWord(gameScore, 0)

		call(pickLetters)																																																																																																														
		call(findWordsInDictionary)
		jr		$ra
		
# ===========================================================================
pickLetters: # Picks 9 random letters and stores them into the letters array
# ===========================================================================
		clearArrayi(qualWords, qualWords_size)
		clearArrayi(foundWords, foundWords_size)
		clearArrayi(letters, letters_size)
		debug_printf(debug, "Letters array: [ ")
		
		.eqv		pickLetters_iterator 		$t0
		.eqv		pickLetters_hasVowel 		$t1
		.eqv		pickLetters_character 		$t2
		li		pickLetters_hasVowel, 0
		
pickLettersLoopStart:
		bnez		pickLetters_hasVowel, pickLettersEnd
		
		for(pickLetters_iterator, 0, letters_size, pickLettersLoop, pickLettersLoopEnd)	
pickLettersLoop:
		.eqv		selectLetter_iterator 		$t3
		.eqv		selectLetter_frequencyAddress	$t4
		.eqv		selectLetter_letterProbability	$f2
		.eqv		selectLetter_zero		$f3
		mtc1		$zero, selectLetter_zero
		li		selectLetter_frequencyAddress, 0
		random_floatl(randomNumberGen)
		
		for(selectLetter_iterator, 0, 26, selectLetterLoop, selectLetterLoopEnd)
selectLetterLoop:
		lwc1		selectLetter_letterProbability, letterFrequency(selectLetter_frequencyAddress)
		sub.s		$f0, $f0, selectLetter_letterProbability
		c.le.s		$f0, selectLetter_zero
		bc1f		selectLetterContinue
		lb		pickLetters_character, letterFrequencyOrder(selectLetter_iterator)
		breakLoop(selectLetterLoopEnd, selectLetter_iterator)
		
selectLetterContinue:
		increment(selectLetter_frequencyAddress, 4)
		jr		$ra
		
selectLetterLoopEnd:
		# Old Algorithm: Randomly select a letter
		#random_intRangeli(randomNumberGen, 26)
		#add		$v0, $v0, 97
		#move		pickLetters_character, $v0
		
		debug_printf(debug, "%c, ", pickLetters_character)
		sb		pickLetters_character, letters(pickLetters_iterator)
		beq		pickLetters_character, ASCII_A, pickLettersSetVowel
		beq		pickLetters_character, ASCII_E, pickLettersSetVowel
		beq		pickLetters_character, ASCII_I, pickLettersSetVowel
		beq		pickLetters_character, ASCII_O, pickLettersSetVowel
		beq		pickLetters_character, ASCII_U, pickLettersSetVowel
		
		j 		pickLettersLoopContinue
		
pickLettersSetVowel:
		li		pickLetters_hasVowel, 1

pickLettersLoopContinue:
		jr		$ra
		
pickLettersLoopEnd:
		j		pickLettersLoopStart

pickLettersEnd:
		debug_printf(debug, "]\n")
		jr 		$ra

# ===========================================================================
findWordsInDictionary: # Picks 9 random letters and stores them into the letters array
# ===========================================================================	
		.eqv		findWordsInDictionary_iterator 			$t0
		.eqv		findWordsInDictionary_qualWordsPtr 		$t1
		.eqv		findWordsInDictionary_strStartAddress 		$t2
		.eqv		findWordsInDictionary_loadingProgress		$s4
		.eqv		findWordsInDictionary_loadingProgressCounter	$s5
		li		findWordsInDictionary_qualWordsPtr, 0
		lw		findWordsInDictionary_strStartAddress, dictionaryPtr
		li		findWordsInDictionary_loadingProgress, 0
		li		findWordsInDictionary_loadingProgressCounter, 0
		
		lw		$a0, dictionaryPtr
		add		$a1, $a0, dictionary_size
		
		printf("Starting new game...\n")
		for(findWordsInDictionary_iterator, $a0, $a1, findWordsInDictionaryLoop, findWordsInDictionaryEnd)
findWordsInDictionaryLoop:
		# Loading progress update
		increment(findWordsInDictionary_loadingProgressCounter)
		blt	findWordsInDictionary_loadingProgressCounter, 443494, findWordsInDictionaryLoopSkipUpdate # Temp dictionary_size / 4
		li	findWordsInDictionary_loadingProgressCounter, 0
		increment(findWordsInDictionary_loadingProgress, 25)
		printf("Setting up game: %i%% complete...\n", findWordsInDictionary_loadingProgress)

findWordsInDictionaryLoopSkipUpdate:
		.eqv		findWordsInDictionary_character 		$t3
		lb		findWordsInDictionary_character, (findWordsInDictionary_iterator)
		
		bne		findWordsInDictionary_character, ASCII_NULL, findWordsInDictionaryContinue
		.eqv		findWordsInDictionary_hasQualLetters 		$t4
		.eqv		findWordsInDictionary_hasMidLetter 		$t5
		.eqv		findWordsInDictionary_usedLetterFlag 		$t6
		
		li		findWordsInDictionary_hasMidLetter, 0
		li		findWordsInDictionary_usedLetterFlag, 0x000001FF
		
		.eqv		isWordInDictionary_iterator 			$t7
		strlen(findWordsInDictionary_strStartAddress)
		decrement($v0)		# The letters array does not contain the newline character
		#printf("Testing word, len (no \n): %i, word: %s\n", $v0, findWordsInDictionary_strStartAddress)
		
		for(isWordInDictionary_iterator, 0, $v0, isWordInDictionaryLoop, isWordInDictionaryLoopEnd)
isWordInDictionaryLoop:
		.eqv		iterateWord_iterator 				$t8
		li		findWordsInDictionary_hasQualLetters, 0
		for(iterateWord_iterator, 0, 9, iterateWordLoop, iterateWordLoopEnd)
		
iterateWordLoop:
		beqz		findWordsInDictionary_hasQualLetters, iterateWordStart	
		breakLoop(iterateWordLoopEnd, iterateWord_iterator)
		
iterateWordStart:
		.eqv		iterateWord_character 				$t9
		.eqv		iterateWord_lettersCharacterAtIndex 		$s0
		.eqv		iterateWord_usedLetterFlagMask 			$s1
		.eqv		iterateWord_usedLetterFlagShiftValue 		$s2
		
		add		iterateWord_character, findWordsInDictionary_strStartAddress, isWordInDictionary_iterator
		lb		iterateWord_character, (iterateWord_character)
		lb		iterateWord_lettersCharacterAtIndex, letters(iterateWord_iterator)
		li		iterateWord_usedLetterFlagShiftValue, 1
		
		sllv		iterateWord_usedLetterFlagShiftValue, iterateWord_usedLetterFlagShiftValue, iterateWord_iterator
		and		iterateWord_usedLetterFlagMask, findWordsInDictionary_usedLetterFlag, iterateWord_usedLetterFlagShiftValue
		
		#printf("Comparing %c from dictionary to %c from letters array...\n", iterateWord_character, iterateWord_lettersCharacterAtIndex)
		bne		iterateWord_character, iterateWord_lettersCharacterAtIndex, iterateWordContinue
		beqz		iterateWord_usedLetterFlagMask, iterateWordContinue
		
		bne		iterateWord_iterator, 4, iterateWordSetFlags
		li		findWordsInDictionary_hasMidLetter, 1
		
iterateWordSetFlags:
		li		findWordsInDictionary_hasQualLetters, 1
		not		iterateWord_usedLetterFlagShiftValue, iterateWord_usedLetterFlagShiftValue		
		and 		findWordsInDictionary_usedLetterFlag, findWordsInDictionary_usedLetterFlag, iterateWord_usedLetterFlagShiftValue

iterateWordContinue:
		jr		$ra
		
iterateWordLoopEnd:
		bnez		findWordsInDictionary_hasQualLetters, isWordInDictionaryContinue
		#printf("Rejecting %s. Contains characters that are not in the leters array\n", findWordsInDictionary_strStartAddress)
		breakLoop(isWordInDictionaryLoopEnd, isWordInDictionary_iterator)
		
isWordInDictionaryContinue:	
		jr		$ra
		
isWordInDictionaryLoopEnd:
		.eqv		findWordsInDictionary_result 			$s3
		li		findWordsInDictionary_result, 1
		and		findWordsInDictionary_result, findWordsInDictionary_hasQualLetters, findWordsInDictionary_hasMidLetter
		beqz		findWordsInDictionary_result, findWordsInDictionaryNewStartAddress
		
		debug_printf(debug, "Adding word to qualWords array: %s", findWordsInDictionary_strStartAddress)
		sw		findWordsInDictionary_strStartAddress, qualWords(findWordsInDictionary_qualWordsPtr)
		incrementwl(qualWordsAmount)
		increment(findWordsInDictionary_qualWordsPtr, 4)

findWordsInDictionaryNewStartAddress:
		strlen(findWordsInDictionary_strStartAddress)
		increment($v0, 1)
		add		findWordsInDictionary_strStartAddress, findWordsInDictionary_strStartAddress, $v0
		setWord(gameScore, 0)
findWordsInDictionaryContinue:
		jr		$ra		

findWordsInDictionaryEnd:
		jr		$ra

# ===========================================================================
printUI: # Prints out the game board and help information
# ===========================================================================
		push_stack($t0, $t1, $t2)

		arrayIndex(letters, 0, $t0)
		arrayIndex(letters, 1, $t1)	
		arrayIndex(letters, 2, $t2)
				
		printf(" --- --- --- \n")
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")
		
		arrayIndex(letters, 3, $t0)
		arrayIndex(letters, 4, $t1)	
		arrayIndex(letters, 5, $t2)
			
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")
				
		arrayIndex(letters, 6, $t0)
		arrayIndex(letters, 7, $t1)	
		arrayIndex(letters, 8, $t2)
							
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")	

		getWord(foundWordsAmount)
		move $v1, $v0
		
		getWord(qualWordsAmount)
		printf("Found %i of %i words\n", $v1, $v0)
		
		getWord(gameTimer)
		printf("You have %i seconds remaining. Score: ", $v0)
		getFloat(gameScore)
		print_float($f0)
		printf("\n")
		
		printf(">> ")
		pop_stack($t0, $t1, $t2)
		jr		$ra

#===========================================================================
gameLoop: # Handles player input
#===========================================================================
			.data
gameLoopInputBuffer:	.space 		10
		.text

 		.eqv		gameLoop_keepPlaying 		$t0
 		.eqv		gameLoop_match			$t1
 		.eqv		gameLoop_foundWordsIndex	$t2
 		.eqv		gameLoop_input			$t3
 		.eqv		gameLoop_time			$t7
 		.eqv		gameLoop_timerElapsed		$t8
 		li		gameLoop_keepPlaying, 1 
 		li		gameLoop_match, 0		
		li		gameLoop_foundWordsIndex, 0
		la		gameLoop_input, gameLoopInputBuffer

		print_stra(helpMessage)
		
		time()
		setWord(gameTime, $v0)
		setWord(gameTimer, 60)

		
gameLoopStart:
		# Terminating conditions
 		beqz		gameLoop_keepPlaying, gameLoopEnd
 		getWord(foundWordsAmount)
 		move		$v1, $v0
 		getWord(qualWordsAmount)
 		beq		$v0, $v1, gameLoopEnd

 		# Time update
		time()
		move		gameLoop_time, $v0
		getWord(gameTime)
		sub		gameLoop_time, gameLoop_time, $v0
 		div		gameLoop_timerElapsed, gameLoop_time, 1000
 		decrementwl(gameTimer, gameLoop_timerElapsed)
 		mul		gameLoop_timerElapsed, gameLoop_timerElapsed, 1000
 		incrementwl(gameTime, gameLoop_timerElapsed)
 		
 		getWord(gameTimer)
 		bltz		$v0, gameLoopEnd
 		
		call(printUI)
		clearArrayi(gameLoopInputBuffer, 10)
		read_stri(gameLoop_input, 9)

		# Quit case
		strcmpl(gameLoop_input, string_quit)
		beqz		$v0, gameLoopEnd
		
		# Shuffle case
		strcmpl(gameLoop_input, string_pound)
		bnez		$v0, gameLoopNewCase
		call(shuffleGameBoard)
		j		gameLoopContinue

gameLoopNewCase:
		strcmpl(gameLoop_input, string_newGame)
		bnez		$v0, gameLoopTimeCase
		call(newGame)
		call(gameLoop)
		exit()
		
gameLoopTimeCase:
		strcmpl(gameLoop_input, string_time)
		bnez		$v0, gameLoopHelpCase
		# Let printUI display the updated time
		j		gameLoopContinue
		
gameLoopHelpCase:
		strcmpl(gameLoop_input, string_help)
		bnez		$v0, gameLoopIsValidWord
		print_stra(helpMessage)
		j		gameLoopContinue

gameLoopIsValidWord:
		.eqv		gameLoop_alreadyFound		$t4
		.eqv		gameLoop_foundWordsIterator	$t5
		.eqv		gameLoop_foundWordsString	$t6
		li		gameLoop_alreadyFound, 0
		
		for(gameLoop_foundWordsIterator, 0, foundWords_size, 4, gameLoopWordFound, gameLoopWordFoundEnd)
gameLoopWordFound:
		lw		gameLoop_foundWordsString, foundWords(gameLoop_foundWordsIterator)
		
		# End of array when null pointer is encountered
		bnez		gameLoop_foundWordsString, gameLoopCompareFoundWord
		breakLoop(gameLoopWordFoundEnd, gameLoop_foundWordsIterator)
		
gameLoopCompareFoundWord:
		strcmp(gameLoop_input, gameLoop_foundWordsString)
		
		bnez		$v0, gameLoopWordFoundContinue
		
		# Remove the newline from the output
		strlen(gameLoop_input)
		decrement($v0)
		add		$t9, gameLoop_input, $v0 	# temp using $t9
		sb		$zero, ($t9)
		
		print_str(gameLoop_input)
		printf(" has already been found!\n")
		li		gameLoop_alreadyFound, 1
		breakLoop(gameLoopWordFoundEnd, gameLoop_foundWordsIterator)
		
gameLoopWordFoundContinue:
		jr		$ra
		
gameLoopWordFoundEnd:			
		bnez		gameLoop_alreadyFound, gameLoopContinue

		.eqv		gameLoop_qualWordsIterator	$t5
		.eqv		gameLoop_qualWordsString	$t6
		
		for(gameLoop_qualWordsIterator, 0, qualWords_size, 4, gameLoopFindWord, gameLoopFindWordEnd)
gameLoopFindWord:
		lw		gameLoop_qualWordsString, qualWords(gameLoop_qualWordsIterator)
		
		# End of array when null pointer is encountered
		bnez		gameLoop_qualWordsString, gameLoopFindWordCompare
		breakLoop(gameLoopFindWordEnd, gameLoop_qualWordsIterator)
		
gameLoopFindWordCompare:
		strcmp(gameLoop_input, gameLoop_qualWordsString)

		bnez		$v0, gameLoopFindWordContinue
		li		gameLoop_match, 1
		sw		gameLoop_qualWordsString, foundWords(gameLoop_foundWordsIndex)
		increment(gameLoop_foundWordsIndex, 4)
		incrementwl(foundWordsAmount)
		
		.data
calculateScore_2f:		.float		2.0
calculateScore_multiplier:	.float		0.1
		.text
		.eqv		calculateScore_two			$f2
		.eqv		calculateScore_timeMultiplier		$f3
		.eqv		calculateScore_wordLength		$f4
		.eqv		calculateScore_result			$f5
		.eqv		calculateScore_timeBetweenEnteries	$f6
		
		l.s		calculateScore_two, calculateScore_2f
		getFloat(gameScore)
		strlen(gameLoop_input)
		decrement($v0)		# Remove the new line character from the count
		mtc1		$v0, calculateScore_wordLength
		cvt.s.w		calculateScore_wordLength, calculateScore_wordLength
		l.s		calculateScore_timeMultiplier, calculateScore_multiplier
		
		time()
		move		gameLoop_time, $v0
		getWord(gameTime)
		sub		gameLoop_time, gameLoop_time, $v0
 		div		gameLoop_timerElapsed, gameLoop_time, 1000
 		mtc1		gameLoop_timerElapsed, calculateScore_timeBetweenEnteries
		cvt.s.w		calculateScore_timeBetweenEnteries, calculateScore_timeBetweenEnteries 

		mul.s 		$f0, calculateScore_two, calculateScore_wordLength
		mul.s		calculateScore_result, calculateScore_timeMultiplier, calculateScore_timeBetweenEnteries
		sub.s		calculateScore_result, $f0, calculateScore_result
		
		# Terminate if time has ran out
		getWord(gameTimer)
		decrement($v0, gameLoop_timerElapsed)
		bgtz		$v0, gameLoopFoundWord
		li		gameLoop_keepPlaying, 0
		
gameLoopFoundWord:
		incrementwl(gameTimer, 20)
		incrementfl(gameScore, calculateScore_result)
		printf("You found a correct word, nice job!\n")
		breakLoop(gameLoopFindWordEnd, gameLoop_qualWordsIterator)	

gameLoopFindWordContinue:
		jr		$ra
		
gameLoopFindWordEnd:
		bnez		gameLoop_match, gameLoopSetMatch
		printf("This word does not qualify. Try again!\n")
		j		gameLoopContinue

gameLoopSetMatch:
		li		gameLoop_match, 0

gameLoopContinue:
		j		gameLoopStart

gameLoopEnd:
		printf("Game over! Your final score is ")
		getFloat(gameScore)
		print_float($f0)
		
		getWord(foundWordsAmount)
		move $v1, $v0
		getWord(qualWordsAmount)
		printf("\nYou found %i of %i words. Here are the words you found:\n", $v1, $v0)
		.eqv		printFoundWords_iterator	$t0
		.eqv		printFoundWords_str		$t1
		for(printFoundWords_iterator, 0, foundWords_size, 4, printFoundWordsLoop, printFoundWordsLoopEnd)
printFoundWordsLoop:
		lw		printFoundWords_str, foundWords(printFoundWords_iterator)
		bnez		printFoundWords_str, printFoundWordsStr
		breakLoop(printFoundWordsLoopEnd, printFoundWords_iterator)
		
printFoundWordsStr:		
		print_str(printFoundWords_str)
		jr		$ra
		
printFoundWordsLoopEnd:		
		printf("Thanks for playing!\n")		
		jr		$ra

#===========================================================================
shuffleGameBoard: # Rearranges the characters in the letters array 
#===========================================================================
		.eqv		shuffleGameBoard_iterator 	$t0
		.eqv		shuffleGameBoard_lettersIndex	$t1
		.eqv		shuffleGameBoard_tempChar1	$t2
		.eqv		shuffleGameBoard_tempChar2	$t3
		push_stack($t0, $t1, $t2, $t3)
		
		for(shuffleGameBoard_iterator, 0, 9, shuffleGameBoardLoop, shuffleGameBoardLoopEnd)
shuffleGameBoardLoop:
		random_intRangeli(randomNumberGen, 9)
		move		shuffleGameBoard_lettersIndex, $v0
		
		# Prevent shuffling the middle letter
		beq		shuffleGameBoard_iterator, 4, shuffleGameBoardLoopContinue
		beq		shuffleGameBoard_lettersIndex, 4, shuffleGameBoardLoopContinue
		
		lb		shuffleGameBoard_tempChar1, letters(shuffleGameBoard_lettersIndex)
		lb		shuffleGameBoard_tempChar2, letters(shuffleGameBoard_iterator)
		sb		shuffleGameBoard_tempChar2, letters(shuffleGameBoard_lettersIndex)
		sb		shuffleGameBoard_tempChar1, letters(shuffleGameBoard_iterator)

shuffleGameBoardLoopContinue:			
		jr		$ra
		
shuffleGameBoardLoopEnd:
		pop_stack($t0, $t1, $t2, $t3)		
		jr		$ra

