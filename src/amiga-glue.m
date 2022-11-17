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

/* This file is automatically generated from amiga-library.xml */

#include "config.h"

#import "amiga-glue.h"

#ifdef OF_MORPHOS
/* All __saveds functions in this file need to use the SysV ABI */
__asm__ (
    ".section .text\n"
    ".align 2\n"
    "__restore_r13:\n"
    "	lwz	%r13, 44(%r12)\n"
    "	blr\n"
);
#endif

bool __saveds
glue_OFInit PPC_PARAMS(unsigned int version, struct OFLibC *_Nonnull libc, FILE *_Nonnull *_Nonnull sF)
{
	M68K_ARG(unsigned int, version, d0)
	M68K_ARG(struct OFLibC *_Nonnull, libc, a0)
	M68K_ARG(FILE *_Nonnull *_Nonnull, sF, a1)

	return OFInit(version, libc, sF);
}

void *_Nullable __saveds
glue_OFAllocMemory PPC_PARAMS(size_t count, size_t size)
{
	M68K_ARG(size_t, count, d0)
	M68K_ARG(size_t, size, d1)

	return OFAllocMemory(count, size);
}

void *_Nullable __saveds
glue_OFAllocZeroedMemory PPC_PARAMS(size_t count, size_t size)
{
	M68K_ARG(size_t, count, d0)
	M68K_ARG(size_t, size, d1)

	return OFAllocZeroedMemory(count, size);
}

void *_Nullable __saveds
glue_OFResizeMemory PPC_PARAMS(void *_Nullable pointer, size_t count, size_t size)
{
	M68K_ARG(void *_Nullable, pointer, a0)
	M68K_ARG(size_t, count, d0)
	M68K_ARG(size_t, size, d1)

	return OFResizeMemory(pointer, count, size);
}

void __saveds
glue_OFFreeMemory PPC_PARAMS(void *_Nullable pointer)
{
	M68K_ARG(void *_Nullable, pointer, a0)

	OFFreeMemory(pointer);
}

void __saveds
glue_OFHashInit PPC_PARAMS(unsigned long *_Nonnull hash)
{
	M68K_ARG(unsigned long *_Nonnull, hash, a0)

	OFHashInit(hash);
}

uint16_t __saveds
glue_OFRandom16(void)
{
	return OFRandom16();
}

uint32_t __saveds
glue_OFRandom32(void)
{
	return OFRandom32();
}

uint64_t __saveds
glue_OFRandom64(void)
{
	return OFRandom64();
}

unsigned long *_Nonnull __saveds
glue_OFHashSeedRef(void)
{
	return OFHashSeedRef();
}

OFStdIOStream *_Nonnull *_Nullable __saveds
glue_OFStdInRef(void)
{
	return OFStdInRef();
}

OFStdIOStream *_Nonnull *_Nullable __saveds
glue_OFStdOutRef(void)
{
	return OFStdOutRef();
}

OFStdIOStream *_Nonnull *_Nullable __saveds
glue_OFStdErrRef(void)
{
	return OFStdErrRef();
}

void __saveds
glue_OFLogV PPC_PARAMS(OFConstantString *format, va_list arguments)
{
	M68K_ARG(OFConstantString *, format, a0)
	M68K_ARG(va_list, arguments, a1)

	OFLogV(format, arguments);
}

int __saveds
glue_OFApplicationMain PPC_PARAMS(int *_Nonnull argc, char *_Nullable *_Nonnull *_Nonnull argv, id <OFApplicationDelegate> delegate)
{
	M68K_ARG(int *_Nonnull, argc, a0)
	M68K_ARG(char *_Nullable *_Nonnull *_Nonnull, argv, a1)
	M68K_ARG(id <OFApplicationDelegate>, delegate, a2)

	return OFApplicationMain(argc, argv, delegate);
}

void *_Nullable __saveds
glue__Block_copy PPC_PARAMS(const void *_Nullable block)
{
	M68K_ARG(const void *_Nullable, block, a0)

	return _Block_copy(block);
}

void __saveds
glue__Block_release PPC_PARAMS(const void *_Nullable block)
{
	M68K_ARG(const void *_Nullable, block, a0)

	_Block_release(block);
}

OFString *_Nonnull __saveds
glue_OFDNSClassName PPC_PARAMS(OFDNSClass DNSClass)
{
	M68K_ARG(OFDNSClass, DNSClass, d0)

	return OFDNSClassName(DNSClass);
}

