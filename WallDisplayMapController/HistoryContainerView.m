//
//  HistoryView.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-27.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import "HistoryContainerView.h"
#import "GlobalLayoutRef.h"
#import "HistoryBarView.h"
#import "HistoryPreviewView.h"

#import "MetricsHistoryDataCenter.h" // this is for test button 2 only!

#define TAB_BAR_HEIGHT 49 // this is simply the default tab height for iOS

@implementation HistoryContainerView
{
    HistoryBarView* historyBarView;
    HistoryPreviewView* historyPreviewView;
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
    
    UIButton* testButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [testButton2 setTitle:@"addTestEntry" forState:UIControlStateNormal];
    testButton2.frame = CGRectMake(600, 500, 150, 50);
    [testButton2 addTarget:self action:@selector(test2ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:testButton2];
    
    return self;
}

- (void)testButtonPressed:(id)sender {
    [self expandGraph];
//    [[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
}

- (void)testButtonReleased:(id)sender {
    [self collapseGraph];
}

- (void)test2ButtonPressed:(id)sender {
    // use the data centre for this test button only in this class!
    [[MetricsHistoryDataCenter instance]addNewDummyEntry];
}

- (void)expandGraph {
    [UIView animateWithDuration:0.35 animations:^(void){
        [historyBarView setHeight:[[GlobalLayoutRef instance]getHistoryBarExpandedHeight]];
        pointerView.center = CGPointMake(historyBarView.frame.size.width / 2, [[GlobalLayoutRef instance]getHistoryBarExpandedHeight]);
    }];
}

- (void)collapseGraph {
    [UIView animateWithDuration:0.35 animations:^(void){
        [historyBarView setHeight:[[GlobalLayoutRef instance]getHistoryBarOriginalHeight]];
        pointerView.center = CGPointMake(historyBarView.frame.size.width / 2, [[GlobalLayoutRef instance]getHistoryBarOriginalHeight]);
    }];
}

- (void) setUpHistoryBar:(nonnull HistoryBarView *) hbv {
    historyBarView = hbv;
    [self addSubview:historyBarView];
    
    // set history bar height without animation
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [historyBarView setHeight:[[GlobalLayoutRef instance]getHistoryBarOriginalHeight]];
    [CATransaction commit];
    
    // draw the selection pointer
    pointerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 20)];
    [self addSubview:pointerView];
    pointerView.backgroundColor = [UIColor redColor];
    pointerView.center = CGPointMake(historyBarView.frame.size.width / 2, [[GlobalLayoutRef instance]getHistoryBarOriginalHeight]);
}

- (void)setUpPreivewView: (nonnull HistoryPreviewView*) hpv {
    historyPreviewView = hpv;
    [self addSubview:historyPreviewView];
    
    historyPreviewView.frame = CGRectMake(0.0,
                                          [[GlobalLayoutRef instance]getHistoryBarOriginalHeight],
                                          self.frame.size.width,
                                          self.frame.size.height - [[GlobalLayoutRef instance]getHistoryBarOriginalHeight] - TAB_BAR_HEIGHT);
    [self sendSubviewToBack:historyPreviewView];
}

@end
