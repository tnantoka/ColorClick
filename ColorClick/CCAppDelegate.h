//
//  CCAppDelegate.h
//  ColorClick
//
//  Created by Tatsuya Tobioka on 12/01/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const CCColorFormatIndex; 

@interface CCAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    NSPoint lastPoint_;
    NSMutableArray *items_;
    NSInteger colorFormatIndex;
    UInt8 currentRed_;
    UInt8 currentGreen_;
    UInt8 currentBlue_;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSTextField *colorLabel;
@property (assign) IBOutlet NSBox *colorBox;
@property (assign) IBOutlet NSTableView *tableView;

@property NSInteger colorFormatIndex;
@property (assign) IBOutlet NSPopUpButton *popUp;

- (IBAction)clearItems:(id)sender;
- (IBAction)popupSelected:(id)sender;

@end
