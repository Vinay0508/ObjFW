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

#include <stdlib.h>
#include <string.h>
#include <limits.h>

#import "OFMutableData.h"
#import "OFMutableAdjacentData.h"

#import "OFOutOfRangeException.h"

static struct {
	Class isa;
} placeholder;

@interface OFMutableDataPlaceholder: OFMutableData
@end

@implementation OFMutableDataPlaceholder
- (instancetype)init
{
	return (id)[[OFMutableAdjacentData alloc] init];
}

- (instancetype)initWithItemSize: (size_t)itemSize
{
	return (id)[[OFMutableAdjacentData alloc] initWithItemSize: itemSize];
}

- (instancetype)initWithItems: (const void *)items count: (size_t)count
{
	return (id)[[OFMutableAdjacentData alloc] initWithItems: items
							  count: count];
}

- (instancetype)initWithItems: (const void *)items
			count: (size_t)count
		     itemSize: (size_t)itemSize
{
	return (id)[[OFMutableAdjacentData alloc] initWithItems: items
							  count: count
						       itemSize: itemSize];
}

- (instancetype)initWithItemsNoCopy: (void *)items
			      count: (size_t)count
		       freeWhenDone: (bool)freeWhenDone
{
	return (id)[[OFMutableAdjacentData alloc]
	    initWithItemsNoCopy: items
			  count: count
		   freeWhenDone: freeWhenDone];
}

- (instancetype)initWithItemsNoCopy: (void *)items
			      count: (size_t)count
			   itemSize: (size_t)itemSize
		       freeWhenDone: (bool)freeWhenDone
{
	return (id)[[OFMutableAdjacentData alloc]
	    initWithItemsNoCopy: items
			  count: count
		       itemSize: itemSize
		   freeWhenDone: freeWhenDone];
}

#ifdef OF_HAVE_FILES
- (instancetype)initWithContentsOfFile: (OFString *)path
{
	return (id)[[OFMutableAdjacentData alloc] initWithContentsOfFile: path];
}
#endif

- (instancetype)initWithContentsOfIRI: (OFIRI *)IRI
{
	return (id)[[OFMutableAdjacentData alloc] initWithContentsOfIRI: IRI];
}

- (instancetype)initWithStringRepresentation: (OFString *)string
{
	return (id)[[OFMutableAdjacentData alloc]
	    initWithStringRepresentation: string];
}

- (instancetype)initWithBase64EncodedString: (OFString *)string
{
	return (id)[[OFMutableAdjacentData alloc]
	    initWithBase64EncodedString: string];
}

- (instancetype)initWithCapacity: (size_t)capacity
{
	return (id)[[OFMutableAdjacentData alloc] initWithCapacity: capacity];
}

- (instancetype)initWithItemSize: (size_t)itemSize capacity: (size_t)capacity
{
	return (id)[[OFMutableAdjacentData alloc] initWithItemSize: itemSize
							  capacity: capacity];
}
@end

@implementation OFMutableData
+ (void)initialize
{
	if (self == [OFMutableData class])
		object_setClass((id)&placeholder,
		    [OFMutableDataPlaceholder class]);
}

+ (instancetype)alloc
{
	if (self == [OFMutableData class])
		return (id)&placeholder;

	return [super alloc];
}

+ (instancetype)dataWithItemSize: (size_t)itemSize
{
	return [[[self alloc] initWithItemSize: itemSize] autorelease];
}

+ (instancetype)dataWithCapacity: (size_t)capacity
{
	return [[[self alloc] initWithCapacity: capacity] autorelease];
}

+ (instancetype)dataWithItemSize: (size_t)itemSize capacity: (size_t)capacity
{
	return [[[self alloc] initWithItemSize: itemSize
				      capacity: capacity] autorelease];
}

- (instancetype)initWithItemSize: (size_t)itemSize
{
	return [self initWithItemSize: 1 capacity: 0];
}

- (instancetype)initWithCapacity: (size_t)capacity
{
	return [self initWithItemSize: 1 capacity: capacity];
}

- (instancetype)initWithItemSize: (size_t)itemSize capacity: (size_t)capacity
{
	OF_INVALID_INIT_METHOD
}

- (instancetype)initWithItemsNoCopy: (void *)items
			      count: (size_t)count
			   itemSize: (size_t)itemSize
		       freeWhenDone: (bool)freeWhenDone
{
	self = [self initWithItems: items count: count itemSize: itemSize];

	if (freeWhenDone)
		OFFreeMemory(items);

	return self;
}

- (void *)mutableItems
{
	OF_UNRECOGNIZED_SELECTOR
}

- (void *)mutableItemAtIndex: (size_t)idx
{
	if (idx >= self.count)
		@throw [OFOutOfRangeException exception];

	return (unsigned char *)self.mutableItems + idx * self.itemSize;
}

- (void *)mutableFirstItem
{
	void *mutableItems = self.mutableItems;

	if (mutableItems == NULL || self.count == 0)
		return NULL;

	return mutableItems;
}

- (void *)mutableLastItem
{
	unsigned char *mutableItems = self.mutableItems;
	size_t count = self.count;

	if (mutableItems == NULL || count == 0)
		return NULL;

	return mutableItems + (count - 1) * self.itemSize;
}

- (OFData *)subdataWithRange: (OFRange)range
{
	size_t itemSize;

	if (range.length > SIZE_MAX - range.location ||
	    range.location + range.length > self.count)
		@throw [OFOutOfRangeException exception];

	itemSize = self.itemSize;
	return [OFData dataWithItems: (unsigned char *)self.mutableItems +
				      (range.location * itemSize)
			       count: range.length
			    itemSize: itemSize];
}

- (void)addItem: (const void *)item
{
	[self insertItems: item atIndex: self.count count: 1];
}

- (void)insertItem: (const void *)item atIndex: (size_t)idx
{
	[self insertItems: item atIndex: idx count: 1];
}

- (void)addItems: (const void *)items count: (size_t)count
{
	[self insertItems: items atIndex: self.count count: count];
}

- (void)insertItems: (const void *)items
	    atIndex: (size_t)idx
	      count: (size_t)count
{
	OF_UNRECOGNIZED_SELECTOR
}

- (void)increaseCountBy: (size_t)count
{
	OF_UNRECOGNIZED_SELECTOR
}

- (void)removeItemAtIndex: (size_t)idx
{
	[self removeItemsInRange: OFMakeRange(idx, 1)];
}

- (void)removeItemsInRange: (OFRange)range
{
	OF_UNRECOGNIZED_SELECTOR
}

- (void)removeLastItem
{
	size_t count = self.count;

	if (count == 0)
		return;

	[self removeItemsInRange: OFMakeRange(count - 1, 1)];
}

- (void)removeAllItems
{
	[self removeItemsInRange: OFMakeRange(0, self.count)];
}

- (id)copy
{
	return [[OFData alloc] initWithItems: self.mutableItems
				       count: self.count
				    itemSize: self.itemSize];
}

- (void)makeImmutable
{
}
@end
