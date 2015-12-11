//
//  Constants.h
//
//


typedef void (^BitrateDownloadCompletion) (BOOL success);

typedef NS_ENUM(NSInteger, AudioFileQuality) {
    AudioFileQualityLow = 1,
    AudioFileQualityHigh = 2,
};

typedef NS_ENUM(NSInteger, MediaType) {
    MediaTypeNone = 0,
    MediaTypeText = 1,
    MediaTypeAudio = 2,
    MediaTypeVideo = 3,
};

typedef NS_OPTIONS(NSUInteger, DownloadStatus) {
    DownloadStatusNoContent = 0,
    DownloadStatusNone = 1 << 0,
    DownloadStatusSome = 1 << 1,
    DownloadStatusAll = 1 << 2,
    DownloadStatusAllValid = 1 << 3,
};

typedef NS_OPTIONS(NSInteger, DownloadOptions) {
    DownloadOptionsEmpty = 0,
    DownloadOptionsText = 1 << 0,
    DownloadOptionsAudio = 1 << 1,
    DownloadOptionsVideo = 1 << 2,
    DownloadOptionsLowQuality = 1 << 3,
    DownloadOptionsHighQuality = 1 << 4,
};



static NSString *const NotificationUserChangedAudioSegment = @"__NotificationUserChangedAudioSegment";
static NSString *const NotificationAudioSegmentDidChange = @"__NotificationAudioSegmentDidChange";
static NSString *const NotificationKeyAudioSegment = @"__NotificationKeyAudioSegment";

#define SELECTION_BLUE_COLOR    [UIColor colorWithRed:76.0/255.0 green:185.0/255.0 blue:224.0/255.0 alpha:1.0]
#define TEXT_COLOR_NORMAL       [UIColor colorWithRed:32.0/255.0 green:27.0/255.0 blue:22.0/255.0 alpha:1.0]
#define BACKGROUND_GRAY               [UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:36.0/255.0 alpha:1.0]
#define BACKGROUND_GREEN          [UIColor colorWithRed:0.0 green:0.588 blue:0.533 alpha:1.0]

#define TABBAR_COLOR_TRANSPARENT [UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:36.0/255.0 alpha:0.75]

#define FONT_LIGHT_ITALIC [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:17]
#define FONT_LIGHT [UIFont fontWithName:@"HelveticaNeue-Light" size:17]
#define FONT_NORMAL [UIFont fontWithName:@"HelveticaNeue" size:17]
#define FONT_MEDIUM [UIFont fontWithName:@"HelveticaNeue-Medium" size:17]


#define VERSION_INFO @"We use a three-level, Church-centric approach for identifying the fidelity of translated Biblical content."
#define LEVEL_1_DESC @"Level 1: internal — Translator (or team) affirms that translation is in line with Statement of Faith and Translation Guidelines."
#define LEVEL_2_DESC @"Level 2: external — Translation is independently checked and confirmed by at least two others not on the translation team."
#define LEVEL_3_DESC @"Level 3: authenticated — Translation is checked and confirmed by leadership of at least one Church network with native speakers of the language."

#define LEVEL_1_IMAGE @"level1Cell"
#define LEVEL_2_IMAGE @"level2Cell"
#define LEVEL_3_IMAGE @"level3Cell"

#define LEVEL_1_REVERSE @"level1"
#define LEVEL_2_REVERSE @"level2"
#define LEVEL_3_REVERSE @"level3"

#define IMAGE_VERIFY_GOOD @"verifyGood"
#define IMAGE_VERIFY_FAIL @"verifyFail.png"
#define IMAGE_VERIFY_EXPIRE @"verifyExpired.png"

#define IMAGE_TRASH_CAN @"delete"

// Allows us to track the verse for each part of an attributed string
static NSString *const USFM_VERSE_NUMBER = @"USFMVerseNumber"; // Duplicated in UWConstants.swift
static NSString *const USFM_FOOTNOTE_NUMBER = @"USFMFootnoteNumber"; // Duplicated in UWConstants.swift


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