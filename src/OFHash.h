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

#import "OFObject.h"

/**
 * \brief A base class for classes providing hash functions.
 */
@interface OFHash: OFObject
{
	BOOL	 isCalculated;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly) BOOL isCalculated;
#endif

/**
 * \return The digest size of the hash, in byte.
 */
+ (size_t)digestSize;

/**
 * \return The block size of the hash, in byte.
 */
+ (size_t)blockSize;

/**
 * Adds a buffer to the hash to be calculated.
 *
 * \param buf The buffer which should be included into the calculation.
 * \param size The size of the buffer
 */
- (void)updateWithBuffer: (const char*)buf
		  ofSize: (size_t)size;

/**
 * \return A buffer containing the hash. The size of the buffer is depending
 *	   on the hash used. The buffer is part of object's memory pool.
 */
- (uint8_t*)digest;

/**
 * \return A boolean whether the hash has already been calculated
 */
- (BOOL)isCalculated;
@end
