//
//  ACTLabelButton.h
//  LocationMapper
//
//  Created by David Solberg on 12/22/14.
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ACTLabelButton;

typedef NS_ENUM(NSInteger, ArrowDirection) {
    ArrowDirectionNone = 0,
    ArrowDirectionUp = 1,
    ArrowDirectionDown = 2,
};

@protocol ACTLabelButtonDelegate <NSObject>
- (void)labelButtonPressed:(ACTLabelButton *)labelButton;
@end

@interface ACTLabelButton : UILabel

@property (nonatomic, weak) id<ACTLabelButtonDelegate>delegate;

@property (nonatomic, strong) UIColor *colorNormal;
@property (nonatomic, strong) UIColor *colorHover;
@property (nonatomic, assign) ArrowDirection direction;

@property (nonatomic, strong) id matchingObject;

+ (CGFloat)widthForArrow;


@end