OFString *_Nonnull __saveds
glue_OFDNSRecordTypeName PPC_PARAMS(OFDNSRecordType recordType)
{
	M68K_ARG(OFDNSRecordType, recordType, d0)

	return OFDNSRecordTypeName(recordType);
}

OFDNSClass __saveds
glue_OFDNSClassParseName PPC_PARAMS(OFString *_Nonnull string)
{
	M68K_ARG(OFString *_Nonnull, string, a0)

	return OFDNSClassParseName(string);
}

OFDNSRecordType __saveds
glue_OFDNSRecordTypeParseName PPC_PARAMS(OFString *_Nonnull string)
{
	M68K_ARG(OFString *_Nonnull, string, a0)

	return OFDNSRecordTypeParseName(string);
}

void __saveds
glue_OFRegisterEmbeddedFile PPC_PARAMS(OFString *_Nonnull name, const uint8_t *_Nonnull bytes, size_t size)
{
	M68K_ARG(OFString *_Nonnull, name, a0)
	M68K_ARG(const uint8_t *_Nonnull, bytes, a1)
	M68K_ARG(size_t, size, d0)

	OFRegisterEmbeddedFile(name, bytes, size);
}

const char *_Nullable __saveds
glue_OFHTTPRequestMethodName PPC_PARAMS(OFHTTPRequestMethod method)
{
	M68K_ARG(OFHTTPRequestMethod, method, d0)

	return OFHTTPRequestMethodName(method);
}

OFHTTPRequestMethod __saveds
glue_OFHTTPRequestMethodParseName PPC_PARAMS(OFString *string)
{
	M68K_ARG(OFString *, string, a0)

	return OFHTTPRequestMethodParseName(string);
}

OFString *_Nonnull __saveds
glue_OFHTTPStatusCodeString PPC_PARAMS(short code)
{
	M68K_ARG(short, code, d0)

	return OFHTTPStatusCodeString(code);
}

OFListItem _Nullable __saveds
glue_OFListItemNext PPC_PARAMS(OFListItem _Nonnull listItem)
{
	M68K_ARG(OFListItem _Nonnull, listItem, a0)

	return OFListItemNext(listItem);
}

OFListItem _Nullable __saveds
glue_OFListItemPrevious PPC_PARAMS(OFListItem _Nonnull listItem)
{
	M68K_ARG(OFListItem _Nonnull, listItem, a0)

	return OFListItemPrevious(listItem);
}

id _Nonnull __saveds
glue_OFListItemObject PPC_PARAMS(OFListItem _Nonnull listItem)
{
	M68K_ARG(OFListItem _Nonnull, listItem, a0)

	return OFListItemObject(listItem);
}

size_t __saveds
glue_OFSizeOfTypeEncoding PPC_PARAMS(const char *type)
{
	M68K_ARG(const char *, type, a0)

	return OFSizeOfTypeEncoding(type);
}

size_t __saveds
glue_OFAlignmentOfTypeEncoding PPC_PARAMS(const char *type)
{
	M68K_ARG(const char *, type, a0)

	return OFAlignmentOfTypeEncoding(type);
}

void __saveds
glue_OFOnce PPC_PARAMS(OFOnceControl *_Nonnull control, OFOnceFunction _Nonnull func)
{
	M68K_ARG(OFOnceControl *_Nonnull, control, a0)
	M68K_ARG(OFOnceFunction _Nonnull, func, a1)

	OFOnce(control, func);
}

void __saveds
glue_OFPBKDF2Wrapper PPC_PARAMS(const OFPBKDF2Parameters *_Nonnull parameters)
{
	M68K_ARG(const OFPBKDF2Parameters *_Nonnull, parameters, a0)

	OFPBKDF2Wrapper(parameters);
}

void __saveds
glue_OFScryptWrapper PPC_PARAMS(const OFScryptParameters *_Nonnull parameters)
{
	M68K_ARG(const OFScryptParameters *_Nonnull, parameters, a0)

	OFScryptWrapper(parameters);
}

void __saveds
glue_OFSalsa20_8Core PPC_PARAMS(uint32_t *_Nonnull buffer)
{
	M68K_ARG(uint32_t *_Nonnull, buffer, a0)

	OFSalsa20_8Core(buffer);
}

