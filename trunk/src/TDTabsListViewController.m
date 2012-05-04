//
//  TDTabsViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabsListViewController.h"
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabListItem.h>
#import <TDAppKit/TDUtils.h>
#import "TDTabListItemStyle.h"
#import "TDTabListItemStyleBrowser.h"
#import "TDTabListItemStylePage.h"

#define TAB_MODEL_KEY @"tabModel"
#define TAB_MODEL_INDEX_KEY @"tabModelIndex"
#define DOC_ID_KEY @"tabbedDocumentIdentifier"

#define ASPECT_RATIO 0.7

#define TDTabPboardType @"TDTabPboardType"

static NSDictionary *sClassNameForListItemStyleDict = nil;

@interface TDTabbedDocument ()
+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier;
@property (nonatomic, copy, readonly) NSString *identifier;
@end

@interface TDTabsListViewController ()
- (TDTabbedDocument *)document;


// remove????????????
- (void)updateAllTabModels;
- (void)updateAllTabModelsFromIndex:(NSUInteger)startIndex;
- (void)updateSelectedTabModel;
@property (nonatomic, retain) TDTabModel *draggingTabModel;
@end

@implementation TDTabsListViewController

+ (void)initialize {
    if (self == [TDTabsListViewController class]) {
        sClassNameForListItemStyleDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          NSStringFromClass([TDTabListItemStyleBrowser class]), @"browser",
                                          NSStringFromClass([TDTabListItemStylePage class]), @"page",
                                          nil];
    }
}

