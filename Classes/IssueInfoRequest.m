//
//  IssueInfoRequest.m
//  iRedmine
//
//  Created by Sven Köhler on 10.11.12.
//

#import "IssueInfoRequest.h"
#import "RESTRequest.h"


@interface  IssueInfoRequest ()

@property (nonatomic, strong) RESTRequest * request;

- (void) didFail;

@end

@implementation IssueInfoRequest

@synthesize delegate = _delegate;
@synthesize request = _request;

+ (id) issue:(int)issueNumber at:(NSString *)baseUrlString for:(id<TTURLRequestDelegate, IssueInfoDelegate>)delegate
{
	IssueInfoRequest * issueRequest = [[self alloc] initForIssue:issueNumber
															  at:baseUrlString];
	issueRequest.delegate = delegate;
	[issueRequest start];
	return issueRequest;
}

- (id) initForIssue:(int)issueNumber at:(NSString *)baseUrlString
{
	[super init];
	NSString * URLString = [baseUrlString stringByAppendingFormat:
							@"issues/%d.xml",issueNumber];
	
	self.request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
	[self.request setCachePolicy:TTURLRequestCachePolicyNoCache];
	[self.request setHttpMethod:@"GET"];

	
	return self;
}

- (void) start
{
	[self.request send];
}

- (void) cancel
{
	[self.request cancel];
}

- (void) didFail
{
	[self dealloc];
}

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	NSDictionary * issue = [(TTURLXMLResponse *)[request response] rootObject];
	if (issue && self.delegate)
		[self.delegate receiveIssue:issue];
	[self dealloc];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[self cancel];
	[super dealloc];
}

@end
