// SPDX-License-Identifier: GPL-2.0

#include <syscall.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#include <sys/syscall.h>
#include <linux/membarrier.h>

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

struct test_case {
	char testname[80];
	int command;		/* membarrier cmd                            */
	int needregister;	/* membarrier cmd needs register cmd	     */
	int flags;		/* flags for given membarrier cmd	     */
	long exp_ret;		/* expected return code for given cmd        */
	int exp_errno;		/* expected errno for given cmd failure      */
	int enabled;		/* enabled, despite results from CMD_QUERY   */
	int always;		/* CMD_QUERY should always enable this test  */
	int force;		/* force if CMD_QUERY reports not enabled    */
	int force_exp_errno;	/* expected errno after forced cmd           */
};

struct test_case tc[] = {
	{
	 /*
	  * case 00) invalid cmd
	  *     - enabled by default
	  *     - should always fail with EINVAL
	  */
	 .testname = "cmd_fail",
	 .command = -1,
	 .exp_ret = -1,
	 .exp_errno = EINVAL,
	 .enabled = 1,
	 },
}

static int sys_membarrier(int cmd, int flags)
{
	return syscall(__NR_membarrier, cmd, flags);
}
