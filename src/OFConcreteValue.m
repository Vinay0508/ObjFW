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

#import "OFConcreteValue.h"
#import "OFMethodSignature.h"
#import "OFString.h"

#import "OFOutOfRangeException.h"

@implementation OFConcreteValue
- (instancetype)initWithBytes: (const void *)bytes
		     objCType: (const char *)objCType
{
	self = [super initWithBytes: bytes objCType: objCType];

	@try {
		_size = OFSizeOfTypeEncoding(objCType);
		_objCType = OFStrDup(objCType);
		_bytes = OFAllocMemory(1, _size);
		memcpy(_bytes, bytes, _size);
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	OFFreeMemory(_bytes);
	OFFreeMemory(_objCType);

	[super dealloc];
}

- (const char *)objCType
{
	return _objCType;
}

- (void)getValue: (void *)value size: (size_t)size
{
	if (size != _size)
		@throw [OFOutOfRangeException exception];

	memcpy(value, _bytes, _size);
}
@end
