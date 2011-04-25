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

#include "config.h"

#include <string.h>
#include <assert.h>

#import "OFXMLElement.h"
#import "OFString.h"
#import "OFArray.h"
#import "OFDictionary.h"
#import "OFXMLAttribute.h"
#import "OFXMLParser.h"
#import "OFXMLElementBuilder.h"
#import "OFAutoreleasePool.h"

#import "OFInvalidArgumentException.h"
#import "OFMalformedXMLException.h"
#import "OFNotImplementedException.h"
#import "OFUnboundNamespaceException.h"

@interface OFXMLElement_OFXMLElementBuilderDelegate: OFObject
{
@public
	OFXMLElement *element;
}
@end

@implementation OFXMLElement_OFXMLElementBuilderDelegate
- (void)elementBuilder: (OFXMLElementBuilder*)builder
       didBuildElement: (OFXMLElement*)elem
{
	element = [elem retain];
}

- (void)dealloc
{
	[element release];

	[super dealloc];
}
@end

@implementation OFXMLElement
+ elementWithName: (OFString*)name_
{
	return [[[self alloc] initWithName: name_] autorelease];
}

+ elementWithName: (OFString*)name
      stringValue: (OFString*)stringval
{
	return [[[self alloc] initWithName: name
			       stringValue: stringval] autorelease];
}

+ elementWithName: (OFString*)name
	namespace: (OFString*)ns
{
	return [[[self alloc] initWithName: name
				 namespace: ns] autorelease];
}

+ elementWithName: (OFString*)name
	namespace: (OFString*)ns
      stringValue: (OFString*)stringval
{
	return [[[self alloc] initWithName: name
				 namespace: ns
			       stringValue: stringval] autorelease];
}

+ elementWithCharacters: (OFString*)chars
{
	return [[[self alloc] initWithCharacters: chars] autorelease];
}

+ elementWithCDATA: (OFString*)cdata
{
	return [[[self alloc] initWithCDATA: cdata] autorelease];
}

+ elementWithComment: (OFString*)comment
{
	return [[[self alloc] initWithComment: comment] autorelease];
}

+ elementWithXMLString: (OFString*)str
{
	return [[[self alloc] initWithXMLString: str] autorelease];
}

- init
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException newWithClass: c
					      selector: _cmd];
}

- initWithName: (OFString*)name_
{
	return [self initWithName: name_
			namespace: nil
		      stringValue: nil];
}

- initWithName: (OFString*)name_
   stringValue: (OFString*)stringval
{
	return [self initWithName: name_
			namespace: nil
		      stringValue: stringval];
}

- initWithName: (OFString*)name_
     namespace: (OFString*)ns_
{
	return [self initWithName: name_
			namespace: ns_
		      stringValue: nil];
}

