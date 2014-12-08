//
//  DWImageGetter.h
//
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ImageCompletionBlock) (NSString *originalUrl, UIImage *image);

@interface DWImageGetter : NSObject

+ (DWImageGetter *) sharedInstance;

- (void) retrieveImageWithURLString:(NSString *)urlString completionBlock:(ImageCompletionBlock) completionBlock;

- (UIImage *) cachedImageFromString:(NSString *) urlString;

- (BOOL)fileExistsForUrlString:(NSString *)string;

@end