- (id)init {
    self = [super initWithNibName:@"TDTabsListView" bundle:[NSBundle bundleForClass:[self class]]];
    return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b{
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    self.scrollView = nil;
    self.listView = nil;
    self.draggingTabModel = nil;
    self.listItemStyle = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [self useStyleNamed:@"browser"];
    
    // setup ui
    listView.backgroundColor = [NSColor colorWithDeviceWhite:.92 alpha:1.0];
    listView.orientation = TDListViewOrientationLandscape;
    listView.displaysClippedItems = YES;

    // setup drag and drop
    [listView registerForDraggedTypes:[NSArray arrayWithObjects:TDTabPboardType, nil]];
    [listView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [listView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}


#pragma mark -
#pragma mark Actions

- (IBAction)closeTabButtonClick:(id)sender {
    [delegate tabsViewController:self didCloseTabModelAtIndex:[sender tag]];
    //[listView reloadData];
}


#pragma mark -
#pragma mark TDListViewDataSource

- (NSUInteger)numberOfItemsInListView:(TDListView *)lv {
    NSUInteger c = [delegate numberOfTabsInTabsViewController:self];
    return c;
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSUInteger)i {
    TDTabModel *tm = [delegate tabsViewController:self tabModelAtIndex:i];
    tm.index = i;
    
    TDTabListItem *listItem = (TDTabListItem *)[listView dequeueReusableItemWithIdentifier:[TDTabListItem reuseIdentifier]];
    
    if (!listItem) {
        listItem = [[[TDTabListItem alloc] init] autorelease];
    }
    
    listItem.tabModel = tm;
    listItem.tabsListViewController = self;
    
    [listItem setNeedsDisplay:YES];
    return listItem;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    NSSize scrollSize = [scrollView frame].size;
    
    if (listView.isPortrait) {
        return floor(scrollSize.width * ASPECT_RATIO);
    } else {
        return floor(scrollSize.height * 1 / ASPECT_RATIO);
    }
}


- (void)listView:(TDListView *)lv willDisplayView:(TDListItem *)itemView forItemAtIndex:(NSUInteger)i {
    
}


- (void)listView:(TDListView *)lv didSelectItemsAtIndexes:(NSIndexSet *)set {
    NSResponder *resp = [[lv window] firstResponder];
    if ([resp isKindOfClass:[NSTextView class]]) {
        [[lv window] makeFirstResponder:nil];
    }

    [delegate tabsViewController:self didSelectTabModelAtIndex:[set firstIndex]];
}


- (void)listViewEmptyAreaWasDoubleClicked:(TDListView *)lv {
    [delegate tabsViewControllerWantsNewTab:self];
}


- (NSMenu *)listView:(TDListView *)lv contextMenuForItemsAtIndexes:(NSIndexSet *)set {
    NSUInteger i = [set firstIndex];
    NSMenu *menu = [delegate tabsViewController:self contextMenuForTabModelAtIndex:i];
    return menu;
}


- (void)listView:(TDListView *)lv itemWasDoubleClickedAtIndex:(NSUInteger)i {
    if (!allowsTabTitleEditing) return;
    
    NSEvent *evt = [[lv window] currentEvent];
    NSPoint p = [evt locationInWindow];
    p = [lv convertPoint:p fromView:nil];
    
    TDTabListItem *li = (TDTabListItem *)[lv hitTest:p];

    p = [li convertPoint:p fromView:lv];
    NSRect r = [li titleRectForBounds:[li bounds]];
    
    if (NSPointInRect(p, r)) {
        r = [li convertRect:r toView:[self view]];
        [self beginEditingTabTitle:li atIndex:i inRect:r];
    }
}


#pragma mark -
#pragma mark TDListViewDelegate Drag

- (BOOL)listView:(TDListView *)lv canDragItemsAtIndexes:(NSIndexSet *)set withEvent:(NSEvent *)evt slideBack:(BOOL *)slideBack {
    *slideBack = YES;
    return YES;
}


- (BOOL)listView:(TDListView *)lv writeItemsAtIndexes:(NSIndexSet *)set toPasteboard:(NSPasteboard *)pboard {
    NSUInteger i = [set firstIndex];
    
    TDTabbedDocument *doc = [self document];
    self.draggingTabModel = [doc tabModelAtIndex:i];

    // declare
    [pboard declareTypes:[NSArray arrayWithObjects:TDTabPboardType, TDListItemPboardType, nil] owner:self];

    // write
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:draggingTabModel];
    NSDictionary *plist = [NSDictionary dictionaryWithObjectsAndKeys:
                           data, TAB_MODEL_KEY,
                           [NSNumber numberWithInteger:i], TAB_MODEL_INDEX_KEY,
                           doc.identifier, DOC_ID_KEY,
                           nil];
    [pboard setPropertyList:plist forType:TDTabPboardType];
    
    return YES;
}


#pragma mark -
#pragma mark TDListViewDelegate Drop

- (NSDragOperation)listView:(TDListView *)lv validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndex:(NSUInteger *)proposedDropIndex dropOperation:(TDListViewDropOperation *)proposedDropOperation {
    NSPasteboard *pboard = [draggingInfo draggingPasteboard];
    
    NSArray *types = [pboard types];
    
    NSDragOperation op = NSDragOperationNone;
    
    if ([types containsObject:TDTabPboardType]) {
        op = NSDragOperationMove;
    }

    return op;
}


- (BOOL)listView:(TDListView *)lv acceptDrop:(id <NSDraggingInfo>)draggingInfo index:(NSUInteger)newIndex dropOperation:(TDListViewDropOperation)dropOperation {
    NSPasteboard *pboard = [draggingInfo draggingPasteboard];
    
    TDTabbedDocument *newDoc = [self document];
    NSArray *types = [pboard types];

    if (![types containsObject:TDTabPboardType]) {
        return NO;
    }
        
    BOOL isLocal = (nil != draggingTabModel);

    NSDictionary *plist = [pboard propertyListForType:TDTabPboardType];
    
    TDTabbedDocument *oldDoc = nil;
    TDTabModel *tm = nil;
    NSUInteger oldIndex = NSNotFound;
    if (isLocal) {
        oldDoc = newDoc;
        tm = draggingTabModel;

        self.draggingTabModel = nil;

        oldIndex = [oldDoc indexOfTabModel:tm];
        NSAssert(NSNotFound != oldIndex, @"");
        if (isLocal && newIndex == oldIndex) { // same index. do nothing
            return YES;
        }
    } else {
        oldDoc = [TDTabbedDocument documentForIdentifier:[plist objectForKey:DOC_ID_KEY]];
        tm = [NSKeyedUnarchiver unarchiveObjectWithData:[plist objectForKey:TAB_MODEL_KEY]];
        oldIndex = [[plist objectForKey:TAB_MODEL_INDEX_KEY] unsignedIntegerValue];
    }
    
    [oldDoc removeTabModelAtIndex:oldIndex];
    [newDoc addTabModel:tm atIndex:newIndex];
    
    [self updateAllTabModelsFromIndex:newIndex];
    newDoc.selectedTabIndex = newIndex;
    
    return YES;
}


- (BOOL)listView:(TDListView *)lv shouldRunPoofAt:(NSPoint)endPointInScreen forRemovedItemsAtIndexes:(NSIndexSet *)set {
    return NO;
    
//    NSUInteger i = [set firstIndex];
//    
//    if (!draggingTabModel) {
//        return NO; // we dont yet support dragging tab thumbnails to a new window
//    }
//    
//    TDTabbedDocument *doc = [self document];
//    NSAssert(NSNotFound != i, @"");
//    NSAssert([set containsIndex:[doc indexOfTabModel:draggingTabModel]], @"");
//    
//    [doc removeTabModel:draggingTabModel];
//    self.draggingTabModel = nil;
//    
//    [self updateAllTabModelsFromIndex:i];
//    return YES;
}


#pragma mark -
#pragma mark Private

- (void)updateAllTabModels {
    [self updateAllTabModelsFromIndex:0];
}


- (void)updateAllTabModelsFromIndex:(NSUInteger)startIndex {
    NSParameterAssert(startIndex != NSNotFound);
    
//    NSArray *wvs = [self webViews];
//    NSUInteger webViewsCount = [wvs count];
//    NSUInteger lastWebViewIndex = webViewsCount - 1;
//    startIndex = startIndex > lastWebViewIndex ? lastWebViewIndex : startIndex; // make sure there's no exception here
//    
//    NSMutableArray *newModels = [NSMutableArray arrayWithCapacity:webViewsCount];
//    if (startIndex > 0 && tabModels) {
//        [newModels addObjectsFromArray:[tabModels subarrayWithRange:NSMakeRange(0, startIndex)]];
//    }
//    
//    NSInteger newModelsCount = [newModels count];
//    NSInteger i = startIndex;   
//    for (i >= 0; i < webViewsCount; i++) {
//        WebView *wv = [wvs objectAtIndex:i];
//        FUTabModel *model = [[[FUTabModel alloc] init] autorelease];
//        [self updateTabModel:model fromWebView:wv atIndex:i];
//        if (i < newModelsCount) {
//            [newModels replaceObjectAtIndex:i withObject:model];
//        } else {
//            [newModels addObject:model];
//        }
//    }
//    
//    self.tabModels = newModels;
//    
//    FUWindowController *wc = [self windowController];
//    for (FUTabController *tc in [wc tabControllers]) {
//        [self startObserveringTabController:tc];
//    }
//    
//    [self updateSelectedTabModel];
    
    [listView reloadData];
}


- (void)updateSelectedTabModel {
//    NSUInteger selectedIndex = [[self document] selectedTabIndex];
//    
//    if (selectedModel) {
//        selectedModel.selected = NO;
//    }
//    
//    if (selectedIndex >= 0 && selectedIndex < [tabModels count]) {
//        self.selectedModel = [tabModels objectAtIndex:selectedIndex];
//        selectedModel.selected = YES;
//        
//        listView.selectionIndexes = [NSIndexSet indexSetWithIndex:selectedIndex];
//    }
}


- (void)beginEditingTabTitle:(TDTabListItem *)li atIndex:(NSUInteger)i inRect:(NSRect)titleRect {    
    editingIndex = i;
    
    TDTabModel *tm = [delegate tabsViewController:self tabModelAtIndex:i];
    
    NSString *str = [tm.title stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    str = str ? str : @"";
    
    NSWindow *win = [li window];
    titleRect = TDNSRectOutset(titleRect, 2.0, 2.0);
    NSTextField *fieldEditor = [[[NSTextField alloc] initWithFrame:titleRect] autorelease];
    
    Class cls = NSClassFromString([sClassNameForListItemStyleDict objectForKey:self.listItemStyle]);
    [fieldEditor setFont:[cls titleFont]];
    [fieldEditor setAlignment:NSLeftTextAlignment];
    [fieldEditor setDrawsBackground:YES];
    [fieldEditor setBackgroundColor:[NSColor whiteColor]];
    [fieldEditor setStringValue:str];
    [fieldEditor setDelegate:self];
    
    [fieldEditor setNeedsDisplay:YES];
    
//    tm.title = nil;
    
    [[self view] addSubview:fieldEditor];
    [listView reloadData];
    
    [win makeFirstResponder:fieldEditor];

    [self tryInvalidateRestorableState];
}


- (void)tryInvalidateRestorableState {
    if ([self respondsToSelector:@selector(invalidateRestorableState)]) {
        [self invalidateRestorableState];
    }
}


//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
//    [super encodeRestorableStateWithCoder:coder];
//    
//    BOOL isEditingText = NO;
//    if (1 == [objs count]) {
//        isEditingText = [[objs objectAtIndex:0] isEditingText];
//    }
//    [coder encodeBool:isEditingText forKey:@"JotTabViewControllerIsEditingText"];
//    [coder encodeInteger:editingIndex forKey:@"JotTabViewControllerEditingIndex"];
//}
//
//
//- (void)restoreStateWithCoder:(NSCoder *)coder {
//    [super restoreStateWithCoder:coder];
//    
//    BOOL isEditingText = [coder decodeBoolForKey:@"JotSelectedObjectIsEditingText"];
//    editingIndex = [coder decodeIntegerForKey:@"JotSelectedObjectEditingIndex"];
//    
//}


#pragma mark -
#pragma mark NSTextDelegate

- (void)controlTextDidEndEditing:(NSNotification *)n {
    NSTextField *fieldEditor = [n object];
    
    TDTabModel *tm = [delegate tabsViewController:self tabModelAtIndex:editingIndex];

//	NSUndoManager *mgr = [[self.view window] undoManager];
//	[[mgr prepareWithInvocationTarget:tm] setTitle:tm.title];
//	[mgr setActionName:NSLocalizedString(@"Change Page Title", @"")];

    tm.title = [fieldEditor stringValue];
    
    [fieldEditor removeFromSuperview];
    [[listView window] endEditingFor:listView];
    [self tryInvalidateRestorableState];
}


#pragma mark -
#pragma mark Properties

- (TDTabbedDocument *)document {
    return [[[self.view window] windowController] document];
}


- (void)useStyleNamed:(NSString *)styleName {
    Class cls = NSClassFromString([sClassNameForListItemStyleDict objectForKey:styleName]);
    self.listItemStyle = [[[cls alloc] init] autorelease];
}

@synthesize delegate;
@synthesize scrollView;
@synthesize listView;
@synthesize allowsTabTitleEditing;
@synthesize listItemStyle;
@synthesize draggingTabModel;
@end
