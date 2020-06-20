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

#import "OFApplication.h"
#import "OFHTTPRequest.h"
#import "OFHTTPResponse.h"
#import "OFMethodSignature.h"
#import "OFStdIOStream.h"
#import "OFZIPArchiveEntry.h"

#import "amiga-library.h"
#import "pbkdf2.h"
#import "platform.h"
#import "scrypt.h"
#import "socket.h"

#ifdef OF_AMIGAOS_M68K
# define PPC_PARAMS(...) (void)
# define M68K_ARG OF_M68K_ARG
#else
# define PPC_PARAMS(...) (__VA_ARGS__)
# define M68K_ARG(...)
#endif

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
glue_of_init PPC_PARAMS(unsigned int version, struct of_libc *libc, FILE **sF)
{
	M68K_ARG(unsigned int, version, d0)
	M68K_ARG(struct of_libc *, libc, a0)
	M68K_ARG(FILE **, sF, a1)

	return of_init(version, libc, sF);
}

int __saveds
glue_of_application_main PPC_PARAMS(int *argc, char ***argv,
    id <OFApplicationDelegate> delegate)
{
	M68K_ARG(int *, argc, a0)
	M68K_ARG(char ***, argv, a1)
	M68K_ARG(id <OFApplicationDelegate>, delegate, a2)

	return of_application_main(argc, argv, delegate);
}

const char *__saveds
glue_of_http_request_method_to_string PPC_PARAMS(
    of_http_request_method_t method)
{
	M68K_ARG(of_http_request_method_t, method, d0)

	return of_http_request_method_to_string(method);
}

of_http_request_method_t __saveds
glue_of_http_request_method_from_string PPC_PARAMS(OFString *string)
{
	M68K_ARG(OFString *, string, a0)

	return of_http_request_method_from_string(string);
}

OFString *__saveds
glue_of_http_status_code_to_string PPC_PARAMS(short code)
{
	M68K_ARG(short, code, d0)

	return of_http_status_code_to_string(code);
}

size_t __saveds
glue_of_sizeof_type_encoding PPC_PARAMS(const char *type)
{
	M68K_ARG(const char *, type, a0)

	return of_sizeof_type_encoding(type);
}

size_t __saveds
glue_of_alignof_type_encoding PPC_PARAMS(const char *type)
{
	M68K_ARG(const char *, type, a0)

	return of_alignof_type_encoding(type);
}

void __saveds
glue_of_logv PPC_PARAMS(OFConstantString *format, va_list arguments)
{
	M68K_ARG(OFConstantString *, format, a0)
	M68K_ARG(va_list, arguments, a1)

	of_logv(format, arguments);
}

OFString *__saveds
glue_of_zip_archive_entry_version_to_string PPC_PARAMS(uint16_t version)
{
	M68K_ARG(uint16_t, version, d0)

	return of_zip_archive_entry_version_to_string(version);
}

OFString *__saveds
glue_of_zip_archive_entry_compression_method_to_string PPC_PARAMS(
    uint16_t compressionMethod)
{
	M68K_ARG(uint16_t, compressionMethod, d0)

	return of_zip_archive_entry_compression_method_to_string(
	    compressionMethod);
}

size_t __saveds
glue_of_zip_archive_entry_extra_field_find PPC_PARAMS(OFData *extraField,
    uint16_t tag, uint16_t *size)
{
	M68K_ARG(OFData *, extraField, a0)
	M68K_ARG(uint16_t, tag, d0)
	M68K_ARG(uint16_t *, size, a1)

	return of_zip_archive_entry_extra_field_find(extraField, tag, size);
}

void __saveds
glue_of_pbkdf2 PPC_PARAMS(OFHMAC *HMAC, size_t iterations,
    const unsigned char *salt, size_t saltLength, const char *password,
    size_t passwordLength, unsigned char *key, size_t keyLength,
    bool allowsSwappableMemory)
{
	M68K_ARG(OFHMAC *, HMAC, a0)
	M68K_ARG(size_t, iterations, d0)
	M68K_ARG(const unsigned char *, salt, a1)
	M68K_ARG(size_t, saltLength, d1)
	M68K_ARG(const char *, password, a2)
	M68K_ARG(size_t, passwordLength, d2)
	M68K_ARG(unsigned char *, key, a3)
	M68K_ARG(size_t, keyLength, d3)
	M68K_ARG(bool, allowsSwappableMemory, d4)

	of_pbkdf2(HMAC, iterations, salt, saltLength, password, passwordLength,
	    key, keyLength, allowsSwappableMemory);
}

