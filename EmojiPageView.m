//
//  EmojiPageView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiPageView.h"

#define BACKSPACE_BUTTON_TAG 10
#define BUTTON_FONT_SIZE 32

@interface EmojiPageView ()

@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) NSUInteger rows;

@end

@implementation EmojiPageView
@synthesize buttonSize = buttonSize_;
@synthesize buttons = buttons_;
@synthesize columns = columns_;
@synthesize rows = rows_;
@synthesize delegate = delegate_;

- (void)setButtonTexts:(NSMutableArray *)buttonTexts {

  NSAssert(buttonTexts != nil, @"Array containing texts to be set on buttons is nil");

  if (([self.buttons count] - 1) == [buttonTexts count]) {
    // just reset text on each button
    for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
      [self.buttons[i] setTitle:buttonTexts[i] forState:UIControlStateNormal];
    }
  } else {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.buttons = nil;
    self.buttons = [NSMutableArray arrayWithCapacity:self.rows * self.columns];
    for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
      UIButton *button = [self createButtonAtIndex:i];
      [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
      [self addToViewButton:button];
    }
    UIButton *button = [self createButtonAtIndex:self.rows * self.columns - 1];
    [button setImage:[UIImage imageNamed:@"backspace_n.png"] forState:UIControlStateNormal];
    button.tag = BACKSPACE_BUTTON_TAG;
    [self addToViewButton:button];
  }
}

- (void)addToViewButton:(UIButton *)button {

  NSAssert(button != nil, @"Button to be added is nil");

  [self.buttons addObject:button];
  [self addSubview:button];
}

// Padding is the expected space between two buttons.
// Thus, space of top button = padding / 2
// extra padding according to particular button's pos = pos * padding
// Margin includes, size of buttons in between = pos * buttonSize
// Thus, margin = padding / 2
//                + pos * padding
//                + pos * buttonSize

- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
  CGFloat padding = ((CGRectGetWidth(self.bounds) - self.columns * self.buttonSize.width) / self.columns);
  return (padding / 2 + column * (padding + self.buttonSize.width));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
  CGFloat padding = ((CGRectGetHeight(self.bounds) - self.rows * self.buttonSize.height) / self.rows);
  return (padding / 2 + rowNumber * (padding + self.buttonSize.height));
}

- (UIButton *)createButtonAtIndex:(NSUInteger)index {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
  NSInteger row = (NSInteger)(index / self.columns);
  NSInteger column = (NSInteger)(index % self.columns);
  button.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:column],
                                           [self YMarginForButtonInRow:row],
                                           self.buttonSize.width,
                                           self.buttonSize.height));
  [button addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (id)initWithFrame:(CGRect)frame buttonSize:(CGSize)buttonSize rows:(NSUInteger)rows columns:(NSUInteger)columns {
  self = [super initWithFrame:frame];
  if (self) {
    self.buttonSize = buttonSize;
    self.columns = columns;
    self.rows = rows;
    self.buttons = [[[NSMutableArray alloc] initWithCapacity:rows * columns] autorelease];
  }
  return self;
}

- (void)emojiButtonPressed:(UIButton *)button {
  if (button.tag == BACKSPACE_BUTTON_TAG) {
    NSLog(@"Back space pressed");
    [self.delegate emojiPageViewDidPressBackSpace:self];
    return;
  }
  NSLog(@"%@", button.titleLabel.text);
  [self.delegate emojiPageView:self didUseEmoji:button.titleLabel.text];
}

- (void)dealloc {
  self.buttons = nil;
  [super dealloc];
}

@end
