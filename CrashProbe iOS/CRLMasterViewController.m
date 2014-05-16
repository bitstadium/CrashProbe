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

#import "CRLMasterViewController.h"
#import "CRLDetailViewController.h"
#import <CrashLib/CrashLib.h>
#import <objc/runtime.h>

@interface CRLMasterViewController ()

@property(nonatomic,strong) NSDictionary *knownCrashes;

@end

@implementation CRLMasterViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
  
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
		categories[crash.category] = [(categories[crash.category] ?: @[]) arrayByAddingObject:crash];
	
	self.knownCrashes = categories.copy;
  
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return (NSInteger)self.knownCrashes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.sortedAllKeys[(NSUInteger)section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (NSInteger)((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"crash" forIndexPath:indexPath];
	CRLCrash *crash = (CRLCrash *)(((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)indexPath.section]])[(NSUInteger)indexPath.row]);
	
	cell.textLabel.text = crash.title;
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		CRLCrash *crash = (CRLCrash *)(((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)indexPath.section]])[(NSUInteger)indexPath.row]);
    
    ((CRLDetailViewController *)segue.destinationViewController).detailItem = crash;
  }
}

@end