void __saveds
glue_OFScryptBlockMix PPC_PARAMS(uint32_t *_Nonnull output, const uint32_t *_Nonnull input, size_t blockSize)
{
	M68K_ARG(uint32_t *_Nonnull, output, a0)
	M68K_ARG(const uint32_t *_Nonnull, input, a1)
	M68K_ARG(size_t, blockSize, d0)

	OFScryptBlockMix(output, input, blockSize);
}

void __saveds
glue_OFScryptROMix PPC_PARAMS(uint32_t *buffer, size_t blockSize, size_t costFactor, uint32_t *tmp)
{
	M68K_ARG(uint32_t *, buffer, a0)
	M68K_ARG(size_t, blockSize, d0)
	M68K_ARG(size_t, costFactor, d1)
	M68K_ARG(uint32_t *, tmp, a1)

	OFScryptROMix(buffer, blockSize, costFactor, tmp);
}

OFSocketAddress __saveds
glue_OFSocketAddressParseIP PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return OFSocketAddressParseIP(IP, port);
}

OFSocketAddress __saveds
glue_OFSocketAddressParseIPv4 PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return OFSocketAddressParseIPv4(IP, port);
}

OFSocketAddress __saveds
glue_OFSocketAddressParseIPv6 PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return OFSocketAddressParseIPv6(IP, port);
}

OFSocketAddress __saveds
glue_OFSocketAddressMakeUNIX PPC_PARAMS(OFString *path)
{
	M68K_ARG(OFString *, path, a0)

	return OFSocketAddressMakeUNIX(path);
}

OFSocketAddress __saveds
glue_OFSocketAddressMakeIPX PPC_PARAMS(uint32_t network, const unsigned char *node, uint16_t port)
{
	M68K_ARG(uint32_t, network, d0)
	M68K_ARG(const unsigned char *, node, a0)
	M68K_ARG(uint16_t, port, d1)

	return OFSocketAddressMakeIPX(network, node, port);
}

OFSocketAddress __saveds
glue_OFSocketAddressMakeAppleTalk PPC_PARAMS(uint16_t network, uint8_t node, uint8_t port)
{
	M68K_ARG(uint16_t, network, d0)
	M68K_ARG(uint8_t, node, d1)
	M68K_ARG(uint8_t, port, d2)

	return OFSocketAddressMakeAppleTalk(network, node, port);
}

bool __saveds
glue_OFSocketAddressEqual PPC_PARAMS(const OFSocketAddress *address1, const OFSocketAddress *address2)
{
	M68K_ARG(const OFSocketAddress *, address1, a0)
	M68K_ARG(const OFSocketAddress *, address2, a1)

	return OFSocketAddressEqual(address1, address2);
}

unsigned long __saveds
glue_OFSocketAddressHash PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressHash(address);
}

OFString *_Nonnull __saveds
glue_OFSocketAddressString PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressString(address);
}

void __saveds
glue_OFSocketAddressSetIPPort PPC_PARAMS(OFSocketAddress *address, uint16_t port)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint16_t, port, d0)

	OFSocketAddressSetIPPort(address, port);
}

uint16_t __saveds
glue_OFSocketAddressIPPort PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressIPPort(address);
}

OFString * __saveds
glue_OFSocketAddressUNIXPath PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressUNIXPath(address);
}

void __saveds
glue_OFSocketAddressSetIPXNetwork PPC_PARAMS(OFSocketAddress *address, uint32_t network)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint32_t, network, d0)

	OFSocketAddressSetIPXNetwork(address, network);
}

uint32_t __saveds
glue_OFSocketAddressIPXNetwork PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressIPXNetwork(address);
}

void __saveds
glue_OFSocketAddressSetIPXNode PPC_PARAMS(OFSocketAddress *address, const unsigned char *node)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(const unsigned char *, node, a1)

	OFSocketAddressSetIPXNode(address, node);
}

void __saveds
glue_OFSocketAddressGetIPXNode PPC_PARAMS(const OFSocketAddress *address, unsigned char *_Nonnull node)
{
	M68K_ARG(const OFSocketAddress *, address, a0)
	M68K_ARG(unsigned char *_Nonnull, node, a1)

	OFSocketAddressGetIPXNode(address, node);
}

