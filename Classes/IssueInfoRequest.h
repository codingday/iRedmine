//
//  IssueInfoRequest.h
//  iRedmine
//
//  Created by Sven Köhler on 10.11.12.
//

#import <Foundation/Foundation.h>

@protocol IssueInfoDelegate <NSObject>
@required
- (void) receiveIssue:(NSDictionary *)issue;
@end

@interface IssueInfoRequest: NSObject <TTURLRequestDelegate>

@property(assign) id <TTURLRequestDelegate, IssueInfoDelegate> delegate;

+ (id) issue:(int)issueNumber at:(NSString *)baseUrlString for:(id<TTURLRequestDelegate, IssueInfoDelegate>)delegate;

- (id) initForIssue:(int)issueNumber at:(NSString *)baseUrlString;

- (void) start;
- (void) cancel;

@end
