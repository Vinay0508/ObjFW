/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
 *               2018, 2019, 2020
 *   Jonathan Schleifer <js@nil.im>
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

#import "OFHMAC.h"
#import "OFSecureData.h"

#import "OFInvalidArgumentException.h"
#import "OFOutOfMemoryException.h"
#import "OFOutOfRangeException.h"

#import "pbkdf2.h"

void
of_pbkdf2(of_pbkdf2_parameters_t param)
{
	void *pool = objc_autoreleasePoolPush();
	size_t blocks, digestSize = param.HMAC.digestSize;
	OFSecureData *buffer = [OFSecureData
		    dataWithCount: digestSize
	    allowsSwappableMemory: param.allowsSwappableMemory];
	OFSecureData *digest = [OFSecureData
		    dataWithCount: digestSize
	    allowsSwappableMemory: param.allowsSwappableMemory];
	unsigned char *bufferItems = buffer.mutableItems;
	unsigned char *digestItems = digest.mutableItems;
	OFSecureData *extendedSalt;
	unsigned char *extendedSaltItems;

	if (param.HMAC == nil || param.iterations == 0 || param.salt == NULL ||
	    param.password == NULL || param.key == NULL || param.keyLength == 0)
		@throw [OFInvalidArgumentException exception];

	blocks = param.keyLength / digestSize;
	if (param.keyLength % digestSize != 0)
		blocks++;

	if (param.saltLength > SIZE_MAX - 4 || blocks > UINT32_MAX)
		@throw [OFOutOfRangeException exception];

	extendedSalt = [OFSecureData
		    dataWithCount: param.saltLength + 4
	    allowsSwappableMemory: param.allowsSwappableMemory];
	extendedSaltItems = extendedSalt.mutableItems;

	@try {
		uint32_t i = OF_BSWAP32_IF_LE(1);

		[param.HMAC setKey: param.password
			    length: param.passwordLength];

		memcpy(extendedSaltItems, param.salt, param.saltLength);

		while (param.keyLength > 0) {
			size_t length;

			memcpy(extendedSaltItems + param.saltLength, &i, 4);

			[param.HMAC reset];
			[param.HMAC updateWithBuffer: extendedSaltItems
					      length: param.saltLength + 4];
			memcpy(bufferItems, param.HMAC.digest, digestSize);
			memcpy(digestItems, param.HMAC.digest, digestSize);

			for (size_t j = 1; j < param.iterations; j++) {
				[param.HMAC reset];
				[param.HMAC updateWithBuffer: digestItems
						      length: digestSize];
				memcpy(digestItems, param.HMAC.digest,
				    digestSize);

				for (size_t k = 0; k < digestSize; k++)
					bufferItems[k] ^= digestItems[k];
			}

			length = digestSize;
			if (length > param.keyLength)
				length = param.keyLength;

			memcpy(param.key, bufferItems, length);
			param.key += length;
			param.keyLength -= length;

			i = OF_BSWAP32_IF_LE(OF_BSWAP32_IF_LE(i) + 1);
		}
	} @catch (id e) {
		[extendedSalt zero];
		[buffer zero];
		[digest zero];

		@throw e;
	} @finally {
		[param.HMAC zero];
	}

	objc_autoreleasePoolPop(pool);
}
