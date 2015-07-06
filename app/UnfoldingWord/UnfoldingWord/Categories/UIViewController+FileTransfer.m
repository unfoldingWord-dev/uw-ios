//
//  UIViewController+FileTransfer.m
//  UnfoldingWord
//
//  Created by David Solberg on 6/29/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UIViewController+FileTransfer.h"
#import "UnfoldingWord-Swift.h"
#import "CoreDataClasses.h"

static NSString *const kTitleSearching =  @"Searching...";
static NSString *const kTextSearchSender = @"Ready to send. Searching for a device to pair.";
static NSString *const kTextSearchReceive = @"Ready to receive file. Searching for a device to pair.";
static NSString *const kSending = @"Sending...";
static NSString *const kReceiving = @"Receiving...";

// Dynamic Setter Keys
static char const * const KeyBTSender = "KeyBTSender";
static char const * const KeyBTReceiver = "KeyBTReceiver";
static char const * const KeyMCSender = "KeyMCSender";
static char const * const KeyMCReceiver = "KeyMCReceiver";

static char const * const KeyAlertController = "KeyAlertController";

@implementation UIViewController (FileTransfer)

@dynamic senderBT;
@dynamic receiverBT;
@dynamic senderMC;
@dynamic receiverMC;
@dynamic alertController;

- (void)transferFileForVersion:(UWVersion *)version transferType:(TransferType)type role:(TransferRole)role
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (type == TransferTypeBluetooth) {
        switch (role) {
            case TransferRoleSend:
                [self sendBluetoothUWVersion:version];
                break;
            case TransferRoleReceive:
                [self receiveBluetooth];
                break;
        }
    }
    if (type == TransferTypeWireless) {
        switch (role) {
            case TransferRoleSend:
                [self sendWirelessUWVersion:version];
                break;
            case TransferRoleReceive:
                [self receiveWireless];
                break;
        }
    }
}

- (void)sendWirelessUWVersion:(UWVersion *)version {
    NSData *data = [self dataForVersion:version];
    if (data) {
        // Set up progress indicator using alert controller
        TransferRole roleSend = TransferRoleSend;
        [self presentAlertController];
        [self updateProgress:0 connected:NO finished:NO role:roleSend type:TransferTypeWireless];
        
        // Create a sender and apply the update block
        __weak typeof(self) weakself = self;
        self.senderMC = [[MultiConnectSender alloc] initWithDataToSend:data filename:version.name updateBlock:^(float percent, BOOL connected , BOOL complete) {
            [weakself updateProgress:percent connected:connected finished:complete role:roleSend type:TransferTypeWireless];
        }];
    }
}

- (void)receiveWireless
{
    // Set up progress indicator using alert controller
    TransferRole roleReceive = TransferRoleReceive;
    [self presentAlertController];
    [self updateProgress:0 connected:NO finished:NO role:roleReceive type:TransferTypeWireless];
    
    // Create a receiver and apply the update block
    __weak typeof(self) weakself = self;
    self.receiverMC = [[MultiConnectReceiver alloc] initWithUpdateBlock:^(float percent, BOOL connected, BOOL complete) {
        [weakself updateProgress:percent connected:connected finished:complete role:roleReceive type:TransferTypeWireless];
    }];
    
}

- (void)sendBluetoothUWVersion:(UWVersion *)version
{
    NSData *data = [self dataForVersion:version];
    TransferRole roleSend = TransferRoleSend;
    if (data) {
        // Set up progress indicator using alert controller
        [self presentAlertController];
        [self updateProgress:0 connected:NO finished:NO role:roleSend type:TransferTypeBluetooth];
        
        // Create a sender and apply the update block
        __weak typeof(self) weakself = self;
        self.senderBT = [[BluetoothFileSender alloc] initWithDataToSend:data updateBlock:^(float percent, BOOL connected , BOOL complete) {
            [weakself updateProgress:percent connected:connected finished:complete role:roleSend type:TransferTypeBluetooth];
        }];
    }
}

- (void)receiveBluetooth
{
    // Set up progress indicator using alert controller
    TransferRole roleReceive = TransferRoleReceive;
    [self presentAlertController];
    [self updateProgress:0 connected:NO finished:NO role:roleReceive type:TransferTypeBluetooth];
    
    // Create a receiver and apply the update block
    __weak typeof(self) weakself = self;
    self.receiverBT = [[BluetoothFileReceiver alloc] initWithUpdateBlock:^(float percent, BOOL connected, BOOL complete) {
        [weakself updateProgress:percent connected:connected finished:complete role:roleReceive type:TransferTypeBluetooth];
    }];
}

