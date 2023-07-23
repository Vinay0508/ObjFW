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

#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif
#ifdef OF_HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
#ifdef HAVE_SYS_SOCKIO_H
# include <sys/sockio.h>
#endif
#ifdef HAVE_NET_IF_H
# include <net/if.h>
#endif
#ifdef HAVE_NET_IF_ARP_H
# include <net/if_arp.h>
#endif
#ifdef HAVE_NET_IF_DL_H
# include <net/if_dl.h>
#endif
#ifdef HAVE_NET_IF_TYPES_H
# include <net/if_types.h>
#endif

#import "OFSystemInfo.h"
#import "OFSystemInfo+NetworkInterfaces.h"
#import "OFArray.h"
#import "OFData.h"
#import "OFDictionary.h"
#ifdef OF_HAVE_FILES
 #import "OFFile.h"
#endif
#import "OFLocale.h"
#import "OFNumber.h"
#import "OFSocket.h"
#import "OFSocket+Private.h"
#import "OFString.h"

#import "OFInvalidFormatException.h"
#import "OFOpenItemFailedException.h"

@implementation OFSystemInfo (NetworkInterfaces)
static bool
queryNetworkInterfaceIndices(OFMutableDictionary *ret)
{
#ifdef HAVE_IF_NAMEINDEX
	OFStringEncoding encoding = [OFLocale encoding];
	struct if_nameindex *nameindex = if_nameindex();

	if (nameindex == NULL)
		return false;

	@try {
		for (size_t i = 0; nameindex[i].if_index != 0; i++) {
			OFString *name = [OFString
			    stringWithCString: nameindex[i].if_name
				     encoding: encoding];
			OFNumber *index = [OFNumber
			    numberWithUnsignedInt: nameindex[i].if_index];
			OFMutableDictionary *interface =
			    [ret objectForKey: name];

			if (interface == nil) {
				interface = [OFMutableDictionary dictionary];
				[ret setObject: interface forKey: name];
			}

			[interface setObject: index
				      forKey: OFNetworkInterfaceIndex];
		}
	} @finally {
		if_freenameindex(nameindex);
	}

	return true;
#else
	return false;
#endif
}

