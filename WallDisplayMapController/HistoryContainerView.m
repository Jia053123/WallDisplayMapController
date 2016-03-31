//
//  HistoryView.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-27.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import "HistoryContainerView.h"
#import "HistoryRenderRef.h"

@implementation HistoryContainerView
{
    HistoryBarController* historyBarController;
    UIView* pointerView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    NSAssert(self, @"init failed");
    
    self.backgroundColor = [UIColor darkGrayColor];
    
    UIButton* testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton setTitle:@"test" forState:UIControlStateNormal];
    testButton.frame = CGRectMake(500, 500, 50, 50);
    [testButton addTarget:self action:@selector(testButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [testButton addTarget:self action:@selector(testButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [testButton addTarget:self action:@selector(testButtonReleased:) forControlEvents:UIControlEventTouchUpOutside];
    [self addSubview:testButton];
    
    return self;
}

- (void)testButtonPressed:(id)sender {
    [UIView animateWithDuration:0.35 animations:^(void){
        [historyBarController setHistoryBarHeight:450];
        pointerView.center = CGPointMake(historyBarController.collectionView.frame.size.width / 2, 450);
    }];
}

- (void)testButtonReleased:(id)sender {
    [UIView animateWithDuration:0.35 animations:^(void){
        [historyBarController setHistoryBarHeight:[[HistoryRenderRef instance]getHistoryBarOriginalHeight]];
        pointerView.center = CGPointMake(historyBarController.collectionView.frame.size.width / 2, [[HistoryRenderRef instance]getHistoryBarOriginalHeight]);
    }];
}

- (void) setUpHistoryBar: (HistoryBarController *) hbc {
    historyBarController = hbc;
    [self addSubview:historyBarController.collectionView];
    
    // set history bar height without animation
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [historyBarController setHistoryBarHeight:[[HistoryRenderRef instance]getHistoryBarOriginalHeight]];
    [CATransaction commit];
    
    // draw the selection pointer
    pointerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 20)];
    [self addSubview:pointerView];
    pointerView.backgroundColor = [UIColor redColor];
    pointerView.center = CGPointMake(historyBarController.collectionView.frame.size.width / 2, [[HistoryRenderRef instance]getHistoryBarOriginalHeight]);
}

@end
