//
//  MNHostingArrayController.h
//  Hostmaster
//
//  Created by Moo on 3/20/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MNDomainArrayController : NSArrayController {
	IBOutlet NSTextField *name;
	IBOutlet NSWindow *myWindow;
	IBOutlet NSWindow *csvSheet;


}

- (IBAction)pleaseSort:(id)sender;
- (IBAction)chooseCSVFile:(id)sender;
- (void)filePanelDidEnd:(NSOpenPanel*)sheet
			 returnCode:(int)returnCode
			contextInfo:(void*)contextInfo;	

@end
