//
//  StoreViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 15.04.11.
//  Copyright 2011 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "Constants.h"

@interface StoreViewController : BaseTableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	SKProductsRequest * _request;
	NSArray * _products;
}

@property (nonatomic, retain, readonly) NSArray * products;

- (IBAction)cancel:(id)sender;
- (IBAction)reloadData:(id)sender;

@end
