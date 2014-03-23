//
//  EmojiKeyBoardView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardView.h"
#import "EmojiPageView.h"
#import "DDPageControl.h"

#define BUTTON_WIDTH 45
#define BUTTON_HEIGHT 37

#define DEFAULT_SELECTED_SEGMENT 0
#define PAGE_CONTROL_INDICATOR_DIAMETER 6.0
#define RECENT_EMOJIS_MAINTAINED_COUNT 50

#define BACKGROUND_COLOR 0xECECEC

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";

@implementation UIColor (TDTAdditions)

+ (UIColor *)colorWithIntegerValue:(NSUInteger)value alpha:(CGFloat)alpha {
  NSUInteger mask = 255;
  NSUInteger blueValue = value & mask;
  value >>= 8;
  NSUInteger greenValue = value & mask;
  value >>= 8;
  NSUInteger redValue = value & mask;
  return [UIColor colorWithRed:(CGFloat)(redValue / 255.0) green:(CGFloat)(greenValue / 255.0) blue:(CGFloat)(blueValue / 255.0) alpha:alpha];
}

@end


@interface EmojiKeyBoardView () <UIScrollViewDelegate, EmojiPageViewDelegate>

@property (nonatomic, retain) UISegmentedControl *segmentsBar;
@property (nonatomic, retain) DDPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) NSString *category;

@end

@implementation EmojiKeyBoardView
@synthesize delegate = delegate_;
@synthesize segmentsBar = segmentsBar_;
@synthesize pageControl = pageControl_;
@synthesize scrollView = scrollView_;
@synthesize emojis = emojis_;
@synthesize pageViews = pageViews_;
@synthesize category = category_;

- (NSDictionary *)emojis {
  if (!emojis_) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis_ = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    NSLog(@"File read");
  }
  return emojis_;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  return categoryList[index];
}

// recent emojis are backed in NSUserDefaults to save them across app restarts.
- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [[emojis mutableCopy] autorelease];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  // remove emojis if they cross the cache maintained limit
  if ([recentEmojis count] > RECENT_EMOJIS_MAINTAINED_COUNT) {
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(RECENT_EMOJIS_MAINTAINED_COUNT, [recentEmojis count] - RECENT_EMOJIS_MAINTAINED_COUNT)];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // initialize category
    self.category = [self categoryNameAtIndex:DEFAULT_SELECTED_SEGMENT];

    self.backgroundColor = [UIColor colorWithIntegerValue:BACKGROUND_COLOR alpha:1.0];

    self.segmentsBar = [[[UISegmentedControl alloc] initWithItems:@[
                         [UIImage imageNamed:@"recent_n.png"],
                         [UIImage imageNamed:@"face_n.png"],
                         [UIImage imageNamed:@"bell_n.png"],
                         [UIImage imageNamed:@"flower_n.png"],
                         [UIImage imageNamed:@"car_n.png"],
                         [UIImage imageNamed:@"characters_n.png"]
                         ]] autorelease];
    self.segmentsBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.segmentsBar.bounds));
    self.segmentsBar.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.segmentsBar setDividerImage:[UIImage imageNamed:@"icons_bg_separator.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setDividerImage:[UIImage imageNamed:@"corner_left.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setDividerImage:[UIImage imageNamed:@"corner_right.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setBackgroundImage:[UIImage imageNamed:@"unselected_center_bg.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setBackgroundImage:[UIImage imageNamed:@"tab_bg.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    [self.segmentsBar addTarget:self action:@selector(categoryChangedViaSegmentsBar:) forControlEvents:UIControlEventValueChanged];
    [self setSelectedCategoryImageInSegmentControl:self.segmentsBar AtIndex:DEFAULT_SELECTED_SEGMENT];
    self.segmentsBar.selectedSegmentIndex = DEFAULT_SELECTED_SEGMENT;
    [self addSubview:self.segmentsBar];

    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.onColor = [UIColor darkGrayColor];
    self.pageControl.offColor = [UIColor lightGrayColor];
    self.pageControl.indicatorDiameter = PAGE_CONTROL_INDICATOR_DIAMETER;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
    self.pageControl.backgroundColor = [UIColor clearColor];
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                       CGRectGetHeight(self.bounds) - pageControlSize.height,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];

    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.segmentsBar.bounds),
                                                                      CGRectGetWidth(self.bounds),
                                                                      CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)] autorelease];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;

    [self addSubview:self.scrollView];
  }
  return self;
}

