@---------------------------------------------------------------------------------------@
@  cw1.s																				@
@																						@
@  Author: Joe Kenyon, Jardel Kerr														@
@																						@
@  Last Updated: 30/10/2019		         												@
@ 																						@
@  Description: Encrypt and decrypt text sent through standard input using two keys.	@
@	E = (27 - key) + plain																@
@	D = (cipher - 27) + key																@
@    Cipher/plain text is then outputted through standard output.						@
@---------------------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
@------------       Equivilent working C implementation      -------------@
@-------------------------------------------------------------------------@


@ int getGCD(int length1, int length2)
@ {
@     while(length1 != length2)
@     {
@         if(length1 > length2)
@             length1 = length1 - length2;
@         if(length1 < length2)
@             length2 = length2 - length1;
@     }
@     return length2;
@ }


@ char encryptChar(char c, char key)
@ {
@     c = (27 - k1) + c;
@     if(c > 'z')
@         c = c - 26;
@
@     return c;
@ }


@ int getlength(char* key)
@ {
@     int keyLength = 0;
@     for(keyLength = 0;key[keyLength] != '\0';keyLength++);
@     return keyLength;
@ }


@ char decryptChar(char c, char key)
@ {
@     c = c - 27 + k1;
@     while(c < 'a')
@         c = c + 26;
@ 
@     return c;
@ }


@ int proccessChar(char c)
@ {
@     if(c < 'A')
@         return -2;
@     if(c > 'z')
@         return -2;
@     if(c < 90)
@         c = c + 32;
@     if(c < 97)
@         return -2;
@     return c;
@ }


@ int main(int argc, char *argv[])
@ {
@     char* mode = argv[1];
@     char* key1 = argv[2];
@     char* key2 = argv[3];
@
@     int key1Length;
@     int key2Length;
@
@     int key1Length = getlength(key1);
@     int key2Length = getlength(key2);
@
@     if( getGCD(key1Length, key2Length) != 1)
@     {
@         printf("Key lengths are not co-prime");
@         return 0;
@     }
@
@     int counter1 = 0;
@     int counter2 = 0;
@  
@     while(1)
@     {
@         int c = getchar();
@
@         if(c == EOF)
@             break;
@       
@         if(counter1 == key1Length)
@             counter1 = 0;
@         if(counter2 == key2Length)
@             counter2 = 0;
@
@         c = proccessChar(c);
@
@         //invalid char
@         if(c == -2)
@             continue;
@
@         //normalize keys
@         char k1 = key1[counter1] - 97;
@         char k2 = key2[counter2] - 97;
@       
@         if( mode[0] == '0')
@         {
@             c = encryptChar(encryptChar(c,k1),k2);
@         }
@         else
@         {
@             c = decryptChar(decryptChar(c,k1),k2);
@         }
@              
@         putchar(c);
@
@         counter1++;
@         counter2++;
@     }
@
@     return 0;
@ }
@-------------------------------------------------------------------------------@

.data
	errorMsg: .asciz "Key lengths are not co-prime\n"
.text
	.global main


main:
	
@--------notable registers and their use----------@
	@r4,  key1 characters
	@r5,  key1 base address
	@r6,  key1 length
	@r7,  counter for key1
	@r8,  key2 base address
	@r9,  mode (encryption/decryption)
	@r10, key2 length
	@r11, counter for key2
	@r12, key2 characters
