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

#import "CRLCrashListViewController.h"
#import <CrashLib/CrashLib.h>
#import <objc/runtime.h>

@interface CRLCrashListViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property(nonatomic,readonly) NSOutlineView *outlineView;
@property(nonatomic,strong) NSDictionary *knownCrashes;

@end

@implementation CRLCrashListViewController

#if __i386__ && !TARGET_IPHONE_SIMULATOR
@synthesize knownCrashes = _knownCrashes, outlineView = _outlineView, delegate = _delegate;
#endif

- (id)initWithOutlineView:(NSOutlineView *)view
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		[self pokeAllCrashes];
		
    NSMutableArray *crashes = [NSMutableArray arrayWithArray:[CRLCrash allCrashes]];
    [crashes sortUsingComparator:^NSComparisonResult(CRLCrash *obj1, CRLCrash *obj2) {
      if ([obj1.category isEqualToString:obj2.category]) {
        return [obj1.title compare:obj2.title];
      } else {
        return [obj1.category compare:obj2.category];
      }
    }];
		NSMutableDictionary *categories = @{}.mutableCopy;
		
		for (CRLCrash *crash in crashes)
#if __i386__ && !TARGET_IPHONE_SIMULATOR
			[categories setObject:[([categories objectForKey:crash.category] ?: @[]) arrayByAddingObject:crash] forKey:crash.category];
#else
			categories[crash.category] = [(categories[crash.category] ?: @[]) arrayByAddingObject:crash];
#endif

		self.knownCrashes = categories.copy;

		self.view = view;
		self.outlineView.dataSource = self;
		self.outlineView.delegate = self;
	}
	return self;
}

- (void)pokeAllCrashes
{
	unsigned int nclasses = 0;
	Class *classes = objc_copyClassList(&nclasses);
	
	for (unsigned int i = 0; i < nclasses; ++i) {
		if (classes[i] &&
			class_getSuperclass(classes[i]) == [CRLCrash class] &&
			class_respondsToSelector(classes[i], @selector(methodSignatureForSelector:)) &&
			classes[i] != [CRLCrash class])
		{
			[CRLCrash registerCrash:[[classes[i] alloc] init]];
		}
	}
	free(classes);
}

- (NSArray *)sortedAllKeys {
  NSMutableArray *result = [NSMutableArray arrayWithArray:self.knownCrashes.allKeys];
  
  [result sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
    return [obj1 compare:obj2];
  }];
  
  return [result copy];
}

- (NSOutlineView *)outlineView
{
	return (NSOutlineView *)self.view;
}

- (void)loadView
{
	NSAssert([self.view isKindOfClass:[NSOutlineView class]], @"Is an outline view");

	[self.outlineView expandItem:nil expandChildren:YES];
	dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ {
		[self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	});
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		return (NSInteger)self.knownCrashes.count;
	else if ([item isKindOfClass:[NSString class]])
#if __i386__ && !TARGET_IPHONE_SIMULATOR
		return (NSInteger)((NSArray *)[self.knownCrashes objectForKey:item]).count;
#else
		return (NSInteger)((NSArray *)self.knownCrashes[item]).count;
#endif
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item == nil)
#if __i386__ && !TARGET_IPHONE_SIMULATOR
		return [self.sortedAllKeys objectAtIndex:(NSUInteger)index];
#else
		return self.sortedAllKeys[(NSUInteger)index];
#endif
	else
#if __i386__ && !TARGET_IPHONE_SIMULATOR
		return [[self.knownCrashes objectForKey:item] objectAtIndex:(NSUInteger)index];
#else
		return self.knownCrashes[item][(NSUInteger)index];
#endif
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [item isKindOfClass:[NSString class]];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if ([item isKindOfClass:[NSString class]])
	{
		NSTableCellView *view = [outlineView makeViewWithIdentifier:@"header" owner:self];
		
		view.textField.stringValue = item;
//		view.textField.textColor = [NSColor redColor];
		return view;
	}
	else if ([item isKindOfClass:[CRLCrash class]])
	{
		NSTableCellView *view = [outlineView makeViewWithIdentifier:@"crash" owner:self];
		
		view.textField.stringValue = ((CRLCrash *)item).title;
		view.textField.textColor = [NSColor blackColor];
		return view;
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return [item isKindOfClass:[NSString class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return [item isKindOfClass:[CRLCrash class]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	typeof(self.delegate) s_delegate = self.delegate;

	[s_delegate controller:self didSelectCrash:[self.outlineView itemAtRow:self.outlineView.selectedRow]];
}

- (CRLCrash *)selectedCrash
{
	id selectedItem = [self.outlineView itemAtRow:self.outlineView.selectedRow];
	
	return [selectedItem isKindOfClass:[CRLCrash class]] ? selectedItem : nil;
}

@end
