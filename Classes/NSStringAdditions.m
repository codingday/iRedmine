//
//  NSStringAdditions.m
//  iRedmine
//
//  Created by Thomas Stägemann on 02.12.09.
//  Copyright 2009 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

- (NSString *)stringByAppendingURLPathComponent:(NSString*)component {
	NSURL * originalURL = [NSURL URLWithString:self];
	NSString * path = [[originalURL path] stringByAppendingPathComponent:component];
	NSURL * URL = [[[NSURL alloc] initWithScheme:[originalURL scheme] host:[originalURL host] path:path] autorelease];
	return [URL absoluteString];
}

- (NSString *)stringByEscapingHTML{
    NSArray *escapeChars = [NSArray arrayWithObjects:
							// Special Characters							
							@"&", @"<", @">", @"\"",
							// ISO 8859-1 Symbols
							@"©", @"®", @"¤", @"€", @"£", @"¢", @"¥",
							@"¡", @"¿", @"·", @"¸", @"«", @"»", @"¶",
							@"×", @"÷", @"±", @"¼", @"½", @"¾", @"´",
							@"º", @"ª", @"¹", @"²", @"³", @"°", @"µ",
							@"¦", @"¨", @"¬", @"¯", @"§",
							// ISO 8859-1 Characters
							@"ç", @"ð", @"ñ", @"þ", @"ý", @"ÿ",
							@"Ç", @"Ð", @"Ñ", @"Þ", @"Ý", @"ß",
							@"à", @"á", @"â", @"ä", @"ã", @"å", @"æ", 
							@"À", @"Á", @"Â", @"Ä", @"Ã", @"Å", @"Æ", 
							@"ò", @"ó", @"ô", @"ö", @"õ", @"ø", 
							@"Ò", @"Ó", @"Ô", @"Ö", @"Õ", @"Ø", 
							@"è", @"é", @"ê", @"ë", 
							@"È", @"É", @"Ê", @"Ë", 
							@"ì", @"í",	@"î", @"ï",	
							@"Ì", @"Í",	@"Î", @"Ï",	
							@"ù", @"ú", @"û", @"ü",
							@"Ù", @"Ú", @"Û", @"Ü",
							nil];
	
    NSArray *entityNames = [NSArray arrayWithObjects:
							// Special Characters
							@"&amp;", @"&lt;", @"&gt;", @"&quot",
							// ISO 8859-1 Symbols
							@"&copy;", @"&reg;", @"&curren;", @"&euro;", @"&pound;", @"&cent;", @"&yen;",
							@"&iexcl;", @"&iquest;", @"&middot;", @"&cedil;", @"&laquo;", @"&raquo;", @"&para;",
							@"&times;", @"&divide;", @"&plusmn;", @"&frac14;", @"&frac12;", @"&frac34;", @"&acute;",
							@"&ordm;", @"&ordf;", @"&sup1;", @"&sup2;", @"&sup3;", @"&deg;", @"&micro;",
							@"&brvbar;", @"&uml;", @"&not;", @"&macr;", @"&sect;",
							// ISO 8859-1 Characters
							@"&ccedil;", @"&eth;", @"&ntilde;", @"&thorn;", @"&yacute;", @"&yuml;",
							@"&Ccedil;", @"&ETH;", @"&Ntilde;", @"&THORN;", @"&Yacute;", @"&szlig;",
							@"&agrave;", @"&aacute;", @"&acirc;", @"&auml;", @"&atilde;", @"&aring;", @"&aelig;", 
							@"&Agrave;", @"&Aacute;", @"&Acirc;", @"&Auml;", @"&Atilde;", @"&Aring;", @"&AElig;", 
							@"&ograve;", @"&oacute;", @"&ocirc;", @"&ouml;", @"&otilde;", @"&oslash;", 
							@"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Ouml;", @"&Otilde;", @"&Oslash;", 
							@"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;", 
							@"&Egrave;", @"&Eacute;", @"&Ecirc;", @"&Euml;", 
							@"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", 
							@"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;", 
							@"&ugrave;", @"&uacute;", @"&ucirc;", @"&uuml;", 
							@"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", 
							nil];
	
    int len = [escapeChars count];
	
    NSMutableString * temp = [self mutableCopy];
	
    for(int i = 0; i < len; i++){		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[entityNames objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

- (NSString *)stringByUnescapingHTML{
    NSArray *escapeChars = [NSArray arrayWithObjects:
							// Special Characters							
							@"&", @"<", @">", @"\"", @"'",
							// ISO 8859-1 Symbols
							@"©", @"®", @"¤", @"€", @"£", @"¢", @"¥",
							@"¡", @"¿", @"·", @"¸", @"«", @"»", @"¶",
							@"×", @"÷", @"±", @"¼", @"½", @"¾", @"´",
							@"º", @"ª", @"¹", @"²", @"³", @"°", @"µ",
							@"¦", @"¨", @"¬", @"¯", @"§", @" ",
							// ISO 8859-1 Characters
							@"ç", @"ð", @"ñ", @"þ", @"ý", @"ÿ",
							@"Ç", @"Ð", @"Ñ", @"Þ", @"Ý", @"ß",
							@"à", @"á", @"â", @"ä", @"ã", @"å", @"æ", 
							@"À", @"Á", @"Â", @"Ä", @"Ã", @"Å", @"Æ", 
							@"ò", @"ó", @"ô", @"ö", @"õ", @"ø", 
							@"Ò", @"Ó", @"Ô", @"Ö", @"Õ", @"Ø", 
							@"è", @"é", @"ê", @"ë", 
							@"È", @"É", @"Ê", @"Ë", 
							@"ì", @"í",	@"î", @"ï",	
							@"Ì", @"Í",	@"Î", @"Ï",	
							@"ù", @"ú", @"û", @"ü",
							@"Ù", @"Ú", @"Û", @"Ü",
							nil];
		
    NSArray *entityNames = [NSArray arrayWithObjects:
							// Special Characters
							@"&amp;", @"&lt;", @"&gt;", @"&quot;", @"&apos;",
							// ISO 8859-1 Symbols
							@"&copy;", @"&reg;", @"&curren;", @"&euro;", @"&pound;", @"&cent;", @"&yen;",
							@"&iexcl;", @"&iquest;", @"&middot;", @"&cedil;", @"&laquo;", @"&raquo;", @"&para;",
							@"&times;", @"&divide;", @"&plusmn;", @"&frac14;", @"&frac12;", @"&frac34;", @"&acute;",
							@"&ordm;", @"&ordf;", @"&sup1;", @"&sup2;", @"&sup3;", @"&deg;", @"&micro;",
							@"&brvbar;", @"&uml;", @"&not;", @"&macr;", @"&sect;", @"&nbsp;",
							// ISO 8859-1 Characters
							@"&ccedil;", @"&eth;", @"&ntilde;", @"&thorn;", @"&yacute;", @"&yuml;",
							@"&Ccedil;", @"&ETH;", @"&Ntilde;", @"&THORN;", @"&Yacute;", @"&szlig;",
							@"&agrave;", @"&aacute;", @"&acirc;", @"&auml;", @"&atilde;", @"&aring;", @"&aelig;", 
							@"&Agrave;", @"&Aacute;", @"&Acirc;", @"&Auml;", @"&Atilde;", @"&Aring;", @"&AElig;", 
							@"&ograve;", @"&oacute;", @"&ocirc;", @"&ouml;", @"&otilde;", @"&oslash;", 
							@"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Ouml;", @"&Otilde;", @"&Oslash;", 
							@"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;", 
							@"&Egrave;", @"&Eacute;", @"&Ecirc;", @"&Euml;", 
							@"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", 
							@"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;", 
							@"&ugrave;", @"&uacute;", @"&ucirc;", @"&uuml;", 
							@"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", 
							nil];

	NSArray *entityNumbers = [NSArray arrayWithObjects:
							// Special Characters
							@"&#38;", @"&#60;", @"&#62;", @"&#34;", @"&#39;",
							// ISO 8859-1 Symbols
							@"&#169;", @"&#174;", @"&#164;", @"&#128;", @"&#163;", @"&#162;", @"&#165;",
							@"&#161;", @"&#191;", @"&#183;", @"&#184;", @"&#171;", @"&#187;", @"&#182;",
							@"&#215;", @"&#247;", @"&#177;", @"&#188;", @"&#189;", @"&#190;", @"&#180;",
							@"&#186;", @"&#170;", @"&#185;", @"&#178;", @"&#179;", @"&#176;", @"&#181;",
							@"&#166;", @"&#168;", @"&#172;", @"&#175;", @"&#167;", @"&#160;",
							// ISO 8859-1 Characters
							@"&#231;", @"&#240;", @"&#241;", @"&#254;", @"&#253;", @"&#255;",
							@"&#199;", @"&#208;", @"&#209;", @"&#222;", @"&#221;", @"&#223;",
							@"&#224;", @"&#225;", @"&#226;", @"&#228;", @"&#227;", @"&#229;", @"&230;", 
							@"&#192;", @"&#193;", @"&#194;", @"&#196;", @"&#195;", @"&#197;", @"&#198;", 
							@"&#242;", @"&#243;", @"&#244;", @"&#246;", @"&#245;", @"&#248;", 
							@"&#210;", @"&#211;", @"&#212;", @"&#214;", @"&#213;", @"&#216;", 
							@"&#232;", @"&#233;", @"&#234;", @"&#235;", 
							@"&#200;", @"&#201;", @"&#202;", @"&#203;", 
							@"&#236;", @"&#237;", @"&#238;", @"&#239;", 
							@"&#204;", @"&#205;", @"&#206;", @"&#207;", 
							@"&#249;", @"&#250;", @"&#251;", @"&#252;", 
							@"&#217;", @"&#218;", @"&#219;", @"&#220;", 
							nil];
	
    int len = [escapeChars count];
	
    NSMutableString * temp = [self mutableCopy];
	
    for(int i = 0; i < len; i++){		
        [temp replaceOccurrencesOfString: [entityNumbers objectAtIndex:i]
							  withString:[escapeChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];

        [temp replaceOccurrencesOfString: [entityNames objectAtIndex:i]
							  withString:[escapeChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

@end
