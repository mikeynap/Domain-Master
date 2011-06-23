//
//  PreferenceController.m
//  RaiseMan
//
//  Created by Moo on 3/14/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import "PreferenceController.h"
//#import "AGKeychain.h"
#define PASSWORD @"micmoo40"

NSString * const MNAutoUploadKey = @"AutoUpload";
NSString * const MNAutoDownloadKey = @"AutoDownload";

@implementation PreferenceController

- (id)init{
	if (![super initWithWindowNibName:@"Preferences"])
		return nil;
	return self;
}

- (void)windowDidLoad{
	[au setState:[self autoUpload]];
	[ad setState:[self autoDownload]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[username setStringValue:[defaults objectForKey:@"username"]];
	[server setStringValue:[defaults objectForKey:@"server"]];
	[path setStringValue:[defaults objectForKey:@"path"]];
	//[password setStringValue:[AGKeychain getPasswordFromKeychainItem:@"Domain Master Password" withItemKind:@"Domain Master Password" forUsername:NSUserName()]];
}


- (IBAction)changeAutoUpload:(id)sender;{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:[au state] forKey:MNAutoUploadKey];
}

- (IBAction)changeAutoDownload:(id)sender;{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:[ad state] forKey:MNAutoDownloadKey];
}

- (IBAction)setServerInfo:(id)sender;{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[server stringValue] forKey:@"server"];
	[defaults setObject:[username stringValue] forKey:@"username"];
	[defaults setObject:[path stringValue] forKey:@"path"];
/*	
	if ([[password stringValue] isEqualToString:@""]) {
		return;
	}
	
	BOOL doesItemExisit = [AGKeychain checkForExistanceOfKeychainItem:@"Domain Master Password" 
														 withItemKind:@"Domain Master Password"
														  forUsername:NSUserName()];
	if (doesItemExisit) {
		[AGKeychain modifyKeychainItem:@"Domain Master Password"
										withItemKind:@"Domain Master Password"
										 forUsername:NSUserName()
									 withNewPassword:[password stringValue]];
	}
	else {
		[AGKeychain addKeychainItem:@"Domain Master Password" 
									 withItemKind:@"Domain Master Password"  
									  forUsername:NSUserName()
									 withPassword:[password stringValue]];
	}*/
}
- (BOOL)autoUpload;{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:MNAutoUploadKey];
}

- (BOOL)autoDownload;{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:MNAutoDownloadKey];
}

//+ (NSString *)password{
//	return [AGKeychain getPasswordFromKeychainItem:@"Domain Master Password"
//							   withItemKind:@"Domain Master Password" 
//								forUsername:NSUserName()];	
//}

+ (NSString *)server;{
	return 	[[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
}

+ (NSString *)username;{
	return 	[[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
}

+ (NSString *)path{
	return 	[[NSUserDefaults standardUserDefaults] stringForKey:@"path"];

}
@end
