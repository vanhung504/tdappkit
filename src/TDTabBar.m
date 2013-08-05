//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <TDAppKit/TDTabBar.h>
#import <TDAppKit/TDTabBarItem.h>

#define TABBAR_HEIGHT 44.0
#define TABBAR_ITEM_MARGIN_X 1.5

@interface TDTabBarItem ()
@property (nonatomic, retain) NSButton *button;
@end

@implementation TDTabBar

+ (CGFloat)defaultHeight {
    return TABBAR_HEIGHT;
}


- (id)initWithFrame:(NSRect)r {
    if (self = [super initWithFrame:r]) {

    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (void)layoutSubviews {
//    CGRect bounds = [self bounds];
//    
//    NSArray *tabBarItems = [self subviews];
//    NSInteger c = [[self subviews] count];
//    
//    if (c > 0) {
//        NSInteger i = 0;
//        CGFloat x = TABBAR_ITEM_MARGIN_X;
//        CGFloat totalWidth = NSWidth(bounds) - (TABBAR_ITEM_MARGIN_X * 2);
//        CGFloat w = totalWidth / c;
//        CGFloat h = NSHeight(bounds);
//        for (TDTabBarItem *item in tabBarItems) {
////            if (selectedIndex == i) {
////                [self highlightButtonAtIndex:i];
////            }
//            i++;
//            //[item.button setFrame:NSMakeRect(x, 0, w, h)];
//            x += w;
//        }
//    }
}




- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    [[NSColor redColor] setFill];
    NSRectFill(bounds);
}


@end
