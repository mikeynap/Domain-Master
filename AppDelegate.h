//  MyDocument.h
//  Domain Master
//
//  Created by Moo on 3/21/09.
//  Copyright Micmoo 2009 . All rights reserved.



#import <Cocoa/Cocoa.h>
@class PreferenceController;
@class MNHostingArrayController;
@class MNDomainArrayController;

@interface AppDelegate : NSObject {
	//Outlets
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextField *hostingName;
	IBOutlet NSTabView *tabView;
	IBOutlet NSButton *uploadChangesButton;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSWindow *myWindow;
	IBOutlet NSWindow *csvSheet;
	
	//Controllers + Presistant Store Crap
	MNHostingArrayController *hostingArrayController;
	MNDomainArrayController *domainArrayController;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	PreferenceController *preferenceController;
	
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (IBAction)saveAction:(id)sender;
- (IBAction)uploadChanges:(id)sender;
- (IBAction)downloadChanges:(id)sender;
- (NSString *)applicationSupportFolder;
- (void) restartOurselves;
- (void)finishedDownload:(NSNotification *)aNotification;
- (void)finishedUpload:(NSNotification *)aNotification;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)backupData:(id)sender;
- (IBAction)saveHostingTemplate:(id)sender;
- (IBAction)saveDomainTemplate:(id)sender;
- (void)saveTemplate:(NSString *)templateName;
- (IBAction)endCSVSheet:(id)sender;
- (IBAction)showCSVSheet:(id)sender;
- (IBAction)billedClient:(id)sender;


@end
