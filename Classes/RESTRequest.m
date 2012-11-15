//
//  RESTRequest.m
//  iRedmine
//
//  Created by Thomas Stägemann on 13.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "RESTRequest.h"

@interface RESTRequest (PrivateMethods)

- (void)xmlTextWriter:(xmlTextWriterPtr)writer writeDictionary:(NSDictionary*)dict;
- (NSData*)XMLDataFromDictionary:(NSDictionary*)dict;

@end

@implementation RESTRequest

@synthesize dictionary=_dictionary;

+ (RESTRequest*)requestWithURL:(NSString*)URL delegate:(id <TTURLRequestDelegate>)delegate
{
	return [[[self alloc] initWithURL:URL delegate:delegate] autorelease];
}

#pragma mark -
#pragma mark Private methods

// Works recursive
- (void)xmlTextWriter:(xmlTextWriterPtr)writer writeDictionary:(NSDictionary*)dict {
	for (NSString * key in [dict allKeys]) {
		xmlTextWriterStartElement(writer, BAD_CAST [key cStringUsingEncoding:NSUTF8StringEncoding]);
		
		id value = [dict valueForKey:key];
		if ([value isKindOfClass:[NSString class]])
			xmlTextWriterWriteString(writer, BAD_CAST [value cStringUsingEncoding:NSUTF8StringEncoding]);
		else if ([value isKindOfClass:[NSNumber class]])
			xmlTextWriterWriteString(writer, BAD_CAST [[value stringValue] cStringUsingEncoding:NSUTF8StringEncoding]);
		else if ([value isKindOfClass:[NSDictionary class]])
			[self xmlTextWriter:writer writeDictionary:value];
		
		xmlTextWriterEndElement(writer);
	}
}

- (NSData*)XMLDataFromDictionary:(NSDictionary*)dict {
	if (!_dictionary) return nil;

	xmlTextWriterPtr writer;
    xmlBufferPtr buffer;
	
    buffer = xmlBufferCreate();
    writer = xmlNewTextWriterMemory(buffer, 0);
	
    // <?xml version="1.0" encoding="UTF-8"?>
    xmlTextWriterStartDocument(writer, "1.0", "UTF-8", NULL);

	// Creates a recursive xml 
	[self xmlTextWriter:writer writeDictionary:dict];
	
    // etc.
    xmlTextWriterEndDocument(writer);
    xmlFreeTextWriter(writer);
	
    // turn libxml2 buffer into NSData* object
    NSData * xmlData = [NSData dataWithBytes:(buffer->content) length:(buffer->use)];
    xmlBufferFree(buffer);
	return xmlData;
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"dictionary"])
		[self setHttpBody:[self XMLDataFromDictionary:_dictionary]];
}

#pragma mark -
#pragma mark Overwritten methods

- (id) init {
	if (self = [super init]) {
		[self setResponse:[[[TTURLXMLResponse alloc] init] autorelease]];
		[self setContentType:@"application/xml"];
		[self addObserver:self forKeyPath:@"dictionary" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[self removeObserver:self forKeyPath:@"dictionary"];
	TT_RELEASE_SAFELY(_dictionary);
	
	[super dealloc];
}

@end
