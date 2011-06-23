//
//  AppDelegate.m
//  Domain Master
//
//  Created by Moo on 3/21/09.
//  Copyright Micmoo 2009 . All rights reserved.
//
/*
	Todo: + Make FTP login work for everyone, not just internal
*/

#import "AppDelegate.h"
#import "MNHostingArrayController.h"
#import "PreferenceController.h"
#import "NSString+CSV.h"
//#import "AGKeychain.h"
//#define PASSWORD @"micmoo40"

@implementation AppDelegate

+ (void)initialize{
	
	//Class init method. Sets the default userDefaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:MNAutoUploadKey]; 
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MNAutoDownloadKey]; 
	[defaultValues setObject:@"micmoo.org" forKey:@"server"]; 
	[defaultValues setObject:@"luigi193" forKey:@"username"]; 
	[defaultValues setObject:@"/www/obj-c/DomainMaster" forKey:@"path"];
	/*NSString *password;
	BOOL doesItemExisit = [AGKeychain checkForExistanceOfKeychainItem:@"Domain Master Password"
														 withItemKind:@"Domain Master Password" 
														  forUsername:NSUserName()];
	if (doesItemExisit) {
		password = [PreferenceController password];
	}
	else{
		[AGKeychain addKeychainItem:@"Domain Master Password" 
									 withItemKind:@"Domain Master Password"  
									  forUsername:NSUserName()
									 withPassword:PASSWORD];
		password = PASSWORD;
	}
	[defaultValues setObject:password forKey:@"password"];
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:defaultValues];*/
}

- (id)init 
{ //If its set for the user to downloadChanges on start, do so
    self = [super init];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MNAutoDownloadKey] == YES)
		[self downloadChanges:nil];
	else
		[self backupData:nil];
    return self;
}

- (void)awakeFromNib
{ //Sort data by exp date
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SUHasLaunchedBefore"] == FALSE){
		preferenceController = [[PreferenceController alloc] init];
		int a = NSRunAlertPanel(@"Welcome!", @"Welcome to Domain Master! By Default, Domain Master will download the newest data file on startup. If you would like to auto upload on close, click \"Go to Preference.\"Remember, you can always manually upload in the File menu." , @"Launch App",@"Go To Preferences",nil);
		if (a == 0)[preferenceController showWindow:self];
		else [myWindow makeKeyAndOrderFront:nil];
	}

	[hostingArrayController pleaseSort:nil];
	[domainArrayController pleaseSort:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
	
}



- (void)objectsDidChange:(NSNotification *)note{
	[hostingArrayController pleaseSort:nil];
	[domainArrayController pleaseSort:nil];

}

- (IBAction)billedClient:(id)sender {
	[hostingArrayController addYear:[tableView dataSource]];
    [hostingArrayController paymentStatusOfItem:10];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    id a = [aCell objectValue];
    NSColor *c = nil;

    [aCell setBackgroundColor:[NSColor purpleColor]];
    [aCell setDrawsBackground:YES];
}



#pragma mark Upload/Download Methods

- (IBAction)backupData:(id)sender{
	NSError* error = nil;
	NSString *file = [[self applicationSupportFolder] stringByAppendingPathComponent:@"Domain Master.xml"];
	NSFileManager *mgr = [NSFileManager defaultManager];
	[mgr createFileAtPath:[file stringByAppendingString:@"Backup"] contents:[NSData dataWithContentsOfFile:file options:0 error:&error] attributes:nil];
	NSLog(@"Error: %@",error);
	
}

