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
#import "Constants.h"

typedef NS_ENUM(NSInteger, TransferType) {
    TransferTypeBluetooth = 1,
    TransferTypeWireless = 2,
    TransferTypeEmail = 3,
    TransferTypeiTunes = 4,
};

typedef NS_ENUM(NSInteger, TransferRole) {
    TransferRoleSend =1,
    TransferRoleReceive =2,
};

static NSString *const kSendWireless = @"Send by Wireless";
static NSString *const kReceiveWireless = @"Receive by Wireless";
static NSString *const kSendBluetooth = @"Send by Bluetooth";
static NSString *const kReceiveBluetooth = @"Receive by Bluetooth";

static NSString *const kTextSearchSender = @"Ready to send. Searching for a device to pair.";
static NSString *const kTextSearchReceive = @"Ready to receive file. Searching for a device to pair.";
static NSString *const kSending = @"Sending...";
static NSString *const kReceiving = @"Receiving...";

// Dynamic Setter Keys
static char const *  KeyBTSender = "KeyBTSender";
static char const *  KeyBTReceiver = "KeyBTReceiver";
static char const *  KeyMCSender = "KeyMCSender";
static char const *  KeyMCReceiver = "KeyMCReceiver";

static char const *  KeyAlertController = "KeyAlertController";
static char const *  KeyFileActivityController = "KeyFileActivityController";

@implementation UIViewController (FileTransfer)

@dynamic senderBT;
@dynamic receiverBT;
@dynamic senderMC;
@dynamic receiverMC;
@dynamic alertController;
@dynamic fileActivityController;

- (void)sendFileForVersion:(UWVersion *)version fromBarButtonOrView:(id)item;
{
    if ( ([version statusAudio] & DownloadStatusSome) || ([version statusVideo] & DownloadStatusSome) ) {
        __weak typeof(self) weakself = self;
        DownloadOptions options = DownloadOptionsText;
        if ([version statusAudio] & DownloadStatusSome) {
            options = options | DownloadOptionsAudio;
        }
        if ([version statusVideo] & DownloadStatusSome) {
            options = options | DownloadOptionsVideo;
        }
        SharingChoicesView *picker = [SharingChoicesView createWithOptions:options completion:^(BOOL canceled, DownloadOptions options) {
            if (canceled == NO) {
                [weakself  initiateActivityPresentationWithVersion:version isSend:YES options:options fromItem:item completion:nil];
            }
        }];
        [self showActionSheetFake:picker];
    } else {
        [self initiateActivityPresentationWithVersion:version isSend:YES options:DownloadOptionsText fromItem:item completion:nil];
    }
}


- (void)receiveFileFromBarButtonOrView:(id)item completion:(FileCompletion)completion
{
    [self initiateActivityPresentationWithVersion:nil isSend:NO options:DownloadOptionsEmpty fromItem:item completion:completion];
}

- (void) handleActivityType:(NSString *)activityType completion:(FileCompletion)completion
{
    NSParameterAssert(self.fileActivityController);
    
    if (self.fileActivityController.isSend) {
        
        if ([activityType isEqualToString:BluetoothSend]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [self sendBluetoothWithCompletion:completion];
        }
        else if ([activityType isEqualToString:MultiConnectSend]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [self sendWirelessWithCompletion:completion];
        }
        else if ([activityType isEqualToString:iTunesSend]) {
            [self sendiTunesWithCompletion:completion];
        }
    }
    else {
        
        if ([activityType isEqualToString:BluetoothReceive]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [self receiveBluetoothWithCompletion:completion];
        }
        else if ([activityType isEqualToString:MultiConnectReceive]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [self receiveWirelessWithCompletion:completion];
        }
        else if ([activityType isEqualToString:iTunesReceive]) {
            [self receiveITunesWithCompletion:completion];
        }
    }
}

