//
//  HistoryBarView.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2016-01-29.
//  Copyright © 2016 Jialiang. All rights reserved.
//

#import "HistoryBarView.h"
#import <pop/POP.h>

#define SPEED_TRACK_INTERVAL 0.03
#define MIN_SCROLL_SPEED_BEFORE_SNAPING 80


@implementation HistoryBarView
CGPoint lastScrollOffset;
NSTimeInterval lastTrackedTime;
bool readyToSnap;
POPCustomAnimation* snappingAnimaiton;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.backgroundColor = [UIColor lightGrayColor];
    
    lastScrollOffset = CGPointZero;
    lastTrackedTime = [NSDate timeIntervalSinceReferenceDate];
    readyToSnap = false;
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // move the scroll bar to the top
    self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, frame.size.height - 6, 0);\
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"Dragging ends");
    
    if (decelerate) {
        // initialize speed tracking vars
        lastScrollOffset = self.contentOffset;
        lastTrackedTime = [NSDate timeIntervalSinceReferenceDate];
        
        // start speed tracking
        readyToSnap = true;
        
        [self trackSpeedAndSnap];
    } else {
        [self snapToClosestCellWithInitialAbsSpeed:MIN_SCROLL_SPEED_BEFORE_SNAPING];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self trackSpeedAndSnap];
}

/*
 * calc speed and decide whether the speed is low enough to snap
 * needs trackingSpeed = true to work
 * also needs initialization of lastTrackedTime and lastScrollOffset before being called and after the deceleration taking place
 */
- (void)trackSpeedAndSnap {
    if (readyToSnap) {
        // measure speed
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval timeDiff = currentTime - lastTrackedTime;
        float distanceScrolled = self.contentOffset.x - lastScrollOffset.x; // positive: scrolled right; negiative: scrolled left
        float speed = distanceScrolled / timeDiff;
//        NSLog(@"timeDiff: %f, speed: %f", timeDiff, speed);
        
        if (timeDiff > SPEED_TRACK_INTERVAL) {
            // check speed every SPEED_TRACK_INTERVAL secs
            if (fabsf(speed) < MIN_SCROLL_SPEED_BEFORE_SNAPING) {
                // too slow: stop tracking
                readyToSnap = false;
                // snap
                NSLog(@"slow enough to snap");
                if (speed > 0) {
                    [self snapToNextCellWithCurrentScrollDirectionRight:YES withInitialAbsSpeed:fabsf(speed)];
                } else {
                    [self snapToNextCellWithCurrentScrollDirectionRight:NO withInitialAbsSpeed:fabsf(speed)];
                }
//                [self snapToClosestCell];
            }
            // reset only after each speed check
            lastScrollOffset = self.contentOffset;
            lastTrackedTime = [NSDate timeIntervalSinceReferenceDate];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches began");
    readyToSnap = false;
    [self pop_removeAllAnimations];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (readyToSnap) {
        NSLog(@"ended decelerating and snap");
        [self snapToClosestCellWithInitialAbsSpeed:MIN_SCROLL_SPEED_BEFORE_SNAPING];
    }
}

- (void)snapToNextCellWithCurrentScrollDirectionRight:(BOOL)scrollingRight withInitialAbsSpeed:(float) speed {
    NSLog(@"snapToNextCell");
    NSIndexPath* indexOfNextCell;
    NSIndexPath* indexOfCenterCell = [self getIndexPathOfCenterCell];
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexOfCenterCell];
    float realXPos = attributes.center.x - self.contentOffset.x;
    float distance = realXPos - self.center.x;

    if (scrollingRight) {
        if (distance < 0) {
            // already past the center. go next
            indexOfNextCell = [NSIndexPath indexPathForItem:indexOfCenterCell.item + 1 inSection:indexOfCenterCell.section];
        } else {
            indexOfNextCell = indexOfCenterCell;
        }
    } else {
        if (distance > 0) {
            // already past the center. go next
            indexOfNextCell = [NSIndexPath indexPathForItem:indexOfCenterCell.item - 1 inSection:indexOfCenterCell.section];
        } else {
            indexOfNextCell = indexOfCenterCell;
        }
    }
    
    // make sure the index is valid
    if (indexOfNextCell.item > [self numberOfItemsInSection:0] - 1 || indexOfNextCell.item < 0) {
        // the center cell is the last/first cell!
        indexOfNextCell = indexOfCenterCell;
    }
    NSAssert(indexOfNextCell, @"indexOfNextCell is nil");
    
    [self snapToCellAtIndexPath:indexOfNextCell withInitialAbsSpeed:speed];
}

- (void)snapToClosestCellWithInitialAbsSpeed:(float)speed {
    [self snapToCellAtIndexPath:[self getIndexPathOfCenterCell] withInitialAbsSpeed:speed];
}

/*
 * return the index path for the cell at the center of the collection view by hit testing
 * guaranteed to return a valid cell except there's no cell in the collection view
 */
- (NSIndexPath*)getIndexPathOfCenterCell {
    NSLog(@"snapToClosestCell");
    NSIndexPath* indexOfCenterCell = [self indexPathForItemAtPoint:CGPointMake(self.center.x + self.contentOffset.x,
                                                                               self.center.y + self.contentOffset.y)];
    if (!indexOfCenterCell && [self numberOfItemsInSection:0]!= 0) {
        if (self.contentOffset.x <= 0) {
            indexOfCenterCell = [NSIndexPath indexPathForItem:0 inSection:0];
        } else {
            indexOfCenterCell = [NSIndexPath indexPathForItem:[self numberOfItemsInSection:0]-1 inSection:0];
        }
    }
    NSAssert(indexOfCenterCell, @"indexOfCenterCell is nil");
    
    return indexOfCenterCell;
}

- (void)snapToCellAtIndexPath:(NSIndexPath*) index withInitialAbsSpeed:(float) speed {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:index];
    float realXPos = attributes.center.x - self.contentOffset.x;
    float distanceToScroll = realXPos - self.center.x;
    
    CGPoint newContentOffset = CGPointMake(self.contentOffset.x + distanceToScroll, 0);
    [self snapToOffset:newContentOffset withInitialAbsSpeed:speed];
}