@--------------------------------------------------@


	PUSH {r4-r12, lr}
		
	@get mode
	LDR  r8, [r1, #4]
	LDRB r9, [r8, #0]
	
	@load keys
	LDR r5, [r1, #8]  @key1
	LDR r8, [r1, #12] @key2

	@get length of key1
	MOV r0, r5
	BL getlength
	MOV r6, r2 

	@get length of key2
	MOV r0, r8
	BL getlength
	MOV r10, r2
		
	@check if co prime
	@getGCD(num1, num2)
	MOV r0, r10 @Key1
	MOV r1, r6  @key2
	BL getGCD

	CMP r2, #1
	BNE notCoPrime
	
	@start main loop
	MOV r7, #0  @counter 1 (for key1)
	MOV r11, #0 @counter 2 (for key2)
	
	loop:

		BL getchar
		MOV r0, r0

		@eof, exit program
		CMP r0, #-1
		BEQ exit

@------- reset key counters if they hit their length -----@
		CMP r7, r6
		MOVEQ r7, #0
		CMP r11, r10
		MOVEQ r11, #0

@--------------------------------------------------@
		
@----Handle processed chars appropriatly -----@

		BL proccessChar
		@ignore invalid char
		CMP r2, #-2
		BEQ loop

@----------------------------------------------@

@--------  Load keys and check if encrypting or decrypting  ---------@

		@load keys into memory
		LDRB r4, [r5, r7] @ key1
		LDRB r12, [r8, r11]@ key2

		@if 0 encrypt, else decrypt
		CMP r9, #48
		BEQ encryption
		BNE decryption

@--------------------------------------------------------------------@



@------ perform encryption / decryption twice, one for each key ----@

		encryption:
			MOV r0, r2 @plain text
			MOV r1, r4 @key1
			BL encryptChar

			MOV r0, r2 @plain text
			MOV r1, r12 @key2
			BL encryptChar
			MOV r0, r2
			B output


		decryption:
			MOV r0, r2 @cipher text
			MOV r1, r4 @key1
			BL decryptChar

			MOV r0, r2 @cipher text
			MOV r1, r12 @key2
			BL decryptChar
			MOV r0, r2
			B output

@------------------------------------------------------------------------@
		
		output:

		BL putchar

		ADD r7, #1
		ADD r11, #1
		B loop
	
	@print relevant error message if two keys are not co prime
	notCoPrime:
		LDR r0, =errorMsg
		BL printf
	
	exit:	

	POP {r4-r12, lr}
	BX lr



@-------------------------------------------------------@
	@Returns the length of a null terminated string
	@r0, key address
	@r2, length of key
@-------------------------------------------------------@


getlength: @int getlength(char* key);

	MOV r2, #0

	l:
		LDRB r3, [r0], #1
		CMP r3, #0
		ADDNE r2, #1
		BNE l

	BX lr
	
@-----------------------------------------------------------------@

@ int getlength(char* key)
@ {
@     int keyLength = 0;
@     for(keyLength = 0;key[keyLength] != '\0';keyLength++);
@     return keyLength;
@ }

@-----------------------------------------------------------------@




@-------------------------------------------------------@
	@calculates the Greatest common divisor
	@r0 first number
	@r1 first number
	@r2 gcd of both numbers
@-------------------------------------------------------@

getGCD: @int getGCD(int length1, int length2);

	gcd:
        CMP r0, r1
        SUBGT r0, r0, r1
        SUBLE r1, r1, r0
        BNE gcd

	MOV r2, r0
	BX lr

@--------------------------------------@

@ int getGCD(int length1, int length2)
@ {
@     while(length1 != length2)
@     {
@         if(length1 > length2)
@             length1 = length1 - length2;
@         if(length1 < length2)
@             length2 = length2 - length1;
@     }
@     return length2;
@ }

@--------------------------------------@




@-------------------------------------------------------@
	@Proccesses each character and ensures its within the lowercase alphabet
	@r0, input character
	@r2, processed character
	@return values
		@-2 if invalid char
		@otherwise a value between 97 - 122 will be returned
@-------------------------------------------------------@

proccessChar: @int proccessChar(char c)

	@Most common output
	MOV r2, #-2
	
	@less than 'A' its invalid
	CMP r0, #65
	BLT end
	
	@greater than 'z' its invalid
	CMP r0, #122
	BGT end
	
	@convert to lowercase if required
	CMP r0, #90
	ADDLE r0, #32

	@between 'Z' and 'a' its invalid
	CMP r0, #97
	BLT end

	@move processed char to return register
	MOV r2, r0

	end:
		BX lr

@--------------------------------------@

@ int proccessChar(char c)
@ {
@     if(c < 'A')
@         return -2;
@     if(c > 'z')
@         return -2;
@     if(c < 90)
@         c = c + 32;
@     if(c < 97)
@         return -2;
@     return c;
@ }

@-----------------------------------@	




@-------------------------------------------------------@
	@Encrypts a character using the formular --> E = (27 - key) + plain
	@r0 plaintext
	@r1 key
	@r2 ecypted char
@-------------------------------------------------------@

encryptChar: @char encryptChar(char c, char key)

	@normilize key between 0 - 25
	SUB r1, #97

	MOV r2, #27
	SUB r2, r1 @(27 - key)
	ADD r2, r0 @ + plain 
	
	@wrap around if larger than 'Z'		
	CMP r2, #122
	SUBGT r2, #26
	CMP r2, #122
	SUBGT r2, #26

	BX lr

@-----------------------------------@

@ char encryptChar(char c, char key)
@ {
@     c = (27 - key) + c;
@     if(c > 'z')
@         c = c - 26;
@ 
@     return c;
@ }

@-----------------------------------@




@-------------------------------------------------------@
	@Decrypts a character using the formular --> D = (cipher - 27) + key
	@r0 cipherText
	@r1 key
	@r2 Decrypted char
@-------------------------------------------------------@

decryptChar: @char decryptChar(char c, char key)

	@normilize key between 0 - 25
	SUB r1, #97

	SUB r0, #27 @(cipher - 27)
	ADD r0, r1  @ + key
			
	@loop round in needed
	CMP r0, #97
	ADDLT r0, #26		
	CMP r0, #97
	ADDLT r0, #26

	MOV r2, r0
	BX lr

@-----------------------------------@

@ char decryptChar(char c, char key)
@ {
@     c = c - 27 + key1;
@     while(c < 'a')
@         c = c + 26;
@
@     return c;
@ }

@-----------------------------------@
