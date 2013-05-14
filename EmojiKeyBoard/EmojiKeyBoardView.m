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

@interface EmojiKeyBoardView () <UIScrollViewDelegate>

@property (nonatomic, retain) UISegmentedControl *segmentsBar;
@property (nonatomic, retain) DDPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic, retain) NSMutableArray *pageViews;

@end

@implementation EmojiKeyBoardView
@synthesize segmentsBar = segmentsBar_;
@synthesize pageControl = pageControl_;
@synthesize scrollView = scrollView_;
@synthesize emojis = emojis_;
@synthesize pageViews = pageViews_;

- (NSDictionary *)emojis {
  if (!emojis_) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis_ = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    NSLog(@"File read");
  }
  return emojis_;
}

- (void)setPageViewForScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {

  if (index >= self.pageControl.numberOfPages) {
    return;
  }
  for (EmojiPageView *page in self.pageViews) {
    if (((page.frame.origin.x / CGRectGetWidth(scrollView.frame)) == index) && (index != 0)) {
      return;
    }
  }
  EmojiPageView *pageView = nil;
  for (EmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(scrollView.frame);
    if (abs(pageNumber - self.pageControl.currentPage) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self.pageViews objectAtIndex:index % 3];
  }

  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.frame.size];
  NSUInteger columns = [self numberOfButtonsInARowForFrameSize:scrollView.frame.size];
  NSUInteger startingIndex = index * rows * columns;
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:@"Nature" fromIndex:startingIndex toIndex:startingIndex + rows * columns];
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.frame), 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
}

- (void)setPage:(NSInteger)page {
  [self setPageViewForScrollView:self.scrollView atIndex:page - 1];
  [self setPageViewForScrollView:self.scrollView atIndex:page];
  [self setPageViewForScrollView:self.scrollView atIndex:page + 1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  NSInteger newPageNumber = scrollView.bounds.origin.x / CGRectGetWidth(scrollView.frame);
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.segmentsBar = [[[UISegmentedControl alloc] initWithItems:@[
                         [UIImage imageNamed:@"recent_n.png"],
                         [UIImage imageNamed:@"face_n.png"],
                         [UIImage imageNamed:@"bell_n.png"],
                         [UIImage imageNamed:@"flower_n.png"],
                         [UIImage imageNamed:@"car_n.png"],
                         [UIImage imageNamed:@"characters_n.png"]
                         ]] autorelease];
    self.segmentsBar.frame = CGRectMake(0, 0, self.frame.size.width, self.segmentsBar.frame.size.height);
    self.segmentsBar.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segmentsBar.tintColor = [UIColor whiteColor];
    [self.segmentsBar addTarget:self action:@selector(categoryChangedViaSegmentsBar:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.segmentsBar];

    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.onColor = [UIColor darkGrayColor];
    self.pageControl.offColor = [UIColor lightGrayColor];
    self.pageControl.indicatorDiameter = 6.0f;
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    self.pageControl.frame = CGRectMake((self.frame.size.width - pageControlSize.width) / 2,
                                        self.frame.size.height - pageControlSize.height,
                                        pageControlSize.width,
                                        pageControlSize.height);
    [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];

    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.segmentsBar.frame),
                                                                      CGRectGetWidth(self.frame),
                                                                      CGRectGetHeight(self.frame) - CGRectGetHeight(self.segmentsBar.frame) - pageControlSize.height)] autorelease];

    NSUInteger numberOfPages = [self numberOfPagesForCategory:@"Nature" inFrame:self.scrollView.frame.size];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    self.pageControl.frame = CGRectMake((self.frame.size.width - pageControlSize.width) / 2,
                                        self.frame.size.height - pageControlSize.height,
                                        pageControlSize.width,
                                        pageControlSize.height);

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberOfPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;

    NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.frame.size];
    NSUInteger columns = [self numberOfButtonsInARowForFrameSize:self.scrollView.frame.size];

    self.pageViews = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i=0; i<3; ++i) {
      EmojiPageView *pageView = [[[EmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))
                                                           buttonSize:CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT)
                                                              columns:columns
                                                                 rows:rows] autorelease];
      [self.pageViews addObject:pageView];
      [self.scrollView addSubview:pageView];
    }

    [self setPage:1];
    [self addSubview:self.scrollView];
  }
  return self;
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  NSLog(@"%d", sender.selectedSegmentIndex);
}

- (void)pageControlTouched:(DDPageControl *)sender {
  NSLog(@"%d", sender.currentPage);
  [self setPage:self.pageControl.currentPage];
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  [self.scrollView scrollRectToVisible:bounds animated:YES];
}

- (NSUInteger)numberOfButtonsInARowForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / BUTTON_WIDTH);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / BUTTON_HEIGHT);
}

- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrame:(CGSize)frameSize {
  NSUInteger emojiCount = [[self.emojis objectForKey:category] count];

  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfButtonsInARowForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;

  NSUInteger retVal = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  NSLog(@"%d %d %d :: %d", numberOfRows, numberOfColumns, emojiCount, retVal);
  return retVal;
}

- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSArray *emojis = [self.emojis objectForKey:category];
  end = ([emojis count] - 1 > end)? end : [emojis count] - 1;
  NSIndexSet *index = [[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)] autorelease];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
