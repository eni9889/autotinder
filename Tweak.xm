#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//Headers
@interface TNDRSlidingPagedViewController : UIViewController
@end

@interface TNDRRecommendationViewController : UIViewController
@end

@interface TNDRMatch : NSObject
-(NSSet *)messages;
@end

@interface TNDRMenuViewController : UIViewController
@property UITableView *tableView;
@end

@interface TNDRMenuCell : UITableViewCell
@property UIImageView *iconImageView;
@property UILabel *infoLabel;
@property UILabel *titleLabel;
@end;

@interface TNDRDataManager : NSObject
@end

//End Headers

@interface NSObject (Tinder)
-(void)sendMessage:(id)message completion:(id)completion;
-(id)recommendationsViewController;
-(id)menuViewController;
-(id)noRecommendationsView;
-(unsigned)numberOfCardsInStack;
-(id)changedMatchesFetchedResultsController;
-(id)fetchedObjects;
-(void)likeButtonTapped:(id)sender;
@end

@interface UIViewController (startTimer) 
@end

NSInteger numOfRows;
NSInteger autoLikeInterval = 2;

@implementation UIViewController (startTimer)

-(void)tapLikeButton:(id)sender {

	UIViewController *controller = [self recommendationsViewController];

	if([controller numberOfCardsInStack] > 0 &&  [(UISwitch *)[[controller view] viewWithTag:666678] isOn]) {
		[controller likeButtonTapped:nil];
	}

	[self startTimer];
}

-(void)startTimer {
	NSTimer *timer = [NSTimer 	scheduledTimerWithTimeInterval:autoLikeInterval 
    							target:self 
    							selector:@selector(tapLikeButton:)
                                userInfo:nil 
                                repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

@end

%hook TNDRSlidingPagedViewController
- (void)viewDidLoad {
	#ifdef DEBUG 
		%log; 
	#endif
	%orig;

	[[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self startTimer];
} 
%end

%hook TNDRRecommendationViewController

- (void)viewDidLoad {
	#ifdef DEBUG 
		%log; 
	#endif
	%orig;
	
    CGRect viewFrame = [((UIView *)[self view]) frame];    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,0,0)];
    mySwitch.frame = CGRectMake((viewFrame.size.width - mySwitch.frame.size.width)/2.0, (viewFrame.size.height - mySwitch.frame.size.height)/2.0 - 50.0f, mySwitch.frame.size.width, mySwitch.frame.size.height);
	mySwitch.tag = 666678;
	mySwitch.alpha = 0.3f;

    [mySwitch addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [(UIView*)[self view] addSubview:mySwitch];
}

%end

%hook TNDRMenuViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    numOfRows = %orig;
    numOfRows++;
    return numOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = %orig;
	return height - 13;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < numOfRows - 1) {
		%orig;
	} else {
	    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (TNDRMenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != numOfRows - 1) {
    	return %orig;
    } else {
    	NSIndexPath *indPth = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    	TNDRMenuCell *cell = %orig(tableView, indPth);
    	cell.iconImageView.image = nil;
    	UISegmentedControl *segCtrl = [[UISegmentedControl alloc] initWithItems:@[@"-", @"+"]];
    	segCtrl.tintColor = [UIColor lightGrayColor];
    	segCtrl.frame = CGRectMake(8, 12, 42, 20);
		[segCtrl addTarget:self action:@selector(segCtrlValueChanged:) forControlEvents:UIControlEventValueChanged];
    	[cell.contentView addSubview:segCtrl];

    	cell.infoLabel.text = [NSString stringWithFormat:@"%d", (int)autoLikeInterval];
    	cell.titleLabel.text = @"Auto-like interval";
        return cell;
    }
}

%new

-(void)segCtrlValueChanged:(UISegmentedControl *)sender {
    NSInteger decOrInc = sender.selectedSegmentIndex;
    sender.selectedSegmentIndex = -1;
    autoLikeInterval = decOrInc == 0 ? autoLikeInterval - 1 : autoLikeInterval + 1;
    if (autoLikeInterval < 1) {
    	autoLikeInterval = 1;
    }
    if (autoLikeInterval > 9) {
    	autoLikeInterval = 9;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numOfRows - 1 inSection:0];
	TNDRMenuCell *cell = (TNDRMenuCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.infoLabel setText:[NSString stringWithFormat:@"%d", autoLikeInterval]];
}

%end

// %hook TNDRDataManager
// -(void)updateMatches {
// 	#ifdef DEBUG 
// 		%log; 
// 	#endif
// 	%orig;

// 	NSArray *newMatches = (NSArray *)[[self changedMatchesFetchedResultsController] fetchedObjects];
// 	for (TNDRMatch *match in newMatches) {
// 		if (match.messages.count <= 0) {
// 			[match sendMessage:@"Hi, how's your day going?" completion:nil];
// 		}
// 	}
// }
// %end