//
//  MapControl.h
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2015-05-21.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapWallDisplayProtocal.h"

@interface MapControlView : UIView <UIGestureRecognizerDelegate>

/*
 @return NO and ignore the init parameters if target already exist
 */
- (BOOL) setTarget: (id <MapWallDisplayProtocal>) mapWallDisplayController AndInitializeWithFacingDirection: (float) fd Pitch: (float) p ZoomFactor:(float) zf Latitude: (double)la Longitude: (double)lo;
- (BOOL) setTarget: (id <MapWallDisplayProtocal>) mapWallDisplayController;

///*
// please refer to MapWallDisplayProtocal.h for documentations of the parameters below
// */
//
//- (void) setFacingDirection:(float)fd;
//- (float) getFacingDirection;
//
//- (void) setPitch:(float)p;
//- (float) getPitch;
//
//- (void) setZoomFactor:(float)zf;
//- (float) getZoomFactor;
//
//- (void) setLat:(double)la Lon:(double)lo;
//- (double) getLat;
//- (double) getLon;

@end
