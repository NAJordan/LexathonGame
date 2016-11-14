# ===========================================================================
# Insert other boilerplate information...
# How to run:
# ===========================================================================
		.include 	"lib/macros.asm"
		.include 	"lib/syscall.asm"
		.include	"lib/c-library.asm"
		.globl		main

		.data

# ***************************************************************************
# Arrays
# ***************************************************************************

qualWords:	.space		1000
		.eqv		qualWords_size 250

foundWords:	.space		1000
		.eqv		foundWords_size 250


letters:	.space		9
		.eqv		letters_size 9		# Address: 0x100107D4

# ***************************************************************************
# Variables
# ***************************************************************************

dictionaryPtr:	.space		4
		.eqv		dictionary_size 1584896

randomNumberGen: .word		0

# ***************************************************************************
# Constants
# ***************************************************************************

string_quit:	.asciiz		"quit"
string_pound:	.asciiz		"#"

		.text
main:
		random_initl(randomNumberGen)
		call(loadDictionary)
		call(newGame)
		call(printUI)
		call(gameLoop)
		exit()


# ***************************************************************************
# Subroutines
# ***************************************************************************

# ===========================================================================
loadDictionary: # Loads a word dictionary from a file into the heap
# ===========================================================================

		# Note: File path is relative to MARS jar file
		.eqv		newGame_fileDescriptor $t0
		file_openli("/home/michael/windows/devenv/src/GitHub/LexathonGame/src/MIPS/dictionary.txt", 0)
		move		newGame_fileDescriptor, $v0
		
		# Not enough memory in the static data section to hold 1.6MB
		sbrki(dictionary_size)
		sw		$v0, dictionaryPtr
		file_readi(newGame_fileDescriptor, $v0, dictionary_size) 
		
		file_close(newGame_fileDescriptor)
		jr		$ra

# ===========================================================================
newGame: # Picks 9 random letters and stores all possible words that can that can be formed with those letters 
# ===========================================================================
		call(pickLetters)
		call(findWordsInDictionary)

# ===========================================================================
pickLetters: # Picks 9 random letters and stores them into the letters array
# ===========================================================================
		clearArrayi(qualWords, qualWords_size)
		clearArrayi(foundWords, foundWords_size)
		clearArrayi(letters, letters_size)
	
		.eqv		pickLetters_iterator $t0
		.eqv		pickLetters_hasVowel $t1
		.eqv		pickLetters_chracter $t2
		li		pickLetters_iterator, 0
		li		pickLetters_hasVowel, 0
		
pickLettersLoopStart:
		bnez		pickLetters_hasVowel, pickLettersEnd
		
		for(pickLetters_iterator, 0, letters_size, pickLettersLoop, pickLettersLoopEnd)	
pickLettersLoop:
		random_intRangeli(randomNumberGen, 26)
		add		$v0, $v0, 97
		sb		$v0, letters(pickLetters_iterator)

		lw		pickLetters_chracter, letters(pickLetters_iterator)
		beq		pickLetters_chracter, ASCII_A, pickLettersSetVowel
		beq		pickLetters_chracter, ASCII_E, pickLettersSetVowel
		beq		pickLetters_chracter, ASCII_I, pickLettersSetVowel
		beq		pickLetters_chracter, ASCII_O, pickLettersSetVowel
		beq		pickLetters_chracter, ASCII_U, pickLettersSetVowel
		
		j 		pickLettersLoopIncrement
		
pickLettersSetVowel:
		li		pickLetters_hasVowel, 1

pickLettersLoopIncrement:
		jr		$ra
		
pickLettersLoopEnd:
		j		pickLettersLoopStart

pickLettersEnd:
		jr 		$ra


# ===========================================================================
findWordsInDictionary: # Picks 9 random letters and stores them into the letters array
# ===========================================================================

		.eqv		findDictionaryWords_iterator 		$t0
		.eqv		findDictionaryWords_qualWordsPtr 	$t1
		li		findDictionaryWords_qualWordsPtr, 0
		
		for(findDictionaryWords_iterator, 0, dictionary_size, findDictionaryWords, findDictionaryWordsEnd)

findDictionaryWords:

		.eqv		findDictionaryWords_dictionaryIterator 	$t2
		.eqv		findDictionaryWords_character 		$t3
		.eqv		findDictionaryWords_wordLength 		$t4
		
		la		findDictionaryWords_dictionaryIterator, dictionaryPtr
		la		findDictionaryWords_character, (findDictionaryWords_dictionaryIterator)
		
		bne		findDictionaryWords_character, ASCII_LF, findDictionaryWordsIncrement
		.eqv		findDictionaryWords_hasQualLetters 	$t5
		.eqv		findDictionaryWords_hasMidLetter 	$t6
		.eqv		findDictionaryWords_temp 		$t7
		.eqv		findDictionaryWords_usedLetterFlag 	$t8
		
		li		findDictionaryWords_hasQualLetters, 1
		li		findDictionaryWords_hasMidLetter, 0
		sub		findDictionaryWords_temp, findDictionaryWords_dictionaryIterator, findDictionaryWords_wordLength
		li		findDictionaryWords_usedLetterFlag, 0x000001FF
		
		
		.eqv		isWordInDictionary_iterator 		$t9
		for(isWordInDictionary_iterator, 0, findDictionaryWords_wordLength, isWordInDictionary, isWordInDictionaryEnd)
