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
	IBOutlet NSTableView * pagesList;
	IBOutlet JTPDFPageView * pageView;
	
	PDFDocument * openedDocument;
	NSMutableArray * thumbnails;
	NSImage * currentPageImage;
}

@property (nonatomic, retain) PDFDocument * openedDocument;
@property (nonatomic, retain) NSMutableArray * thumbnails;
@property (nonatomic, assign) NSImage * currentPageImage;

- (IBAction)exportDocument:(id)sender;

@end
