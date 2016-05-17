//
//  PlaceRegion.h
//  MapBox
//
//  Created by Shyla PC on 5/13/16.
//  Copyright © 2016 Mobinius.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceRegion : NSObject
@property(retain,nonatomic)NSMutableArray *placeInfoArr;

- (id)initWithJSON:(NSDictionary *)json;

@end