- (void)snapToOffset:(CGPoint)offset withInitialAbsSpeed:(float) originalSpeed {
    // stop scrolling animaiton
    [self setContentOffset:self.contentOffset animated:NO];
    
    originalSpeed = fabsf(originalSpeed);
    float distance = offset.x - self.contentOffset.x;
    if (distance < 0) {
        // cell move to the left
        originalSpeed = -1 * originalSpeed;
    } else if(distance == 0) {
        return;
    }
    __block float v = originalSpeed;
    
    // acceleration should be of the opposite sign to speed
    __block float acc = -1 * powf(v, 2.0) / (2 * distance);

    __block NSTimeInterval lastTimeStamp = [NSDate timeIntervalSinceReferenceDate];
    
    snappingAnimaiton = [POPCustomAnimation animationWithBlock:^BOOL(id obj, POPCustomAnimation *animation) {
        NSLog(@"speed: %f", v);
        
        NSTimeInterval currentTimeStamp = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval timeLapse = currentTimeStamp - lastTimeStamp;
        
        float distanceThisFrame = timeLapse * v;
        
        // update content offset
        self.contentOffset = CGPointMake(self.contentOffset.x + distanceThisFrame, 0);
        
        // decelerate speed
        v += acc * timeLapse;
        // update time stamp
        lastTimeStamp = currentTimeStamp;
        
        if (v * originalSpeed <= 0) {
            // sign changed. animation stopped
            return NO;
        } else {
            // not there yet
            return YES;
        }
    }];
    
    [snappingAnimaiton setCompletionBlock:nil]; // TODO

    [self pop_addAnimation:snappingAnimaiton forKey:@"snap"];
}

@end
