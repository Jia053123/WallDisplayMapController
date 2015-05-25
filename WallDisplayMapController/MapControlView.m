//
//  MapControl.m
//  WallDisplayMapController
//
//  Created by Jialiang Xiang on 2015-05-21.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "MapControlView.h"

@implementation MapControlView {
    id <MapWallDisplayProtocal> target;
    float facingDirection;
    float pitch;
    float zoomFactor;
    double lat;
    double lon;
    
    BOOL rotatingGestureOngoing;
    
    UIPanGestureRecognizer* twoFingerPanRecognizer;
    UIRotationGestureRecognizer* rotationRecognizer;
}

float const twoFingerPitchingDetectionThresholdYXRatio = 0.3;
float const twoFingerPitchingDetectionThresholdYTranslation = 1;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (BOOL) setTarget: (id <MapWallDisplayProtocal>) mapWallDisplayController AndInitializeWithFacingDirection: (float) fd Pitch: (float) p ZoomFactor:(float) zf Latitude: (double)la Longitude: (double)lo
{
    if (target == nil) {
        target = mapWallDisplayController;
        
        [self setFacingDirection:fd];
        [self setPitch:p];
        [self setZoomFactor:zf];
        [self setLat:la Lon:lo];
        
        return YES;
    } else {
        return NO;
    }
}

- (void) customInit
{
    // init iVars
    rotatingGestureOngoing = NO;
    
    // init gesture recognizers
    [self initGestureRecgonizers];
    
    // init UI
    [self initUI];
}

#pragma mark - Gesture Recognition

- (void) initGestureRecgonizers
{
    UIPanGestureRecognizer* oneFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    oneFingerPanRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:oneFingerPanRecognizer];
    
    // TODO: replace this with a custom recognizer
    twoFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPanRecognizer.minimumNumberOfTouches = 2;
    twoFingerPanRecognizer.delegate = self;
    [self addGestureRecognizer:twoFingerPanRecognizer];
    
    rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationRecognizer.delegate = self;
    [self addGestureRecognizer:rotationRecognizer];
}

- (void) handleOneFingerPan: (UIPanGestureRecognizer*) uigr
{
    static CGPoint prevTranslation;
    
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [uigr translationInView:self];  // the new accumlated translation
            CGPoint newTranslation = CGPointMake(translation.x - prevTranslation.x, translation.y - prevTranslation.y); // the new net translation to report
            
            [self moveByLat:[self convertScreenTranslationToLat:newTranslation.x] Lon:[self convertScreenTranslationToLon:newTranslation.y]];
            
            prevTranslation = translation; // update accumulated translation
            break;
        }
        case UIGestureRecognizerStateEnded: {
            prevTranslation = CGPointZero; // don't forget to reset!
            break;
        }
        default:
            break;
    }
}

- (void) handleTwoFingerPan: (UIPanGestureRecognizer*) uigr
{
    static CGPoint prevTranslation;
    
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [uigr translationInView:self];  // the new accumlated translation
            CGPoint newTranslation = CGPointMake(translation.x - prevTranslation.x, translation.y - prevTranslation.y); // the new net translation to report
            
            
            // if the translation is roughfuly horizontal or the y translation is too small or the rotation is ongoing, move lat lon
            // else, pitch
            if (fabsf(newTranslation.y / newTranslation.x) < twoFingerPitchingDetectionThresholdYXRatio || fabsf(newTranslation.y) < twoFingerPitchingDetectionThresholdYTranslation || rotatingGestureOngoing) {
                [self moveByLat:[self convertScreenTranslationToLat:newTranslation.x] Lon:[self convertScreenTranslationToLon:newTranslation.y]];
            } else {
                [self increasePitchBy:[self convertScreenTranslationToPitch:newTranslation.y]];
            }
            
            prevTranslation = translation; // update accumulated translation
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            prevTranslation = CGPointZero; // don't forget to reset!
            break;
        }
        default:
            break;
    }
}

- (void) handleRotation: (UIRotationGestureRecognizer*) uigr
{
    static CGFloat prevRotation;
    
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan: {
            rotatingGestureOngoing = YES;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat rotation = [uigr rotation];
            CGFloat newRotation = rotation - prevRotation;
            
            [self increaseFacingDirectionBy:newRotation]; // no need to convert?
            
            prevRotation = rotation;
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            rotatingGestureOngoing = NO;
            prevRotation = 0.0;
            break;
        }
        default:
            break;
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ((gestureRecognizer == rotationRecognizer && otherGestureRecognizer == twoFingerPanRecognizer) || (gestureRecognizer == twoFingerPanRecognizer && otherGestureRecognizer == rotationRecognizer)) {
        return YES;
    } else {
        return NO;
    }
}

- (float) convertScreenTranslationToPitch:(float) t
{
    // move from top of the screen to the button goes from M_PI/2 to 0
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    return t/screenHeight*(M_PI/2);
}

- (double) convertScreenTranslationToLat:(float) t
{
    return ((double)t) * 0.000001;
}

- (double) convertScreenTranslationToLon:(float) t
{
    return ((double)t) * 0.000001;
}

#pragma mark - User Interface

- (void) initUI
{
    
}

#pragma mark - Getters and Setters

- (void) increaseFacingDirectionBy:(float)angle
{
    CGFloat newFacingDirection = facingDirection + angle;
    
    // check validity
    if (newFacingDirection < 0) {
        newFacingDirection = M_PI * 2 + fmod(newFacingDirection, (M_PI * 2.0));
    } else if (newFacingDirection > M_PI * 2) {
        newFacingDirection = fmod(newFacingDirection, (M_PI * 2.0));
    }
    
    // set the value on map and update iVar if necessary
    if (facingDirection != newFacingDirection) {
        BOOL flag = [target setMapFacingDirection:newFacingDirection];
        if (flag) {
            facingDirection = newFacingDirection;
        }
    }
}

- (void) setFacingDirection:(float)fd
{
    // TODO: update UI
    
    facingDirection = fd;
}

- (float) getFacingDirection
{
    return facingDirection;
}

- (void) increasePitchBy:(float)angle
{
    float newPitch = pitch + angle;
    
    // check validity
    if (newPitch < 0) {
        newPitch = 0;
    } else if (newPitch > M_PI/2) {
        newPitch = M_PI/2;
    }
    
    // set the value on map and update iVar if necessary
    if (pitch != newPitch) {
        BOOL flag = [target setMapPitch:newPitch];
        if (flag) {
            pitch = newPitch;
        }
    }
}

- (void) setPitch:(float)p
{
    pitch = p;
}

- (float) getPitch
{
    return pitch;
}

- (void) increaseZoomFactorBy:(float)factor
{
    
}

- (void) setZoomFactor:(float)zf
{
    zoomFactor = zf;
}

- (float) getZoomFactor
{
    return zoomFactor;
}

- (void) moveByLat:(double)la Lon:(double)lo
{
    double newLat = lat + la;
    double newLon = lon + lo;
    
    // check validity
    if (newLat < -90) {
        newLat = -90;
    } else if (newLat > 90){
        newLat = 90;
    }
    
    if (newLon < -180) {
        newLon = -180;
    } else if (newLon > 180) {
        newLon = 180;
    }
    
    // set new value on map and update iVars if necessary
    if (lat != newLat || lon != newLon) {
        BOOL flag = [target setMapLat:newLat Lon:newLon];
        if (flag) {
            lat = newLat;
            lon = newLon;
        }
    }
}

- (void) setLat:(double)la Lon:(double)lo
{
    lat = la;
    lon = lo;
}

- (double) getLat
{
    return lat;
}

- (double) getLon
{
    return lon;
}

@end