- initWithName: (OFString*)name_
     namespace: (OFString*)ns_
   stringValue: (OFString*)stringval
{
	self = [super init];

	@try {
		name = [name_ copy];
		ns = [ns_ copy];

		if (stringval != nil) {
			OFAutoreleasePool *pool;

			pool = [[OFAutoreleasePool alloc] init];
			[self addChild:
			    [OFXMLElement elementWithCharacters: stringval]];
			[pool release];
		}

		namespaces = [[OFMutableDictionary alloc]
		    initWithKeysAndObjects:
		    @"http://www.w3.org/XML/1998/namespace", @"xml",
		    @"http://www.w3.org/2000/xmlns/", @"xmlns", nil];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithCharacters: (OFString*)chars
{
	self = [super init];

	@try {
		characters = [chars copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithCDATA: (OFString*)cdata_
{
	self = [super init];

	@try {
		cdata = [cdata_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithComment: (OFString*)comment_
{
	self = [super init];

	@try {
		comment = [comment_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithXMLString: (OFString*)str
{
	OFAutoreleasePool *pool;
	OFXMLParser *parser;
	OFXMLElementBuilder *builder;
	OFXMLElement_OFXMLElementBuilderDelegate *delegate;

	[self release];

	pool = [[OFAutoreleasePool alloc] init];

	parser = [OFXMLParser parser];
	builder = [OFXMLElementBuilder elementBuilder];
	delegate = [[[OFXMLElement_OFXMLElementBuilderDelegate alloc] init]
	    autorelease];

	[parser setDelegate: builder];
	[builder setDelegate: delegate];

	[parser parseString: str];

	if (![parser finishedParsing])
		@throw [OFMalformedXMLException newWithClass: isa
						      parser: parser];

	self = [delegate->element retain];

	@try {
		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (OFString*)name
{
	return [[name copy] autorelease];
}

- (OFString*)namespace
{
	return [[ns copy] autorelease];
}

- (OFArray*)attributes
{
	return [[attributes copy] autorelease];
}

- (void)setChildren: (OFArray*)children_
{
	OFMutableArray *new = [children_ mutableCopy];

	@try {
		[children release];
	} @catch (id e) {
		[new release];
		@throw e;
	}

	children = new;
}

- (OFArray*)children
{
	return [[children copy] autorelease];
}

- (void)setStringValue: (OFString*)value
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];

	[self setChildren: [OFArray arrayWithObject:
	    [OFXMLElement elementWithCharacters: value]]];

	[pool release];
}

- (OFString*)stringValue
{
	OFAutoreleasePool *pool;
	OFMutableString *ret;
	OFXMLElement **children_c;
	size_t i, count = [children count];

	if (count == 0)
		return @"";

	ret = [OFMutableString string];
	children_c = [children cArray];
	pool = [[OFAutoreleasePool alloc] init];

	for (i = 0; i < count; i++) {
		if (children_c[i]->characters != nil)
			[ret appendString: children_c[i]->characters];
		else if (children_c[i]->cdata != nil)
			[ret appendString: children_c[i]->cdata];
		else if (children_c[i]->comment == nil) {
			[ret appendString: [children_c[i] stringValue]];
			[pool releaseObjects];
		}
	}

	[pool release];

	/*
	 * Class swizzle the string to be immutable. We declared the return type
	 * to be OFString*, so it can't be modified anyway. But not swizzling it
	 * would create a real copy each time -[copy] is called.
	 */
	ret->isa = [OFString class];
	return ret;
}

- (OFString*)_XMLStringWithParent: (OFXMLElement*)parent
{
	OFAutoreleasePool *pool, *pool2;
	char *str_c;
	size_t len, i, j, attrs_count;
	OFString *prefix, *parent_prefix;
	OFXMLAttribute **attrs_carray;
	OFString *ret, *tmp;
	OFMutableDictionary *all_namespaces;
	OFString *def_ns;

	if (characters != nil)
		return [characters stringByXMLEscaping];

	if (cdata != nil)
		return [OFString stringWithFormat: @"<![CDATA[%@]]>", cdata];

	if (comment != nil) {
		OFMutableString *str;

		str = [OFMutableString stringWithString: @"<!--"];
		[str appendString: comment];
		[str appendString: @"-->"];

		/*
		 * Class swizzle the string to be immutable. We declared the
		 * return type to be OFString*, so it can't be modified anyway.
		 * But not swizzling it would create a real copy each time
		 * -[copy] is called.
		 */
		str->isa = [OFString class];
		return str;
	}

	pool = [[OFAutoreleasePool alloc] init];
	def_ns = (defaultNamespace != nil
	    ? defaultNamespace
	    : (parent != nil ? parent->defaultNamespace : (OFString*)nil));

	if (parent != nil && parent->namespaces != nil) {
		OFEnumerator *key_enum = [namespaces keyEnumerator];
		OFEnumerator *obj_enum = [namespaces objectEnumerator];
		id key, obj;

		all_namespaces = [[parent->namespaces mutableCopy] autorelease];

		while ((key = [key_enum nextObject]) != nil &&
		    (obj = [obj_enum nextObject]) != nil)
			[all_namespaces setObject: obj
					   forKey: key];
	} else
		all_namespaces = namespaces;

	prefix = [all_namespaces objectForKey:
	    (ns != nil ? ns : (OFString*)@"")];
	parent_prefix = [all_namespaces objectForKey:
	    (parent != nil && parent->ns != nil ? parent->ns : (OFString*)@"")];

	i = 0;
	len = [name cStringLength] + 3;
	str_c = [self allocMemoryWithSize: len];

	/* Start of tag */
	str_c[i++] = '<';

	if (prefix != nil && ![ns isEqual: def_ns] &&
	    (![ns isEqual: (parent != nil ? parent->ns : (OFString*)nil)] ||
	    parent_prefix != nil)) {
		len += [prefix cStringLength] + 1;
		@try {
			str_c = [self resizeMemory: str_c
					    toSize: len];
		} @catch (id e) {
			[self freeMemory: str_c];
			@throw e;
		}

		memcpy(str_c + i, [prefix cString],
		    [prefix cStringLength]);
		i += [prefix cStringLength];
		str_c[i++] = ':';
	}

	memcpy(str_c + i, [name cString], [name cStringLength]);
	i += [name cStringLength];

	/* xmlns if necessary */
	if (ns != nil && prefix == nil && ![ns isEqual: def_ns] &&
	     (![ns isEqual: (parent != nil ? parent->ns : (OFString*)nil)] ||
	     parent_prefix != nil)) {
		len += [ns cStringLength] + 9;

		@try {
			str_c = [self resizeMemory: str_c
					    toSize: len];
		} @catch (id e) {
			[self freeMemory: str_c];
			@throw e;
		}

		memcpy(str_c + i, " xmlns='", 8);
		i += 8;
		memcpy(str_c + i, [ns cString], [ns cStringLength]);
		i += [ns cStringLength];
		str_c[i++] = '\'';

		def_ns = ns;
	}

	/* Attributes */
	attrs_carray = [attributes cArray];
	attrs_count = [attributes count];

	pool2 = [[OFAutoreleasePool alloc] init];
	for (j = 0; j < attrs_count; j++) {
		OFString *attr_name = [attrs_carray[j] name];
		OFString *attr_prefix = nil;
		tmp = [[attrs_carray[j] stringValue] stringByXMLEscaping];

		if ([attrs_carray[j] namespace] != nil &&
		    (attr_prefix = [all_namespaces objectForKey:
		    [attrs_carray[j] namespace]]) == nil)
			@throw [OFUnboundNamespaceException
			    newWithClass: isa
			       namespace: [attrs_carray[j] namespace]];

		len += [attr_name cStringLength] +
		    (attr_prefix != nil ? [attr_prefix cStringLength] + 1 : 0) +
		    [tmp cStringLength] + 4;

		@try {
			str_c = [self resizeMemory: str_c
					    toSize: len];
		} @catch (id e) {
			[self freeMemory: str_c];
			@throw e;
		}

		str_c[i++] = ' ';
		if (attr_prefix != nil) {
			memcpy(str_c + i, [attr_prefix cString],
			    [attr_prefix cStringLength]);
			i += [attr_prefix cStringLength];
			str_c[i++] = ':';
		}
		memcpy(str_c + i, [attr_name cString],
				[attr_name cStringLength]);
		i += [attr_name cStringLength];
		str_c[i++] = '=';
		str_c[i++] = '\'';
		memcpy(str_c + i, [tmp cString], [tmp cStringLength]);
		i += [tmp cStringLength];
		str_c[i++] = '\'';

		[pool2 releaseObjects];
	}

	/* Childen */
	if (children != nil) {
		OFXMLElement **children_carray = [children cArray];
		size_t children_count = [children count];
		IMP append;

		tmp = [OFMutableString string];
		append = [tmp methodForSelector:
		    @selector(appendCStringWithoutUTF8Checking:)];

		for (j = 0; j < children_count; j++)
			append(tmp, @selector(
			    appendCStringWithoutUTF8Checking:),
			    [[children_carray[j]
			    _XMLStringWithParent: self] cString]);

		len += [tmp cStringLength] + [name cStringLength] + 2;
		@try {
			str_c = [self resizeMemory: str_c
					    toSize: len];
		} @catch (id e) {
			[self freeMemory: str_c];
			@throw e;
		}

		str_c[i++] = '>';
		memcpy(str_c + i, [tmp cString], [tmp cStringLength]);
		i += [tmp cStringLength];
		str_c[i++] = '<';
		str_c[i++] = '/';
		if (prefix != nil) {
			len += [prefix cStringLength] + 1;
			@try {
				str_c = [self resizeMemory: str_c
						    toSize: len];
			} @catch (id e) {
				[self freeMemory: str_c];
				@throw e;
			}

			memcpy(str_c + i, [prefix cString],
			    [prefix cStringLength]);
			i += [prefix cStringLength];
			str_c[i++] = ':';
		}
		memcpy(str_c + i, [name cString], [name cStringLength]);
		i += [name cStringLength];
	} else
		str_c[i++] = '/';

	str_c[i++] = '>';
	assert(i == len);

	[pool release];

	@try {
		ret = [OFString stringWithCString: str_c
					   length: len];
	} @finally {
		[self freeMemory: str_c];
	}
	return ret;
}

- (OFString*)XMLString
{
	return [self _XMLStringWithParent: nil];
}

- (OFString*)description
{
	return [self XMLString];
}

- (void)addAttribute: (OFXMLAttribute*)attr
{
	if (name == nil)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	if (attributes == nil)
		attributes = [[OFMutableArray alloc] init];

	if ([self attributeForName: attr->name
			 namespace: attr->ns] == nil)
		[attributes addObject: attr];
}

- (void)addAttributeWithName: (OFString*)name_
		 stringValue: (OFString*)value
{
	[self addAttributeWithName: name_
			 namespace: nil
		       stringValue: value];
}

- (void)addAttributeWithName: (OFString*)name_
		   namespace: (OFString*)ns_
		 stringValue: (OFString*)value
{
	OFAutoreleasePool *pool;

	if (name == nil)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	pool = [[OFAutoreleasePool alloc] init];
	[self addAttribute: [OFXMLAttribute attributeWithName: name_
						    namespace: ns_
						  stringValue: value]];
	[pool release];
}

- (OFXMLAttribute*)attributeForName: (OFString*)attrname
{
	return [self attributeForName: attrname
			    namespace: nil];
}

- (OFXMLAttribute*)attributeForName: (OFString*)attrname
			  namespace: (OFString*)attrns
{
	OFXMLAttribute **attrs_c = [attributes cArray];
	size_t i, attrs_count = [attributes count];

	if (attrns != nil) {
		for (i = 0; i < attrs_count; i++)
			if ([attrs_c[i]->ns isEqual: attrns] &&
			    [attrs_c[i]->name isEqual: attrname])
				return attrs_c[i];
	} else {
		for (i = 0; i < attrs_count; i++)
			if (attrs_c[i]->ns == nil &&
			    [attrs_c[i]->name isEqual: attrname])
				return attrs_c[i];
	}

	return nil;
}

- (void)removeAttributeForName: (OFString*)attrname
{
	[self removeAttributeForName: attrname
			   namespace: nil];
}

- (void)removeAttributeForName: (OFString*)attrname
		     namespace: (OFString*)attrns
{
	OFXMLAttribute **attrs_c = [attributes cArray];
	size_t i, attrs_count = [attributes count];

	if (attrns != nil) {
		for (i = 0; i < attrs_count; i++) {
			if ([attrs_c[i]->ns isEqual: attrns] &&
			    [attrs_c[i]->name isEqual: attrname]) {
				[attributes removeObjectAtIndex: i];

				return;
			}
		}
	} else {
		for (i = 0; i < attrs_count; i++) {
			if (attrs_c[i]->ns == nil &&
			    [attrs_c[i]->name isEqual: attrname]) {
				[attributes removeObjectAtIndex: i];

				return;
			}
		}
	}
}

- (void)setPrefix: (OFString*)prefix
     forNamespace: (OFString*)ns_
{
	if (name == nil || prefix == nil || [prefix isEqual: @""])
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];
	if (ns_ == nil)
		ns_ = @"";

	[namespaces setObject: prefix
		       forKey: ns_];
}

- (void)bindPrefix: (OFString*)prefix
      forNamespace: (OFString*)ns_
{
	[self setPrefix: prefix
	   forNamespace: ns_];
	[self addAttributeWithName: prefix
			 namespace: @"http://www.w3.org/2000/xmlns/"
		       stringValue: ns_];
}

- (OFString*)defaultNamespace
{
	if (name == nil)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	return [[defaultNamespace retain] autorelease];
}

- (void)setDefaultNamespace: (OFString*)ns_
{
	if (name == nil)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	OFString *old = defaultNamespace;
	defaultNamespace = [ns_ copy];
	[old release];
}

- (void)addChild: (OFXMLElement*)child
{
	if (name == nil)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	if (children == nil)
		children = [[OFMutableArray alloc] init];

	[children addObject: child];
}

- (OFXMLElement*)elementForName: (OFString*)elemname
{
	return [self elementForName: elemname
			  namespace: nil];
}

- (OFArray*)elementsForName: (OFString*)elemname
{
	return [self elementsForName: elemname
			   namespace: nil];
}

- (OFXMLElement*)elementForName: (OFString*)elemname
		      namespace: (OFString*)elemns
{
	return [[self elementsForName: elemname
			    namespace: elemns] firstObject];
}

- (OFArray*)elementsForName: (OFString*)elemname
		  namespace: (OFString*)elemns
{
	OFMutableArray *ret = [OFMutableArray array];
	OFXMLElement **children_c = [children cArray];
	size_t i, children_count = [children count];

	if (elemns != nil) {
		for (i = 0; i < children_count; i++)
			if ([children_c[i]->ns isEqual: elemns] &&
			    [children_c[i]->name isEqual: elemname])
				[ret addObject: children_c[i]];
	} else {
		for (i = 0; i < children_count; i++)
			if (children_c[i]->ns == nil &&
			    [children_c[i]->name isEqual: elemname])
				[ret addObject: children_c[i]];
	}

	return ret;
}

- (void)dealloc
{
	[name release];
	[ns release];
	[defaultNamespace release];
	[attributes release];
	[namespaces release];
	[children release];
	[characters release];
	[cdata release];
	[comment release];

	[super dealloc];
}
@end
