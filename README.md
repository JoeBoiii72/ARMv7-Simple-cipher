# ARMv7-Simple-cipher
- A simple cipher in the ARMv7 assembly language

- The actual text to be encrypted/decrypted is passed to the program using standard
input. 

- The program then returns its output using standard output.

- The key lengths must be co-prime. If this requirement is not met, the program will return the following error message, "Key lengths are not co-prime".


# Usage

./cipher 1 keystring1 keystring2

- The first argument must be 0 or 1 denoting encryption/decryption.
- The second argument must be a string representing the first private key.
- The third argument must be a string representing the second private key.

so...

cat textfile.txt | ./cipher 0 keystring1 keystring2 | ./cipher 1 keystring1 keystring2

...will return the original text from textfile.txt, albeit lower case and without
white spaces and punctuation.
