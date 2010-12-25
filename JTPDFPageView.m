//
//  JTPDFPageView.m
//  PDF Optimizer
//
//  Created by Jason Terhorst on 12/25/10.
//  Copyright 2010 Jason Terhorst. All rights reserved.
//

#import "JTPDFPageView.h"


@implementation JTPDFPageView

@synthesize pageImage, currentDocument, currentPage;



- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code here.
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithRect:[self bounds]] fill];
	
	if (self.pageImage != nil)
	{
		// draw the image
		[self.pageImage drawInRect:[self bounds] fromRect:NSMakeRect(0, 0, [self.pageImage size].width, [self.pageImage size].height) operation:NSCompositeSourceOver fraction:1.0];
		
		return;
	}
	
	if (self.currentDocument != nil)
	{
		// draw the pdf page instead
		[[self.currentDocument pageAtIndex:self.currentPage] drawWithBox:kPDFDisplayBoxCropBox];
	}
	
}

- (void)setPageImage:(NSImage *)anImage;
{
	[pageImage release];
	pageImage = [anImage retain];
	
	[self setNeedsDisplay:YES];
}

- (void)setCurrentPage:(NSInteger)aPage;
{
	currentPage = aPage;
	
	[self setNeedsDisplay:YES];
}

- (void)setCurrentDocument:(PDFDocument *)aDocument;
{
	currentDocument = aDocument;
	
	[self setNeedsDisplay:YES];
}

@end
