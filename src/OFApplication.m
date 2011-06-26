/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
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

#define OF_APPLICATION_M

#include <stdlib.h>
#include <string.h>

#import "OFApplication.h"
#import "OFString.h"
#import "OFArray.h"
#import "OFDictionary.h"
#import "OFAutoreleasePool.h"

#import "OFNotImplementedException.h"

#import "macros.h"

#if defined(__MACH__) && !defined(OF_IOS)
# include <crt_externs.h>
#elif !defined(OF_IOS)
extern char **environ;
#endif

static OFApplication *app = nil;

static void
atexit_handler(void)
{
	id <OFApplicationDelegate> delegate = [app delegate];

	[delegate applicationWillTerminate];
}

int
of_application_main(int *argc, char **argv[], Class cls)
{
	OFApplication *app = [OFApplication sharedApplication];
	id <OFApplicationDelegate> delegate = [[cls alloc] init];

	[app setArgumentCount: argc
	    andArgumentValues: argv];

	[app setDelegate: delegate];
	[(id)delegate release];

	[app run];

	return 0;
}

@implementation OFApplication
+ sharedApplication
{
	if (app == nil)
		app = [[self alloc] init];

	return app;
}

+ (OFString*)programName
{
	return [app programName];
}

+ (OFArray*)arguments
{
	return [app arguments];
}

+ (OFDictionary*)environment
{
	return [app environment];
}

+ (void)terminate
{
	exit(0);
}

+ (void)terminateWithStatus: (int)status
{
	exit(status);
}

- init
{
	self = [super init];

	@try {
		OFAutoreleasePool *pool;
#if defined(__MACH__) && !defined(OF_IOS)
		char **env = *_NSGetEnviron();
#elif !defined(OF_IOS)
		char **env = environ;
#else
		char *env;
#endif

		environment = [[OFMutableDictionary alloc] init];

		atexit(atexit_handler);

		pool = [[OFAutoreleasePool alloc] init];
#ifndef OF_IOS
		for (; *env != NULL; env++) {
			OFString *key;
			OFString *value;
			char *sep;

			if ((sep = strchr(*env, '=')) == NULL) {
				fprintf(stderr, "Warning: Invalid environment "
				    "variable: %s\n", *env);
				continue;
			}

			key = [OFString stringWithCString: *env
						   length: sep - *env];
			value = [OFString stringWithCString: sep + 1];
			[environment setObject: value
					forKey: key];

			[pool releaseObjects];
		}
#else
		/*
		 * iOS does not provide environ and Apple does not allow using
		 * _NSGetEnviron on iOS. Therefore, we just get a few common
		 * variables from the environment which applications might
		 * expect.
		 */
		if ((env = getenv("HOME")) != NULL)
			[environment
			    setObject: [OFString stringWithCString: env]
			       forKey: @"HOME"];
		if ((env = getenv("PATH")) != NULL)
			[environment
			    setObject: [OFString stringWithCString: env]
			       forKey: @"PATH"];
		if ((env = getenv("SHELL")) != NULL)
			[environment
			    setObject: [OFString stringWithCString: env]
			       forKey: @"SHELL"];
		if ((env = getenv("TMPDIR")) != NULL)
			[environment
			    setObject: [OFString stringWithCString: env]
			       forKey: @"TMPDIR"];
		if ((env = getenv("USER")) != NULL)
			[environment
			    setObject: [OFString stringWithCString: env]
			       forKey: @"USER"];
#endif
		[pool release];

		/*
		 * Class swizzle the environment to be immutable, as we don't
		 * need to change it anymore and expose it only as
		 * OFDictionary*. But not swizzling it would create a real copy
		 * each time -[copy] is called.
		 */
		environment->isa = [OFDictionary class];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)setArgumentCount: (int*)argc_
       andArgumentValues: (char***)argv_
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	int i;

	[programName release];
	[arguments release];

	argc = argc_;
	argv = argv_;

	programName = [[OFString alloc] initWithCString: (*argv)[0]];
	arguments = [[OFMutableArray alloc] init];

	for (i = 1; i < *argc; i++)
		[arguments addObject: [OFString stringWithCString: (*argv)[i]]];

	/*
	 * Class swizzle the arguments to be immutable, as we don't need to
	 * change them anymore and expose them only as OFArray*. But not
	 * swizzling it would create a real copy each time -[copy] is called.
	 */
	arguments->isa = [OFArray class];

	[pool release];
}

- (void)getArgumentCount: (int**)argc_
       andArgumentValues: (char****)argv_
{
	*argc_ = argc;
	*argv_ = argv;
}

- (OFString*)programName
{
	OF_GETTER(programName, YES)
}

- (OFArray*)arguments
{
	OF_GETTER(arguments, YES)
}

- (OFDictionary*)environment
{
	OF_GETTER(environment, YES)
}

- (id <OFApplicationDelegate>)delegate
{
	OF_GETTER(delegate, YES)
}

- (void)setDelegate: (id <OFApplicationDelegate>)delegate_
{
	OF_SETTER(delegate, delegate_, YES, NO)
}

- (void)run
{
	[delegate applicationDidFinishLaunching];
}

- (void)terminate
{
	exit(0);
}

- (void)terminateWithStatus: (int)status
{
	exit(status);
}

- (void)dealloc
{
	[arguments release];
	[environment release];
	[(id)delegate release];

	[super dealloc];
}
@end

@implementation OFObject (OFApplicationDelegate)
- (void)applicationDidFinishLaunching
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- (void)applicationWillTerminate
{
}
@end
