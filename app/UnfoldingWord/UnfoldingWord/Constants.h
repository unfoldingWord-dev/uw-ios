//
//  Constants.h
//
//

#define LANGUAGES_API @"https://api.unfoldingword.org/obs/txt/1/obs-catalog.json"

#define SELECTION_BLUE_COLOR    [UIColor colorWithRed:76.0/255.0 green:185.0/255.0 blue:224.0/255.0 alpha:1.0]
#define TEXT_COLOR_NORMAL       [UIColor colorWithRed:32.0/255.0 green:27.0/255.0 blue:22.0/255.0 alpha:1.0]
#define BACKGROUND_GRAY               [UIColor colorWithRed:42.0/255.0 green:34.0/255.0 blue:26.0/255.0 alpha:1.0]
#define BACKGROUND_GREEN          [UIColor colorWithRed:170.0/255.0 green:208.0/255.0 blue:0.0/255.0 alpha:1.0]
#define TABBAR_COLOR_TRANSPARENT [UIColor colorWithRed:42.0/255.0 green:34.0/255.0 blue:26.0/255.0 alpha:0.7]

#define FONT_LIGHT [UIFont fontWithName:@"HelveticaNeue-Light" size:17]
#define FONT_NORMAL [UIFont fontWithName:@"HelveticaNeue" size:17]
#define FONT_MEDIUM [UIFont fontWithName:@"HelveticaNeue-Medium" size:17]

#define LEVEL_1_DESC NSLocalizedString(@"Level 1: internal — Translator (or team) affirms that translation is in line with Statement of Faith and Translation Guidelines.", nil)
#define LEVEL_2_DESC NSLocalizedString(@"Level 2: external — Translation is independently checked and confirmed by at least two others not on the translation team.", nil)
#define LEVEL_3_DESC NSLocalizedString(@"Level 3: authenticated — Translation is checked and confirmed by leadership of at least one Church network with native speakers of the language.", nil)

#define LEVEL_1_IMAGE @"level1Cell"
#define LEVEL_2_IMAGE @"level2Cell"
#define LEVEL_3_IMAGE @"level3Cell"

#define LEVEL_1_REVERSE @"level1"
#define LEVEL_2_REVERSE @"level2"
#define LEVEL_3_REVERSE @"level3"

#define IMAGE_VERIFY_GOOD @"verifyGood"
#define IMAGE_VERIFY_FAIL @"verifyFail.png"
#define IMAGE_VERIFY_EXPIRE @"verifyExpired.png"


// Allows us to track the verse for each part of an attributed string
static NSString *const USFM_VERSE_NUMBER = @"USFMVerseNumber";

static NSString *const SignatureFileAppend = @".sig"; // Duplicated in UWConstants.swift

static NSString *const FileExtensionUFW = @"ufw"; /// Duplicated in UWConstants.swift

// Duplicated in UWConstants.swift
static NSString *const  BluetoothSend = @"BluetoothSend";
static NSString *const  BluetoothReceive = @"BluetoothReceive";

static NSString *const  MultiConnectSend = @"MultiConnectSend";
static NSString *const  MultiConnectReceive = @"MultiConnectReceive";

static NSString *const  iTunesSend = @"iTunesSend";
static NSString *const  iTunesReceive = @"iTunesReceive";


static NSString *const IMAGE_DIGLOT = @"diglot";