//
//  UWDownloadOptions.h
//  UnfoldingWord
//
//  Created by David Solberg on 11/24/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, DownloadOptions) {
    DownloadOptionsEmpty = 0,
    DownloadOptionsText = 1 << 0,
    DownloadOptionsAudio = 1 << 1,
    DownloadOptionsVideo = 1 << 2,
};