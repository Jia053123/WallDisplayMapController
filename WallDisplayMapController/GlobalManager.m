//
//  GlobalManager.m
//  WallDisplayMapController
//
//  Created by Siyi Meng on 2015-07-07.
//  Copyright (c) 2015 Jialiang. All rights reserved.
//

#import "GlobalManager.h"
#import "RabbitMQManager.h"
#import "XMLDictionary.h"
#import "DensityModel.h"
#import "EnergyModel.h"
#import "BuildingsModel.h"
#import "DistrictEnergyModel.h"

@interface GlobalManager()

@property (nonatomic, strong) DensityModel *modelDensity;
@property (nonatomic, strong) BuildingsModel *modelBuildings;
@property (nonatomic, strong) EnergyModel *modelEnergy;
@property (nonatomic, strong) DistrictEnergyModel *modelDistrictEnergy;

@property (nonatomic, strong) NSMutableDictionary *dictWidgetStatus;

@end

@implementation GlobalManager

+ (GlobalManager *)sharedInstance {
    static GlobalManager *instance;
    static dispatch_once_t done;
    dispatch_once(&done,^{
        instance = [[GlobalManager alloc] init];
        instance.dictWidgetStatus = [NSMutableDictionary dictionaryWithCapacity:25.0];
    });
    return instance;
}

- (NSDictionary *)getPeopleAndDwellings {
    return @{@"people" : self.modelBuildings? self.modelBuildings.people : @0,
             @"dwellings" : self.modelBuildings? self.modelBuildings.dwellings : @0};

}

