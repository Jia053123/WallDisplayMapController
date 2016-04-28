//
//  HistoryViewController.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-27.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import "HistoryContainerViewController.h"
#import "HistoryContainerView.h"
#import "HistoryBarController.h"
#import "HistoryPreviewController.h"
#import "MetricsHistoryDataCenter.h"
#import "MetricsDataEntry.h"
#import "MetricsConfigs.h"

@interface HistoryContainerViewController ()

@end

@implementation HistoryContainerViewController
{
    HistoryBarController* historyBarController;
    HistoryPreviewController* historyPreviewController;
    NSArray<NSNumber*>* metricsDisplayedInOrder; // stores the configuration that which metrics should be displayed and in what order
}

- (id)init {
    self = [super init];
    if (self) {
        [[MetricsHistoryDataCenter instance] setDelegate:self];
        
        metricsDisplayedInOrder = [NSArray arrayWithObjects:[NSNumber numberWithInteger:density_modelActiveTripsPercent],
                                                            [NSNumber numberWithInteger:building_people],
                                                            [NSNumber numberWithInteger:building_detachedPercent],
                                                            [NSNumber numberWithInteger:districtEnergy_energyHouseholdIncome], nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create and init containerView
    HistoryContainerView *historyContainerView = [[HistoryContainerView alloc] initWithFrame:self.view.bounds];
    self.view = historyContainerView;
    
    // create and init preview controller
    historyPreviewController = [[HistoryPreviewController alloc]initWithContainerController:self];
    NSAssert(historyPreviewController, @"init failed");
    
    [self addChildViewController:historyPreviewController];
    
    // give historyPreviewView to containerView to add it as subview and init the size
    [(HistoryContainerView*)self.view setUpPreivewView:(HistoryPreviewView*)historyPreviewController.view];
    
    // create and init historyBarController
    historyBarController = [[HistoryBarController alloc]initWithContainerController:self];
    NSAssert(historyBarController, @"init failed");
    
    [self addChildViewController:historyBarController];
    
    // give historyBarView to containerView to add it as subview and init the size
    [(HistoryContainerView*)self.view setUpHistoryBar:(HistoryBarView*)historyBarController.collectionView];
}

- (NSInteger)getTotalNumberOfData {
    return [[MetricsHistoryDataCenter instance] getTotalNumberOfData];
}

- (NSDictionary*)getMetricsDisplayPositionsAtTimeIndex:(NSInteger)index {
    // TODO
    
    return [[MetricsHistoryDataCenter instance] getMetricsDataAtTimeIndex:index].metricsValues;
}

- (NSString*)getPreviewImagePathForIndex:(NSInteger)index {
    return [[MetricsHistoryDataCenter instance]getMetricsDataAtTimeIndex:index].previewImagePath;
}

- (void)showPreviewForIndex:(NSInteger)index {
    [historyPreviewController showPreviewAtIndex:index];
}

- (void)newEntryAppendedInDataCenter {
    [historyBarController appendNewEntryIfAvailable];
    if (historyPreviewController.currentIndex == [[MetricsHistoryDataCenter instance]getTotalNumberOfData] - 1) {
        // the entry added is exactly the one currenly displaying. Refresh preview.
        [historyPreviewController refreshCurrentPreview];
    }
}

@end
