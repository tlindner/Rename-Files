//
//  TLAppDelegate.h
//  Rename Files
//
//  Created by Tim on 7/17/14.
//  Copyright 2014 by Me. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TLAppDelegate : NSObject <NSApplicationDelegate> {
//    NSWindow *window;
//	NSTableView *tableview;
	
	NSMutableArray *allFiles, *renamed;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableview;
@property (assign) IBOutlet NSTabView *tabview;
@property (assign) IBOutlet NSTextField *srSearch;
@property (assign) IBOutlet NSTextField *srReplace;
@property (assign) IBOutlet NSButton *useGrep;
@property (assign) IBOutlet NSTextView *errorText;
@property (assign) IBOutlet NSPopUpButton *partPopupButton;
@property (assign) IBOutlet NSTextField *insertText;
@property (assign) IBOutlet NSTextField *insertCharacterDistance;
@property (assign) IBOutlet NSPopUpButton *InsertLeftOrRight;
@property (assign) IBOutlet NSTextField *numberPrefix;
@property (assign) IBOutlet NSTextField *numberSuffix;
@property (assign) IBOutlet NSTextField *numberStart;
@property (assign) IBOutlet NSPopUpButton *numberFormat;

@property (retain) NSMutableArray *allFiles;
@property (retain) NSMutableArray *renamed;

- (IBAction)recalculate:(id)sender;
- (IBAction)doIt:(id)sender;

@end
