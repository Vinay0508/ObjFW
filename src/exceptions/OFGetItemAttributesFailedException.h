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

#import "OFException.h"

OF_ASSUME_NONNULL_BEGIN

@class OFIRI;

/**
 * @class OFGetItemAttributesFailedException \
 *	  OFGetItemAttributesFailedException.h \
 *	  ObjFW/OFGetItemAttributesFailedException.h
 *
 * @brief An exception indicating an item's attributes could not be retrieved.
 */
@interface OFGetItemAttributesFailedException: OFException
{
	OFIRI *_IRI;
	int _errNo;
	OF_RESERVE_IVARS(OFGetItemAttributesFailedException, 4)
}

/**
 * @brief The IRI of the item whose attributes could not be retrieved.
 */
@property (readonly, nonatomic) OFIRI *IRI;

/**
 * @brief The errno of the error that occurred.
 */
@property (readonly, nonatomic) int errNo;

/**
 * @brief Creates a new, autoreleased retrieve item attributes failed exception.
 *
 * @param IRI The IRI of the item whose attributes could not be retrieved
 * @param errNo The errno of the error that occurred
 * @return A new, autoreleased retrieve item attributes failed exception
 */
+ (instancetype)exceptionWithIRI: (OFIRI *)IRI errNo: (int)errNo;

+ (instancetype)exception OF_UNAVAILABLE;

/**
 * @brief Initializes an already allocated retrieve item attributes failed
 *	  exception.
 *
 * @param IRI The IRI of the item whose attributes could not be retrieved
 * @param errNo The errno of the error that occurred
 * @return An initialized retrieve item attributes failed exception
 */
- (instancetype)initWithIRI: (OFIRI *)IRI
		      errNo: (int)errNo OF_DESIGNATED_INITIALIZER;

- (instancetype)init OF_UNAVAILABLE;
@end

OF_ASSUME_NONNULL_END
