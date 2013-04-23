//
//  EmojiKeyBoardViewController.m
//  EmojiKeyBoard
//
//  Created by Ayush on 17/04/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardViewController.h"

@interface Sample : UIViewController
@property (nonatomic, retain) UILabel *label;
@end
@implementation Sample

- (id)init {
  self = [super init];
  if (self) {
    self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
    self.label.text = @"Text";
    self.label.textColor = [UIColor grayColor];
    [self.view addSubview:self.label];
  }
  return self;
}

@end

@interface EmojiKeyBoardViewController () <UIScrollViewDelegate>
@property (nonatomic, retain) NSMutableArray *viewControllers;
@end

@implementation EmojiKeyBoardViewController
@synthesize segmentsBar = segmentsBar_;
@synthesize pageControl = pageControl_;
@synthesize scrollView = scrollView_;
@synthesize takePhotoButton = takePhotoButton_;
@synthesize selectFromGalleryButton = selectFromGalleryButton_;
@synthesize doodleButton = doodleButton_;
@synthesize viewControllers = viewControllers_;

#define BUTTON_HEIGHT 80
#define BUTTON_TEXT_FONT @"Helvetica Neue"
#define BUTTON_TEXT_FONT_SIZE 12

- (UIButton *)buttonWithImage:(UIImage *)image title:(NSString *)title atPos:(NSUInteger)pos{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  CGFloat buttonWidth = self.view.frame.size.width / 3;
  button.frame = CGRectMake(buttonWidth * pos,
                            self.view.frame.size.height - BUTTON_HEIGHT,
                            buttonWidth,
                            BUTTON_HEIGHT);
  [button setBackgroundImage:[UIImage imageNamed:@"bg_bottom_button.png"] forState:UIControlStateNormal];
  [button setTitle:title forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont fontWithName:BUTTON_TEXT_FONT size:BUTTON_TEXT_FONT_SIZE];
  button.titleLabel.textColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.9 alpha:1.0];
  button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.15];

  [button setTitleColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
  [button setImage:image forState:UIControlStateNormal];

  [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
  [button setImageEdgeInsets:UIEdgeInsetsMake(2,
                                                         (buttonWidth - button.imageView.frame.size.width) / 2,
                                                         0,
                                                         0)];
  CGSize titleSize = [title sizeWithFont:button.titleLabel.font];
  [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.frame.size.height + 2,
                                                         ((buttonWidth - titleSize.width) / 2) - button.imageView.frame.size.width,
                                                         0,
                                                         0)];

  return button;
}

- (void)viewDidLoad
{
  NSLog(@"View loaded");
  self.view.backgroundColor = [UIColor whiteColor];
  [super viewDidLoad];

  NSArray *segmentElements = @[[UIImage imageNamed:@"recent_n.png"], [UIImage imageNamed:@"face_n.png"], [UIImage imageNamed:@"bell_n.png"], [UIImage imageNamed:@"flower_n.png"], [UIImage imageNamed:@"car_n.png"], [UIImage imageNamed:@"characters_n.png"]];
  self.segmentsBar = [[UISegmentedControl alloc] initWithItems:segmentElements];
  self.segmentsBar.frame = CGRectMake(0, 100, self.view.frame.size.width, self.segmentsBar.frame.size.height);
  [self.segmentsBar setDividerImage:[UIImage imageNamed:@"tab_bg.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  // fixme: when setting dividers, it places it on the current segment and the next one
  // this misaligns the image in the current as well as the next segment

//  [self.segmentsBar setDividerImage:[UIImage imageNamed:@"corner_left.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//  [self.segmentsBar setDividerImage:[UIImage imageNamed:@"corner_right.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

  self.segmentsBar.segmentedControlStyle = UISegmentedControlStyleBar;
  self.segmentsBar.tintColor = [UIColor whiteColor];
  [self.segmentsBar setBackgroundImage:[UIImage imageNamed:@"corner_left.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [self.segmentsBar setBackgroundImage:[UIImage imageNamed:@"tab_bg.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
  self.segmentsBar.selectedSegmentIndex = 0;

  [self.view addSubview:self.segmentsBar];

  NSUInteger numberOfPages = 10;

  self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)] autorelease];
  self.viewControllers = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < numberOfPages; i++)
  {
		[self.viewControllers addObject:[NSNull null]];
  }
  // a page is the width of the scroll view
  self.scrollView.pagingEnabled = YES;
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberOfPages, CGRectGetHeight(self.scrollView.frame));
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.scrollsToTop = NO;
  self.scrollView.delegate = self;

  [self loadScrollViewWithPage:0];
  [self loadScrollViewWithPage:1];
  [self.view addSubview:self.scrollView];

  self.pageControl = [[[DDPageControl alloc] init] autorelease];
  [self.pageControl setCenter:CGPointMake(self.view.center.x, 30)];
  [self.pageControl setNumberOfPages:10];
  [self.pageControl setCurrentPage:0];
  [self.pageControl setOnColor:[UIColor darkGrayColor]];
  [self.pageControl setOffColor:[UIColor lightGrayColor]];
  [self.pageControl setIndicatorDiameter: 4.8f];
  [self.pageControl setIndicatorSpace:11.0f];
  [self.pageControl setHidesForSinglePage:YES];
  [self.pageControl setDefersCurrentPageDisplay:YES];
  [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.pageControl];

  // Add buttons at bottom
  self.takePhotoButton = [self buttonWithImage:[UIImage imageNamed:@"capturephoto.png"] title:@"Take a Photo" atPos:0];
  self.selectFromGalleryButton = [self buttonWithImage:[UIImage imageNamed:@"choose_existing.png"] title:@"Choose Existing" atPos:1];
  self.doodleButton = [self buttonWithImage:[UIImage imageNamed:@"capturephoto.png"] title:@"Create Doodle" atPos:2];
  [self.view addSubview:self.takePhotoButton];
  [self.view addSubview:self.selectFromGalleryButton];
  [self.view addSubview:self.doodleButton];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pageControlTouched:(id)sender {
  NSLog(@"control touched");
  [self changePage];
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
  NSLog(@"load scroll view %d", page);

  //fixme: numberOfPages to be a property of viewController
  if (page >= 10) {
    return;
  }

  // replace the placeholder if necessary
  Sample *controller = [self.viewControllers objectAtIndex:page];
  if ((NSNull *)controller == [NSNull null])
  {
    controller = [[Sample alloc] init];
    [self.viewControllers replaceObjectAtIndex:page withObject:controller];
  }

  // add the controller's view to the scroll view
  if (controller.view.superview == nil)
  {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * page;
    frame.origin.y = 0;
    controller.view.frame = frame;

    [self addChildViewController:controller];
    [self.scrollView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  NSLog(@"decelarating");

  // switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
  NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  self.pageControl.currentPage = page;
  [self changePage];
}

- (void)changePage {
  [self.pageControl updateCurrentPageDisplay];
  [self gotoPage:YES];
}

- (void)gotoPage:(BOOL)animated
{
  NSLog(@"goto");

  NSInteger page = self.pageControl.currentPage;

  // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];

	// update the scroll view to the appropriate page
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * page;
  bounds.origin.y = 0;
  [self.scrollView scrollRectToVisible:bounds animated:animated];
}

@end
