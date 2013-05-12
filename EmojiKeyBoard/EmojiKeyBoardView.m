//
//  EmojiKeyBoardView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardView.h"

@interface EmojiKeyBoardView ()

@property (nonatomic, retain) UISegmentedControl *segmentsBar;
@property (nonatomic, retain) DDPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSDictionary *emojis;

@end

@implementation EmojiKeyBoardView
@synthesize segmentsBar = segmentsBar_;
@synthesize pageControl = pageControl_;
@synthesize scrollView = scrollView_;
@synthesize emojis = emojis_;

- (NSDictionary *)emojis {
  if (!emojis_) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis_ = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    NSLog(@"File read");
  }
  return emojis_;
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
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.scrollView];
  }
  return self;
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  NSLog(@"%d", sender.selectedSegmentIndex);
}

- (void)pageControlTouched:(DDPageControl *)sender {
  NSLog(@"%d", sender.currentPage);
}

#define BUTTON_WIDTH 35
#define BUTTON_HEIGHT 35

- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrame:(CGSize)frameSize {
  NSUInteger emojiCount = [[self.emojis objectForKey:category] count];

  NSUInteger numberOfRows = (NSUInteger)floor(frameSize.height / BUTTON_HEIGHT);
  NSUInteger numberOfColumns = (NSUInteger)floor(frameSize.width / BUTTON_WIDTH);
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;

  NSUInteger retVal = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  NSLog(@"%d %d %d :: %d", numberOfRows, numberOfColumns, emojiCount, retVal);
  return retVal;
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
