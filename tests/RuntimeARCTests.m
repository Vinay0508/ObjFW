/*
 * Copyright (c) 2008-2023 Jonathan Schleifer <js@nil.im>
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

#import "TestsAppDelegate.h"

static OFString *const module = @"Runtime (ARC)";

@interface RuntimeARCTest: OFObject
@end

@implementation RuntimeARCTest
- (instancetype)init
{
	self = [super init];

#if defined(OF_WINDOWS) && defined(OF_AMD64)
	/*
	 * Clang has a bug on Windows where it creates an invalid call into
	 * objc_retainAutoreleasedReturnValue(). Work around it by not using an
	 * autoreleased exception.
	 */
	@throw [[OFException alloc] init];
#else
	@throw [OFException exception];
#endif

	return self;
}
@end

@implementation TestsAppDelegate (RuntimeARCTests)
- (void)runtimeARCTests
{
	id object;
	__weak id weak;

	EXPECT_EXCEPTION(@"Exceptions in init", OFException,
	    object = [[RuntimeARCTest alloc] init])

	object = [[OFObject alloc] init];
	weak = object;
	TEST(@"weakly referencing an object", weak == object)

	object = nil;
	TEST(@"weak references becoming nil", weak == nil)
}
@end
