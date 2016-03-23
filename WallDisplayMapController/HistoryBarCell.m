//
//  HistoryBarCell.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-02-03.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import "HistoryBarCell.h"
#import "MetricView.h"
#import "HistoryBarGlobalManager.h"

#define TIME_LABEL_FONT_SIZE 10
#define TIME_LABEL_BUTTON_MARGIN 3
#define GREY_LINE_THICKNESS 2
#define TAG_VIEW_HEIGHT 30
#define TAG_VIEW_WIDTH 68

@implementation HistoryBarCell
{
    UILabel* timeStampLabel;
    UIView* greyLineView;
    UIView* tagView;
    NSMutableArray <UIView*>* metricViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    NSAssert(self, @"init failed");
    
    metricViews = [[NSMutableArray alloc]init];
    
    self.backgroundColor = [UIColor whiteColor];
//    self.layer.borderColor = [UIColor grayColor].CGColor;
//    self.layer.borderWidth = 1.0; // the border is within the bound (inset)
    
    // add the time stamp label
    timeStampLabel = [UILabel new];
    NSAssert(timeStampLabel, @"init failed");
    [self.contentView addSubview:timeStampLabel];
    
    timeStampLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray <NSLayoutConstraint*>* timeStampConstraints = [[NSMutableArray alloc]init];
    [timeStampConstraints addObject:[NSLayoutConstraint constraintWithItem:timeStampLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-1*TIME_LABEL_BUTTON_MARGIN]];
    [timeStampConstraints addObject:[NSLayoutConstraint constraintWithItem:timeStampLabel
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [NSLayoutConstraint activateConstraints:timeStampConstraints];
    
    
    // add the grey line
    greyLineView = [UIView new];
    NSAssert(greyLineView, @"init failed");
    greyLineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:greyLineView];
    greyLineView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray <NSLayoutConstraint*>* greyLineConstraints = [[NSMutableArray alloc]init];
    [greyLineConstraints addObject:[NSLayoutConstraint constraintWithItem:greyLineView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [greyLineConstraints addObject:[NSLayoutConstraint constraintWithItem:greyLineView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:timeStampLabel
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [greyLineConstraints addObject:[NSLayoutConstraint constraintWithItem:greyLineView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:GREY_LINE_THICKNESS]];
    [greyLineConstraints addObject:[NSLayoutConstraint constraintWithItem:greyLineView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [NSLayoutConstraint activateConstraints:greyLineConstraints];
    
    
    // add the tag view
    tagView = [UIView new];
    NSAssert(tagView, @"init failed");
    tagView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:tagView];
    tagView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray <NSLayoutConstraint*>* tagViewConstraints = [[NSMutableArray alloc]init];
    [tagViewConstraints addObject:[NSLayoutConstraint constraintWithItem:tagView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:TAG_VIEW_WIDTH]];
    [tagViewConstraints addObject:[NSLayoutConstraint constraintWithItem:tagView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:TAG_VIEW_HEIGHT]];
    [tagViewConstraints addObject:[NSLayoutConstraint constraintWithItem:tagView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    [tagViewConstraints addObject:[NSLayoutConstraint constraintWithItem:tagView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:greyLineView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0.0]];
    [NSLayoutConstraint activateConstraints:tagViewConstraints];
    
    
    return self;
}

- (void)initForReuseWithTimeStamp:(nonnull NSDate*) time tag:(nonnull NSString*)tag flagOrNot:(BOOL)flag metricNamePositionPairs:(nonnull NSDictionary*) metricData {
    
    // set the timeStamp label
    NSDateFormatter* formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSAssert(timeStampLabel,@"timeStampLabel is nil");
    timeStampLabel.text = [formatter stringFromDate:time];
    timeStampLabel.font = [timeStampLabel.font fontWithSize:TIME_LABEL_FONT_SIZE];
    [timeStampLabel sizeToFit];
    
    
    // TODO set the tag
    
    // remove old metric views
    for (int i=[metricViews count]-1; i>=0; i--) {
        [[metricViews objectAtIndex:i]removeFromSuperview];
        [metricViews removeObjectAtIndex:i];
    }
    
    // add the metric views, one for each metric, overlapping on top of each other
    for (NSString* key in metricData) {
        id value = [metricData objectForKey:key];
        
        // validate key and value
        NSAssert([key isKindOfClass:[NSString class]], @"key is not a string"); // TODO: check if name is valid
        NSAssert([value isKindOfClass:[NSNumber class]], @"value is not a NSNumber");
        
        CGFloat floatV = [(NSNumber*)value floatValue];
        NSAssert(floatV >= 0.0 && floatV <= 1.0, @"value smaller than 0 or greater than 1");
        
        // create a new MetricView, init with key and value
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        MetricView* mv = [[MetricView new]initWithMetricName:key position:floatV color:color]; // TODO not testing lines yet
        [self addSubview:mv];
        
        // set auto layout
        mv.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray <NSLayoutConstraint*>* metricViewConstraints = [[NSMutableArray alloc]init];
        
        // set auto layout: align center X
        [metricViewConstraints addObject:[NSLayoutConstraint constraintWithItem:mv
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:0.0]];
        
        // set auto layout: evenly distribute the bottoms of metric views along height of the cell: the height of the cell is divided into the same number of chunks evenly. Then, the second to the last dividing points are assigned as the bottom of the metric views. This creates the problem that the tops of all the metric views except the last one goes above the cell, while the top of the last metric view aligns perfectly with that of the cell. This problem is solved by using the next constraint on top of this one.
        [metricViewConstraints addObject:[NSLayoutConstraint constraintWithItem:mv
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:(1.0/metricData.count) * ([metricViews count]+1)
                                                                       constant:-1 * (timeStampLabel.frame.size.height
                                                                                      + TAG_VIEW_HEIGHT
                                                                                      + TIME_LABEL_BUTTON_MARGIN)
                                                                                   * (1.0/metricData.count) * ([metricViews count]+1)]];
        [metricViewConstraints lastObject].priority = UILayoutPriorityDefaultHigh; // make this constraint of lower priority than default so that it doesn't get in the way of the next constraint
        
        // set auto layout: the top cannot be above that of the cell. This constraint acts on top of the previous one (of higher priority)
        [metricViewConstraints addObject:[NSLayoutConstraint constraintWithItem:mv
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0]];
        
        // set auto layout: width equal to that of the cell
        [metricViewConstraints addObject:[NSLayoutConstraint constraintWithItem:mv
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0]];
        // set auto layout: height equal to that of the cell
        [metricViewConstraints addObject:[NSLayoutConstraint constraintWithItem:mv
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:[HistoryBarGlobalManager getHistoryBarOriginalHeight]
                                                                                - 1 * (timeStampLabel.frame.size.height
                                                                                      + TAG_VIEW_HEIGHT
                                                                                      + TIME_LABEL_BUTTON_MARGIN)]];
        [NSLayoutConstraint activateConstraints:metricViewConstraints];
        
        // add the MetricView to the array
        [metricViews addObject:mv];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // remove the graphs
}

@end
