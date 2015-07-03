//
//  UIViewController+FileTransfer.h
//  UnfoldingWord
//
//  Created by David Solberg on 6/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UWVersion, BluetoothFileSender, BluetoothFileReceiver, MultiConnectReceiver, MultiConnectSender;

typedef NS_ENUM(NSInteger, TransferType) {
    TransferTypeBluetooth = 1,
    TransferTypeWireless = 2,
    TransferTypeEmail = 3,
};

typedef NS_ENUM(NSInteger, TransferRole) {
    TransferRoleSend =1,
    TransferRoleReceive =2,
};

@interface UIViewController (FileTransfer)

@property (nonatomic, strong) BluetoothFileSender *senderBT;
@property (nonatomic, strong) BluetoothFileReceiver *receiverBT;

@property (nonatomic, strong) MultiConnectSender *senderMC;
@property (nonatomic, strong) MultiConnectReceiver *receiverMC;

@property (nonatomic, strong) UIAlertController *alertController;

- (void)transferFileForVersion:(UWVersion *)version transferType:(TransferType)type role:(TransferRole)role;

@end
