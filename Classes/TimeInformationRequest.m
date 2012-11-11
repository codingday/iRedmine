//
//  TimeInformationRequest.m
//  iRedmine
//
//  Created by Sven Köhler on 10.11.12.
//

#import "TimeInformationRequest.h"
#import "RESTRequest.h"

@interface TimeInformationRequest ()

- (void) didFail;
- (void) sendOff;
- (void) reset;

@property (nonatomic) double estimated;
@property (nonatomic) double spent;
@property (nonatomic) BOOL alreadyStarted;
@property (nonatomic, retain, readonly) NSString * requestBaseUrl;
@property (nonatomic, strong) RESTRequest * request;
@property (nonatomic) int pendingIssues;

@end

@implementation TimeInformationRequest

@synthesize requestBaseUrl = _requestBaseUrl;
@synthesize delegate = _delegate;
@synthesize alreadyStarted = _alreadyStarted;
@synthesize request = _request;
@synthesize pendingIssues = _pendingIssues;

+ (id) withURL:(NSString *)baseUrlString forProject:(NSString *)project
{
	return [[self alloc] initWithURL:baseUrlString forProject:project];
}

- (id)initWithURL:(NSString *)baseUrlString forProject:(NSString*)project
{
	[super init];
	_requestBaseUrl = [baseUrlString retain];
	
	NSString * URLString = [baseUrlString stringByAppendingFormat:
							@"issues.xml?project_id=%@",project];
	

	self.request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
	[self.request setCachePolicy:TTURLRequestCachePolicyNoCache];
	
	return self;
}

- (void)start
{
	if (self.alreadyStarted)
		return;

	self.alreadyStarted = YES;
	[self.request send];
}

- (void)cancel
{
	[self.request cancel];
}

- (void) sendOff
{
	if (self.delegate) {
		[self.delegate setTimeEstimated:self.estimated andSpent:self.spent];
	}
}

- (void) reset
{
	self.pendingIssues = 0;
	self.estimated = 0.0;
	self.spent = 0.0;
	self.alreadyStarted = NO;
}

- (void) didFail
{
	NSLog(@"Failed to load estimated and spent time");
}

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	
	NSArray * issues = [dict valueForKey:@"___Array___" ];
	if (!issues || ![issues count]) {
		[self sendOff];
		return;
	}
	
	self.pendingIssues = [issues count];
	
	for (NSDictionary * issue in issues) {
		int issueId = [[issue valueForKeyPath:@"id.___Entity_Value___"] intValue];
		
		// Get a somewhat more detailed issue that containes spent_hours
		[IssueInfoRequest issue:issueId at:[self requestBaseUrl] for:self];
	}
}

#pragma mark -
#pragma mark Issue Info Request Delegate

- (void) receiveIssue:(NSDictionary *)moreDetailedIssue
{
	self.pendingIssues--;

	self.estimated += [[moreDetailedIssue valueForKeyPath:@"estimated_hours.___Entity_Value___"] doubleValue];
	self.spent += [[moreDetailedIssue valueForKeyPath:@"spent_hours.___Entity_Value___"] doubleValue];

	[self sendOff];

	if (self.pendingIssues <= 0 && self.alreadyStarted)
		[self reset];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[self cancel];
	[super dealloc];
}

@end