#if defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H)
static bool
queryNetworkInterfaceAddresses(OFMutableDictionary *ret,
    OFNetworkInterfaceKey key, OFSocketAddressFamily addressFamily, int family,
    size_t sockaddrSize)
{
	OFStringEncoding encoding = [OFLocale encoding];
	int sock = socket(family, SOCK_DGRAM, 0);
	OFMutableDictionary *interface;
	OFEnumerator *enumerator;

	if (sock < 0)
		return false;

# if defined(HAVE_STRUCT_LIFCONF) && defined(SIOCGLIFCONF)
	struct lifconf lifc;
	struct lifreq *lifrs;

	if ((lifrs = malloc(128 * sizeof(struct lifreq))) == NULL) {
		closesocket(sock);
		return false;
	}

	@try {
		char *buffer;

		memset(&lifc, 0, sizeof(lifc));
		lifc.lifc_buf = (void *)lifrs;
		lifc.lifc_len = 128 * sizeof(struct lifreq);
		if (ioctl(sock, SIOCGLIFCONF, &lifc) < 0)
			return false;

		for (buffer = lifc.lifc_buf;
		    buffer < (char *)lifc.lifc_buf + lifc.lifc_len;
		    buffer += sizeof(struct lifreq)) {
			struct lifreq *current =
			    (struct lifreq *)(void *)buffer;
			OFString *name;
			OFMutableData *addresses;
			OFSocketAddress address;

			if (current->lifr_addr.ss_family != family)
				continue;

			name = [OFString stringWithCString: current->lifr_name
						  encoding: encoding];
			if ((interface = [ret objectForKey: name]) == nil) {
				interface = [OFMutableDictionary dictionary];
				[ret setObject: interface forKey: name];
			}

			addresses = [interface objectForKey: key];
			if (addresses == nil) {
				addresses = [OFMutableData
				    dataWithItemSize: sizeof(OFSocketAddress)];
				[interface setObject: addresses forKey: key];
			}

			memset(&address, 0, sizeof(address));
			address.family = addressFamily;
			memcpy(&address.sockaddr.in, &current->lifr_addr,
			    sockaddrSize);

#  if defined(OF_HAVE_IPV6) && defined(HAVE_IF_NAMETOINDEX)
			if (address.sockaddr.in6.sin6_family == AF_INET6 &&
			    address.sockaddr.in6.sin6_addr.s6_addr[0] == 0xFE &&
			    (address.sockaddr.in6.sin6_addr.s6_addr[1] & 0xC0)
			    == 0x80)
				address.sockaddr.in6.sin6_scope_id =
				    if_nametoindex(
				    [name cStringWithEncoding: encoding]);
#  endif

			[addresses addItem: &address];
		}
	} @finally {
		free(lifrs);
		closesocket(sock);
	}
# else
	struct ifconf ifc;
	struct ifreq *ifrs;

	if (sock < 0)
		return false;

	if ((ifrs = malloc(128 * sizeof(struct ifreq))) == NULL) {
		closesocket(sock);
		return false;
	}

	@try {
		char *buffer;

		memset(&ifc, 0, sizeof(ifc));
		ifc.ifc_buf = (void *)ifrs;
		ifc.ifc_len = 128 * sizeof(struct ifreq);
		if (ioctl(sock, SIOCGIFCONF, &ifc) < 0)
			return false;

		buffer = ifc.ifc_buf;
		while (buffer < (char *)ifc.ifc_buf + ifc.ifc_len) {
			struct ifreq *current = (struct ifreq *)(void *)buffer;
			OFString *name;
			OFMutableData *addresses;
			OFSocketAddress address;

			if (current->ifr_addr.sa_family != family)
				goto next;

			name = [OFString stringWithCString: current->ifr_name
						  encoding: encoding];
			if ((interface = [ret objectForKey: name]) == nil) {
				interface = [OFMutableDictionary dictionary];
				[ret setObject: interface forKey: name];
			}

			addresses = [interface objectForKey: key];
			if (addresses == nil) {
				addresses = [OFMutableData
				    dataWithItemSize: sizeof(OFSocketAddress)];
				[interface setObject: addresses forKey: key];
			}

			memset(&address, 0, sizeof(address));
			address.family = addressFamily;
			memcpy(&address.sockaddr.in, &current->ifr_addr,
			    sockaddrSize);

#  if defined(OF_HAVE_IPV6) && defined(HAVE_IF_NAMETOINDEX)
			if (address.sockaddr.in6.sin6_family == AF_INET6 &&
			    address.sockaddr.in6.sin6_addr.s6_addr[0] == 0xFE &&
			    (address.sockaddr.in6.sin6_addr.s6_addr[1] & 0xC0)
			    == 0x80)
				address.sockaddr.in6.sin6_scope_id =
				    if_nametoindex(
				    [name cStringWithEncoding: encoding]);
#  endif

			[addresses addItem: &address];

next:
# ifdef _SIZEOF_ADDR_IFREQ
			buffer += _SIZEOF_ADDR_IFREQ(*current);
# else
			buffer += sizeof(struct ifreq);
# endif
		}
	} @finally {
		free(ifrs);
		closesocket(sock);
	}
# endif

	enumerator = [ret objectEnumerator];
	while ((interface = [enumerator nextObject]) != nil)
		[[interface objectForKey: key] makeImmutable];

	return true;
}
#endif

static bool
queryNetworkInterfaceIPv4Addresses(OFMutableDictionary *ret)
{
#if defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H)
	return queryNetworkInterfaceAddresses(ret,
	    OFNetworkInterfaceIPv4Addresses, OFSocketAddressFamilyIPv4,
	    AF_INET, sizeof(struct sockaddr_in));
#else
	return false;
#endif
}

#ifdef OF_HAVE_IPV6
static bool
queryNetworkInterfaceIPv6Addresses(OFMutableDictionary *ret)
{
# if defined(OF_LINUX) && defined(OF_HAVE_FILES)
#  ifdef HAVE_IF_NAMETOINDEX
	OFStringEncoding encoding = [OFLocale encoding];
#  endif
	OFFile *file;
	OFString *line;
	OFMutableDictionary *interface;
	OFEnumerator *enumerator;

	@try {
		file = [OFFile fileWithPath: @"/proc/net/if_inet6" mode: @"r"];
	} @catch (OFOpenItemFailedException *e) {
		return false;
	}

	while ((line = [file readLine]) != nil) {
		OFArray *components = [line
		    componentsSeparatedByString: @" "
					options: OFStringSkipEmptyComponents];
		OFString *addressString, *name;
		OFSocketAddress address;
		OFMutableData *addresses;

		if (components.count < 6)
			continue;

		addressString = [components objectAtIndex: 0];
		name = [components objectAtIndex: 5];

		if (addressString.length != 32)
			continue;

		if ((interface = [ret objectForKey: name]) == nil) {
			interface = [OFMutableDictionary dictionary];
			[ret setObject: interface forKey: name];
		}

		memset(&address, 0, sizeof(address));
		address.family = OFSocketAddressFamilyIPv6;
		address.sockaddr.in6.sin6_family = AF_INET6;

		for (size_t i = 0; i < 32; i += 2) {
			unsigned long long byte;

			@try {
				byte = [[addressString
				    substringWithRange: OFMakeRange(i, 2)]
				    unsignedLongLongValueWithBase: 16];
			} @catch (OFInvalidFormatException *e) {
				goto next_line;
			}

			if (byte > 0xFF)
				goto next_line;

			address.sockaddr.in6.sin6_addr.s6_addr[i / 2] =
			    (unsigned char)byte;
		}

#  ifdef HAVE_IF_NAMETOINDEX
		if (address.sockaddr.in6.sin6_addr.s6_addr[0] == 0xFE &&
		    (address.sockaddr.in6.sin6_addr.s6_addr[1] & 0xC0) == 0x80)
			address.sockaddr.in6.sin6_scope_id = if_nametoindex(
			    [name cStringWithEncoding: encoding]);
#  endif

		if ((addresses = [interface
		    objectForKey: OFNetworkInterfaceIPv6Addresses]) == nil) {
			addresses = [OFMutableData
			    dataWithItemSize: sizeof(OFSocketAddress)];
			[interface setObject: addresses
				      forKey: OFNetworkInterfaceIPv6Addresses];
		}

		[addresses addItem: &address];

next_line:
		continue;
	}

	enumerator = [ret objectEnumerator];
	while ((interface = [enumerator nextObject]) != nil)
		[[interface objectForKey: OFNetworkInterfaceIPv6Addresses]
		    makeImmutable];

	return false;
# elif defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H)
	return queryNetworkInterfaceAddresses(ret,
	    OFNetworkInterfaceIPv6Addresses, OFSocketAddressFamilyIPv6,
	    AF_INET6, sizeof(struct sockaddr_in6));
# else
	return false;
# endif
}
#endif

