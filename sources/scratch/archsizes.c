#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/utsname.h>

int main(int argc, char **argv) {
	int i = 1024;
	int *p = &i;

	struct utsname info;

	memset((void *) &info, 0, sizeof(info));

	uname(&info);

	printf("OS: %s (%s)\n", &info.sysname, &info.release);
	printf("Arch: %s\n", &info.machine);
	printf("Version: %s\n", &info.version);
	printf("------------------------\n");
	printf("type\tsize\tmax #\t\n");
	printf("------------------------\n");
	printf("void\t%d\n", sizeof(void *));
	printf("char\t%d\t%lu\n", sizeof(char), sysconf(_SC_UCHAR_MAX));
	printf("short\t%d\t%u\n", sizeof(short), sysconf(_SC_USHRT_MAX));
	printf("int\t%d\t%lu\n", sizeof(int), sysconf(_SC_UINT_MAX));
	printf("float\t%d\n", sizeof(float));
	printf("double\t%d\n", sizeof(double));
	printf("long\t%d\t%lu\n", sizeof(long), sysconf(_SC_ULONG_MAX));
	printf("llong\t%d\n", sizeof(long long));
	printf("void *\t%d\n", sizeof(void *));
	printf("------------------------\n");
	printf("ptr = %p and %d\n", p, *p);
	printf("test = %d\n", (1) ? 0 : 1);
}
