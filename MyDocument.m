//
//  MyDocument.m
//  PDF Optimizer
//
//  Created by Jason Terhorst on 12/24/10.
//  Copyright 2010 Jason Terhorst. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument


@synthesize openedDocument, thumbnails, currentPageImage;


- (id)init
{
	self = [super init];
	if (self)
	{
		// Add your subclass-specific initialization here.
		// If an error occurs here, send a [self release] message and return nil.
		
		quality = 3.0;
	}
	return self;
}

- (NSString *)windowNibName
{
	return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[super windowControllerDidLoadNib:aController];
	
	NSLog(@"loaded nib. %d pages", [self.openedDocument pageCount]);
	
	[pageView setCurrentDocument:self.openedDocument];
	[pageView setCurrentPage:0];
	
	
	[pageView setPageImage:[[self.thumbnails objectAtIndex:[pagesList selectedRow]] valueForKey:@"image"]];
	
	
	if (docWindow == nil)
		NSLog(@"no window");
	if (summaryView == nil)
		NSLog(@"no view");
	
	
	NSRect oldFrame = [docWindow frame];
	NSRect newFrame = [summaryView frame];
	newFrame.origin.x = oldFrame.origin.x;
	newFrame.origin.y = oldFrame.origin.y;
	
	[docWindow setFrame:newFrame display:YES];
	
	[[docWindow contentView] addSubview:summaryView];
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	PDFDocument * outputDocument = [[[PDFDocument alloc] init] autorelease];
	
	for (NSMutableDictionary * imageObj in self.thumbnails) {
		if ([[imageObj objectForKey:@"enabled"] boolValue] == YES)
		{
			PDFPage * aPage = [[PDFPage alloc] initWithImage:[imageObj objectForKey:@"image"]];
			[outputDocument insertPage:aPage atIndex:[self.thumbnails indexOfObject:imageObj]];
			[aPage release];
		}
	}
	
	/*
	QuartzFilter * quartzFilter = nil;
	if (quality == 1.0)
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115low" withExtension:@"qfilter"]];
	else if (quality == 2.0)
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115avg" withExtension:@"qfilter"]];
	else if (quality == 3.0)
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115high" withExtension:@"qfilter"]];
	*/
	
	//[outputDocument writeToURL:outputURL withOptions:[NSDictionary dictionaryWithObject:quartzFilter forKey:@"QuartzFilter"]];
	
	return [outputDocument dataRepresentation];
	
	/*
	NSData * outputData = [self.openedDocument dataRepresentation];
	if (outputData != nil)
		return outputData;
	 */
	
	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	self.openedDocument = [[[PDFDocument alloc] initWithData:data] autorelease];
	if (self.openedDocument == nil)
		return NO;
	
	self.thumbnails = [NSMutableArray array];
	
	int x = 0;
	
	for (x = 0; x < [self.openedDocument pageCount]; x++) {
		PDFPage * aPage = [self.openedDocument pageAtIndex:x];
		NSImage * image = [[NSImage alloc] initWithData:[aPage dataRepresentation]];
		float sourceWidth = [image size].width;
		float sourceHeight = [image size].height;
		
		NSLog(@"fetching image...");
		
		if (sourceWidth < 1024 && sourceHeight < 1024)
		{
			NSLog(@"this page isn't very big. I'm not going to size it down. just rendering.");
			
			NSMutableDictionary * imageDict = [NSMutableDictionary dictionary];
			[imageDict setObject:image forKey:@"image"];
			[imageDict setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
			[self.thumbnails addObject:imageDict];
		}
		else
		{
			float imageSizeRatio, width, height;
			
			
			if (sourceWidth > sourceHeight) {
				imageSizeRatio = sourceWidth / 1024;
				width = sourceWidth;
				height = sourceHeight * imageSizeRatio;
			}
			else {
				imageSizeRatio = sourceHeight / 1024;
				height = sourceHeight;
				width = sourceWidth * imageSizeRatio;
			}
			
			NSImage *smallImage = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
			[smallImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[image setSize:NSMakeSize(width, height)];
			[image compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
			[smallImage unlockFocus];
			
			NSMutableDictionary * imageDict = [NSMutableDictionary dictionary];
			[imageDict setObject:smallImage forKey:@"image"];
			[imageDict setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
			[self.thumbnails addObject:imageDict];
			
			[smallImage release];
		}
		
		[image release];
	}
	
	
	
	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	
	return YES;
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[pageView setPageImage:[[self.thumbnails objectAtIndex:[pagesList selectedRow]] valueForKey:@"image"]];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"thumbnail"])
		return [[self.thumbnails objectAtIndex:rowIndex] valueForKey:@"image"];
	if ([[aTableColumn identifier] isEqualToString:@"enabled"])
		return [[self.thumbnails objectAtIndex:rowIndex] valueForKey:@"enabled"];
	
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSLog(@"obj: %@", [anObject description]);
	
	if ([[aTableColumn identifier] isEqualToString:@"thumbnail"])
		[[self.thumbnails objectAtIndex:rowIndex] setObject:anObject forKey:@"image"];
	if ([[aTableColumn identifier] isEqualToString:@"enabled"])
		[[self.thumbnails objectAtIndex:rowIndex] setObject:anObject forKey:@"enabled"];
	
	[self updateChangeCount:NSChangeDone];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self.thumbnails count];
}





- (IBAction)showSummaryView:(id)sender;
{
	if ([summaryView superview] != nil)
		return;
	
	if ([fullView superview])
		[fullView removeFromSuperview];
	
	NSRect oldFrame = [docWindow frame];
	NSRect newFrame = [summaryView frame];
	newFrame.origin.x = oldFrame.origin.x - ((newFrame.size.width - oldFrame.size.width) / 2);
	newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height);
	
	[docWindow setFrame:newFrame display:YES animate:YES];
	
	[[docWindow contentView] addSubview:summaryView];
}