#ifdef OF_HAVE_IPX
static bool
queryNetworkInterfaceIPXAddresses(OFMutableDictionary *ret)
{
# if defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H)
	return queryNetworkInterfaceAddresses(ret,
	    OFNetworkInterfaceIPXAddresses, OFSocketAddressFamilyIPX,
	    AF_IPX, sizeof(struct sockaddr_ipx));
# else
	return false;
# endif
}
#endif

#ifdef OF_HAVE_APPLETALK
static bool
queryNetworkInterfaceAppleTalkAddresses(OFMutableDictionary *ret)
{
# if defined(OF_LINUX) && defined(OF_HAVE_FILES)
	OFFile *file;
	OFString *line;
	OFMutableDictionary *interface;
	OFEnumerator *enumerator;

	@try {
		file = [OFFile fileWithPath: @"/proc/net/atalk/interface"
				       mode: @"r"];
	} @catch (OFOpenItemFailedException *e) {
		return false;
	}

	/* First line is "Interface Address Networks Status" */
	if (![[file readLine] hasPrefix: @"Interface "])
		return false;

	while ((line = [file readLine]) != nil) {
		OFArray *components = [line
		    componentsSeparatedByString: @" "
					options: OFStringSkipEmptyComponents];
		OFString *addressString, *name;
		unsigned long long network, node;
		OFSocketAddress address;
		OFMutableData *addresses;

		if (components.count < 4)
			continue;

		name = [components objectAtIndex: 0];
		addressString = [components objectAtIndex: 1];

		if (addressString.length != 7 ||
		    [addressString characterAtIndex: 4] != ':')
			continue;

		if ((interface = [ret objectForKey: name]) == nil) {
			interface = [OFMutableDictionary dictionary];
			[ret setObject: interface forKey: name];
		}

		@try {
			network = [[addressString
			    substringWithRange: OFMakeRange(0, 4)]
			    unsignedLongLongValueWithBase: 16];
			node = [[addressString
			    substringWithRange: OFMakeRange(5, 2)]
			    unsignedLongLongValueWithBase: 16];
		} @catch (OFInvalidFormatException *e) {
			continue;
		}

		if (network > 0xFFFF || node > 0xFF)
			continue;

		address = OFSocketAddressMakeAppleTalk(
		    (uint16_t)network, (uint8_t)node, 0);

		if ((addresses = [interface objectForKey:
		    OFNetworkInterfaceAppleTalkAddresses]) == nil) {
			addresses = [OFMutableData
			    dataWithItemSize: sizeof(OFSocketAddress)];
			[interface
			    setObject: addresses
			       forKey: OFNetworkInterfaceAppleTalkAddresses];
		}

		[addresses addItem: &address];
	}

	enumerator = [ret objectEnumerator];
	while ((interface = [enumerator nextObject]) != nil)
		[[interface objectForKey: OFNetworkInterfaceAppleTalkAddresses]
		    makeImmutable];

	return false;
# elif defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H)
	return queryNetworkInterfaceAddresses(ret,
	    OFNetworkInterfaceAppleTalkAddresses,
	    OFSocketAddressFamilyAppleTalk, AF_APPLETALK,
	    sizeof(struct sockaddr_at));
# else
	return false;
# endif
}
#endif