- (void)initiateActivityPresentationWithVersion:(UWVersion *) version isSend:(BOOL)isSend options:(DownloadOptions)options fromItem:(id)item completion:(FileCompletion)completion
{
    self.fileActivityController = [[FileActivityController alloc] initWithVersion:version options:options shouldSend:isSend];
    UIActivityViewController *activityController = self.fileActivityController.activityViewController;
    __weak typeof(self) weakself = self;
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (completed) {
            [weakself handleActivityType:activityType completion:completion];
        }
    };
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:activityController];

        if ([item isKindOfClass:[UIBarButtonItem class]]) {
            [popover presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else if ([item isKindOfClass:[UIView class]]) {
            UIView *itemView = (UIView *)item;
            [popover presentPopoverFromRect:itemView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [popover presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2.0, self.view.frame.size.height - 10, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
    else {
        [self presentViewController:activityController animated:YES completion:^{}];
    }

}

- (void)sendWirelessWithCompletion:(FileCompletion)completion {
    NSData *data = [self data];
    if (data) {
        NSString *title = self.fileActivityController.ufwVersion.name;
        
        // Set up progress indicator using alert controller
        TransferRole roleSend = TransferRoleSend;
        [self presentAlertControllerWithTitle:kSendWireless completion:completion];
        
        // Create a sender and apply the update block
        __weak typeof(self) weakself = self;
        self.senderMC = [[MultiConnectSender alloc] initWithDataToSend:data filename:title updateBlock:^(float percent, BOOL connected , BOOL complete) {
            [weakself updateProgress:percent connected:connected finished:complete role:roleSend type:TransferTypeWireless completion:completion];
        }];
        
        [self updateProgress:0 connected:NO finished:NO role:roleSend type:TransferTypeWireless completion:completion];
    }
}

- (void)sendiTunesWithCompletion:(FileCompletion)completion {
    NSData *data = [self data];
    NSString *filename = [self.fileActivityController.ufwVersion filename];
    
    ITunesSharingSender *sender = [[ITunesSharingSender alloc] init];
    if ( [sender sendToITunesFolder:data filename:filename]) {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:[NSString stringWithFormat:@"The file %@ was successfully saved to your iTunes folder.", filename] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not save to iTunes folder." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
}

- (void)receiveWirelessWithCompletion:(FileCompletion)completion
{
    // Set up progress indicator using alert controller
    TransferRole roleReceive = TransferRoleReceive;
    [self presentAlertControllerWithTitle:kReceiveWireless completion:completion];
    
    // Create a receiver and apply the update block
    __weak typeof(self) weakself = self;
    self.receiverMC = [[MultiConnectReceiver alloc] initWithUpdateBlock:^(float percent, BOOL connected, BOOL complete) {
        [weakself updateProgress:percent connected:connected finished:complete role:roleReceive type:TransferTypeWireless completion:completion];
    }];
    [self updateProgress:0 connected:NO finished:NO role:roleReceive type:TransferTypeWireless completion:completion];

}

- (void)sendBluetoothWithCompletion:(FileCompletion)completion
{
    NSData *data = [self data];
    TransferRole roleSend = TransferRoleSend;
    if (data) {
        // Set up progress indicator using alert controller
        [self presentAlertControllerWithTitle:kSendBluetooth completion:completion];
        
        // Create a sender and apply the update block
        __weak typeof(self) weakself = self;
        self.senderBT = [[BluetoothFileSender alloc] initWithDataToSend:data updateBlock:^(float percent, BOOL connected , BOOL complete) {
            [weakself updateProgress:percent connected:connected finished:complete role:roleSend type:TransferTypeBluetooth completion:completion];
        }];
        
        [self updateProgress:0 connected:NO finished:NO role:roleSend type:TransferTypeBluetooth completion:completion];
    }
}

- (void)receiveBluetoothWithCompletion:(FileCompletion)completion
{
    // Set up progress indicator using alert controller
    TransferRole roleReceive = TransferRoleReceive;
    [self presentAlertControllerWithTitle:kReceiveBluetooth completion:completion];
    
    // Create a receiver and apply the update block
    __weak typeof(self) weakself = self;
    self.receiverBT = [[BluetoothFileReceiver alloc] initWithUpdateBlock:^(float percent, BOOL connected, BOOL complete) {
        [weakself updateProgress:percent connected:connected finished:complete role:roleReceive type:TransferTypeBluetooth completion:completion];
    }];
    [self updateProgress:0 connected:NO finished:NO role:roleReceive type:TransferTypeBluetooth completion:completion];

}


- (void)receiveITunesWithCompletion:(FileCompletion)completion
{
    __weak typeof(self) weakself = self;
    UINavigationController *navController = [ITunesFilePickerTableVC pickerInsideNavController:^(BOOL canceled, NSString *filepath ) {
        [weakself dismissViewControllerAnimated:YES completion:^{
            if (canceled == YES) {
                return;
            }
            
            [weakself presentAlertControllerWithTitle:@"Importing..." completion:completion];
            [self.alertController setMessage:@"Please wait."];
            
            // We want to give the alert controller time to show.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL isSuccessful = NO;
                if ( filepath != nil) {
                    ITunesSharingReceiver *receiver = [[ITunesSharingReceiver alloc] init];
                    isSuccessful = [receiver importFileAtPath:filepath];
                }
                [weakself dismissWithSuccess:isSuccessful completion:completion];
            });

        }];

    }];
    [self presentViewController:navController animated:YES completion:^{}];
}

#pragma mark - Helpers
- (NSData *)data
{
    NSParameterAssert(self.fileActivityController);
    NSData *data = nil;
    if (self.fileActivityController != nil) {
        NSURL *fileUrl = [self.fileActivityController.urlProvider url];
        data = [[NSFileManager defaultManager] contentsAtPath:fileUrl.path];
    }
    
    if (data == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create a file!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    return data;
}


- (void)resetAllState
{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        self.senderBT = nil;
        self.receiverBT = nil;
        self.senderMC = nil;
        self.receiverMC = nil;
        self.fileActivityController = nil;
        self.alertController = nil;
}

#pragma mark - Alert Controller
- (void)presentAlertControllerWithTitle:(NSString *)title completion:(FileCompletion)completion
{
    __weak typeof(self) weakself = self;
    void(^alertBlock)() = ^void () {
        self.alertController = [UIAlertController alertControllerWithTitle:title message:@"Preparing..." preferredStyle:UIAlertControllerStyleAlert];
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [weakself dismissWithSuccess:NO completion:completion];
        }]];
        [self presentViewController:self.alertController animated:YES completion:^{}];
    };
    
    if (self.presentedViewController != nil) { // State check
        [self dismissViewControllerAnimated:NO completion:^{
            alertBlock();
        }];
    }
    else {
        alertBlock();
    }
}

- (void)dismissWithSuccess:(BOOL) success completion:(FileCompletion)something {
    [self resetAllState];
    [self dismissViewControllerAnimated:YES completion:^{
        if (success) {
            [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your file transfer was successful." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:@"There was an error with this file." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
        if (something != nil) {
            something(success);
        }
    }];
}

#pragma mark - Progress Update
- (void)updateProgress:(CGFloat)percent connected:(BOOL)connected finished:(BOOL)finished role:(TransferRole)role type:(TransferType)type completion:(FileCompletion)completion
{
    if (finished == YES) {
        if (role == TransferRoleReceive) {
            [self.alertController setTitle:@"Importing"];
            [self.alertController setMessage:@"Importing and saving the received file."];
            
            NSData *data = nil;
            switch (type) {
                case TransferTypeBluetooth:
                    data = self.receiverBT.receivedData;
                    break;
                case TransferTypeWireless:
                    data = self.receiverMC.receivedFileData;
                    break;
                default:
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveFile:data completion:completion];
            });
        }
        else if (role == TransferRoleSend) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissWithSuccess:YES completion:completion];
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
        if (self.senderBT != nil) {
            [self.alertController setTitle:kSendBluetooth];
        }
        else if (self.senderMC != nil) {
            [self.alertController setTitle:kSendWireless];
        }
        else if (self.receiverBT != nil) {
            [self.alertController setTitle:kReceiveBluetooth];
        }
        else if (self.receiverMC != nil) {
            [self.alertController setTitle:kReceiveWireless];
        }
        else {
            [self.alertController setTitle:@"Unknown State"];
        }
        [self.alertController setMessage:message];
    }
}

#pragma mark - Process File

- (void)saveFile:(NSData *)fileData completion:(FileCompletion)completion
{
    UFWFileImporter *importer = [[UFWFileImporter alloc] init];
    BOOL success = [importer importData: fileData];
    [self dismissWithSuccess:success completion:completion];
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

- (FileActivityController *)fileActivityController
{
    return objc_getAssociatedObject(self, KeyFileActivityController);
}

- (void)setFileActivityController:(FileActivityController *)fileActivityController
{
    objc_setAssociatedObject(self, KeyFileActivityController, fileActivityController, OBJC_ASSOCIATION_RETAIN);
}

@end
