/*
 * Copyright (c) 2008 - 2009
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of libobjfw. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#import "OFObject.h"
#import "OFString.h"
#import "OFDictionary.h"

extern int _OFXMLParser_reference;

@class OFXMLParser;

@protocol OFXMLParserDelegate
-     (BOOL)xmlParser: (OFXMLParser*)parser
  didStartTagWithName: (OFString*)name
	    andPrefix: (OFString*)prefix
	 andNamespace: (OFString*)ns
	andAttributes: (OFDictionary*)attrs;
-   (BOOL)xmlParser: (OFXMLParser*)parser
  didEndTagWithName: (OFString*)name
	  andPrefix: (OFString*)prefix
       andNamespace: (OFString*)ns;
- (BOOL)xmlParser: (OFXMLParser*)parser
      foundString: (OFString*)string;
@end

@interface OFXMLParser: OFObject
{
	OFObject <OFXMLParserDelegate> *delegate;
	int state;
}

+ xmlParser;
- (id)delegate;
- setDelegate: (OFObject <OFXMLParserDelegate>*)delegate;
@end

@protocol OFXMLUnescapingDelegate
- (OFString*)foundUnknownEntityNamed: (OFString*)entitiy;
@end

@interface OFString (OFXMLUnescaping)
- stringByXMLUnescaping;
- stringByXMLUnescapingWithHandler: (OFObject <OFXMLUnescapingDelegate>*)h;
@end
