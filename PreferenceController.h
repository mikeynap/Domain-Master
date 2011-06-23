//
//  PreferenceController.h
//  Domain Master, borrowed from RaiseMan
//
//  Created by Moo on 3/(22)14/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString * const MNAutoUploadKey;
extern NSString * const MNAutoDownloadKey;

@interface PreferenceController : NSWindowController {
	//Shear lazyness right here... I'm ashamed. au = autoUpload, ad=autoDownload
	IBOutlet NSButton *au;
	IBOutlet NSButton *ad;
	IBOutlet NSTextField *server;
	IBOutlet NSTextField *username;
	IBOutlet NSSecureTextField *password;
	IBOutlet NSTextField *path;
}

- (IBAction)changeAutoUpload:(id)sender;
- (IBAction)changeAutoDownload:(id)sender;
//- (IBAction)changeServer:(id)sender;
//- (IBAction)changeUsername:(id)sender;
//- (IBAction)changePassword:(id)sender;
//- (IBAction)changePath:(id)sender;
- (IBAction)setServerInfo:(id)sender;
- (BOOL)autoUpload;
- (BOOL)autoDownload;
+ (NSString *)server;
+ (NSString *)username;
//+ (NSString *)password;
+ (NSString *)path;




@end
