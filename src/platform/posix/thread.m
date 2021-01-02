/*
 * Copyright (c) 2008-2021 Jonathan Schleifer <js@nil.im>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#include <errno.h>

#ifdef HAVE_PTHREAD_NP_H
# include <pthread_np.h>
#endif

#ifdef OF_HAIKU
# include <kernel/OS.h>
#endif

#import "thread.h"
#import "macros.h"

static int minPrio = 0, maxPrio = 0, normalPrio = 0;

struct thread_ctx {
	void (*function)(id object);
	id object;
	const char *name;
};

/*
 * This is done here to make sure this is done as early as possible in the main
 * thread.
 */
OF_CONSTRUCTOR()
{
	pthread_attr_t attr;

	if (pthread_attr_init(&attr) == 0) {
#ifdef HAVE_PTHREAD_ATTR_GETSCHEDPOLICY
		int policy;
#endif
		struct sched_param param;

#ifdef HAVE_PTHREAD_ATTR_GETSCHEDPOLICY
		if (pthread_attr_getschedpolicy(&attr, &policy) == 0) {
			minPrio = sched_get_priority_min(policy);
			maxPrio = sched_get_priority_max(policy);

			if (minPrio == -1 || maxPrio == -1)
				minPrio = maxPrio = 0;
		}
#endif

		if (pthread_attr_getschedparam(&attr, &param) != 0)
			normalPrio = param.sched_priority;
		else
			minPrio = maxPrio = 0;

		pthread_attr_destroy(&attr);
	}
}

static void *
functionWrapper(void *data)
{
	struct thread_ctx *ctx = data;

	if (ctx->name != NULL)
		of_thread_set_name(ctx->name);

	pthread_cleanup_push(free, data);

	ctx->function(ctx->object);

	pthread_cleanup_pop(1);
	return NULL;
}

int
of_thread_attr_init(of_thread_attr_t *attr)
{
	int error;
	pthread_attr_t POSIXAttr;

	attr->priority = 0;
	attr->stackSize = 0;

	if ((error = pthread_attr_init(&POSIXAttr)) != 0) {
		if (error == ENOSYS)
			return 0;

		return error;
	}

	error = pthread_attr_getstacksize(&POSIXAttr, &attr->stackSize);

	pthread_attr_destroy(&POSIXAttr);

	return error;
}

int
of_thread_new(of_thread_t *thread, const char *name, void (*function)(id),
    id object, const of_thread_attr_t *attr)
{
	int error = 0;
	pthread_attr_t POSIXAttr;
	bool POSIXAttrAvailable = true;

	if ((error = pthread_attr_init(&POSIXAttr)) != 0) {
		if (error == ENOSYS)
			POSIXAttrAvailable = false;
		else
			return error;
	}

	@try {
		struct thread_ctx *ctx;

		if (attr != NULL && POSIXAttrAvailable) {
			struct sched_param param;

			if (attr->priority < -1 || attr->priority > 1)
				return EINVAL;

#ifdef HAVE_PTHREAD_ATTR_SETINHERITSCHED
			if ((error = pthread_attr_setinheritsched(&POSIXAttr,
			    PTHREAD_EXPLICIT_SCHED)) != 0)
				return error;
#endif

			if (attr->priority < 0) {
				param.sched_priority = minPrio +
				    (1.0f + attr->priority) *
				    (normalPrio - minPrio);
			} else
				param.sched_priority = normalPrio +
				    attr->priority * (maxPrio - normalPrio);

			if ((error = pthread_attr_setschedparam(&POSIXAttr,
			    &param)) != 0)
				return error;

			if (attr->stackSize > 0) {
				if ((error = pthread_attr_setstacksize(
				    &POSIXAttr, attr->stackSize)) != 0)
					return error;
			}
		}

		if ((ctx = malloc(sizeof(*ctx))) == NULL)
			return ENOMEM;

		ctx->function = function;
		ctx->object = object;
		ctx->name = name;

		error = pthread_create(thread, &POSIXAttr, functionWrapper,
		    ctx);
	} @finally {
		if (POSIXAttrAvailable)
			pthread_attr_destroy(&POSIXAttr);
	}

	return error;
}

int
of_thread_join(of_thread_t thread)
{
	void *ret;

	return pthread_join(thread, &ret);
}

int
of_thread_detach(of_thread_t thread)
{
	return pthread_detach(thread);
}

void
of_thread_set_name(const char *name)
{
#if defined(OF_HAIKU)
	rename_thread(find_thread(NULL), name);
#elif defined(HAVE_PTHREAD_SET_NAME_NP)
	pthread_set_name_np(pthread_self(), name);
#elif defined(HAVE_PTHREAD_SETNAME_NP)
# if defined(OF_MACOS) || defined(OF_IOS)
	pthread_setname_np(name);
# elif defined(__GLIBC__)
	char buffer[16];

	strncpy(buffer, name, 15);
	buffer[15] = 0;

	pthread_setname_np(pthread_self(), buffer);
# endif
#endif
}
