//
//  MNHostingArrayController.h
//  Hostmaster
//
//  Created by Moo on 3/20/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MNHostingArrayController : NSArrayController {
	IBOutlet NSTextField *name;
	IBOutlet NSTableView *tableView;
	IBOutlet NSWindow *myWindow;
	IBOutlet NSWindow *csvSheet;
}

- (IBAction)pleaseSort:(id)sender;
- (IBAction)addObjectsFromArray:(id)sender;
- (IBAction)chooseCSVFile:(id)sender;
- (void)filePanelDidEnd:(NSOpenPanel*)sheet
			 returnCode:(int)returnCode
			contextInfo:(void*)contextInfo;	
- (IBAction)addYear:(id)sender;

@end
