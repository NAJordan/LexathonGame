package lexathon;
import java.util.*;
import java.io.*;
import java.util.Timer;
import java.util.TimerTask;
/*
Author: Brian Hoang

GENERAL LEXATHON ALGORITHM:

1. Randomly generate 9 letters, and designate one as the required/middle letter.
   a. The 9 letters will be displayed in a 3x3 format.
2. Parse the dictionary.txt file for words that contain only the 9 letters.
3. Store the qualified words into an ArrayList.
4. Have the user input a word.
   a. If the word is invalid (doesn't match with any qualfied words), return an 
      error and prompt the user for another word.
   b. If the word is valid, store it in a found words ArrayList and return a 
      notification and updated time and count of found words 
      (e.g. Found 10 of 93 words).
   c. If the word is repeated (valid but already found), return an error and
      prompt the user for another word.
   d. If the user enters "#", that will shuffle the letters.
   e. If the users enters "quit", that will quit the game.
5. Continue prompting until the user enters "quit", time runs out, or all words 
   are found.

LATEST VERSION NOTES:

1. Letter shuffling works.
2. Vowel enforcement works.
3. Repeated qualified words now return a unique error.
4. The file path is local to Brian's computer.
5. Still need to account for time.
*/
public class Lexathon {

    public static void main(String[] args) throws IOException {
        Random rand = new Random(); // Create a new Random object
        char[] letters = new char[9]; // Create an array for the letters
        boolean hasVowel = false; // Create a flag for whether or not there's at least one vowel
        
        do {
            // Randomly pick 9 letters and store them in the array
            for (int count = 0; count < 9; count++) {
                letters[count] = (char)(rand.nextInt(26) + 'a');
                // If the array contains at least one vowel, then set the flag to true
                if (letters[count] == 'a' || letters[count] == 'e' ||
                        letters[count] == 'i' || letters[count] == 'o' ||
                        letters[count] == 'u') {
                    hasVowel = true;
                }
            }
        } while (hasVowel == false);
        
        // Display the letters in a 3x3 format
        for (int count = 0; count < 9; count++) {
            System.out.print(letters[count] + " ");
            
            // If a row has 3 letters, start on a new line
            if (((count + 1) % 3) == 0) {
                System.out.println();
            }
        }
        
        List<String> qualWords = new ArrayList<String>(); // Initializes an ArrayList for qualified words
        List<String> foundWords = new ArrayList<String>(); // Initializes an ArrayList for found words
        
        // Input the dictionary.txt file
        File dictionary = new File("C:/Users/Brian/Documents/GitHub/LexathonGame/dictionary.txt");
        Scanner words = new Scanner(dictionary);
        
        // For every word in the dictionary file...
        while(words.hasNext()) {
            boolean hasQualLetters = true, hasMidLetter = false;
            String temp = words.next();

            // Prevent words from using multiple characters that are not in our letters array by setting
            // the position bit to 0 when we used the character from the letters array.
            int usedLetterFlag = 0x000001FF;

            for (int i = 0; i < temp.length(); i++) {
                // Sets flag to false for every iteration
                hasQualLetters = false;
                
                // Set the hasQualLetters flag to false if the word contains a non-given letter
                for (int count = 0; count < 9 && !hasQualLetters; count++) {
                    if (temp.charAt(i) == letters[count] && (usedLetterFlag & (1 << count)) != 0) {
                        // Set the hasMidLetter flag to true if the word contains the middle letter
                        if(count == 4){
                            hasMidLetter = true;
                        }

                        hasQualLetters = true;
                        usedLetterFlag = usedLetterFlag & ~(1 << count);
                    }
                }
                
                // If a letter is invalid, then stop checking
                if (hasQualLetters == false) {
                    break;
                }
            }
            // If both flags are true, then add the current word to the qualWords ArrayList
            if (hasQualLetters == true && hasMidLetter == true) {
                qualWords.add(temp);
            }
        }
        words.close();
        
        boolean keepPlaying = true, match = false;
        int score = 0;
        
        // While the player hasn't entered "quit!"...
        while (keepPlaying) {
            // User inputs a word
            Scanner input = new Scanner(System.in);
            System.out.print("Enter a word, or \"quit!\" to stop the game: ");
            String userWord = input.next();
            
            // If the word is "quit!", then set the keepPlaying flag to false
            if (userWord.equals("quit!")) {
                keepPlaying = false;
            }
            // If the word is "#", then shuffle the letters
            else if (userWord.equals("#")) {
                
                for (int i = 0; i < letters.length; i++) {
                    // Shuffle the letters
                    int index = rand.nextInt(9);
                    if (index == 4 || i == 4) {
                        continue; // Don't touch the middle letter
                    }             
                    char temp = letters[index];
                    letters[index] = letters[i];
                    letters[i] = temp;
                     
                }
                
                // Display the letters in a 3x3 format
                for (int count = 0; count < 9; count++) {
                    System.out.print(letters[count] + " ");
            
                    // If a row has 3 letters, start on a new line
                    if (((count + 1) % 3) == 0) {
                        System.out.println();
                    }
                }
            }
            // Otherwise...
            else {
                boolean alreadyFound = false;
                // If userWord matches with one of the found words...
                for (String s: foundWords) {
                    if (userWord.equals(s)) {
                        System.out.println(userWord + " has already been found!");
                        alreadyFound = true;
                        break;
                    }
                }
                if (alreadyFound) {
                    continue;
                }
                
                // If userWord matches with one of the qualified words...
                for (String s: qualWords) {
                    if (userWord.equals(s)) {
                        match = true; // Update the flag
                        score++; // Update the score
                        foundWords.add(userWord); // Add userWord to the foundWords ArrayList
                        System.out.println("Nice job! You found " + foundWords.size() + 
                                " of " + qualWords.size() + " words.\n");
                        
                        break;
                    }
                }
                // If userWord does not match with one of the qualified words...
                if (match == false) {
                    System.out.println("This word does not qualify. Try again!"); // Display an error
                }
                else {
                    match = false; // Reset match flag to true
                }
            }
        }
        
        System.out.println("Your final score is: " + score + "\n"); // Display final score after quitting game
    }    
}
