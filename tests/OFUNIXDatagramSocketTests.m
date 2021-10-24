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

#import "TestsAppDelegate.h"

static OFString *const module = @"OFUNIXDatagramSocket";

@implementation TestsAppDelegate (OFUNIXDatagramSocketTests)
- (void)UNIXDatagramSocketTests
{
	void *pool = objc_autoreleasePoolPush();
	OFString *path;
	OFUNIXDatagramSocket *sock;
	OFSocketAddress address1, address2;
	char buffer[5];

	path = [[OFSystemInfo temporaryDirectoryPath]
	    stringByAppendingPathComponent: [[OFUUID UUID] UUIDString]];

	TEST(@"+[socket]", (sock = [OFUNIXDatagramSocket socket]))

	TEST(@"-[bindToPath:]", R(address1 = [sock bindToPath: path]))

	TEST(@"-[sendBuffer:length:receiver:]",
	    R([sock sendBuffer: "Hello" length: 5 receiver: &address1]))

	TEST(@"-[receiveIntoBuffer:length:sender:]",
	    [sock receiveIntoBuffer: buffer length: 5 sender: &address2] == 5 &&
	    memcmp(buffer, "Hello", 5) == 0 &&
	    OFSocketAddressEqual(&address1, &address2) &&
	    OFSocketAddressHash(&address1) == OFSocketAddressHash(&address2))

	objc_autoreleasePoolPop(pool);
}
@end