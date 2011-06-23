//
//  MNHostingArrayController.m
//  Hostmaster
//
//  Created by Moo on 3/20/09.
//  Copyright 2009 Micmoo. All rights reserved.
//

#import "MNDomainArrayController.h"
#import "NSString+CSV.h"
@implementation MNDomainArrayController

- (void)awakeFromNib{
	[super awakeFromNib];
	[self pleaseSort:nil];
	[name becomeFirstResponder];
}


- (id)newObject{
	id newObj = [super newObject];
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:31556926]; 
	[newObj setValue:date forKey:@"expirationDate"];
	[newObj setValue:[NSNumber numberWithBool:NO] forKey:@"needsToBeRenewed"];
	[name becomeFirstResponder];
	return newObj;
}

- (IBAction)addObjectsFromArray:(id)sender{
	NSLog(@"Add");
	NSError *error = nil;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:[NSString stringWithString:sender]									  
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
	
	if (stringFromFileAtPath == nil) {
		NSLog(@"%@",error);
		return;
	}
	NSArray *array = [stringFromFileAtPath csvRows];
	[stringFromFileAtPath release];
	NSLog(@"%@",array);
	NSLog(@"%@",error);
	NSArray* keyArray = [NSArray arrayWithObjects:@"domainName",@"username",@"password",@"price",
						 @"expirationDate",@"client",@"numberOfYears",@"registrar",@"comment",nil];
	for(int i = 1; i <= ([array count] - 1); i++){
		NSLog(@"IN");
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
		id newObj = [super newObject];
		
		for(int j = 0; j < [keyArray count]; j++){
			id tmp;
			id elm = [[array objectAtIndex:i] objectAtIndex:j];
			if (j == 3 || j == 6){
				NSMutableString *mutableString = [elm mutableCopy];
				[mutableString replaceOccurrencesOfString:@"$" withString:@"" 
												  options:NSCaseInsensitiveSearch
													range:NSMakeRange(0,[elm length])];
				tmp = [NSNumber numberWithFloat:[mutableString floatValue]];
			}
			else if (j == 4){
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

- (IBAction)chooseCSVFile:(id)sender{
	[NSApp endSheet:csvSheet]; 
	// Hide the sheet 
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

- (IBAction)pleaseSort:(id)sender;{
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"expirationDate" ascending:YES];
	[self setSortDescriptors:[NSArray arrayWithObject:sd]];
	[sd release];	
	[self rearrangeObjects];
}

@end
