//
//  MNHostingArrayController.m
//  Hostmaster
//
//  Created by Moo on 3/20/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import "MNHostingArrayController.h"
#import "NSString+CSV.h"
@implementation MNHostingArrayController

- (void)awakeFromNib{
	[super awakeFromNib];	
	[self pleaseSort:nil];
	[name becomeFirstResponder];
}

- (id)newObject{
	id newObj = [super newObject];
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:31556926]; //aka one yaer
	[newObj setValue:[NSDate date] forKey:@"setupDate"];
	[newObj setValue:date forKey:@"expirationDate"];
	[newObj setValue:[NSNumber numberWithBool:NO] forKey:@"needsToBeRenewed"];
    NSArray *a = [tableView tableColumns];

	[self rearrangeObjects];
	[name becomeFirstResponder]; //Focus on that blue ring thing
	return newObj;
}

//Domain,Username,Password,Price,Creation,Expiration,Comments
//0		,1		 ,2		  ,3	,4		 ,5			,6

#pragma mark CSV Methods
- (IBAction)addObjectsFromArray:(id)sender{
	NSLog(@"Add");
	NSError *error = nil;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:[NSString stringWithString:sender]									  
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
	
	if (stringFromFileAtPath == nil) {
		NSLog(@"%@ asdfasdf",error);
		return;
	}
	NSArray *array = [stringFromFileAtPath csvRows];
	[stringFromFileAtPath release];
	NSLog(@"%@",array);
	NSLog(@"%@",error);
	NSArray* keyArray = [NSArray arrayWithObjects:@"domainName",@"username",@"password",@"price",
						 @"setupDate",@"expirationDate",@"comment",nil];
	for(int i = 1; i <= ([array count] - 1); i++){
		NSLog(@"IN");
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
		id newObj = [super newObject];
		for(int j = 0; j < [keyArray count]; j++){
			id tmp;
			id elm = [[array objectAtIndex:i] objectAtIndex:j];
			if (j == 3){
				NSMutableString *mutableString = [elm mutableCopy];
				[mutableString replaceOccurrencesOfString:@"$" withString:@"" 
														   options:NSCaseInsensitiveSearch
															 range:NSMakeRange(0,[elm length])];
				tmp = [NSNumber numberWithFloat:[mutableString floatValue]];
			}
			else if (j == 4 || j == 5){
				NSDateFormatter *inputFormatter;
				inputFormatter = [[NSDateFormatter alloc] init];
				[inputFormatter setDateStyle:NSDateFormatterShortStyle];
				tmp = [inputFormatter dateFromString:elm];
				[inputFormatter release];
				NSLog(@"%@",tmp);
			}
			else
				tmp = elm;
			[newObj setValue:tmp forKey:[keyArray objectAtIndex:j]];
		}
		NSLog(@"Did We Insert? %@",newObj);
		[pool drain];
	}
}

- (int)paymentStatusOfItem:(int)index{
    NSLog(@"dasdfThings");
    id a = [[self arrangedObjects] objectAtIndex:index];
    [a objectForKey:@"expirationDate"];
    NSLog(@"Things %@",a);
    return 1;
}

- (void)objectAdded: (NSNotification *)note{
    
    
}

#pragma mark CSV File Open Methods
- (IBAction)chooseCSVFile:(id)sender{
	[NSApp endSheet:csvSheet]; 
	[csvSheet orderOut:sender]; 
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel beginSheetForDirectory:NSHomeDirectory()
							 file:nil
							types:[NSArray arrayWithObject:@"csv"]
				   modalForWindow:myWindow
					modalDelegate:self
				   didEndSelector:@selector(filePanelDidEnd:
											returnCode:
											contextInfo:)
					  contextInfo:nil];
}


- (void)filePanelDidEnd:(NSOpenPanel*)sheet
            returnCode:(int)returnCode
           contextInfo:(void*)contextInfo{
	NSLog(@"DONE");
	[self addObjectsFromArray:[sheet filename]]; 
}

- (IBAction)addYear:(id)sender; {
	id obj = [[self selectedObjects] objectAtIndex:0];
	[obj setValue: [[obj valueForKey:@"expirationDate"] addTimeInterval:60*60*24*365] forKey:@"expirationDate"];
	[self pleaseSort:nil];

}

#pragma mark Sorting Method
- (IBAction)pleaseSort:(id)sender;{ //set sort stuff
	NSLog(@"PLease sort");
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"expirationDate" ascending:YES];
	[self setSortDescriptors:[NSArray arrayWithObject:sd]];
	[sd release];	
	[self rearrangeObjects];
}

@end
