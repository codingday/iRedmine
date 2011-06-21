//
//  StoreViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 15.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import "StoreViewController.h"

@implementation StoreViewController

@synthesize products=_products;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
	if (self = [super initWithNavigatorURL:URL query:query]) {
		[self setTitle:NSLocalizedString(@"Store",@"")];
		
		NSSet * productSet = [NSSet setWithObjects:kInAppPurchaseIdentifierPro,kInAppPurchaseIdentifierAdsFree,nil];
		_request = [[[SKProductsRequest alloc] initWithProductIdentifiers:productSet] retain];
		[_request setDelegate:self];
		[_request start];
		
		[self addObserver:self forKeyPath:@"products" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([[[self navigationController] topViewController] isEqual:self]) {
		UIBarButtonItem * cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel:)] autorelease];
		[[self navigationItem] setLeftBarButtonItem:cancelButton];
	}
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self reloadData:self];
}

#pragma mark -
#pragma mark Products request delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	[self willChangeValueForKey:@"products"];
	_products = [[response products] retain];
	[self didChangeValueForKey:@"products"];
}
	
#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)cancel:(id)sender {	
	[_request cancel];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)reloadData:(id)sender {
	if (![self products])
		return [self setDataSource:nil];
	
	TTSectionedDataSource * ds = [TTSectionedDataSource dataSourceWithItems:[NSMutableArray array] 
																   sections:[NSMutableArray array]];
	
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	NSArray * purchases = [[NSUserDefaults standardUserDefaults] arrayForKey:@"purchases"];
	BOOL showRestore = NO;
	
	for (SKProduct * product in [self products]) {
		[formatter setLocale:[product priceLocale]];
		NSString * currency = [formatter stringFromNumber:[product price]];
		
		TTTableButton * purchaseButton = [TTTableButton itemWithText:NSLocalizedString(@"Installed",@"")];
		if (![purchases containsObject:[product productIdentifier]]) {
			showRestore = YES;
			
			NSString * purchaseLabel = [NSString stringWithFormat:NSLocalizedString(@"Purchase %@ (%@)",@""),[product localizedTitle],currency];
			purchaseButton = [TTTableButton itemWithText:purchaseLabel delegate:self selector:@selector(purchase:)];
			[purchaseButton setUserInfo:[NSDictionary dictionaryWithObject:product forKey:@"product"]];
		}
		
		[[ds sections] addObject:[product localizedTitle]];
		[[ds items] addObject:[NSMutableArray arrayWithObjects:[TTTableLongTextItem itemWithText:[product localizedDescription]], purchaseButton, nil]];
	}
	
	if (showRestore) {
		TTTableButton * restoreButton = [TTTableButton itemWithText:NSLocalizedString(@"Restore purchases",@"") delegate:self selector:@selector(restore:)];
		[[ds sections] addObject:@""];
		[[ds items] addObject:[NSMutableArray arrayWithObject:restoreButton]];
	}
	
	[self setDataSource:ds];
}

#pragma mark -
#pragma mark Selectors

- (void)purchase:(TTTableButton *)sender {
	NSDictionary * userInfo = [sender userInfo];
	SKPayment * payment = [SKPayment paymentWithProduct:[userInfo valueForKey:@"product"]];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restore:(TTTableButton *)sender {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[_request setDelegate:nil];
	TT_RELEASE_SAFELY(_request);
	TT_RELEASE_SAFELY(_products);

	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[self removeObserver:self forKeyPath:@"products"];
	[super dealloc];
}

#pragma mark -
#pragma mark Payment queue transaction observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	NSUserDefaults * defaults  = [NSUserDefaults standardUserDefaults];
	NSMutableArray * purchases = [[defaults arrayForKey:@"purchases"] mutableCopy];
	if (!purchases)  purchases = [NSMutableArray array];
	
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
				if (![purchases containsObject:[[transaction payment] productIdentifier]])
					[purchases addObject:[[transaction payment] productIdentifier]];
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
            case SKPaymentTransactionStateRestored:
				if (![purchases containsObject:[[[transaction originalTransaction] payment] productIdentifier]])
					[purchases addObject:[[[transaction originalTransaction] payment] productIdentifier]];
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
            case SKPaymentTransactionStateFailed:
				if ([[transaction error] code] != SKErrorPaymentCancelled) {
					[[[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"") 
												 message:[[transaction error] localizedDescription] 
												delegate:nil cancelButtonTitle:TTLocalizedString(@"OK", @"") 
									   otherButtonTitles:nil] autorelease] show];
				}
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            default:
                break;
        }
	}
	
	if (![purchases isEqualToArray:[defaults arrayForKey:@"purchases"]]) {
		[defaults setValue:purchases forKeyPath:@"purchases"];
		[defaults synchronize];
		[self reloadData:self];
	}
}

@end
