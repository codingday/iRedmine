//
//  TimeInformationRequest.m
//  iRedmine
//
//  Created by Sven Köhler on 10.11.12.
//

#import "TimeInformationRequest.h"
#import "Account.h"

@interface TimeInformationRequest ()

- (void) didFail;

@property (nonatomic) BOOL alreadyStarted;

@end

@implementation TimeInformationRequest

@synthesize delegate=_delegate;
@synthesize alreadyStarted = _alreadyStarted;

- (id)initWithURL:(NSString *)baseUrlString forProject:(NSString*)project
{
	[super init];
	NSURL * url = [NSURL URLWithString: baseUrlString];
	NSString * URLString = [baseUrlString stringByAppendingFormat:
							@"issues.xml?project_id=%@",project];
	

	_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
	[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
	
	Account * account = [Account accountWithURL:[url absoluteString]];
	_login = [[Login loginWithURL:url
						 username:[account username]
						 password:[account password]] retain];
	[_login setDelegate:self];
	[_login setDidFinishSelector:@selector(loginFinished:)];
	[_login setDidFailSelector:@selector(loginFailed:)];
	
	self.alreadyStarted = NO;
	
	return self;
}

- (void)start
{
	if (self.alreadyStarted)
		return;
		
	self.alreadyStarted = YES;
	if (![_login start])
		[_request send];
}

- (void)cancel
{
	[_login setDelegate:nil];
	[_login cancel];
	TT_RELEASE_SAFELY(_login);
	
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
}

- (void) didFail
{
	
}

#pragma mark -
#pragma mark Login selectors

- (void)loginFinished:(Login*)login {
	[_request send];
}

- (void)loginFailed:(Login*)login {
	[self didFail];
}

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	
	if (self.delegate) {
		[self.delegate setTimeSpend:(int)0 andEstimated:(int)0];
	}
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[self cancel];
	[super dealloc];
}

@end
