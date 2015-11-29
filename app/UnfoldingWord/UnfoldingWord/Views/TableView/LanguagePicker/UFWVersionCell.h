//
//  UWExpandableLanguageCell.h
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UWVersion;
#import "Constants.h"

@protocol VersionCellDelegate <NSObject>
- (void)userDidRequestShow:(MediaType)type forVersion:(UWVersion *)version;
- (void)userDidRequestShowCheckingLevelForType:(MediaType)type forVersion:(UWVersion *)version;
@end


@interface UFWVersionCell : UITableViewCell
@property (nonatomic, strong) UWVersion *version;
@property (nonatomic, weak) id <VersionCellDelegate> delegate;
@end