isWordInDictionary:
		li		findDictionaryWords_hasQualLetters, 0
		
		.eqv		iterateWord_iterator 			$s0
		for(iterateWord_iterator, 0, 9, iterateWord, iterateWordEnd)
iterateWord:
		bnez		findDictionaryWords_hasQualLetters, iterateWordStart	
		breakLoop(iterateWordEnd, iterateWord_iterator)
		
iterateWordStart:
		.eqv		iterateWord_character 			$s1
		.eqv		iterateWord_lettersCharacterAtIndex 	$s2
		.eqv		iterateWord_usedLetterFlagMask 		$s3
		.eqv		iterateWord_usedLetterFlagShiftValue 	$s4
		
		add		iterateWord_character, findDictionaryWords_temp, iterateWord_iterator
		la		iterateWord_character, (iterateWord_character)
		la		iterateWord_lettersCharacterAtIndex, letters(iterateWord_iterator)
		li		iterateWord_usedLetterFlagShiftValue, 1
		
		sllv		iterateWord_usedLetterFlagShiftValue, iterateWord_usedLetterFlagShiftValue, iterateWord_iterator
		and		iterateWord_usedLetterFlagMask, findDictionaryWords_usedLetterFlag, iterateWord_usedLetterFlagShiftValue
		
		bne		iterateWord_character, iterateWord_lettersCharacterAtIndex, iterateWordIncrement
		beqz		iterateWord_usedLetterFlagMask, iterateWordIncrement
		
		bne		iterateWord_iterator, 4, iterateWordSetFlags
		li		findDictionaryWords_hasMidLetter, 1
		
iterateWordSetFlags:
		
		li		findDictionaryWords_hasQualLetters, 1
		
		li		iterateWord_usedLetterFlagShiftValue, 1
		sllv		iterateWord_usedLetterFlagShiftValue, iterateWord_usedLetterFlagShiftValue, iterateWord_iterator
		not		iterateWord_usedLetterFlagShiftValue, iterateWord_usedLetterFlagShiftValue		
		and 		findDictionaryWords_usedLetterFlag, findDictionaryWords_usedLetterFlag, iterateWord_usedLetterFlagShiftValue

		j		iterateWordIncrement
		
iterateWordIncrement:
		jr		$ra
iterateWordEnd:
		
		bnez		findDictionaryWords_hasQualLetters, isWordInDictionaryIncrement
		breakLoop(isWordInDictionaryEnd, isWordInDictionary_iterator)
		
isWordInDictionaryIncrement:
				
		jr		$ra
isWordInDictionaryEnd:


findDictionaryWordsIncrement:
		
		increment(findDictionaryWords_dictionaryIterator)
		increment(findDictionaryWords_wordLength)
		jr		$ra
findDictionaryWordsEnd:


		.eqv		findDictionaryWords_result $t0
		and		findDictionaryWords_result, findDictionaryWords_hasQualLetters, findDictionaryWords_hasMidLetter
		beqz		findDictionaryWords_result, findWordsInDictionaryEnd
		
		sw		findDictionaryWords_temp, qualWords(findDictionaryWords_qualWordsPtr)
		increment(findDictionaryWords_qualWordsPtr, 4)
		
findWordsInDictionaryEnd:

		jr		$ra

# ===========================================================================
printUI: # Prints out the game board and help information
# ===========================================================================

		arrayIndex(letters, 0)
		move $t0, $v0
		arrayIndex(letters, 1)
		move $t1, $v0		
		arrayIndex(letters, 2)
		move $t2, $v0		
		printf(" --- --- --- \n")
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")
		
		arrayIndex(letters, 3)
		move $t0, $v0
		arrayIndex(letters, 4)
		move $t1, $v0		
		arrayIndex(letters, 5)
		move $t2, $v0		
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")
				
		arrayIndex(letters, 6)
		move $t0, $v0
		arrayIndex(letters, 7)
		move $t1, $v0		
		arrayIndex(letters, 8)
		move $t2, $v0						
		printf("| %c | %c | %c |\n", $t0, $t1, $t2)
		printf(" --- --- --- \n")	

		jr		$ra

