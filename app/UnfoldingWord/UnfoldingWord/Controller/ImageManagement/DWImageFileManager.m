//
//  DWImageFileManager.m
//
//  Copyright (c) 2014 David Solberg. All rights reserved.
//


#import "DWImageFileManager.h"
#import "NSString+Trim.h"

static NSInteger const kMaxCurrentDownloads = 3;

@interface DWImageFileManager ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableDictionary *fileOperationDictionary;
@property (nonatomic, strong) NSMutableArray *webRetrievalOperations;
@property (nonatomic, strong) NSMutableArray *webRetrievalKeys;
@end

@implementation DWImageFileManager
{
    dispatch_queue_t webArrayQueue;
    dispatch_queue_t fileDictionaryQueue;
    dispatch_queue_t _fileManagerQueue;
    NSOperationQueue *_downloadOpQueue;
    NSOperationQueue *_fileOpQueue;
    NSInteger _numberOfActiveOperations;
}

- (id) init {
    self = [super init];
    if (self) {
        [self createFileManager];
        [self createQueues];
    }
    return self;
}

- (void) createFileManager;
{
    self.fileManager = [[NSFileManager alloc] init];
}

- (void) createQueues;
{
    _downloadOpQueue = [[NSOperationQueue alloc] init];
    _fileOpQueue = [[NSOperationQueue alloc] init];
    
    fileDictionaryQueue = dispatch_queue_create("File Dictionary Queue", DISPATCH_QUEUE_SERIAL);
    self.fileOperationDictionary = [NSMutableDictionary dictionary];
    
    _fileManagerQueue = dispatch_queue_create("File Manager Queue", DISPATCH_QUEUE_SERIAL);
    
    webArrayQueue = dispatch_queue_create("fileRetrievalQueue", DISPATCH_QUEUE_SERIAL);
    
    self.webRetrievalKeys = [NSMutableArray array];
    self.webRetrievalOperations = [NSMutableArray array];
    _numberOfActiveOperations = 0;
}

- (void)imageFromBaseUrlString:(NSString *) urlString withCompletionBlock:(void (^) (NSString *originalUrl, UIImage *image)) block;
{
    // Make sure they sent a real string.
    if ( [urlString length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(urlString, nil);
        });
        return;
    }
    
    NSBlockOperation *fileOp = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *diskImage = [self diskImageFromBaseUrlString:urlString];
        if (diskImage)
            dispatch_async(dispatch_get_main_queue(), ^{
                block(urlString, diskImage);
            });
        else {
            [self internetImageFromBaseUrlString:urlString withCompletionBlock:block];
        }
        
        dispatch_async(fileDictionaryQueue, ^{
            [_fileOperationDictionary removeObjectForKey:urlString];
        });
    }];
    [_fileOpQueue addOperation:fileOp];
    
    dispatch_async(fileDictionaryQueue, ^{
        [_fileOperationDictionary setValue:fileOp forKey:urlString];
    });
}

- (BOOL)fileExistsForBaseUrlString:(NSString *)urlString
{
    NSString *bundleName = [self fileSafeStringFromURLString:urlString];
    // First check whether it's in the app bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:nil];
    if (bundlePath != nil) {
        return YES;
    }
    else {
        __block BOOL fileExists;
        NSString *storagePath = [self localPathFromURLString:urlString];
        dispatch_sync(_fileManagerQueue, ^{
            fileExists = ( [_fileManager fileExistsAtPath:storagePath]) ? YES : NO;
        });
        return fileExists;
    }
}

- (UIImage *) diskImageFromBaseUrlString:(NSString *)urlString
{
    NSString *bundleName = [self fileSafeStringFromURLString:urlString];
    // First check whether it's in the app bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:nil];
    if (bundlePath != nil) {
        UIImage *image = [UIImage imageNamed:bundleName];
        if (image) {
            return image;
        }
    }
    
    NSString *storagePath = [self localPathFromURLString:urlString];

    __block NSData *imageData;
    dispatch_sync(_fileManagerQueue, ^{
        if ( [_fileManager fileExistsAtPath:storagePath]) {
            imageData = [NSData dataWithContentsOfFile:storagePath];
        }
    });
    
    if ([imageData length] == 0) {
        return nil;
    }
    else {
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        // Ensure that we're reporting the correct scale so it appears as retina if necessary (rather than twice as big)
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale != image.scale) {
            image = [UIImage imageWithCGImage:image.CGImage scale:screenScale orientation:image.imageOrientation];
        }
        
        // Double check it's really an image
        if ([image isKindOfClass:[UIImage class]]) {
            return image;
        }
        else {
            return nil;
        }
    }
}

