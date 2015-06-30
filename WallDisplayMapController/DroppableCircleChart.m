//
//  DroppableCircleChart.m
//  WallDisplayMapController
//
//  Created by Siyi Meng on 2015-06-26.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "DroppableCircleChart.h"
#import "PNChart.h"
#import "UIColor+Extend.h"
#import <ChameleonFramework/Chameleon.h>

const CGFloat CIRCLE_EDGE_INSET = 40.0;

@implementation DroppableCircleChart {
    PNCircleChart *circleChart;
    NSDictionary *dictTypeColor;
    
    UIView *imageBg;
    UIImageView *ivIcon;
    UILabel *lblTitle;
    UILabel *lblPercent;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        dictTypeColor = @{@"Mobility" : COLOR_LIGHT_BLUE,
                          @"Land Use" : COLOR_WATERMELON,
                          @"Energy & Carbon" : FlatGreen,
                          @"Economy" : FlatPlum,
                          @"Equity" : FlatCoffee,
                          @"Well Being" : FlatYellow};
        circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(CIRCLE_EDGE_INSET-10.0, CIRCLE_EDGE_INSET+10.0, self.frame.size.width-2*CIRCLE_EDGE_INSET, self.frame.size.height-2*CIRCLE_EDGE_INSET)
                                                                    total:@100
                                                                  current:@0
                                                                clockwise:YES
                                                                   shadow:YES
                                                              shadowColor:[UIColor colorFromHexString:@"#e3e3e3"]
                                                     displayCountingLabel:NO
                                                        overrideLineWidth:[NSNumber numberWithFloat:CIRCLE_EDGE_INSET-15.0]];
        circleChart.backgroundColor = COLOR_BG_WHITE;
        self.backgroundColor = COLOR_BG_WHITE;
        circleChart.userInteractionEnabled = NO;
        [self addSubview:circleChart];
        
        // Init Icons
        double sideLength = self.frame.size.width;
        imageBg= [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideLength-140.0, sideLength-140.0)];
        imageBg.layer.cornerRadius = (sideLength-140.0)/2;
        imageBg.layer.masksToBounds = YES;
        ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sideLength-160.0, sideLength-160.0)];
        imageBg.center = circleChart.center;
        ivIcon.center = imageBg.center;
        [self addSubview:imageBg];
        [self addSubview:ivIcon];
        
        // Init Labels
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30.0)];
        lblTitle.center = CGPointMake(circleChart.center.x, 25.0);
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.textColor = [UIColor lightGrayColor];
        lblTitle.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_CONDENSEDBOLD size:25.0];
        [self addSubview:lblTitle];
        
        lblPercent = [[UILabel alloc] initWithFrame:CGRectMake(sideLength-120.0, sideLength-50.0, 100.0, 50.0)];
        lblPercent.textAlignment = NSTextAlignmentRight;
        lblPercent.textColor = [UIColor lightGrayColor];
        lblPercent.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_CONDENSEDBOLD size:28.0];
        [self addSubview:lblPercent];

    }
    return self;
}

- (void)updateCircleChartWithCurrent:(NSNumber *)current type:(NSString *)type icon:(NSString *)iconName {
    [circleChart setStrokeColor:dictTypeColor[type]];
    [circleChart strokeChart];
    [circleChart updateChartByCurrent:current];
    
    
    // Update Icons
    imageBg.backgroundColor = dictTypeColor[type];
    ivIcon.image = [UIImage imageNamed:iconName];

    // Update Labels
    lblTitle.text = iconName;
    lblPercent.text = [NSString stringWithFormat:@"%d%%", [current intValue]];
}

@end