- (NSArray *)getWidgetElementsByCategory:(NSString *)category {
    if ([category isEqualToString:@"Travel"] && self.modelDensity) {
        
        NSDictionary *detail_info_mob0 = @{@"type" : @"desc",
                                          @"data" : @{@"title" : @"Distance",
                                                      @"subtitle" : @"(km per person in a year)"}};
        
        NSDictionary *detail_info_mob1 = @{@"type" : @"desc",
                                           @"data" : @{@"subtitle" : @"(People per hectare and mode thresholds)",
                                                       @"additional" : @[@"Active", @"Transit"]}};
        
        NSDictionary *detail_info_mob234 = @{@"type" : @"desc",
                                           @"data" : @{@"title" : @"Mode",
                                                       @"subtitle" : @"(% of annual trips by mode)"}};
        
        
        NSMutableDictionary *mob0 = [NSMutableDictionary dictionaryWithDictionary: @{@"ch_type" : CHART_TYPE_BAR,
                                                                                     @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"model_vkt" : self.modelDensity.modelVKT,                        @"CEEI_vkt" : self.modelDensity.CEEIKVT,
                                                                                                                                                   @"detail_info" : detail_info_mob0}]}];
        
        NSMutableDictionary *mob4 = [NSMutableDictionary dictionaryWithDictionary:@{@"ch_type" : CHART_TYPE_CIRCLE,
                               @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"active_pct" : self.modelDensity.modelActiveTripsPercent,
                                                                                             @"detail_info" : detail_info_mob234}]}];
        
        NSMutableDictionary *mob2 = [NSMutableDictionary dictionaryWithDictionary:@{@"ch_type" : CHART_TYPE_CIRCLE,
                               @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"transit_pct" : self.modelDensity.modelTransitTripsPercent,
                                                                                             @"detail_info" : detail_info_mob234}]}];
        
        NSMutableDictionary *mob3 = [NSMutableDictionary dictionaryWithDictionary:@{@"ch_type" : CHART_TYPE_CIRCLE,
                               @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"vehicle_pct" : self.modelDensity.modelVehicleTripsPercent,
                                                                                             @"detail_info" : detail_info_mob234}]}];
        
        NSMutableDictionary *mob1 = [NSMutableDictionary dictionaryWithDictionary:@{@"ch_type" : CHART_TYPE_SINGLE_BAR,
                                                                                    @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"detail_info" : detail_info_mob1, @"thresholds" : @[@{@"thresh_value" : self.modelDensity.transitDensityThreshold,                                  @"thresh_icon" : @"transit_pct.png"},
                                                                                                                                                                    @{@"thresh_value" : self.modelDensity.activeDensityThreshold,
                                                                                                                                                                      @"thresh_icon" : @"active_pct.png"}],
                                                                                                                                                  @"current" : self.modelDensity.densityMetric,
                                                                                                                                                  @"title": @"Population Density"}]}];
        
        DEFINE_WEAK_SELF
        NSMutableArray *temp = [NSMutableArray arrayWithArray:@[mob0, mob1, mob2, mob3, mob4]];
        [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *mobi = (NSMutableDictionary *)obj;
            NSString *key = [NSString stringWithFormat:@"mob%d", (int)idx];
            mobi[@"ch_data"][@"ch_key"] = key;
            if (!weakSelf.dictWidgetStatus[key]) {
                weakSelf.dictWidgetStatus[key] = [NSNumber numberWithBool:YES];
            }
        }];
        
        return temp;
        
    } else if ([category isEqualToString:@"Land Use"] && self.modelBuildings) {
        
        NSDictionary *detail_info_lu0 = @{@"type" : @"desc",
                                         @"data" : @{@"title" : @"Floor area",
                                                     @"subtitle" : @"(% of floor area used for Residential)"}};
        
        NSDictionary *detail_info_lu1 = @{@"type" : @"desc",
                                         @"data" : @{@"title" : @"Floor area",
                                                     @"subtitle" : @"(% of floor area used for Commercial)"}};
        
        NSDictionary *detail_info_lu2 = @{@"type" : @"desc",
                                         @"data" : @{@"title" : @"Floor area",
                                                     @"subtitle" : @"(% of floor area used for Civic)"}};
        
        NSDictionary *detail_info_lu3 = @{@"type" : @"desc",
                                         @"data" : @{@"title" : @"Floor area",
                                                     @"subtitle" : @"(% of floor area used for Industrial)"}};
        
        NSDictionary *lu0 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"rez" : self.modelBuildings.rezPercent,
                                                                                            @"detail_info" : detail_info_lu0}]};
        NSDictionary *lu1 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"comm" : self.modelBuildings.commPercent,
                                                                                            @"detail_info" : detail_info_lu1}]};
        NSDictionary *lu2 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"civic" : self.modelBuildings.civicPercent,
                                                                                            @"detail_info" : detail_info_lu2}]};
        NSDictionary *lu3 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"ind" : self.modelBuildings.indPercent,
                                                                                            @"detail_info" : detail_info_lu3}]};
        
        DEFINE_WEAK_SELF
        NSMutableArray *temp = [NSMutableArray arrayWithArray:@[lu0, lu1, lu2, lu3]];
        [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *lui = (NSMutableDictionary *)obj;
            NSString *key = [NSString stringWithFormat:@"lu%d", (int)idx];
            lui[@"ch_data"][@"ch_key"] = key;
            if (!weakSelf.dictWidgetStatus[key]) {
                weakSelf.dictWidgetStatus[key] = [NSNumber numberWithBool:YES];
            }
        }];
        
        return temp;
        
    } else if ([category isEqualToString:@"Energy & Carbon"] && self.modelDistrictEnergy) {
        
        NSDictionary *detail_info_ec0 = @{@"type" : @"desc",
                                           @"data" : @{@"title" : @"Individual",
                                                       @"subtitle" : @"emissions discounted when district energy threshold met"}};
        
        NSDictionary *detail_info_ec1 = @{@"type" : @"circles",
                                          @"data" : @[@{@"key" : @"heating",
                                                        @"value" : self.modelDistrictEnergy.heatingPercent},
                                                      @{@"key" : @"lights",
                                                        @"value" : self.modelDistrictEnergy.lightsPercent},
                                                      @{@"key" : @"mobility",
                                                        @"value" : self.modelDistrictEnergy.mobilityPercent}]};
        
        NSDictionary *detail_info_ec2 = @{@"type" : @"desc",
                                          @"data" : @{@"subtitle" : @"(floor area per neighbourhood area)",
                                                      @"additional" : @[@"DE"]}};
        
        
        NSDictionary *ec0 = @{@"ch_type" : CHART_TYPE_NUMBER,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"main" : [self.modelDistrictEnergy.emissionsPerCapita stringValue],
                                    @"sub" : @"Individual",
                                    @"desc" : @"(tonnes CO2e per capita)",
                                                                                            @"detail_info" : detail_info_ec0}]};
        
        
        NSDictionary *ec1 = @{@"ch_type" : CHART_TYPE_NUMBER,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"main" : [NSString stringWithFormat:@"$%d", [self.modelDistrictEnergy.energyHouseholdIncome intValue]],
                                    @"sub" : @"Household",
                                    @"desc" : @"(annual average cost of energy)",
                                                                                            @"detail_info" : detail_info_ec1}]};
        
        NSDictionary *ec2 = @{@"ch_type" : CHART_TYPE_SINGLE_BAR,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"detail_info" : detail_info_ec2, @"thresholds" : @[@{@"thresh_value" : self.modelDistrictEnergy.districtThresholdFAR,                                  @"thresh_icon" : @"DE.png"}],
                                                                                            @"current" : self.modelDistrictEnergy.far,
                                                                                            @"title": @"Building Density"}]};
        
        DEFINE_WEAK_SELF
        NSMutableArray *temp = [NSMutableArray arrayWithArray:@[ec0, ec1, ec2]];
        [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *lui = (NSMutableDictionary *)obj;
            NSString *key = [NSString stringWithFormat:@"ec%d", (int)idx];
            lui[@"ch_data"][@"ch_key"] = key;
            if (!weakSelf.dictWidgetStatus[key]) {
                weakSelf.dictWidgetStatus[key] = [NSNumber numberWithBool:YES];
            }
        }];
        
        return temp;
        
        
    } else if ([category isEqualToString:@"Economy"]) {
        
        return @[];
        
    } else if ([category isEqualToString:@"Dwellings"] && self.modelBuildings) {
        
        NSDictionary *detail_info_eq = @{@"type" : @"desc",
                                          @"data" : @{@"title" : @"Unit Type",
                                                      @"subtitle" : @"(% of all residential units)"}};
        
        NSDictionary *eq0 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"single" : self.modelBuildings.detachedPercent,
                                                                                            @"detail_info" : detail_info_eq}]};
        NSDictionary *eq1 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"rowhouse" : self.modelBuildings.attachedPercent,
                                                                                            @"detail_info" : detail_info_eq}]};
        NSDictionary *eq2 = @{@"ch_type" : CHART_TYPE_CIRCLE,
                              @"ch_data" : [NSMutableDictionary dictionaryWithDictionary: @{@"apart" : self.modelBuildings.stackedPercent,
                                                                                            @"detail_info" : detail_info_eq}]};
        
        DEFINE_WEAK_SELF
        NSMutableArray *temp = [NSMutableArray arrayWithArray:@[eq0, eq1, eq2]];
        [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *lui = (NSMutableDictionary *)obj;
            NSString *key = [NSString stringWithFormat:@"eq%d", (int)idx];
            lui[@"ch_data"][@"ch_key"] = key;
            if (!weakSelf.dictWidgetStatus[key]) {
                weakSelf.dictWidgetStatus[key] = [NSNumber numberWithBool:YES];
            }
        }];
        
        return temp;
        
    } else if ([category isEqualToString:@"Well Being"]){
        
        return @[];

    } else return @[];
    
}

