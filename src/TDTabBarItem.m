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

#import <TDAppKit/TDTabBarItem.h>
#import "TDTabBarItemButton.h"

@interface TDTabBarItem ()
@property (nonatomic, retain) NSButton *button;
@end

@implementation TDTabBarItem

- (id)initWithTabBarSystemItem:(TDTabBarSystemItem)systemItem tag:(NSInteger)aTag {
    NSString *aTitle = nil;
    NSString *imgPath = nil;
    NSString *imgHiPath = nil;
    
    NSBundle *b = [NSBundle bundleForClass:[TDTabBarItem class]];
    
    switch (systemItem) {
        case TDTabBarSystemItemMore:
            aTitle = NSLocalizedString(@"More", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_more.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_more_hi.png"];
            break;
        case TDTabBarSystemItemFavorites:
            aTitle = NSLocalizedString(@"Favorites", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_favorites.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_favorites_hi.png"];
            break;
        case TDTabBarSystemItemFeatured:
            aTitle = NSLocalizedString(@"Featured", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_featured.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_featured_hi.png"];
            break;
        case TDTabBarSystemItemTopRated:
            aTitle = NSLocalizedString(@"Top Rated", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_toprated.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_toprated_hi.png"];
            break;
        case TDTabBarSystemItemRecents:
            aTitle = NSLocalizedString(@"Recents", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_recents.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_recents_hi.png"];
            break;
        case TDTabBarSystemItemContacts:
            aTitle = NSLocalizedString(@"Contacts", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_contacts.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_contacts_hi.png"];
            break;
        case TDTabBarSystemItemHistory:
            aTitle = NSLocalizedString(@"History", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_history.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_history_hi.png"];
            break;
        case TDTabBarSystemItemBookmarks:
            aTitle = NSLocalizedString(@"Bookmarks", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_bookmarks.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_bookmarks_hi.png"];
            break;
        case TDTabBarSystemItemSearch:
            aTitle = NSLocalizedString(@"Search", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_search.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_search_hi.png"];
            break;
        case TDTabBarSystemItemDownloads:
            aTitle = NSLocalizedString(@"Downloads", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_downloads.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_downloads_hi.png"];
            break;
        case TDTabBarSystemItemMostRecent:
            aTitle = NSLocalizedString(@"Most Recent", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_mostrecent.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_mostrecent_hi.png"];
            break;
        case TDTabBarSystemItemMostViewed:
            aTitle = NSLocalizedString(@"Most Viewed", @"");
            imgPath = [b pathForImageResource:@"tabbar_system_item_mostviewed.png"];
            imgHiPath = [b pathForImageResource:@"tabbar_system_item_mostviewed_hi.png"];
            break;
        default:
            break;
    }
    
    NSImage *img = [[[NSImage alloc] initWithContentsOfFile:imgPath] autorelease];
    NSImage *imgHi = [[[NSImage alloc] initWithContentsOfFile:imgHiPath] autorelease];

    self = [self initWithTitle:aTitle image:img tag:aTag];
    [button setAlternateImage:imgHi];
    return self;
}



- (id)initWithTitle:(NSString *)aTitle image:(NSImage *)img tag:(NSInteger)aTag {
    if (self = [super init]) {
        self.button = [[[TDTabBarItemButton alloc] initWithFrame:NSZeroRect] autorelease];
        
        self.title = aTitle;
        self.image = img;
        self.tag = aTag;
    }
    return self;
}


- (void)dealloc {
    [button removeFromSuperview];
    self.button = nil;
    self.badgeValue = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabBarItem: %p '%@'>", self, [self title]];
}


- (void)setEnabled:(BOOL)yn {
    [super setEnabled:yn];
    [button setEnabled:yn];
}


- (id)target {
    return [button target];
}


- (void)setTarget:(id)t {
    [button setTarget:t];
}


- (SEL)action {
    return [button action];
}


- (void)setAction:(SEL)sel {
    [button setAction:sel];
}


- (void)setTitle:(NSString *)aTitle {
    [super setTitle:aTitle];
    [button setTitle:aTitle];
}


- (void)setImage:(NSImage *)img {
    [super setImage:img];
    [button setImage:img];
}


- (void)setTag:(NSInteger)aTag {
    [super setTag:aTag];
    [button setTag:aTag];
}

@synthesize button;
@synthesize badgeValue;
@end
