#include <stdio.h>
#include <string.h>


int getGCD(int length1, int length2)
{
    while(length1 != length2)
    {
        if(length1 > length2)
            length1 = length1 - length2;
        if(length1 < length2)
            length2 = length2 - length1;
    }
    return length2;
}

char encryptChar(char c, char key)
{
    c = (27 - key) + c;
    if(c > 'z')
        c = c - 26;
    return c;
}


int getlength(char* key)
{
    int keyLength = 0;
    for(keyLength = 0;key[keyLength] != '\0';keyLength++);
    return keyLength;
}

char decryptChar(char c, char key)
{
    c = c - 27 + key;
    while(c < 'a')
        c = c + 26;
    return c;
}

int proccessChar(char c)
{
    if(c < 'A')
        return -2;
    if(c > 'z')
        return -2;
    if(c < 'Z'-1)
        c = c + 32;
    if(c < 97)
        return -2;
    return c;
}


int main(int argc, char *argv[])
{
    char* mode = argv[1];
    char* key1 = argv[2];
    char* key2 = argv[3];

    int key1Length = getlength(key1);
    int key2Length = getlength(key2);

    if( getGCD(key1Length, key2Length) != 1)
    {
        printf("Key lengths are not co-prime");
        return 0;
    }

    int counter1 = 0;
    int counter2 = 0;
  
    while(1)
    {
        int c = getchar();

        if(c == EOF)
            break;

        if(counter1 == key1Length)
            counter1 = 0;
        if(counter2 == key2Length)
            counter2 = 0;

        c = proccessChar(c);

        //invalid char
        if(c == -2)
            continue;

        //normilize keys
        char k1 = key1[counter1] - 97;
        char k2 = key2[counter2] - 97;
        
        if( mode[0] == '0')
        {
            c = encryptChar(encryptChar(c,k1),k2);
        }
        else
        {
            c = decryptChar(decryptChar(c,k1),k2);
        }
              
        putchar(c);

        counter1++;
        counter2++;
    }


    return 0;
}