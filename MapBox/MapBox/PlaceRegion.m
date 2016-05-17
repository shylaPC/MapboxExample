//
//  PlaceRegion.m
//  MapBox
//
//  Created by Shyla PC on 5/13/16.
//  Copyright © 2016 Mobinius.com. All rights reserved.
//

#import "PlaceRegion.h"
#import "Place.h"

@implementation PlaceRegion

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        self.placeInfoArr =[NSMutableArray new];

        if ([[json valueForKey:@"features"]count]) {
            
            for (int i=0;i<[[json valueForKey:@"features"] count]; i++) {
                NSDictionary *dict = [[json valueForKey:@"features"]objectAtIndex:i];
                Place *place= [[Place alloc] init];
                place.nameRegion=[NSString stringWithFormat:@"%@",[dict valueForKey:@"text"]];
               
                place.longitud=[[[dict valueForKey:@"center"] objectAtIndex:0]doubleValue] ;
                place.latitude=[[[dict valueForKey:@"center"] objectAtIndex:1]doubleValue] ;
                
                [self.placeInfoArr addObject:place];

            }
        }
        
    }
    return self;
}


@end
