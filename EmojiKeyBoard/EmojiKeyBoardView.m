//
//  EmojiKeyBoardView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardView.h"
#import "EmojiPageView.h"

#define BUTTON_WIDTH 35
#define BUTTON_HEIGHT 35

#define PAGE_CACHE_SIZE 3
#define DEFAULT_SELECTED_SEGMENT 1
#define PAGE_CONTROL_INDICATOR_DIAMETER 6.0
#define RECENT_EMOJIS_MAINTAINED_COUNT 50

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface EmojiKeyBoardView () <UIScrollViewDelegate, EmojiPageViewDelegate>

@property (nonatomic, retain) UISegmentedControl *segmentsBar;
@property (nonatomic, retain) DDPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) NSString *category;
@end

@implementation EmojiKeyBoardView
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

- (NSMutableArray *)recentEmojis {
  NSLog(@"Readeing recent emojis");
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  NSLog(@"Setting recent emojis");
  if ([recentEmojis count] > RECENT_EMOJIS_MAINTAINED_COUNT) {
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(RECENT_EMOJIS_MAINTAINED_COUNT, [recentEmojis count] - RECENT_EMOJIS_MAINTAINED_COUNT)];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    NSLog(@"Initializing");
    // initialize category
    self.category = @"People";

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
    self.segmentsBar.tintColor = [UIColor whiteColor];
    self.segmentsBar.selectedSegmentIndex = DEFAULT_SELECTED_SEGMENT;
    [self.segmentsBar addTarget:self action:@selector(categoryChangedViaSegmentsBar:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.segmentsBar];

    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.onColor = [UIColor darkGrayColor];
    self.pageControl.offColor = [UIColor lightGrayColor];
    self.pageControl.indicatorDiameter = PAGE_CONTROL_INDICATOR_DIAMETER;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
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

- (void)layoutSubviews {
  NSLog(@"Layout subviews called");
  
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
  [self createPagesWithNumberOfPages:numberOfPages setCurrentPage:currentPage];
}

- (void)createPagesWithNumberOfPages:(NSUInteger)numberOfPages setCurrentPage:(NSInteger)currentPage {
  NSLog(@"Creating pages..");
  
  self.pageViews = nil;
  self.pageViews = [[[NSMutableArray alloc] initWithCapacity:PAGE_CACHE_SIZE] autorelease];
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
  [self setPage:currentPage];
}

- (EmojiPageView *)createPage {
  NSLog(@"Created a page");

  NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
  EmojiPageView *pageView = [[[EmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))
                                                       buttonSize:CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT)
                                                          columns:columns
                                                             rows:rows] autorelease];
  pageView.isBeingUsed = NO;
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.scrollView addSubview:pageView];
  return pageView;
}

#pragma mark event handlers

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  // recalculate number of pages for new category and recreate emoji pages
  NSLog(@"Category changed %d", sender.selectedSegmentIndex);
  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  self.category = categoryList[sender.selectedSegmentIndex];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category inFrameSize:self.scrollView.bounds.size];
  self.pageControl.currentPage = 0;
  self.pageControl.numberOfPages = numberOfPages;
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.scrollView.contentOffset = CGPointMake(0, 0);
  [self createPagesWithNumberOfPages:numberOfPages setCurrentPage:0];
}

- (void)pageControlTouched:(DDPageControl *)sender {
  NSLog(@"Pagecontrol touched %d", sender.currentPage);
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  // scrollViewDidScroll is called here. Page set at that time.
  // fixme: the currentpage is determined by the page control. When page is changed
  // via pagecontrol, the current page changes first, and thus scroll view sets and resets pages twice.
  // * pagecontrol page changed to p+1
  // * scrollViewDidScroll checks that page hasn't scrolled and is at p
  // * it sets pagecontrol back to p, tries to set pages for p which are already there.
  // * scroll view is still scrolling, and once it's contentOffset crosses half of pageWidth, new page number is set and pages set.
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

- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  NSLog(@"checking requirement to generate pageview at index %d", index);

  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (EmojiPageView *page in self.pageViews) {
    if ((page.isBeingUsed == YES) &&
        (page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

- (EmojiPageView *)availablePageViewInScrollView:(UIScrollView *)scrollView {
  NSLog(@"seeing a pageview to return");

  EmojiPageView *pageView = nil;
  for (EmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(scrollView.bounds);
    if ((abs(pageNumber - self.pageControl.currentPage) > 1) ||
        (page.isBeingUsed == NO)) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self createPage];
  }
  return pageView;
}

- (void)setPageViewForScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {

  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }

  EmojiPageView *pageView = [self availablePageViewInScrollView:scrollView];

  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * rows * columns;
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:(startingIndex + rows * columns)];
  NSLog(@"Setting buttontexts on page at index %d", index);
  [pageView setButtonTexts:buttonTexts];
  pageView.isBeingUsed = YES;
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

- (void)setPage:(NSInteger)page {
  NSLog(@"trying to set page at index %d", page);

  [self setPageViewForScrollView:self.scrollView atIndex:page - 1];
  [self setPageViewForScrollView:self.scrollView atIndex:page];
  [self setPageViewForScrollView:self.scrollView atIndex:page + 1];
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / BUTTON_WIDTH);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / BUTTON_HEIGHT);
}

- (NSArray *)emojisForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {

  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }

  NSUInteger emojiCount = [[self emojisForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns);

  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  NSLog(@"%d %d %d :: %d", numberOfRows, numberOfColumns, emojiCount, numberOfPages);
  return numberOfPages;
}

- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSLog(@"getting emoji texts for category %@", category);

  NSArray *emojis = [self emojisForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)] autorelease];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)emojiPageView:(EmojiPageView *)emojiPageView emojiUsed:(NSString *)emoji {
  NSLog(@"Emoji used %@", emoji);
  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
      [recentEmojis insertObject:emoji atIndex:0];
      [self setRecentEmojis:recentEmojis];
      return;
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

@end
