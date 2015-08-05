//
//  UIViewController+FileTransfer.h
//  UnfoldingWord
//
//  Created by David Solberg on 6/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UWVersion, BluetoothFileSender, BluetoothFileReceiver, MultiConnectReceiver, MultiConnectSender, FileActivityController;

/// This class adds UWVersion file transfer capabilities to any view controller.

@interface UIViewController (FileTransfer)

@property (nonatomic, strong) BluetoothFileSender *senderBT;
@property (nonatomic, strong) BluetoothFileReceiver *receiverBT;

@property (nonatomic, strong) MultiConnectSender *senderMC;
@property (nonatomic, strong) MultiConnectReceiver *receiverMC;

@property (nonatomic, strong) UIAlertController *alertController;

@property (nonatomic, strong) FileActivityController *fileActivityController;

- (void)sendFileForVersion:(UWVersion *)version;

- (void)receiveFile;

@end
