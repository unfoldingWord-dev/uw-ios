//
//  UIViewController+FileTransfer.h
//  UnfoldingWord
//
//  Created by David Solberg on 6/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWVersion, BluetoothFileSender, BluetoothFileReceiver, MultiConnectReceiver, MultiConnectSender, FileActivityController;

/// This class adds UWVersion file transfer capabilities to any view controller. Used in conjunction with UFWActivity objects that are presented by a UIActivityViewController;

typedef void (^FileCompletion) (BOOL success);

@interface UIViewController (FileTransfer)

@property (nonatomic, strong) BluetoothFileSender *senderBT;
@property (nonatomic, strong) BluetoothFileReceiver *receiverBT;

@property (nonatomic, strong) MultiConnectSender *senderMC;
@property (nonatomic, strong) MultiConnectReceiver *receiverMC;

@property (nonatomic, strong) UIAlertController *alertController;

@property (nonatomic, strong) FileActivityController *fileActivityController;

/// Use this method in your view controller to manage sending a version as a file, either through a network, email, or saving to iTunes. There is nothing more to do. The item is either a bar button or view from which to show the popover on iPad. It has no effect on iPhone.
- (void)sendFileForVersion:(UWVersion *)version fromBarButtonOrView:(id)item;

/// Use this method in your view controller to manage receiving a version as a file, either through a network, email, or opening from iTunes. There is nothing more to do to import a version, although some lists of versions might need to be refreshed after using this (future improvement). The item is either a bar button or view from which to show the popover on iPad. It has no effect on iPhone.
- (void)receiveFileFromBarButtonOrView:(id)item completion:(FileCompletion)completion;


@end
