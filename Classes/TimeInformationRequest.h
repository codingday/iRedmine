//
//  TimeInformationRequest.h
//  iRedmine
//
//  Created by Sven Köhler on 10.11.12.
//

#import <Foundation/Foundation.h>
#import "IssueInfoRequest.h"

@protocol TimeInformationDelegate <NSObject>
@required
- (void) setTimeEstimated:(double)timeEstimated
				 andSpent:(double)timeSpent;
@end

@interface TimeInformationRequest : NSObject <TTURLRequestDelegate, IssueInfoDelegate>

+ (id)withURL:(NSString *)baseUrlString forProject:(NSString *) project;
- (id)initWithURL:(NSString *)baseUrlString forProject:(NSString *)project;
- (void)start;
- (void)cancel;

@property(assign) id <TimeInformationDelegate> delegate;

@end
