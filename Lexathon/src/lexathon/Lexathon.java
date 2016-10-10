package lexathon;
import java.util.*;
import java.io.*;
/*
GENERAL LEXATHON ALGORITHM:

1. Randomly generate 9 letters, and designate one as the required/middle letter.
   a. The 9 letters will be displayed in a 3x3 format.
2. Parse the dictionary.txt file for words that contain only the 9 letters.
3. Store the qualified words into an ArrayList.
4. Have the user input a word.
   a. If the word is invalid (doesn't match with any qualfied words), store it
      in a rejected words ArrayList, and return an error and prompt the user for 
      another word.
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

1. The qualWords ArrayList doesn't seem to be working. I think the problem is 
   either the dictionary terms aren't inputting correctly, or I'm not checking
   it properly for a match.
2. The quit option works, though.
3. The file path is local to Brian's computer.
4. We're currently on step 4 of the algorithm above. ArrayList troubleshooting
   needs to be done, which may involve fixing step 3 of the algorithm.
*/
public class Lexathon {

    public static void main(String[] args) throws IOException {
        Random rand = new Random(); // Create a new Random object
        char[] letters = new char[9]; // Create an array for the letters
        
        // Randomly pick 9 letters, store them in the array, and display them in a 3x3 format
        for (int count = 0; count < 9; count++) {
            letters[count] = (char)(rand.nextInt(26) + 'a');
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
            else {
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