void __saveds
glue_OFSocketAddressSetIPXPort PPC_PARAMS(OFSocketAddress *address, uint16_t port)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint16_t, port, d0)

	OFSocketAddressSetIPXPort(address, port);
}

uint16_t __saveds
glue_OFSocketAddressIPXPort PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressIPXPort(address);
}

void __saveds
glue_OFSocketAddressSetAppleTalkNetwork PPC_PARAMS(OFSocketAddress *address, uint16_t network)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint16_t, network, d0)

	OFSocketAddressSetAppleTalkNetwork(address, network);
}

uint16_t __saveds
glue_OFSocketAddressAppleTalkNetwork PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressAppleTalkNetwork(address);
}

void __saveds
glue_OFSocketAddressSetAppleTalkNode PPC_PARAMS(OFSocketAddress *address, uint8_t node)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint8_t, node, (nil))

	OFSocketAddressSetAppleTalkNode(address, node);
}

uint8_t __saveds
glue_OFSocketAddressAppleTalkNode PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressAppleTalkNode(address);
}

void __saveds
glue_OFSocketAddressSetAppleTalkPort PPC_PARAMS(OFSocketAddress *address, uint8_t port)
{
	M68K_ARG(OFSocketAddress *, address, a0)
	M68K_ARG(uint8_t, port, (nil))

	OFSocketAddressSetAppleTalkPort(address, port);
}

uint8_t __saveds
glue_OFSocketAddressAppleTalkPort PPC_PARAMS(const OFSocketAddress *address)
{
	M68K_ARG(const OFSocketAddress *, address, a0)

	return OFSocketAddressAppleTalkPort(address);
}

OFString * __saveds
glue_OFTLSStreamErrorCodeDescription PPC_PARAMS(OFTLSStreamErrorCode errorCode)
{
	M68K_ARG(OFTLSStreamErrorCode, errorCode, d0)

	return OFTLSStreamErrorCodeDescription(errorCode);
}

const char *_Nullable __saveds
glue_OFStrPTime PPC_PARAMS(const char *buffer, const char *format, struct tm *tm, int16_t *_Nullable tz)
{
	M68K_ARG(const char *, buffer, a0)
	M68K_ARG(const char *, format, a1)
	M68K_ARG(struct tm *, tm, a2)
	M68K_ARG(int16_t *_Nullable, tz, a3)

	return OFStrPTime(buffer, format, tm, tz);
}

OFStringEncoding __saveds
glue_OFStringEncodingParseName PPC_PARAMS(OFString *string)
{
	M68K_ARG(OFString *, string, a0)

	return OFStringEncodingParseName(string);
}

OFString *_Nullable __saveds
glue_OFStringEncodingName PPC_PARAMS(OFStringEncoding encoding)
{
	M68K_ARG(OFStringEncoding, encoding, d0)

	return OFStringEncodingName(encoding);
}

size_t __saveds
glue_OFUTF16StringLength PPC_PARAMS(const OFChar16 *string)
{
	M68K_ARG(const OFChar16 *, string, a0)

	return OFUTF16StringLength(string);
}

size_t __saveds
glue_OFUTF32StringLength PPC_PARAMS(const OFChar32 *string)
{
	M68K_ARG(const OFChar32 *, string, a0)

	return OFUTF32StringLength(string);
}

OFString *_Nonnull __saveds
glue_OFZIPArchiveEntryVersionToString PPC_PARAMS(uint16_t version)
{
	M68K_ARG(uint16_t, version, d0)

	return OFZIPArchiveEntryVersionToString(version);
}

OFString *_Nonnull __saveds
glue_OFZIPArchiveEntryCompressionMethodName PPC_PARAMS(OFZIPArchiveEntryCompressionMethod compressionMethod)
{
	M68K_ARG(OFZIPArchiveEntryCompressionMethod, compressionMethod, d0)

	return OFZIPArchiveEntryCompressionMethodName(compressionMethod);
}

size_t __saveds
glue_OFZIPArchiveEntryExtraFieldFind PPC_PARAMS(OFData *extraField, OFZIPArchiveEntryExtraFieldTag tag, uint16_t *size)
{
	M68K_ARG(OFData *, extraField, a0)
	M68K_ARG(OFZIPArchiveEntryExtraFieldTag, tag, d0)
	M68K_ARG(uint16_t *, size, a1)

	return OFZIPArchiveEntryExtraFieldFind(extraField, tag, size);
}
