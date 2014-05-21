//
//  GTUser.h
//  GetThere
//
//  Created by Jessica Liu on 5/20/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GTUser : NSObject

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* status;
@property (assign, nonatomic) CLLocationDegrees currentLatitude;
@property (assign, nonatomic) CLLocationDegrees* currentLongitude;
@property (strong, nonatomic) UIImage *photo;

@end