#pragma mark - Helpers
- (NSData *)dataForVersion:(UWVersion *)version
{
    NSData *data = nil;
    if (version != nil) {
        UFWFileExporter *exporter = [[UFWFileExporter alloc] initWithVersion:version];
        data = exporter.fileData;
    }
    
    if (data == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not create a file for %@", version.name] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    return data;
}

- (void)resetAllState
{
    void (^cleanup)() = ^void() {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        self.senderBT = nil;
        self.receiverBT = nil;
        self.alertController = nil;
    };
    
    if ([self.presentedViewController isEqual:self.alertController]) {
        [self dismissViewControllerAnimated:YES completion:^{
            cleanup();
        }];
    }
    else {
        cleanup();
    }
}

#pragma mark - Alert Controller
- (void)presentAlertController
{
    if (self.presentedViewController != nil) { // State check
        [self dismissViewControllerAnimated:NO completion:^{}];
    }
    
    __weak typeof(self) weakself = self;
    self.alertController = [UIAlertController alertControllerWithTitle:kTitleSearching message:@"Preparing..." preferredStyle:UIAlertControllerStyleAlert];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [weakself dismissWithSuccess:NO];
    }]];
    [self presentViewController:self.alertController animated:YES completion:^{}];
}

- (void)dismissWithSuccess:(BOOL) success {
    [self dismissViewControllerAnimated:YES completion:^{
        [self resetAllState];
        
        if (success) {
            [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your file was successfully transmitted!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:@"There was an error transmitting this file." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
    }];
}

#pragma mark - Progress Update
- (void)updateProgress:(CGFloat)percent connected:(BOOL)connected finished:(BOOL)finished role:(TransferRole)role type:(TransferType)type
{
    if (finished == YES) {
        if (role == TransferRoleReceive) {
            [self.alertController setTitle:@"Importing"];
            [self.alertController setMessage:@"Importing and saving the received file."];
            
            NSData *data = nil;
            switch (type) {
                case TransferTypeBluetooth:
                    data = self.receiverBT.receivedData;
                case TransferTypeWireless:
                    data = self.receiverMC.receivedFileData;
                default:
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveFile:data];
            });
        }
        else if (role == TransferRoleSend) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissWithSuccess:YES];
            });
        }
    }
    else if (connected == YES) {
        NSString *activity = (role == TransferRoleSend) ? kSending : kReceiving;
        [self.alertController setTitle:activity];
        [self.alertController setMessage:[NSString stringWithFormat:@"%.2f%% complete.", percent*100]];
    }
    else { // not connected!
        NSString *message = (role == TransferRoleSend) ? kTextSearchSender : kTextSearchReceive;
        [self.alertController setTitle:kTitleSearching];
        [self.alertController setMessage:message];
    }
}

#pragma mark - Process File

- (void)saveFile:(NSData *)fileData
{
    BOOL success = NO;
    if (fileData != nil) {
        UFWFileImporter *importer = [[UFWFileImporter alloc] initWithData:fileData];
        if (importer.file.isValid) {
            success = importer.importFile;
        }
    }
    [self dismissWithSuccess:success];
}

#pragma mark - Dynamic Property Setters and Getters

- (MultiConnectSender *)senderMC
{
    return objc_getAssociatedObject(self, KeyMCSender);
}

- (void)setSenderMC:(MultiConnectSender *)senderMC
{
    objc_setAssociatedObject(self, KeyMCSender, senderMC, OBJC_ASSOCIATION_RETAIN);
}

- (MultiConnectReceiver *)receiverMC
{
    return objc_getAssociatedObject(self, KeyMCReceiver);
}

- (void)setReceiverMC:(MultiConnectReceiver *)receiverMC
{
    objc_setAssociatedObject(self, KeyMCReceiver, receiverMC, OBJC_ASSOCIATION_RETAIN);
}

- (BluetoothFileSender *)senderBT
{
    return objc_getAssociatedObject(self, KeyBTSender);
}

- (void)setSenderBT:(BluetoothFileSender *)sender
{
    objc_setAssociatedObject(self, KeyBTSender, sender, OBJC_ASSOCIATION_RETAIN);
}

- (BluetoothFileReceiver *)receiverBT
{
    return objc_getAssociatedObject(self, KeyBTReceiver);
}

- (void)setReceiverBT:(BluetoothFileReceiver *)receiver
{
    objc_setAssociatedObject(self, KeyBTReceiver, receiver, OBJC_ASSOCIATION_RETAIN);
}

- (UIAlertController *)alertController
{
    return objc_getAssociatedObject(self, KeyAlertController);
}

- (void)setAlertController:(UIAlertController *)alertController
{
    objc_setAssociatedObject(self, KeyAlertController, alertController, OBJC_ASSOCIATION_RETAIN);
}


@end
