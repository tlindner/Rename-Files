//
//  TLAppDelegate.m
//  Rename Files
//
//  Created by Tim on 7/17/14.
//  Copyright 2014 by Me. All rights reserved.
//

NSString *InsertString( NSString *baseString, NSString *leftOrRight, NSInteger distance, NSString *insertString);
NSString *MoveString(NSString *filename, NSString *titleOfSelectedItem, NSInteger moveCharacterCount, NSString *moveText);

#import "TLAppDelegate.h"

@implementation TLAppDelegate

@synthesize window;
@synthesize tableview;
@synthesize tabview;
@synthesize srSearch;
@synthesize srReplace;
@synthesize useGrep;
@synthesize errorText;
@synthesize partPopupButton;

@synthesize insertText;
@synthesize insertCharacterDistance;
@synthesize InsertLeftOrRight;

@synthesize numberPrefix;
@synthesize numberSuffix;
@synthesize numberStart;
@synthesize numberFormat;

@synthesize moveText;
@synthesize moveCharacterCount;
@synthesize moveTextWhence;

@synthesize allFiles;
@synthesize renamed;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	if (self.allFiles == nil) {
		self.allFiles = [[NSMutableArray alloc] initWithCapacity:100];
	}
    
    [tableview registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [tabview selectTabViewItemWithIdentifier:[ud stringForKey:@"tabview"]];
    [srSearch setStringValue:[ud stringForKey:@"srSearch"]];
    [srReplace setStringValue:[ud stringForKey:@"srReplace"]];
    [useGrep setState:[ud integerForKey:@"useGrep"]];
    [partPopupButton selectItemAtIndex:[ud integerForKey:@"partPopupButton"]];
    
    [insertText setStringValue:[ud stringForKey:@"insertText"]];
    [insertCharacterDistance setStringValue:[ud stringForKey:@"insertCharacterDistance"]];
    [InsertLeftOrRight selectItemAtIndex:[ud integerForKey:@"InsertLeftOrRight"]];
    
    [numberPrefix setStringValue:[ud stringForKey:@"numberPrefix"]];
    [numberSuffix setStringValue:[ud stringForKey:@"numberSuffix"]];
    [numberStart setStringValue:[ud stringForKey:@"numberStart"]];
    [numberFormat selectItemAtIndex:[ud integerForKey:@"numberFormat"]];
    
    [moveText setStringValue:[ud stringForKey:@"moveText"]];
    [moveCharacterCount setStringValue:[ud stringForKey:@"moveCharacterCount"]];
    [moveTextWhence selectItemAtIndex:[ud integerForKey:@"moveTextWhence"]];
    
//    [numberInsertDistance setStringValue:[ud stringForKey:@"numberInsertDistance"]];
//    [numberInsertLeftOrRight selectItemAtIndex:[ud integerForKey:@"numberInsertLeftOrRight"]];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setValue:[[tabview selectedTabViewItem] identifier] forKey:@"tabview"];
    [ud setValue:[srSearch stringValue] forKey:@"srSearch"];
    [ud setValue:[srReplace stringValue] forKey:@"srReplace"];
    [ud setInteger:[useGrep state] forKey:@"useGrep"];
    [ud setInteger:[partPopupButton indexOfSelectedItem] forKey:@"partPopupButton"];
    
    [ud setValue:[insertText stringValue] forKey:@"insertText"];
    [ud setValue:[insertCharacterDistance stringValue] forKey:@"insertCharacterDistance"];
    [ud setInteger:[InsertLeftOrRight indexOfSelectedItem] forKey:@"InsertLeftOrRight"];
    
    [ud setValue:[numberPrefix stringValue] forKey:@"numberPrefix"];
    [ud setValue:[numberSuffix stringValue] forKey:@"numberSuffix"];
    [ud setValue:[numberStart stringValue] forKey:@"numberStart"];
    [ud setInteger:[numberFormat indexOfSelectedItem] forKey:@"numberFormat"];
    
    [ud setValue:[moveText stringValue] forKey:@"moveText"];
    [ud setValue:[moveCharacterCount stringValue] forKey:@"moveCharacterCount"];
    [ud setInteger:[moveTextWhence indexOfSelectedItem] forKey:@"moveTextWhence"];

//    [ud setValue:[numberInsertDistance stringValue] forKey:@"numberInsertDistance"];
//    [ud setInteger:[numberInsertLeftOrRight indexOfSelectedItem] forKey:@"numberInsertLeftOrRight"];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	[self.allFiles addObjectsFromArray:filenames];
    [self recalculate:self];
}

