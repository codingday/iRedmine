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
- (void) finishWithEstimated:(double)estimated andSpent:(double)spent;

@property (nonatomic) BOOL alreadyStarted;

@end

@implementation TimeInformationRequest

@synthesize delegate=_delegate;
@synthesize alreadyStarted = _alreadyStarted;

+ (id) withURL:(NSString *)baseUrlString forProject:(NSString *)project
{
	return [[self alloc] initWithURL:baseUrlString forProject:project];
}

- (id)initWithURL:(NSString *)baseUrlString forProject:(NSString*)project
{
	[super init];
	NSURL * url = [NSURL URLWithString: baseUrlString];
	NSString * URLString = [baseUrlString stringByAppendingFormat:
							@"issues.xml?project_id=%@",project];
	

	_request = [[RESTRequest requestWithURL:URLString delegate:self] retain];
	[_request setCachePolicy:TTURLRequestCachePolicyNoCache];
	
	self.alreadyStarted = NO;
	
	return self;
}

- (void)start
{
	if (self.alreadyStarted)
		return;

	[_request send];
}

- (void)cancel
{
	[_request cancel];
	TT_RELEASE_SAFELY(_request);
}

- (void) finishWithEstimated:(double)estimated andSpent:(double)spent
{
	if (self.delegate) {
		[self.delegate setTimeEstimated:estimated andSpent:spent];
	}
	self.alreadyStarted = NO;
}

- (void) didFail
{
	NSLog(@"Failed to load estimated and spent time");
}

#pragma mark -
#pragma mark Request delegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	[self didFail];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	NSDictionary * dict = [(TTURLXMLResponse *)[request response] rootObject];
	
	double estimated = 0.0;
	double spent = 0.0;
	
	NSArray * issues = [dict valueForKey:@"___Array___" ];
	if (issues && [issues count]) {
		for (NSDictionary * issue in issues) {
			estimated += [[issue valueForKeyPath:@"estimated_hours.___Entity_Value___"] doubleValue];
			spent += [[issue valueForKeyPath:@"spent_hours.___Entity_Value___"] doubleValue];
		}
	}
	[self finishWithEstimated:estimated andSpent:spent];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[self cancel];
	[super dealloc];
}

@end
