//
//  JTPDFPageView.h
//  PDF Optimizer
//
//  Created by Jason Terhorst on 12/25/10.
//  Copyright 2010 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Quartz/Quartz.h>



@interface JTPDFPageView : NSView
{
	
}

@property (nonatomic, retain) NSImage * pageImage;
@property (nonatomic, retain) PDFDocument * currentDocument;
@property (nonatomic, assign) NSInteger currentPage;

@end
