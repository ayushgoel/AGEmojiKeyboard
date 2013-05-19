//
//  EmojiPageView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiPageView.h"

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
@synthesize isBeingUsed = isBeingUsed_;
@synthesize delegate = delegate_;

- (void)setButtonTexts:(NSMutableArray *)buttonTexts {
  NSLog(@"setting button texts. Previous number of buttons count : %d", [self.buttons count]);
  if ([self.buttons count] == [buttonTexts count]) {
    // just reset text on each button
    for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
      UIButton *button = [self.buttons objectAtIndex:i];
      if (!button) {
        button = [self createButtonAtIndex:i];
        [self addToViewButton:button];
      }
      [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
    }
  } else {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.buttons = nil;
    self.buttons = [[[NSMutableArray alloc] initWithCapacity:self.rows * self.columns] autorelease];
    for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
      UIButton *button = [self createButtonAtIndex:i];
      [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
      [self addToViewButton:button];
    }
  }
}

- (void)addToViewButton:(UIButton *)button {
  [self.buttons addObject:button];
  [self addSubview:button];
}

- (CGFloat)XMarginForButtons {
  return ((CGRectGetWidth(self.bounds) - (self.columns * self.buttonSize.width)) / 2);
}

- (CGFloat)YMarginForButtons {
  return ((CGRectGetHeight(self.bounds) - (self.rows * self.buttonSize.height)) / 2);
}

- (UIButton *)createButtonAtIndex:(NSUInteger)index {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:30];
  button.frame = CGRectIntegral(CGRectMake([self XMarginForButtons] + self.buttonSize.width * (index % self.columns),
                                           [self YMarginForButtons] + self.buttonSize.height * (index / self.columns),
                                           self.buttonSize.width,
                                           self.buttonSize.height));
  [button addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (id)initWithFrame:(CGRect)frame buttonSize:(CGSize)buttonSize columns:(NSUInteger)columns rows:(NSUInteger)rows{
  self = [super initWithFrame:frame];
  if (self) {
    NSLog(@"Initializing page view");

    self.buttonSize = buttonSize;
    self.columns = columns;
    self.rows = rows;
    self.buttons = [[[NSMutableArray alloc] initWithCapacity:rows * columns] autorelease];
  }
  return self;
}

- (void)emojiButtonPressed:(UIButton *)button {
  NSLog(@"Emoji pressed %@", button.titleLabel.text);
  [self.delegate emojiPageView:self emojiUsed:button.titleLabel.text];
}


@end
