CFLAGS=-Wno-error=format -Wno-error=format-security

all:
	gcc -I. -o mknod mknod.c
	gcc -I. -o archsizes archsizes.c
	gcc -I. -o membarrier membarrier.c
	gcc -I. -o islittle islittle.c
	gcc -I. -o s390x-be s390x-be.c
	gcc -I. -O0 -o littlebig littlebig.c
	gcc -I. -O0 -o temp temp.c

clean:
	rm -f islittle
	rm -f archsizes
	rm -f mknod
	rm -f membarrier
	rm -f s390x-be
	rm -f littlebig
	rm -f temp
