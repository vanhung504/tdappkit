//
//  TDViewControllerView.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/14/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDColorView.h>

@class TDViewController;

@interface TDViewControllerView : TDColorView {
    TDViewController *viewController;
}

@property (nonatomic, assign) TDViewController *viewController;
@end