- (IBAction)showFullView:(id)sender;
{
	if ([fullView superview] != nil)
		return;
	
	if ([summaryView superview])
		[summaryView removeFromSuperview];
	
	NSRect oldFrame = [docWindow frame];
	NSRect newFrame = [fullView frame];
	newFrame.origin.x = oldFrame.origin.x - ((newFrame.size.width - oldFrame.size.width) / 2);
	newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height);
	
	[docWindow setFrame:newFrame display:YES animate:YES];
	
	[[docWindow contentView] addSubview:fullView];
}




- (IBAction)changeQuality:(id)sender;
{
	NSLog(@"quality: %f", [sender floatValue]);
	
	quality = [sender floatValue];
	
	if (quality == 1.0)
		[qualityLabel setStringValue:@"Quality: Low"];
	else if (quality == 2.0)
		[qualityLabel setStringValue:@"Quality: Average"];
	else
		[qualityLabel setStringValue:@"Quality: High"];
	
	[qualityLabelFull setStringValue:[qualityLabel stringValue]];
	
	[qualitySlider setFloatValue:quality];
	[qualitySliderFull setFloatValue:quality];
}



- (IBAction)exportDocument:(id)sender;
{
	NSURL * outputURL = nil;
	if (self.fileURL)
		outputURL = self.fileURL;
	
	if (!outputURL)
	{
		NSSavePanel * outputSavePanel = [NSSavePanel savePanel];
		[outputSavePanel setTitle:@"Save as PDF"];
		[outputSavePanel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
		if ([outputSavePanel runModal] == NSFileHandlingPanelOKButton)
			outputURL = [outputSavePanel URL];
		else
			return;
	}
	
	PDFDocument * outputDocument = [[PDFDocument alloc] init];
	
	for (NSMutableDictionary * imageObj in self.thumbnails) {
		if ([[imageObj objectForKey:@"enabled"] boolValue] == YES)
		{
			PDFPage * aPage = [[PDFPage alloc] initWithImage:[imageObj objectForKey:@"image"]];
			[outputDocument insertPage:aPage atIndex:[self.thumbnails indexOfObject:imageObj]];
			[aPage release];
		}
	}
	
	QuartzFilter * quartzFilter = nil;
	if (quality == 1.0)
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115low" withExtension:@"qfilter"]];
	else if (quality == 2.0)
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115avg" withExtension:@"qfilter"]];
	else
		quartzFilter = [QuartzFilter quartzFilterWithURL:[[NSBundle mainBundle] URLForResource:@"115high" withExtension:@"qfilter"]];
	
    if (quartzFilter == nil)
        [[NSException exceptionWithName:@"No quartz filter" reason:@"Cannot be nil" userInfo:nil] raise];
    
	[outputDocument writeToURL:outputURL withOptions:[NSDictionary dictionaryWithObject:quartzFilter forKey:@"QuartzFilter"]];
	
	[outputDocument release];
	
	
	[self updateChangeCount:NSChangeCleared];
	
}





@end
