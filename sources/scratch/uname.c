#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/utsname.h>

int main(int argc, char **argv) {
	int ret, major, minor, rev;
	char *temp;
	struct utsname uts;

	memset(&uts, 0, sizeof(struct utsname));
	ret = uname(&uts);

	if ((temp = strtok((char *) &uts.release, ".")) == NULL)
		perror("strtok"), exit(1);
	major = atoi(temp);

	if ((temp = strtok(NULL, ".")) == NULL)
		perror("strtok"), exit(1);
	minor = atoi(temp);

	if ((temp = strtok(NULL, ".")) == NULL)
		perror("strtok"), exit(1);
	rev = atoi(temp);

	printf("%d.%d.%d\n", major, minor, rev);
}