static bool
queryNetworkInterfaceHardwareAddress(OFMutableDictionary *ret)
{
#if defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H) && defined(SIOCGIFHWADDR) && \
    defined(HAVE_STRUCT_IFREQ_IFR_HWADDR)
	OFStringEncoding encoding = [OFLocale encoding];
	int sock = socket(AF_INET, SOCK_DGRAM, 0);

	if (sock < 0)
		return false;

	for (OFString *name in ret) {
		size_t nameLength = [name cStringLengthWithEncoding: encoding];
		struct ifreq ifr;
		OFData *hardwareAddress;

		if (nameLength > IFNAMSIZ)
			continue;

		memset(&ifr, 0, sizeof(ifr));
		memcpy(&ifr.ifr_name, [name cStringWithEncoding: encoding],
		    nameLength);

		if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0)
			continue;

		if (ifr.ifr_hwaddr.sa_family != ARPHRD_ETHER)
			continue;

		hardwareAddress = [OFData dataWithItems: ifr.ifr_hwaddr.sa_data
						  count: 6];
		[[ret objectForKey: name]
		    setObject: hardwareAddress
		       forKey: OFNetworkInterfaceHardwareAddress];
	}

	return true;
#elif defined(HAVE_IOCTL) && defined(HAVE_NET_IF_H) && \
    defined(HAVE_STRUCT_SOCKADDR_DL)
	OFStringEncoding encoding = [OFLocale encoding];
	int sock = socket(AF_INET, SOCK_DGRAM, 0);
	struct ifconf ifc;
	struct ifreq *ifrs;

	if (sock < 0)
		return false;

	ifrs = malloc(128 * sizeof(struct ifreq));
	if (ifrs == NULL) {
		closesocket(sock);
		return false;
	}

	@try {
		char *buffer;

		memset(&ifc, 0, sizeof(ifc));
		ifc.ifc_buf = (void *)ifrs;
		ifc.ifc_len = 128 * sizeof(struct ifreq);
		if (ioctl(sock, SIOCGIFCONF, &ifc) < 0)
			return false;

		buffer = ifc.ifc_buf;
		while (buffer < (char *)ifc.ifc_buf + ifc.ifc_len) {
			struct ifreq *current = (struct ifreq *)(void *)buffer;
			struct sockaddr_dl *sdl;
			OFString *name;
			OFMutableDictionary *interface;
			OFData *hardwareAddress;

			if (current->ifr_addr.sa_family != AF_LINK)
				goto next;

			sdl = (struct sockaddr_dl *)(void *)&current->ifr_addr;
			if (sdl->sdl_type != IFT_ETHER)
				goto next;

			name = [OFString stringWithCString: current->ifr_name
						  encoding: encoding];
			if ((interface = [ret objectForKey: name]) == nil) {
				interface = [OFMutableDictionary dictionary];
				[ret setObject: interface forKey: name];
			}

			hardwareAddress = [OFData dataWithItems: LLADDR(sdl)
							  count: sdl->sdl_alen];
			[interface
			    setObject: hardwareAddress
			       forKey: OFNetworkInterfaceHardwareAddress];

next:
# ifdef _SIZEOF_ADDR_IFREQ
			buffer += _SIZEOF_ADDR_IFREQ(*current);
# else
			buffer += sizeof(struct ifreq);
# endif
		}
	} @finally {
		free(ifrs);
		closesocket(sock);
	}

	return true;
#else
	return false;
#endif
}

+ (OFDictionary OF_GENERIC(OFString *, OFNetworkInterface) *)networkInterfaces
{
	void *pool = objc_autoreleasePoolPush();
	OFMutableDictionary *ret = [OFMutableDictionary dictionary];
	bool success = false;
	OFEnumerator *enumerator;
	OFMutableDictionary *interface;

	success |= queryNetworkInterfaceIndices(ret);
	success |= queryNetworkInterfaceIPv4Addresses(ret);
#ifdef OF_HAVE_IPV6
	success |= queryNetworkInterfaceIPv6Addresses(ret);
#endif
#ifdef OF_HAVE_IPX
	success |= queryNetworkInterfaceIPXAddresses(ret);
#endif
#ifdef OF_HAVE_APPLETALK
	success |= queryNetworkInterfaceAppleTalkAddresses(ret);
#endif
	success |= queryNetworkInterfaceHardwareAddress(ret);

	if (!success) {
		objc_autoreleasePoolPop(pool);
		return nil;
	}

	enumerator = [ret objectEnumerator];
	while ((interface = [enumerator nextObject]) != nil)
		[interface makeImmutable];

	[ret makeImmutable];
	[ret retain];

	objc_autoreleasePoolPop(pool);

	return [ret autorelease];
}
@end
