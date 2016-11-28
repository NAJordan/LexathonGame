# Fry’s Electronics - Lexathon

## About

Lexathon is a game which players are given a 3x3 grid of letters and must create as many valid words as possible within the time allotted using the middle letter and at least three other letters. Words must contain the middle letter exactly once and the other letters no more than once. The game timer starts with 60 seconds, and 20 seconds are added after every correct word. The game is over whenever time runs out or the player gives up. Scoring is determined by the number of words found, word length, and time taken to find each word. So find as many words are you can, as quickly as you can.

## How to run the program

1. Download the zip file and unzip the contents into a local directory.
2. Load the MARS jar distributed with this program.
3. Assemble main.asm and run the program to play Lexathon.

## Notes

If there are issues locating the dictionary file (e.g. Linux), replace the 'dictionaryPath' variable value to an absolute path to the dictionary. Additionally, it is recommend to use forward slashes as the path separators rather than backslashes to prevent issues with escape characters.

After re-running the program multiple times in MARS, occasionally Lexathon will dramatically slow down for loading a new game. This can be fixed by exiting MARS and reloading the program.

## How to play

Your goal is to find as many words you can with the given letters in the time allotted. Words must contain the middle letter exactly and at least three other letters no more than once. The game ends when times runs out or when you give up.
 
## Commands
* # &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Shuffles the game board
* new! &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Starts a new game
* time! &nbsp;&nbsp;&nbsp;&nbsp; Shows current time remaining
* quit! &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Exit from the game
* help! &nbsp;&nbsp;&nbsp;&nbsp; Displays this message

## Frys Electoronics Team
* Brian
* Nick
* Yusuf
* Michael