- (IBAction) recalculate:(id)sender
{
    NSTabViewItem *selectedTabViewItem = [tabview selectedTabViewItem];
    self.renamed = nil;
    self.renamed = [[NSMutableArray alloc] initWithCapacity:[self.allFiles count]];
    NSMutableArray *stageIn = [[NSMutableArray alloc] initWithCapacity:[self.allFiles count]];
    NSMutableArray *stageOut = [[NSMutableArray alloc] initWithCapacity:[self.allFiles count]];
    
    /* Fill renamed array with file name, file suffix, or both */
    for (NSString *path in self.allFiles) {
        NSString *part;
        
        if ([partPopupButton indexOfSelectedItem] == 0) {
            /* Name only */
            part = [[path lastPathComponent] stringByDeletingPathExtension];
        }
        else if ([partPopupButton indexOfSelectedItem] == 1) {
            /* Suffix only */
            part = [[path lastPathComponent] pathExtension];
        }
        else if ([partPopupButton indexOfSelectedItem] == 2) {
            /* Both */
            part = [path lastPathComponent];
        }
        else {
            /* Unknown */
            part = [path lastPathComponent];
        }
        
        [stageIn addObject:part];
    }
    
    /* Discover which tab is in view and do it's work */
    if ([[selectedTabViewItem identifier] isEqualToString:@"1"]) {
        /* Search and Replace Tab */
        
        if ([useGrep intValue] == NO) {
            for (NSString *filename in stageIn) {
                [stageOut addObject:[filename stringByReplacingOccurrencesOfString:[srSearch stringValue] withString:[srReplace stringValue]]];
            }
        }
        else {
            NSError *myErr = nil;
            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:[srSearch stringValue] options:NSRegularExpressionAnchorsMatchLines error:&myErr];
            
            if (re == nil) {
                [errorText insertText:@"Regular expression not created."];
                
                for (NSString *filename in stageIn) {
                    [stageOut addObject:filename];
                }
            }
            else if (myErr != nil) {
                [errorText insertText:[myErr description]];
                
                for (NSString *filename in stageIn) {
                    [stageOut addObject:filename];
                }
            }
            else {
                NSUInteger count = 0;
                for (NSString *fn in stageIn) {
                    NSMutableString *filename = [fn mutableCopy];
                    NSRange range = NSMakeRange(0, [filename length]);
                    count += [re replaceMatchesInString:filename options:NSMatchingAnchored range:range withTemplate:[srReplace stringValue]];
                    [stageOut addObject:filename];
                    [filename release];
                }
                
                [errorText insertText:[NSString stringWithFormat:@"Total count: %ld", (unsigned long)count]];
            }
        }
    }
    else if ([[selectedTabViewItem identifier] isEqualToString:@"2"]) {
        /* Insert tab */
        for (NSString *filename in stageIn) {
            [stageOut addObject:InsertString(filename, [InsertLeftOrRight titleOfSelectedItem], [insertCharacterDistance intValue], [insertText stringValue])];
        }
    }
    else if ([[selectedTabViewItem identifier] isEqualToString:@"3"]) {
        /* Number tab */
        NSInteger currentNumber = [numberStart intValue];
        int formatLength = (int)[[numberFormat titleOfSelectedItem] length];
        
        for (NSString *filename in stageIn) {
            NSString *numberString = [NSString stringWithFormat:@"%0*ld", formatLength, (long)currentNumber++];
            numberString = [NSString stringWithFormat:@"%@%@%@", [numberPrefix stringValue], numberString, [numberSuffix stringValue]];
            
//            [stageOut addObject:InsertString(filename, [numberInsertLeftOrRight titleOfSelectedItem], [numberInsertDistance intValue], numberString)];
            [stageOut addObject:numberString];
        }
    }
    else if ([[selectedTabViewItem identifier] isEqualToString:@"4"]) {
        /* Move tab */
        for (NSString *filename in stageIn) {
            [stageOut addObject:MoveString(filename, [moveTextWhence titleOfSelectedItem], [moveCharacterCount intValue], [moveText stringValue])];
        }
    }
    else {
        NSLog ( @"Unknown tab" );
        for (NSString *filename in stageIn) {
            [stageOut addObject:filename];
        }
    }

    /* Fill renamed array with file name, file suffix, or both */
    NSUInteger i=0;
    for (NSString *part in stageOut) {

        if ([partPopupButton indexOfSelectedItem] == 0) {
            /* Name only */
            NSString *extension = [[self.allFiles objectAtIndex:i++] pathExtension];
            [self.renamed addObject:[part stringByAppendingPathExtension:extension]];
        }
        else if ([partPopupButton indexOfSelectedItem] == 1) {
            /* Suffix only */
            NSString *base = [[[self.allFiles objectAtIndex:i++] lastPathComponent] stringByDeletingPathExtension];
            [self.renamed addObject:[base stringByAppendingPathExtension:part]];
        }
        else if ([partPopupButton indexOfSelectedItem] == 2) {
            /* Both */
            [self.renamed addObject:part];
        }
        else {
            /* Unknown */
            [self.renamed addObject:part];
        }
    }

    [stageIn release];
    [stageOut release];
    
	[self.tableview reloadData];
}

