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

	printf("OS: %s (%s)\n", (char *) &info.sysname, (char *) &info.release);
	printf("Arch: %s\n", (char *) &info.machine);
	printf("Version: %s\n", (char *) &info.version);
	printf("------------------------\n");
	printf("type\tsize\tmax #\t\n");
	printf("------------------------\n");
	printf("void\t%d\n", (int) sizeof(void *));
	printf("char\t%d\t%ld\n", (int) sizeof(char), sysconf(_SC_UCHAR_MAX));
	printf("short\t%d\t%ld\n", (int) sizeof(short), sysconf(_SC_USHRT_MAX));
	printf("int\t%d\t%ld\n", (int) sizeof(int), sysconf(_SC_UINT_MAX));
	printf("float\t%d\n", (int) sizeof(float));
	printf("double\t%d\n", (int) sizeof(double));
	printf("long\t%d\t%lu\n", (int) sizeof(long), sysconf(_SC_ULONG_MAX));
	printf("llong\t%d\n", (int) sizeof(long long));
	printf("void *\t%d\n", (int) sizeof(void *));
	printf("------------------------\n");
	printf("ptr = %p and %d\n", p, *p);
	printf("test = %d\n", (1) ? 0 : 1);
}
