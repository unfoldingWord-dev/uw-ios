//
//  DWImageFileManager.h
//
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SaveType) {
    SaveTypeCache,
    SaveTypeFile,
};

@interface DWImageFileManager : NSObject

@property (nonatomic, assign) SaveType saveType;

- (void)imageFromBaseUrlString:(NSString *) urlString withCompletionBlock:(void (^) (NSString *originalUrl, UIImage *image)) block;

- (void) cancelAll;
- (void) cancelUrlString:(NSString *) urlString;

- (BOOL)fileExistsForBaseUrlString:(NSString *)urlString;

@end
