//
//  HistoryBarController.h
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-29.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryBarView.h"
//#import "HistoryContainerViewController.h"
#import "HistoryBarViewMyDelegate.h"

@interface HistoryBarController : UICollectionViewController <HistoryBarViewMyDelegate>

/*
 * custom initializer
 */
- (instancetype) initWithContainerController: (UIViewController*) hcvc;

- (void)setHistoryBarHeight:(CGFloat)height;

@end