#===========================================================================
gameLoop: # Current corresponding java code
#===========================================================================
 
 		.eqv		gameLoop_keepPlaying 	$t0
 		.eqv		gameLoop_match		$t1
 		.eqv		gameLoop_score		$t2
 		
 		li		gameLoop_keepPlaying, 1
 		li		gameLoop_match, 0
 		li		gameLoop_score, 0

gameLoopStart:
 		beqz		gameLoop_keepPlaying, gameLoopEnd
		
		.data
gameLoopInputBuffer:	.space 		10
		.text
		
		.eqv		gameLoop_input		$t3
		.eqv		gameLoop_strQuit	$t4
		.eqv		gameLoop_strPound	$t5
		la		gameLoop_input, gameLoopInputBuffer
		la		gameLoop_strQuit, string_quit
		la		gameLoop_strPound, string_pound

		print_strl("Enter a word, or \"quit!\" to stop the game: \n")
		read_stri(gameLoop_input, 9)
		
		strcmp(gameLoop_input, gameLoop_strQuit)
		bnez		$v0, gameLoopShuffle
		j		gameLoopEnd
		
gameLoopShuffle:
		
		strcmp(gameLoop_input, gameLoop_strPound)
		bnez		$v0, gameLoopIsValidWord

		.eqv		gameLoop_ShuffleIterator 	$t6
		.eqv		gameLoop_LettersIndex		$t7
		.eqv		gameLoop_tempCharIndex		$t8
		.eqv		gameLoop_tempCharIterator	$t9
		for(gameLoop_ShuffleIterator, 0, 9, gameLoopShuffleLoop, gameLoopShuffleLoopEnd)
		
gameLoopShuffleLoop:
		random_intRangeli(randomNumberGen, 9)
		move		gameLoop_LettersIndex, $v0
		
		
#                for (int i = 0; i < letters.length; i++) {
#                    // Shuffle the letters
#                    int index = rand.nextInt(9);
#                    if (index == 4 || i == 4) {
#                        continue; // Don't touch the middle letter
#                    }             
#                     
#                }
		
		lb		gameLoop_tempCharIndex, letters(gameLoop_LettersIndex)
		lb		gameLoop_tempCharIterator, letters(gameLoop_ShuffleIterator)
		sw		gameLoop_tempCharIterator, letters(gameLoop_LettersIndex)
		sw		gameLoop_tempCharIndex, letters(gameLoop_ShuffleIterator)
		
		jr		$ra
gameLoopShuffleLoopEnd:		



gameLoopIsValidWord:


		call(printUI)
		

#        // While the player hasn't entered "quit!"...
#        while (keepPlaying) {
#            // User inputs a word
#            Scanner input = new Scanner(System.in);
#            System.out.print("Enter a word, or \"quit!\" to stop the game: ");
#            String userWord = input.next();
#            
#            // If the word is "quit!", then set the keepPlaying flag to false
#            if (userWord.equals("quit!")) {
#                keepPlaying = false;
#            }
#            // If the word is "#", then shuffle the letters
#            else if (userWord.equals("#")) {
#                
#                for (int i = 0; i < letters.length; i++) {
#                    // Shuffle the letters
#                    int index = rand.nextInt(9);
#                    if (index == 4 || i == 4) {
#                        continue; // Don't touch the middle letter
#                    }             
#                    char temp = letters[index];
#                    letters[index] = letters[i];
#                    letters[i] = temp;
#                     
#                }
#                
#                // Display the letters in a 3x3 format
#                for (int count = 0; count < 9; count++) {
#                    System.out.print(letters[count] + " ");
#            
#                    // If a row has 3 letters, start on a new line
#                    if (((count + 1) % 3) == 0) {
#                        System.out.println();
#                    }
#                }
#            }
#            // Otherwise...
#            else {
#                boolean alreadyFound = false;
#                // If userWord matches with one of the found words...
#                for (String s: foundWords) {
#                    if (userWord.equals(s)) {
#                        System.out.println(userWord + " has already been found!");
#                        alreadyFound = true;
#                        break;
#                    }
#                }
#                if (alreadyFound) {
#                    continue;
#                }
#                
#                // If userWord matches with one of the qualified words...
#                for (String s: qualWords) {
#                    if (userWord.equals(s)) {
#                        match = true; // Update the flag
#                        score++; // Update the score
#                        foundWords.add(userWord); // Add userWord to the foundWords ArrayList
#                        System.out.println("Nice job! You found " + foundWords.size() + 
#                                " of " + qualWords.size() + " words.\n");
#                        
#                        break;
#                    }
#                }
#                // If userWord does not match with one of the qualified words...
#                if (match == false) {
#                    System.out.println("This word does not qualify. Try again!"); // Display an error
#                }
#                else {
#                    match = false; // Reset match flag to true
#                }
#            }
#        }

gameLoopContinue:
		j		gameLoopStart

gameLoopEnd:
		printf("Your final score is: %i\n", gameLoop_score)
		jr		$ra


