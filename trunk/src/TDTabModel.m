//
//  TDTabModel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabViewController.h>
#import <TDAppKit/TDUtils.h>

@interface TDTabModel ()

@end

@implementation TDTabModel

+ (TDTabModel *)tabModelFromPlist:(NSDictionary *)plist {
    TDTabModel *m = [[[self alloc] init] autorelease];
    m.index = [[plist objectForKey:@"index"] integerValue];
    m.selected = [[plist objectForKey:@"selected"] boolValue];
    return m;
}


- (id)init {
    if (self = [super init]) {
        changeCount = 0;
    }
    return self;
}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    self.representedObject = nil;
    self.document = nil;
    self.tabViewController = nil;
    self.image = nil;
    self.scaledImage = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabModel %p %@>", self, self.title];
}


- (BOOL)isDocumentEdited {
    NSAssert(!TDIsLionOrLater(), @"");
    NSAssert(changeCount != NSNotFound, @"invalid changeCount");
    //NSLog(@"%d", changeCount);
    BOOL yn = changeCount != 0;
    [[[[document windowControllers] objectAtIndex:0] window] setDocumentEdited:yn];
    return yn;
}


- (void)updateChangeCount:(NSDocumentChangeType)type {
    NSAssert(!TDIsLionOrLater(), @"");
    NSAssert(changeCount != NSNotFound, @"invalid changeCount");

    switch (type) {
        case NSChangeDone:
            changeCount++;
            break;
        case NSChangeUndone:
            changeCount--;
            break;
        case NSChangeRedone:
            changeCount++;
            break;
        case NSChangeCleared:
            changeCount = 0;
            break;
        case NSChangeReadOtherContents:
            break;
        case NSChangeAutosaved:
            break;
        default:
            NSAssert(0, @"unknown changeType");
            break;
    }

    NSAssert(changeCount != NSNotFound, @"invalid changeCount");
}


- (NSDictionary *)plist {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
    [d setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [d setObject:[NSNumber numberWithInteger:selected] forKey:@"selected"];
    return d;
}


- (BOOL)wantsNewImage {
    if (needsNewImage || !image) {
        needsNewImage = NO;
        return YES;
    }

    return NO;
}


- (void)setNeedsNewImage:(BOOL)yn {
    needsNewImage = yn;
}


- (NSString *)title {
    return [representedObject valueForKey:@"title"];
}


- (void)setTitle:(NSString *)title {
    [self willChangeValueForKey:@"title"];
    [representedObject setValue:[[title copy] autorelease] forKey:@"title"];
    [self didChangeValueForKey:@"title"];
}

@synthesize representedObject;
@synthesize document;
@synthesize tabViewController;
@synthesize image;
@synthesize scaledImage;
@synthesize index;
@synthesize selected;
@synthesize busy;
@end