- (void) internetImageFromBaseUrlString:(NSString *) urlString withCompletionBlock:(void (^) (NSString *originalUrl, UIImage *image)) block;
{
    
    NSBlockOperation *queuedOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = queuedOperation;
    [queuedOperation addExecutionBlock:^{
        
        // Check again for a disk image because this has been queued.
        UIImage *savedImage = [self diskImageFromBaseUrlString:urlString];
        if ( savedImage != nil) {
            if ( ! [weakOp isCancelled]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(urlString, savedImage);
                });
            }
        }
        // Okay, we need to retrieve one from the URL.
        else {
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSMutableURLRequest *request = nil;
            NSURL *url = [NSURL URLWithString:urlString];
            if (url != nil) {
                request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
            }
            
            if ( ! request) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self cancelWebOperations];
                    block(urlString, nil);
                });
                return;
            }
            
            UIImage *retrievedImage = nil;
            @autoreleasepool {
                
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                if (error || [data length] == 0) {
                    NSLog(@"Error %@ loading %@ with response %@.", error, urlString, response);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(urlString, nil);
                    });
                }
                
                retrievedImage = [UIImage imageWithData:data];
                
                // Ensure that we're reporting the correct scale so it appears as retina if necessary (rather than twice as big)
                CGFloat screenScale = [UIScreen mainScreen].scale;
                if (screenScale != retrievedImage.scale) {
                    retrievedImage = [UIImage imageWithCGImage:retrievedImage.CGImage scale:screenScale orientation:retrievedImage.imageOrientation];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(urlString, retrievedImage);
                });
                
                if ( retrievedImage) {

                    dispatch_sync(_fileManagerQueue, ^{
                        [self writeData:data withString:urlString];
                    });
                }
            };
            
            // Finally, we restart the queue.
            dispatch_async(webArrayQueue, ^{
                _numberOfActiveOperations--;
                [self runQueue];
            });
        }
    }];
    
    dispatch_async(webArrayQueue, ^{
        [_webRetrievalKeys addObject:urlString];
        [_webRetrievalOperations addObject:queuedOperation];
        [self runQueue];
    });
}

- (void) runQueue;
{
    if (_numberOfActiveOperations >= kMaxCurrentDownloads || ! [_webRetrievalOperations count] ) {
        return;
    }
    
    NSBlockOperation *operation = [_webRetrievalOperations objectAtIndex:0];
    if (operation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_downloadOpQueue addOperation:operation];
        });
        _numberOfActiveOperations++;
        [_webRetrievalOperations removeObjectAtIndex:0];
        [_webRetrievalKeys removeObjectAtIndex:0];
    }
}


#pragma mark - Cancel Operations in Progress

- (void) cancelAll
{
    [self cancelWebOperations];
    [self cancelFileOperations];
}

- (void)cancelWebOperations
{
    dispatch_sync(webArrayQueue, ^{
        [_webRetrievalKeys removeAllObjects];
        [_webRetrievalOperations removeAllObjects];
    });
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_downloadOpQueue cancelAllOperations];
    });
}

- (void)cancelFileOperations
{
    dispatch_sync(fileDictionaryQueue, ^{
        [_fileOperationDictionary removeAllObjects];
    });
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_fileOpQueue cancelAllOperations];
    });
}

- (void) cancelUrlString:(NSString *) urlString
{
    dispatch_async(fileDictionaryQueue, ^{
        NSBlockOperation *operation = [_fileOperationDictionary valueForKey:urlString];
        [operation cancel];
        [_fileOperationDictionary removeObjectForKey:urlString];
    });
    dispatch_async(webArrayQueue, ^{
        NSInteger location = -1;
        
        for (int i = 0 ; i < [_webRetrievalKeys count] ; i++) {
            if ([urlString isEqualToString:[_webRetrievalKeys objectAtIndex:i]]) {
                location = i;
                break;
            }
        }
        if (location >= 0) {
            NSBlockOperation *operation = [_webRetrievalOperations objectAtIndex:location];
            [operation cancel];
            [_webRetrievalKeys removeObjectAtIndex:location];
            [_webRetrievalOperations removeObjectAtIndex:location];
        }
    });
}

- (BOOL) writeData:(NSData *) data withString:(NSString *) urlString;
{
    NSString *storagePath = [self localPathFromURLString:urlString];
    return [_fileManager createFileAtPath:storagePath contents:data attributes:nil];
}


#pragma mark - File naming helper

- (NSString *) localPathFromURLString:(NSString *) urlString {
    
    NSString *safeString = [self fileSafeStringFromURLString:urlString];
    NSString *baseDirectory = [self baseImageDirectory];
    return [baseDirectory stringByAppendingPathComponent:safeString];
}

- (NSString *)fileSafeStringFromURLString:(NSString *) urlString
{
    NSString *safeString = [urlString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    safeString = [safeString stringByReplacingOccurrencesOfString:@":" withString:@""];
    safeString = [safeString stringByReplacingOccurrencesOfString:@"." withString:@""];
    return safeString;
}

- (NSString *)baseImageDirectory
{
    NSString *directory = nil;
    switch (self.saveType) {
        case SaveTypeCache:
        {
            NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            directory = [cacheDirectories objectAtIndex:0];
        }
            break;
        case SaveTypeFile:
        {
            directory = [[NSString documentsDirectory] stringByAppendingPathComponent:@"ImageFileManagerDirectory"];
            
            // Ensure the directory exists; otherwise, saving file there won't work
            [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
            break;
    }
    return directory;
}

@end
