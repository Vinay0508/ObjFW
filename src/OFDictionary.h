/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012
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

#ifndef __STDC_LIMIT_MACROS
# define __STDC_LIMIT_MACROS
#endif
#ifndef __STDC_CONSTANT_MACROS
# define __STDC_CONSTANT_MACROS
#endif

#include <stdarg.h>

#import "OFObject.h"
#import "OFCollection.h"
#import "OFEnumerator.h"
#import "OFSerialization.h"
#import "OFJSONRepresentation.h"

@class OFArray;

#ifdef OF_HAVE_BLOCKS
typedef void (^of_dictionary_enumeration_block_t)(id key, id object,
     BOOL *stop);
typedef BOOL (^of_dictionary_filter_block_t)(id key, id object);
typedef id (^of_dictionary_map_block_t)(id key, id object);
#endif

/**
 * \brief An abstract class for storing objects in a dictionary.
 *
 * Keys are copied and thus must conform to the OFCopying protocol.
 *
 * Note: Fast enumeration on a dictionary enumerates through the keys of the
 * dictionary.
 */
@interface OFDictionary: OFObject <OFCopying, OFMutableCopying, OFCollection,
    OFSerialization, OFJSONRepresentation>
/**
 * \brief Creates a new OFDictionary.
 *
 * \return A new autoreleased OFDictionary
 */
+ dictionary;

/**
 * \brief Creates a new OFDictionary with the specified dictionary.
 *
 * \param dictionary An OFDictionary
 * \return A new autoreleased OFDictionary
 */
+ dictionaryWithDictionary: (OFDictionary*)dictionary;

/**
 * \brief Creates a new OFDictionary with the specified key and object.
 *
 * \param key The key
 * \param object The object
 * \return A new autoreleased OFDictionary
 */
+ dictionaryWithObject: (id)object
		forKey: (id)key;

/**
 * \brief Creates a new OFDictionary with the specified keys and objects.
 *
 * \param keys An array of keys
 * \param objects An array of objects
 * \return A new autoreleased OFDictionary
 */
+ dictionaryWithObjects: (OFArray*)objects
		forKeys: (OFArray*)keys;

/**
 * \brief Creates a new OFDictionary with the specified keys and objects.
 *
 * \param keys An array of keys
 * \param objects An array of objects
 * \param count The number of objects in the arrays
 * \return A new autoreleased OFDictionary
 */
+ dictionaryWithObjects: (id*)objects
		forKeys: (id*)keys
		  count: (size_t)count;

/**
 * \brief Creates a new OFDictionary with the specified keys objects.
 *
 * \param firstKey The first key
 * \return A new autoreleased OFDictionary
 */
+ dictionaryWithKeysAndObjects: (id)firstKey, ...;

/**
 * \brief Initializes an already allocated OFDictionary.
 *
 * \return An initialized OFDictionary
 */
- init;

/**
 * \brief Initializes an already allocated OFDictionary with the specified
 *	  OFDictionary.
 *
 * \param dictionary An OFDictionary
 * \return An initialized OFDictionary
 */
- initWithDictionary: (OFDictionary*)dictionary;

/**
 * \brief Initializes an already allocated OFDictionary with the specified key
 *	  and object.
 *
 * \param key The key
 * \param object The object
 * \return A new initialized OFDictionary
 */
- initWithObject: (id)object
	  forKey: (id)key;

/**
 * \brief Initializes an already allocated OFDictionary with the specified keys
 *	  and objects.
 *
 * \param keys An array of keys
 * \param objects An array of objects
 * \return A new initialized OFDictionary
 */
- initWithObjects: (OFArray*)objects
	  forKeys: (OFArray*)keys;

/**
 * \brief Initializes an already allocated OFDictionary with the specified keys
 *	  and objects.
 *
 * \param keys An array of keys
 * \param objects An array of objects
 * \param count The number of objects in the arrays
 * \return A new initialized OFDictionary
 */
- initWithObjects: (id*)objects
	  forKeys: (id*)keys
	    count: (size_t)count;

/**
 * \brief Initializes an already allocated OFDictionary with the specified keys
 *	  and objects.
 *
 * \param firstKey The first key
 * \return A new initialized OFDictionary
 */
- initWithKeysAndObjects: (id)firstKey, ...;

/**
 * \brief Initializes an already allocated OFDictionary with the specified key
 *	  and va_list.
 *
 * \param firstKey The first key
 * \param arguments A va_list of the other arguments
 * \return A new initialized OFDictionary
 */
- initWithKey: (id)firstKey
    arguments: (va_list)arguments;

/**
 * \brief Returns the object for the given key or nil if the key was not found.
 *
 * The returned object is <i>not</i> retained and autoreleased for performance
 * reasons!
 *
 * \param key The key whose object should be returned
 * \return The object for the given key or nil if the key was not found
 */
- (id)objectForKey: (id)key;
- (id)objectForKeyedSubscript: (id)key;

/**
 * \brief Checks whether the dictionary contains an object with the specified
 *	  address.
 *
 * \param object The object which is checked for being in the dictionary
 * \return A boolean whether the dictionary contains an object with the
 *	   specified address.
 */
- (BOOL)containsObjectIdenticalTo: (id)object;

/**
 * \brief Returns an array of all keys.
 *
 * \return An array of all keys
 */
- (OFArray*)allKeys;

/**
 * \brief Returns an array of all objects.
 *
 * \return An array of all objects
 */
- (OFArray*)allObjects;

/**
 * \brief Returns an OFEnumerator to enumerate through the dictionary's keys.
 *
 * \return An OFEnumerator to enumerate through the dictionary's keys
 */
- (OFEnumerator*)keyEnumerator;

#ifdef OF_HAVE_BLOCKS
/**
 * \brief Executes a block for each key / object pair.
 *
 * \param block The block to execute for each key / object pair.
 */
- (void)enumerateKeysAndObjectsUsingBlock:
    (of_dictionary_enumeration_block_t)block;

/**
 * \brief Creates a new dictionary, mapping each object using the specified
 *	  block.
 *
 * \param block A block which maps an object for each object
 * \return A new, autorelease OFDictionary
 */
- (OFDictionary*)mappedDictionaryUsingBlock: (of_dictionary_map_block_t)block;

/**
 * \brief Creates a new dictionary, only containing the objects for which the
 *	  block returns YES.
 *
 * \param block A block which determines if the object should be in the new
 *		dictionary
 * \return A new, autoreleased OFDictionary
 */
- (OFDictionary*)filteredDictionaryUsingBlock:
    (of_dictionary_filter_block_t)block;
#endif

#if defined(OF_SET_M) || defined(OF_COUNTED_SET_M)
- _initWithDictionary: (OFDictionary*)dictionary
	     copyKeys: (BOOL)copyKeys;
#endif
@end

#import "OFMutableDictionary.h"

#ifndef NSINTEGER_DEFINED
/* Required for dictionary literals to work */
@compatibility_alias NSDictionary OFDictionary;
#endif
