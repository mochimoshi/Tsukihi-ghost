//
//  GTMapAnnotation.h
//  GetThere
//
//  Created by Jessica Liu on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GTMapAnnotation : NSObject <MKAnnotation>{
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
    //NSString *displayType;
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString *displayType;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;

@end
