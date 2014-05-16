/*
 * Copyright (c) 2014 HockeyApp, Bit Stadium GmbH.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CRLMainWindowController.h"
#import "CRLCrashListViewController.h"
#import <CrashLib/CrashLib.h>

@interface CRLMainWindowController () <CRLCrashListViewControllerDelegate>

@property(nonatomic,strong) IBOutlet NSOutlineView *crashList;
@property(nonatomic,strong) IBOutlet NSSplitView *splitView;
@property(nonatomic,strong) IBOutlet NSTextField *titleText;
@property(nonatomic,strong) IBOutlet NSTextField *detailText;
@property(nonatomic,strong) IBOutlet NSImageView *detailImage;
@property(nonatomic,strong) IBOutlet NSButton *crashButton;
@property(nonatomic,strong) CRLCrashListViewController *listController;

@end

@implementation CRLMainWindowController

#if __i386__
@synthesize crashList = _crashList, crashButton = _crashButton, listController = _listController,
			splitView = _splitView, titleText = _titleText, detailText = _detailText, detailImage = _detailImage;
#endif

- (id)init
{
	return [super initWithWindowNibName:@"CRLMainWindow"];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
#if __i386__ && !TARGET_IPHONE_SIMULATOR
	self.listController = [[[CRLCrashListViewController alloc] initWithOutlineView:self.crashList] autorelease];
#else
	self.listController = [[CRLCrashListViewController alloc] initWithOutlineView:self.crashList];
#endif
	self.listController.delegate = self;
	[self.listController loadView];
	self.crashButton.target = self;
	self.crashButton.action = @selector(causeCrash:);
	[self controller:self.listController didSelectCrash:nil];
}

- (void)causeCrash:(id)sender
{
	[self.listController.selectedCrash crash];
}

- (void)controller:(CRLCrashListViewController *)controller didSelectCrash:(CRLCrash *)crash
{
	self.titleText.stringValue = crash.title ?: @"";
	self.detailText.stringValue = crash.desc ?: @"";
//	self.detailImage.image = crash.animation;
}

@end
