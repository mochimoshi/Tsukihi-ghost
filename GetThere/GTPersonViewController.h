//
//  GTPersonViewController.h
//  GetThere
//
//  Created by Angela Yeung on 5/5/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GTPersonViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) id sender;

@end