void __saveds
glue_of_scrypt PPC_PARAMS(size_t blockSize, size_t costFactor,
    size_t parallelization, const unsigned char *salt, size_t saltLength,
    const char *password, size_t passwordLength, unsigned char *key,
    size_t keyLength, bool allowsSwappableMemory)
{
	M68K_ARG(size_t, blockSize, d0)
	M68K_ARG(size_t, costFactor, d1)
	M68K_ARG(size_t, parallelization, d2)
	M68K_ARG(const unsigned char *, salt, a0)
	M68K_ARG(size_t, saltLength, d3)
	M68K_ARG(const char *, password, a1)
	M68K_ARG(size_t, passwordLength, d4)
	M68K_ARG(unsigned char *, key, a2)
	M68K_ARG(size_t, keyLength, d5)
	M68K_ARG(bool, allowsSwappableMemory, d6)

	of_scrypt(blockSize, costFactor, parallelization, salt, saltLength,
	    password, passwordLength, key, keyLength, allowsSwappableMemory);
}

of_socket_address_t __saveds
glue_of_socket_address_parse_ip PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return of_socket_address_parse_ip(IP, port);
}

of_socket_address_t __saveds
glue_of_socket_address_parse_ipv4 PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return of_socket_address_parse_ipv4(IP, port);
}

of_socket_address_t __saveds
glue_of_socket_address_parse_ipv6 PPC_PARAMS(OFString *IP, uint16_t port)
{
	M68K_ARG(OFString *, IP, a0)
	M68K_ARG(uint16_t, port, d0)

	return of_socket_address_parse_ipv6(IP, port);
}

of_socket_address_t __saveds
glue_of_socket_address_ipx PPC_PARAMS(const unsigned char *node,
    uint32_t network, uint16_t port)
{
	M68K_ARG(const unsigned char *, node, a0)
	M68K_ARG(uint32_t, network, d0)
	M68K_ARG(uint16_t, port, d1)

	return of_socket_address_ipx(node, network, port);
}

bool __saveds
glue_of_socket_address_equal PPC_PARAMS(const of_socket_address_t *address1,
    const of_socket_address_t *address2)
{
	M68K_ARG(const of_socket_address_t *, address1, a0)
	M68K_ARG(const of_socket_address_t *, address2, a1)

	return of_socket_address_equal(address1, address2);
}

uint32_t __saveds
glue_of_socket_address_hash PPC_PARAMS(const of_socket_address_t *address)
{
	M68K_ARG(const of_socket_address_t *, address, a0)

	return of_socket_address_hash(address);
}

OFString *__saveds
glue_of_socket_address_ip_string PPC_PARAMS(const of_socket_address_t *address,
    uint16_t *port)
{
	M68K_ARG(const of_socket_address_t *, address, a0)
	M68K_ARG(uint16_t *, port, a1)

	return of_socket_address_ip_string(address, port);
}

void __saveds
glue_of_socket_address_set_port PPC_PARAMS(of_socket_address_t *address,
    uint16_t port)
{
	M68K_ARG(of_socket_address_t *, address, a0)
	M68K_ARG(uint16_t, port, d0)

	of_socket_address_set_port(address, port);
}

uint16_t __saveds
glue_of_socket_address_get_port PPC_PARAMS(const of_socket_address_t *address)
{
	M68K_ARG(const of_socket_address_t *, address, a0)

	return of_socket_address_get_port(address);
}

void __saveds
glue_of_socket_address_set_ipx_network PPC_PARAMS(of_socket_address_t *address,
    uint32_t network)
{
	M68K_ARG(of_socket_address_t *, address, a0)
	M68K_ARG(uint32_t, network, d0)

	of_socket_address_set_ipx_network(address, network);
}

uint32_t __saveds
glue_of_socket_address_get_ipx_network PPC_PARAMS(
    const of_socket_address_t *address)
{
	M68K_ARG(const of_socket_address_t *, address, a0)

	return of_socket_address_get_ipx_network(address);
}

void __saveds
glue_of_socket_address_set_ipx_node PPC_PARAMS(of_socket_address_t *address,
    const unsigned char *node)
{
	M68K_ARG(of_socket_address_t *, address, a0)
	M68K_ARG(const unsigned char *, node, a1)

	of_socket_address_set_ipx_node(address, node);
}

void __saveds
glue_of_socket_address_get_ipx_node PPC_PARAMS(
    const of_socket_address_t *address, unsigned char *node)
{
	M68K_ARG(const of_socket_address_t *, address, a0)
	M68K_ARG(unsigned char *, node, a1)

	of_socket_address_get_ipx_node(address, node);
}
