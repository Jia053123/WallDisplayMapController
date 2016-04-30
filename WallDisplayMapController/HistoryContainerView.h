//
//  HistoryView.h
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-27.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import <UIKit/UIKit.h> 
@class HistoryBarView;
@class HistoryPreviewView;
@class LegendView;

@interface HistoryContainerView : UIView

/**
  given the historyBarView from the historyBarContainer, initialize the size of it and add it as a subview
 */
- (void)setUpHistoryBar: (nonnull HistoryBarView*) hbv;
- (void)setUpPreivewView: (nonnull HistoryPreviewView*) hpv;
- (void)setUpLegendView: (nonnull LegendView*) lv;

- (void)expandGraph;

- (void)collapseGraph;

@end
