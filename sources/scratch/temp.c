#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <endian.h>

//typedef uint64_t uptr;

void
show1(char *n1, char *n2)
{
    printf("%x", n1[0]);
    printf("%x", n1[1]);
}

int
main(int argc, char *argv)
{
    unsigned long num[2];

    num[0] = 0x00000000FEDCBA98;
    num[1] = 0x7654321000000000;

    show1((char *) &num[0], (char *) &num[1]);
}

