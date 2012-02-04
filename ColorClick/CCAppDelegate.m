//
//  CCAppDelegate.m
//  ColorClick
//
//  Created by Tatsuya Tobioka on 12/01/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCAppDelegate.h"

NSString * const CCColorFormatIndex = @"Color Format Index";

#define kCCColorFormatIndexHex 0
#define kCCColorFormatIndexDecimal 1

@interface CCAppDelegate()
- (void)globalMouseMoved:(NSEvent *)event;
- (void)globalMouseDown:(NSEvent *)event;
- (void)pasteToClipBoard;
@end

@implementation CCAppDelegate
@synthesize popUp;

@synthesize window = _window;
@synthesize imageView;
@synthesize colorLabel;
@synthesize colorBox;
@synthesize tableView;

+ (void)initialize {
    NSLog(@"initialize");
    
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithInt:kCCColorFormatIndexHex] forKey:CCColorFormatIndex];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    
}

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
    self.tableView.delegate = self;
    self.tableView.doubleAction = @selector(pasteToClipBoard);
    
    self.colorFormatIndex = 0;
    
    
    [self.popUp selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]];
    
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

    switch ([[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]) {
        case kCCColorFormatIndexHex:
            self.colorLabel.stringValue = [NSString stringWithFormat:@"#%x%x%x", r, g, b];
            break;
        case kCCColorFormatIndexDecimal:
            self.colorLabel.stringValue = [NSString stringWithFormat:@"rgb(%d, %d, %d)", r, g, b];
            break;            
        default:
            break;
    }
    
    
    self.colorBox.fillColor = [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];

    currentRed_ = r;
    currentGreen_ = g;
    currentBlue_ = b;
    
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
    
    NSString *hex = [NSString stringWithFormat:@"#%x%x%x", currentRed_, currentGreen_, currentBlue_];
    NSString *decimal = [NSString stringWithFormat:@"rgb(%d, %d, %d)", currentRed_, currentGreen_, currentBlue_];

    NSColor *color = [NSColor colorWithDeviceRed:currentRed_/255.0 green:currentGreen_/255.0 blue:currentBlue_/255.0 alpha:1.0];
    
//    NSMutableArray *item = [NSMutableArray array];
//    [item insertObject:hex atIndex:kCCColorFormatIndexHex];
//    [item insertObject:decimal atIndex:kCCColorFormatIndexDecimal];
    NSArray *item = [NSArray arrayWithObjects:hex, decimal, color, nil];
    
    [items_ addObject:item];
    
//    [items_ addObject:self.colorLabel.stringValue];
    [self.tableView reloadData];
    
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return items_.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"row = %d", row);
    
    NSLog(@"colorIndex = %d", [[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]);
//    return [items_ objectAtIndex:row];
//    return [[items_ objectAtIndex:row] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]];

    // default is null
    NSLog(@"tableColumn = %@", [tableColumn identifier]);

    switch ([tableColumn.identifier intValue]) {
        case 0:
            return @"";
            break;
            
        case 1:
            return [[items_ objectAtIndex:row] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]];
            break;

        default:
            break;
    }

}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"0"]) {
        NSLog(@"class %@, color %@", [cell class], [[items_ objectAtIndex:row] lastObject]);
        [cell setBackgroundColor:[[items_ objectAtIndex:row] lastObject]];
    }
}

- (IBAction)clearItems:(id)sender {
    [items_ removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)popupSelected:(id)sender {
    sender = (NSPopUpButton *)sender;
    NSLog(@"popup! %d", [sender indexOfSelectedItem]);
    [[NSUserDefaults standardUserDefaults] setInteger:[sender indexOfSelectedItem] forKey:CCColorFormatIndex];
    [self.tableView reloadData];
}

- (void)pasteToClipBoard {
    NSLog(@"clicked: %ld, %@", self.tableView.clickedRow, [[items_ objectAtIndex:self.tableView.clickedRow]  objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]]);
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pb setString:[[items_ objectAtIndex:self.tableView.clickedRow]  objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:CCColorFormatIndex]] forType:NSStringPboardType];
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