- (IBAction)uploadChanges:(id)sender{
	// Upload the data file to my server. See Todo note above.
	NSLog(@"Upload");
	[self backupData:nil];
	NSTask *tasky = [[NSTask alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(finishedUpload:) 
												 name:NSTaskDidTerminateNotification 
											   object:nil]; //When it finished, send a notification to sel.
	[self saveAction:nil];
	NSString* applicationSupportFile = [[self applicationSupportFolder] stringByAppendingPathComponent: 
										@"Domain Master.xml"];
	[tasky setLaunchPath:@"/usr/bin/curl"];

	[tasky setArguments:[NSArray arrayWithObjects:@"-T",applicationSupportFile,@"-u",@"luigi193:micmoo40",
	  @"ftp://ftp.micmoo.org/www/obj-c/DomainMaster/",@"-s",nil]];
	[tasky launch];
	if (sender == nil){
		// if this method is being called by a "not button"
		[tasky waitUntilExit]; //wait for the upload to complete before we continue
		//This is used if were uploading before close.
	}
}

- (void)downloadChanges:(id)sender{ 
	NSLog(@"Download");
	[self backupData:nil];
	if ([sender class] != NULL){//If clicked by a button, after it finishes, go to sel.
		[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(finishedDownload:) 
												 name:NSTaskDidTerminateNotification 
											   object:nil];
	}
	NSTask* curl=[[NSTask alloc] init];
	[curl setLaunchPath:@"/usr/bin/curl"];
	[curl setArguments: [NSArray arrayWithObjects:@"-o",
						 [[self applicationSupportFolder] stringByAppendingPathComponent:@"Domain Master.xml"],
						 @"http://micmoo.org/obj-c/DomainMaster/Domain%20Master.xml",@"-s",
						 nil]];
	[curl launch];
	[curl waitUntilExit];
	[curl release];
}

- (void)finishedDownload:(NSNotification *)aNotification {
	[self restartOurselves];
}

- (void)finishedUpload:(NSNotification *)aNotification {
	[uploadChangesButton setTitle:@"Upload Changes"];
}

- (void) restartOurselves
{	// Method I borrowed from a website to restart your own app.
	NSString *ourPID = [NSString stringWithFormat:@"%d",
	[[NSProcessInfo processInfo] processIdentifier]];
	NSString * pathToUs = [[NSBundle mainBundle] bundlePath];
	NSArray *shArgs = [NSArray arrayWithObjects:@"-c", // -c tells sh to execute the next argument, passing it the remaining arguments.
	@"kill -9 $1 \n open \"$2\"",
	@"", //$0 path to script (ignored)
	ourPID, //$1 in restartScript
	pathToUs, //$2 in the restartScript
	nil];
	NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
	[restartTask waitUntilExit]; //wait for killArg1AndOpenArg2Script to finish
	NSLog(@"*** ERROR: %@ should have been terminated, but we are still running", pathToUs);
	assert(!"We should not be running!");
}

#pragma mark PreGenerated CoreData Crap

- (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Domain Master"];
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Domain Master.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

#pragma mark SaveMethods
- (IBAction) saveAction:(id)sender {
	[hostingArrayController pleaseSort:nil];
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) //Save!
			[[NSApplication sharedApplication] presentError:error];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	//When the app is on its way out, save.
	[self saveAction:nil]; //if Pref is set to upload on quit, do so.
	NSLog(@"%i ",[[NSUserDefaults standardUserDefaults] boolForKey:MNAutoUploadKey]);
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MNAutoUploadKey] == YES)
			[self uploadChanges:nil];

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
               if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 
				
                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

#pragma mark CSV Template Methods

- (IBAction)showCSVSheet:(id)sender 
{ 
    [NSApp beginSheet:csvSheet 
       modalForWindow:myWindow
        modalDelegate:nil 
       didEndSelector:NULL 
          contextInfo:NULL]; 
} 

- (IBAction)endCSVSheet:(id)sender;
{ 
	// Return to normal event handling 
	[NSApp endSheet:csvSheet]; 
	// Hide the sheet 
	[csvSheet orderOut:sender]; 
} 

- (IBAction)saveHostingTemplate:(id)sender;{
	[self saveTemplate:@"hostingCSVImporter"];
}

- (IBAction)saveDomainTemplate:(id)sender;{
	[self saveTemplate:@"domainCSVImporter"];
}

- (void)saveTemplate:(NSString *)templateName;{
	NSString *string = [[NSBundle mainBundle] pathForResource:templateName ofType:@"xls"];
	NSSavePanel *sp;
	int runResult;
	
	/* create or get the shared instance of NSSavePanel */
	sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"xls"];
	
	/* display the NSSavePanel */
	runResult = [sp runModalForDirectory:NSHomeDirectory() file:templateName];
	NSData *textData = [[NSData alloc] initWithContentsOfFile:string];
	/* if successful, save file under designated name */
	if (runResult == NSOKButton) {
		if (![textData writeToFile:[sp filename] atomically:YES])
			NSBeep();
	}
	[textData release];
	[self endCSVSheet:nil];
}

#pragma mark Open/Close Methods

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication{
	//Quit app when window closes.
	return YES;
}

- (void) dealloc {
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

#pragma mark AppControllingMethods

- (IBAction)showPreferencePanel:(id)sender{
	if (!preferenceController)
		preferenceController = [[PreferenceController alloc] init];
	[preferenceController showWindow:self];
}



#pragma mark DEPRECATED_METHODS
/*
	Nothing Here... ='(
*/
@end
