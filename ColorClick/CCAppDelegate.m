//
//  CCAppDelegate.m
//  ColorClick
//
//  Created by Tatsuya Tobioka on 12/01/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCAppDelegate.h"

@interface CCAppDelegate()
- (void)globalMouseMoved:(NSEvent *)event;
- (void)globalMouseDown:(NSEvent *)event;
- (void)pasteToClipBoard;
@end

@implementation CCAppDelegate

@synthesize window = _window;
@synthesize imageView;
@synthesize colorLabel;
@synthesize colorBox;
@synthesize tableView;

- (void)dealloc
{
    [items_ release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    lastPoint_ = [NSEvent mouseLocation];
    
    // Insert code here to initialize your application
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent *event) {
        [self globalMouseMoved:event]; 
    }];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        [self globalMouseDown:event]; 
    }];
    
    items_ = [[NSMutableArray array] retain];
    
    self.tableView.dataSource = self;
    self.tableView.target = self;
    self.tableView.doubleAction = @selector(pasteToClipBoard);
    
    self.colorFormatIndex = 0;
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:nil];
    return NO;
}

- (void)globalMouseMoved:(NSEvent *)event {
    /*
    NSPoint currentPoint = [NSEvent mouseLocation];
    float xDiff = fabs(lastPoint_.x - currentPoint.x); 
    float yDiff = fabs(lastPoint_.y - currentPoint.y);
    
    if (xDiff > 1 && yDiff > 1) {
        lastPoint_ = currentPoint;
    }
*/
//    NSPoint currentPoint = [NSEvent mouseLocation];
//    NSLog(@"Global mouse moved x=%f, y=%f", currentPoint.x, currentPoint.y);
/*
    CGEventRef eventRef = CGEventCreate(NULL);
    CGPoint point = CGEventGetLocation(eventRef);
    NSLog(@"point x=%f, y=%f", point.x, point.y);
    CFRelease(eventRef);
 */

    CGEventRef eventRef = CGEventCreate(NULL);
    CGPoint currentPoint = CGEventGetLocation(eventRef);
    CFRelease(eventRef);
    
    int captureSize = 10;
    CGRect captureRect = CGRectMake(currentPoint.x - (captureSize / 2), currentPoint.y - (captureSize / 2), captureSize, captureSize);
    CGImageRef cgImageRef = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageBoundsIgnoreFraming);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:cgImageRef];
    NSImage *image = [[[NSImage alloc] init] autorelease];
    [image addRepresentation:bitmap];
    
    imageView.image = image;

    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImageRef);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);

    size_t width = CGImageGetWidth(cgImageRef);
    size_t height = CGImageGetHeight(cgImageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImageRef);
    
    NSLog(@"w = %ld, h = %ld, pc = %ld, bp = %ld, br = %ld", width, height, bitsPerComponent, bitsPerPixel, bytesPerRow);
    NSLog(@"x = %f, y = %f, w = %f, h = %f", captureRect.origin.x, captureRect.origin.y, captureRect.size.width, captureRect.size.height);
    // captureSize = 8
    // w = 8, h = 8, pc = 8, bp = 32, br = 64
    // captureSize = 10
    // w = 10, h = 10, pc = 8, bp = 32, br = 64
    
    int w = captureSize;
    int bytes = 4;
    
    // Center
    int x = captureSize / 2;
    int y = x;

    UInt8 *index = buffer + ((x + (y * w)) * bytes);

    // BGRA
    UInt8 r = *(index + 2);
    UInt8 g = *(index + 1);
    UInt8 b = *(index + 0);
    //UInt8 a = *(index + 3);
        
    self.colorLabel.stringValue = [NSString stringWithFormat:@"rgb(%d, %d, %d)", r, g, b];
    self.colorBox.fillColor = [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];

}

- (void)globalMouseDown:(NSEvent *)event {
/*

//    NSPoint currentPoint = [NSEvent mouseLocation];

    CGEventRef eventRef = CGEventCreate(NULL);
    CGPoint currentPoint = CGEventGetLocation(eventRef);
    CFRelease(eventRef);

    float captureSize = 100;
    CGRect captureRect = CGRectMake(currentPoint.x, currentPoint.y, captureSize, captureSize);
    CGImageRef cgImage = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageBoundsIgnoreFraming);

    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    NSImage *image = [[[NSImage alloc] init] autorelease];
    [image addRepresentation:bitmap];
    
    imageView.image = image;
    
    NSLog(@"Global mouse down x=%f, y=%f, w=%f, h=%f", captureRect.origin.x, captureRect.origin.y, captureRect.size.width, captureRect.size.height);
*/  
    
    NSLog(self.colorLabel.stringValue);
    [items_ addObject:self.colorLabel.stringValue];
    [self.tableView reloadData];
    
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return items_.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"row = %d", row);
    return [items_ objectAtIndex:row];
}

- (IBAction)clearItems:(id)sender {
    [items_ removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)popupSelected:(id)sender {
    sender = (NSPopUpButton *)sender;
    NSLog(@"popup! %d", [sender indexOfSelectedItem]);
}

- (void)pasteToClipBoard {
    NSLog(@"clicked: %ld, %@", self.tableView.clickedRow, [items_ objectAtIndex:self.tableView.clickedRow]);
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pb setString:[items_ objectAtIndex:self.tableView.clickedRow] forType:NSStringPboardType];
}

- (void)setColorFormatIndex:(NSInteger)index {
    NSLog(@"set colorIndex");
    colorFormatIndex = index;
}

- (NSInteger)colorFormatIndex {
    NSLog(@"get colorIndex");
    return colorFormatIndex;
}

@end
