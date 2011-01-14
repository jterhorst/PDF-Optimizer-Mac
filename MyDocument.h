//
//  MyDocument.h
//  PDF Optimizer
//
//  Created by Jason Terhorst on 12/24/10.
//  Copyright 2010 Jason Terhorst. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import <Quartz/Quartz.h>

#import "JTPDFPageView.h"



@interface MyDocument : NSDocument
{
	IBOutlet NSView * summaryView;
	IBOutlet NSView * fullView;
	
	IBOutlet NSSlider * qualitySlider;
	IBOutlet NSTextField * qualityLabel;
	
	
	IBOutlet NSTableView * pagesList;
	IBOutlet JTPDFPageView * pageView;
	
	PDFDocument * openedDocument;
	NSMutableArray * thumbnails;
	NSImage * currentPageImage;
	
	IBOutlet NSWindow * docWindow;
}

@property (nonatomic, retain) PDFDocument * openedDocument;
@property (nonatomic, retain) NSMutableArray * thumbnails;
@property (nonatomic, assign) NSImage * currentPageImage;


- (IBAction)showSummaryView:(id)sender;
- (IBAction)showFullView:(id)sender;



- (IBAction)exportDocument:(id)sender;

@end