- (NSDictionary *)getWidgetElementByCategory:(NSString *)category andKey:(NSString *)key {
    NSArray *resultsByCategory = [self getWidgetElementsByCategory:category];
    __block NSDictionary *result;
    [resultsByCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *dataKey = obj[@"ch_data"][@"ch_key"];
        if ([dataKey isEqualToString:key]) {
            result = obj;
            *stop = YES;
        }
    }];

    return result;
}

- (void)beginConsumingMetricsData {
    DEFINE_WEAK_SELF
    
    RabbitMQManager *rmqManager = [RabbitMQManager sharedInstance];
    [rmqManager beginConsumingWidgetsWithCallbackBlock:^(NSString *msg) {
        // parse xml into a dictionary
        NSDictionary *dictTemp = [NSDictionary dictionaryWithXMLString:[msg stringByReplacingOccurrencesOfString:@"d2p1:" withString:@""]];
        NSArray *attributes = dictTemp[@"ResultDict"][@"KeyValueOfstringstring"];
        
        NSMutableDictionary *dictModel = [NSMutableDictionary dictionary];
        [attributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *temp = obj;
            dictModel[temp[@"Key"]] = temp[@"Value"];
        }];
        
        
        NSString *urlBase = dictModel[@"_url_base"];
        // Map the dictModel to corresponding model objects
        if ([urlBase containsString:WIDGET_DENSITY]){
            if (!_modelDensity)
                _modelDensity = [[DensityModel alloc] init];
            [_modelDensity updateModelWithDictionary:dictModel];
            
            
        } else if ([urlBase containsString:WIDGET_BUILDINGS]) {
            if (!_modelBuildings)
                _modelBuildings = [[BuildingsModel alloc] init];
            [_modelBuildings updateModelWithDictionary:dictModel];
            
            
            
        } else if ([urlBase containsString:WIDGET_DISTRICTENERGY]) {
            if (!_modelDistrictEnergy)
                _modelDistrictEnergy = [[DistrictEnergyModel alloc] init];
            [_modelDistrictEnergy updateModelWithDictionary:dictModel];
            
            
            
        } else if ([urlBase containsString:WIDGET_ENERGY]) {
            if (!_modelEnergy)
                _modelEnergy = [[EnergyModel alloc] init];
            [_modelEnergy updateModelWithDictionary:dictModel];
            

            
        } else {
            // model received is unrecognized/undefined
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (weakSelf.targetVC) {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Touch+"
                                         message:@"Sorry, the widget model data received is unrecognized."
                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];

                    [alert addAction:cancelAction];
                    [weakSelf.targetVC presentViewController:alert animated:YES completion:nil];
                }

            });
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:WIDGET_DATA_UPDATED object:nil]];
        NSLog(@"message: %@", msg);
    }];
}

- (BOOL)isWidgetAvailableForKey:(NSString *)key {
    NSNumber *isAvailable = self.dictWidgetStatus[key];
    return [isAvailable boolValue];
}

- (void)setWidgetForKey:(NSString *)key available:(BOOL)isAvailable {
    self.dictWidgetStatus[key] = [NSNumber numberWithBool:isAvailable];
}

@end