- (IBAction)doIt:(id)sender {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    NSInteger i=0;
    NSMutableArray *newFiles = [NSMutableArray arrayWithCapacity:[self.allFiles count]];
    
    for (NSString *source in self.allFiles) {
        NSString *dest;
        
        dest = [[source stringByDeletingLastPathComponent] stringByAppendingPathComponent:[self.renamed objectAtIndex:i++]];
        err = nil;
        
        [fm moveItemAtPath:source toPath:dest error:&err];
        
        if (err != nil) {
            NSLog(@"file move error: %@", err);
            [newFiles addObject:source];
        }
        else {
            [newFiles addObject:dest];
        }
    }
    
    self.allFiles = newFiles;
    [self recalculate:self];    
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self recalculate:self];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self recalculate:self];
}

//  Table view data source delegate methods.

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return	[self.allFiles count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"before"]) {
		return [self.allFiles objectAtIndex:rowIndex];
	}
	else {
		return [self.renamed objectAtIndex:rowIndex];
	}	
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSArray *drops = [[info draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:nil];
    
    for (NSURL *file in drops) {
        if ([file isFileURL]) {
            [self.allFiles addObject:[file path]];
        }
    }
    
    [self recalculate:self];
    return YES;
}

@end

NSString *InsertString( NSString *baseString, NSString *leftOrRight, NSInteger distance, NSString *insertString)
{
    NSInteger length = [baseString length];
    NSInteger useDistance = MIN(distance, length);
    NSRange leftRange, rightRange;
    
    if ([leftOrRight isEqualToString:@"Left"]) {
        leftRange = NSMakeRange(0, useDistance);
        rightRange = NSMakeRange(useDistance, length - useDistance);
    }
    else if ([leftOrRight isEqualToString:@"Right"]) {
        leftRange = NSMakeRange(0, length - useDistance);
        rightRange = NSMakeRange(length - useDistance, useDistance);
    }
    else {
        NSLog ( @"Unknown \"Left\" or \"Right\"" );
        leftRange = NSMakeRange(0, useDistance);
        rightRange = NSMakeRange(useDistance, length - useDistance);
    }
    
    return [NSString stringWithFormat:@"%@%@%@",[baseString substringWithRange:leftRange], insertString, [baseString substringWithRange:rightRange]];
}

NSString *MoveString(NSString *filename, NSString *titleOfSelectedItem, NSInteger moveCharacterCount, NSString *moveText)
{
    NSRange range = [filename rangeOfString:moveText];
    NSString *result = filename;
    NSRange start;
    
    if (range.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:range withString:@""];
        
        if ([titleOfSelectedItem isEqualToString:@"To Left"]) {
            start = NSMakeRange(range.location - moveCharacterCount, 0);
            
            if( start.location < 1 )
            {
                result = [moveText stringByAppendingString:result];
            }
            else
            {
                result = [result stringByReplacingCharactersInRange:start withString:moveText];
            }
        }
        else if ([titleOfSelectedItem isEqualToString:@"To Right"]) {
            start = NSMakeRange(range.location + moveCharacterCount, 0);
            
            if( start.location > ([result length]-1) )
            {
                result = [result stringByAppendingString:moveText];
            }
            else
            {
                result = [result stringByReplacingCharactersInRange:start withString:moveText];
            }
        }
        else if ([titleOfSelectedItem isEqualToString:@"From Begining"]) {
            start = NSMakeRange(moveCharacterCount, 0);
            
            if( start.location > ([result length]-1) )
            {
                result = [result stringByAppendingString:moveText];
            }
            else
            {
                result = [result stringByReplacingCharactersInRange:start withString:moveText];
            }
        }
        else if ([titleOfSelectedItem isEqualToString:@"From End"]) {
            start = NSMakeRange([result length] - moveCharacterCount, 0);
            
            if( start.location < 1 )
            {
                result = [moveText stringByAppendingString:result];
            }
            else
            {
                result = [result stringByReplacingCharactersInRange:start withString:moveText];
            }
        }
        else
        {
            /* Do nothing */
        }
     }
 
    return result;
}











