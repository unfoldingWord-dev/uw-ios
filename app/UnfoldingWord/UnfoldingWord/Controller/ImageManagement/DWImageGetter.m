//
//  DWImageGetter.m
//
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import "DWImageGetter.h"
#import "DWImageFileManager.h"

@interface DWImageGetter ()
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) DWImageFileManager *fileManager;
@end

@implementation DWImageGetter

#pragma mark - Initialization
+ (DWImageGetter *) sharedInstance;
{
    static DWImageGetter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DWImageGetter alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if (self ) {
        [self createImageCache];
        [self createFileManager];
    }
    return self;
}

- (BOOL)fileExistsForUrlString:(NSString *)string
{
    return [self.fileManager fileExistsForBaseUrlString:string] ? YES : NO;
}

- (void) createImageCache
{
    self.imageCache = [[NSCache alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)memoryWarningNotification:(NSNotification *) notification
{
    [self.imageCache removeAllObjects];
}

- (void) createFileManager;
{
    self.fileManager = [[DWImageFileManager alloc] init];
    self.fileManager.saveType = SaveTypeFile;
}

#pragma mark - *** Exposed Methods ***

- (void) retrieveImageWithURLString:(NSString *)urlString completionBlock:(ImageCompletionBlock) completionBlock;
{
    UIImage *image = [self cachedImageFromString:urlString];
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            completionBlock(urlString,image);
        });
    }
    else {
        
        [_fileManager imageFromBaseUrlString:urlString withCompletionBlock:^(NSString *originalUrl, UIImage *image) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                completionBlock(urlString, image);
            });
            if (image) {
                [self cacheImage:image withString:urlString];
            }
        }];
    }
}

- (void)clearCachedImagesWithUrlString:(NSString *)urlString
{
    [self.imageCache removeObjectForKey:urlString];
}

- (void) cancelRequestForURLString:(NSString *) urlString;
{
    [_fileManager cancelUrlString:urlString];
}

- (void) cancelAllRequests;
{
    [_fileManager cancelAll];
}

#pragma mark - Caching

- (void) cacheImage:(UIImage *) image withString:(NSString*) urlString;
{
    [_imageCache setObject:image forKey:urlString];
}

- (UIImage *) cachedImageFromString:(NSString *) urlString;
{
    return [_imageCache objectForKey:urlString];
}

@end