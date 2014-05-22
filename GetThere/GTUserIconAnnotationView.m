//
//  GTUserIconAnnotationView.m
//  GetThere
//
//  Created by Jessica Liu on 5/22/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTUserIconAnnotationView.h"

@implementation GTUserIconAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Compensate frame a bit so everything's aligned
        [self setCenterOffset:CGPointMake(-9, -3)];
        [self setCalloutOffset:CGPointMake(-2, 3)];
        
        // Add the pin icon
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 32, 37)];
        [self addSubview:iconView];
    }
    return self;
}

- (void)setAnnotation:(id)annotation {
    [super setAnnotation:annotation];
   /* Place *place = (Place *)annotation;
    icon = [UIImage imageNamed:
            [NSString stringWithFormat:@"pin_%d.png", [place.icon intValue]]];*/
    [iconView setImage:icon];
}

/// Override to make sure shadow image is always set
- (void)setImage:(UIImage *)image {
    [super setImage:[UIImage imageNamed:@"pin_shadow.png"]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
