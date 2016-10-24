# ===========================================================================
# Insert other boilerplate information...
# How to run:
# ===========================================================================
		.include 	"lib/macros.asm"
		.include 	"lib/syscall.asm"
		.globl		main

# ***************************************************************************
# Global variables
# ***************************************************************************
		.data

qualWords:	.space		1000
		.eqv		qualWords_size 250

foundWords:	.space		1000
		.eqv		foundWords_size 250


letters:	.space		9			# Address: 0x100107D0
		.eqv		letters_size 9		
		
		.text
main:
		call(newGame)
		call(gameLoop)
		exit()


# ***************************************************************************
# Subroutines
# ***************************************************************************

# ===========================================================================
newGame: # Picks 9 random letters and stores all possible words that can that can be formed with those letters 
# ===========================================================================
		.data
# Variables
randID:		.word		0

		.text

		random_initl(randID)
		clearArrayi(qualWords, qualWords_size)
		clearArrayi(foundWords, foundWords_size)
		clearArrayi(letters, letters_size)
	
		.eqv		newGame_pickLetters_iterator $t0
		li		newGame_pickLetters_iterator, 0
		
		for(newGame_pickLetters_iterator, 0, letters_size, pickLetters, pickLettersEnd)	
pickLetters:
		random_intRangeli(randID, 26)
		add		$v0, $v0, 97
		sb		$v0, letters(newGame_pickLetters_iterator)
		jr		$ra
		
pickLettersEnd:
		
# TODO: Implement the following java code
		
# // Input the dictionary.txt file
# File dictionary = new File("C:/Users/Brian/Documents/GitHub/LexathonGame/dictionary.txt");
# Scanner words = new Scanner(dictionary);
# 
# // For every word in the dictionary file...
# while(words.hasNext()) {
#     boolean hasQualLetters = true, hasMidLetter = false;
#     String temp = words.next();
# 
#     // Prevent words from using multiple characters that are not in our letters array by setting
#     // the position bit to 0 when we used the character from the letters array.
#     int usedLetterFlag = 0x000001FF;
# 
#     for (int i = 0; i < temp.length(); i++) {
#         // Sets flag to false for every iteration
#         hasQualLetters = false;
#         
#         // Set the hasQualLetters flag to false if the word contains a non-given letter
#         for (int count = 0; count < 9 && !hasQualLetters; count++) {
#             if (temp.charAt(i) == letters[count] && (usedLetterFlag & (1 << count)) != 0) {
#                 // Set the hasMidLetter flag to true if the word contains the middle letter
#                 if(count == 4){
#                     hasMidLetter = true;
#                 }
# 
#                 hasQualLetters = true;
#                 usedLetterFlag = usedLetterFlag & ~(1 << count);
#             }
#         }
#         
#         // If a letter is invalid, then stop checking
#         if (hasQualLetters == false) {
#             break;
#         }
#     }
#     // If both flags are true, then add the current word to the qualWords ArrayList
#     if (hasQualLetters == true && hasMidLetter == true) {
#         qualWords.add(temp);
#     }
# }
# words.close();
# 
# boolean keepPlaying = true, match = false;
# int score = 0;
		
		jr		$ra

# ===========================================================================
printUI: # Current corresponding java code
# ===========================================================================

# System.out.print(letters[count] + " ");
# 
# // If a row has 3 letters, start on a new line
# if (((count + 1) % 3) == 0) {
#     System.out.println();
# }


		jr		$ra

# ===========================================================================
gameLoop: # Current corresponding java code
# ===========================================================================

# // For every word in the dictionary file...
# while(words.hasNext()) {
#     boolean hasQualLetters = true, hasMidLetter = false;
#     String temp = words.next();
#
#     // Prevent words from using multiple characters that are not in our letters array by setting
#     // the position bit to 0 when we used the character from the letters array.
#     int usedLetterFlag = 0x000001FF;
#
#     for (int i = 0; i < temp.length(); i++) {
#         // Sets flag to false for every iteration
#         hasQualLetters = false;
#         
#         // Set the hasQualLetters flag to false if the word contains a non-given letter
#         for (int count = 0; count < 9 && !hasQualLetters; count++) {
#             if (temp.charAt(i) == letters[count] && (usedLetterFlag & (1 << count)) != 0) {
#                 // Set the hasMidLetter flag to true if the word contains the middle letter
#                 if(count == 4){
#                     hasMidLetter = true;
#                 }
#
#                 hasQualLetters = true;
#                 usedLetterFlag = usedLetterFlag & ~(1 << count);
#             }
#         }
#         
#         // If a letter is invalid, then stop checking
#         if (hasQualLetters == false) {
#             break;
#         }
#     }
#     // If both flags are true, then add the current word to the qualWords ArrayList
#     if (hasQualLetters == true && hasMidLetter == true) {
#         qualWords.add(temp);
#     }
# }
# words.close();
# 
# boolean keepPlaying = true, match = false;
# int score = 0;
# 
# // While the player hasn't entered "quit!"...
# while (keepPlaying) {
#     // User inputs a word
#     Scanner input = new Scanner(System.in);
#     System.out.print("Enter a word, or \"quit!\" to stop the game: ");
#     String userWord = input.next();
#     
#     // If the word is "quit!", then set the keepPlaying flag to false
#     if (userWord.equals("quit!")) {
#         keepPlaying = false;
#     }
#     else {
#         // If userWord matches with one of the qualified words...
#         for (String s: qualWords) {
#             if (userWord.equals(s)) {
#                 match = true; // Update the flag
#                 score++; // Update the score
#                 foundWords.add(userWord); // Add userWord to the foundWords ArrayList
#                 System.out.println("Nice job! You found " + foundWords.size() + 
#                         " of " + qualWords.size() + " words.\n");
#                 
#                 break;
#             }
#         }
#         // If userWord does not match with one of the qualified words...
#         if (match == false) {
#             System.out.println("This word does not qualify. Try again!"); // Display an error
#         }
#         else {
#             match = false; // Reset match flag to true
#         }
#     }
# }
# 
# System.out.println("Your final score is: " + score + "\n"); // Display final score after quitting game

		jr		$ra


