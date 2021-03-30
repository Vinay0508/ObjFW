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

#import "OFException.h"
#import "OFLocking.h"

OF_ASSUME_NONNULL_BEGIN

/**
 * @class OFUnlockFailedException \
 *	  OFUnlockFailedException.h ObjFW/OFUnlockFailedException.h
 *
 * @brief An exception indicating that unlocking a lock failed.
 */
@interface OFUnlockFailedException: OFException
{
	id <OFLocking> _lock;
	int _errNo;
}

/**
 * @brief The lock which could not be unlocked.
 */
@property OF_NULLABLE_PROPERTY (readonly, nonatomic) id <OFLocking> lock;

/**
 * @brief The errno of the error that occurred.
 */
@property (readonly, nonatomic) int errNo;

/**
 * @brief Creates a new, autoreleased unlock failed exception.
 *
 * @param lock The lock which could not be unlocked
 * @param errNo The errno of the error that occurred
 * @return A new, autoreleased unlock failed exception
 */
+ (instancetype)exceptionWithLock: (nullable id <OFLocking>)lock
			    errNo: (int)errNo;

/**
 * @brief Initializes an already allocated unlock failed exception.
 *
 * @param lock The lock which could not be unlocked
 * @param errNo The errno of the error that occurred
 * @return An initialized unlock failed exception
 */
- (instancetype)initWithLock: (nullable id <OFLocking>)lock
		       errNo: (int)errNo OF_DESIGNATED_INITIALIZER;

- (instancetype)init OF_UNAVAILABLE;
@end

OF_ASSUME_NONNULL_END
