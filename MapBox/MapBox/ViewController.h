//
//  ViewController.h
//  MapBox
//
//  Created by Shyla PC on 4/29/16.
//  Copyright © 2016 Mobinius.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSString *QueryStr;
    NSString *Mode;
    NSString *Types;
    NSString *Country;
    double *proximity;
    
    __weak IBOutlet UITableView *searchTable;
}

@end