- (void)dealloc {
  self.pageControl = nil;
  self.scrollView = nil;
  self.segmentsBar = nil;
  self.category = nil;
  self.emojis = nil;
  [self purgePageViews];
  [super dealloc];
}

- (void)layoutSubviews {
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];

  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;

  // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                     CGRectGetHeight(self.bounds) - pageControlSize.height,
                                                     pageControlSize.width,
                                                     pageControlSize.height));

  self.scrollView.frame = CGRectMake(0,
                                     CGRectGetHeight(self.segmentsBar.bounds),
                                     CGRectGetWidth(self.bounds),
                                     CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark event handlers

- (void)setSelectedCategoryImageInSegmentControl:(UISegmentedControl *)segmentsBar AtIndex:(NSInteger)index {
  NSArray *imagesForSelectedSegments = @[[UIImage imageNamed:@"recent_s.png"],
                                         [UIImage imageNamed:@"face_s.png"],
                                         [UIImage imageNamed:@"bell_s.png"],
                                         [UIImage imageNamed:@"flower_s.png"],
                                         [UIImage imageNamed:@"car_s.png"],
                                         [UIImage imageNamed:@"characters_s.png"]];
  NSArray *imagesForNonSelectedSegments = @[[UIImage imageNamed:@"recent_n.png"],
                                            [UIImage imageNamed:@"face_n.png"],
                                            [UIImage imageNamed:@"bell_n.png"],
                                            [UIImage imageNamed:@"flower_n.png"],
                                            [UIImage imageNamed:@"car_n.png"],
                                            [UIImage imageNamed:@"characters_n.png"]];
  for (int i=0; i < self.segmentsBar.numberOfSegments; ++i) {
    [segmentsBar setImage:imagesForNonSelectedSegments[i] forSegmentAtIndex:i];
  }
  [segmentsBar setImage:imagesForSelectedSegments[index] forSegmentAtIndex:index];
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  // recalculate number of pages for new category and recreate emoji pages
  NSLog(@"%d", sender.selectedSegmentIndex);

  self.category = [self categoryNameAtIndex:sender.selectedSegmentIndex];
  [self setSelectedCategoryImageInSegmentControl:sender AtIndex:sender.selectedSegmentIndex];
  self.pageControl.currentPage = 0;
  // This triggers layoutSubviews
  // Choose a number that can never be equal to numberOfPages of pagecontrol else
  // layoutSubviews would not be called
  self.pageControl.numberOfPages = 100;
}

- (void)pageControlTouched:(DDPageControl *)sender {
  NSLog(@"%d", sender.currentPage);
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  // scrollViewDidScroll is called here. Page set at that time.
  [self.scrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (EmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

// Create a pageView and add it to the scroll view.
- (EmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
  EmojiPageView *pageView = [[[EmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))
                                                       buttonSize:CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT)
                                                             rows:rows
                                                          columns:columns] autorelease];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.scrollView addSubview:pageView];
  return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (EmojiPageView *)usableEmojiPageView {
  EmojiPageView *pageView = nil;
  for (EmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds);
    if (abs(pageNumber - self.pageControl.currentPage) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {

  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }

  EmojiPageView *pageView = [self usableEmojiPageView];

  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * (rows * columns - 1);
  NSUInteger endingIndex = (index + 1) * (rows * columns - 1);
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  NSLog(@"Setting page at index %d", index);
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (EmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / BUTTON_WIDTH);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / BUTTON_HEIGHT);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {

  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }

  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;

  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  NSLog(@"%d %d %d :: %d", numberOfRows, numberOfColumns, emojiCount, numberOfPages);
  return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)] autorelease];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");

  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

// add the emoji to recents
- (void)emojiPageView:(EmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(EmojiPageView *)emojiPageView {
  NSLog(@"Back button pressed");
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

@end
