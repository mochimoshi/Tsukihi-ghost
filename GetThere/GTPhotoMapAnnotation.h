//
//  GTMapAnnotation.h
//  GetThere
//
//  Created by Jessica Liu on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GTPhotoMapAnnotation : NSObject <MKAnnotation>{
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;

@end
