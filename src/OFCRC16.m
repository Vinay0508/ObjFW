/*
 * Copyright (c) 2008-2022 Jonathan Schleifer <js@nil.im>
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

#import "OFCRC16.h"

static const uint16_t CRC16Magic = 0xA001;

uint16_t
OFCRC16(uint16_t CRC, const void *bytes_, size_t length)
{
	const unsigned char *bytes = bytes_;

	for (size_t i = 0; i < length; i++) {
		CRC ^= bytes[i];

		for (uint8_t j = 0; j < 8; j++)
			CRC = (CRC >> 1) ^ (CRC16Magic & (~(CRC & 1) + 1));
	}

	return CRC;
}
