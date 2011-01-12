//
//  PDFOptimizerAppDelegate.m
//  PDF Optimizer
//
//  Created by Jason Terhorst on 1/11/11.
//  Copyright 2011 Jason Terhorst. All rights reserved.
//

#import "PDFOptimizerAppDelegate.h"


@implementation PDFOptimizerAppDelegate

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	NSLog(@"active");
	
	NSDocumentController * documentController = [NSDocumentController sharedDocumentController];
	
	if ([[[NSApplication sharedApplication] orderedDocuments] count] == 0)
		[documentController openDocument:self];
}

@end
