//
//  EmojiPageView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiPageView.h"

@interface EmojiPageView ()

@property (nonatomic, retain) NSMutableArray *buttonTexts;
@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) NSUInteger rows;

@end

@implementation EmojiPageView
@synthesize buttonTexts = buttonTexts_;
@synthesize buttonSize = buttonSize_;
@synthesize buttons = buttons_;
@synthesize columns = columns_;
@synthesize rows = rows_;

- (void)setButtonTexts:(NSMutableArray *)buttonTexts {
  if (buttonTexts_ != buttonTexts) {
    if ([buttonTexts_ count] == [buttonTexts count]) {
      // just reset text on each button
      for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
        [[self.buttons objectAtIndex:i] setTitle:[buttonTexts objectAtIndex:i] forState:UIControlStateNormal];
      }
    } else if ([buttonTexts_ count] == 0) {
      buttonTexts_ = nil;
      buttonTexts_ = [buttonTexts retain];
      for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
        UIButton *button = [self createButtonAtIndex:i];
        [button setTitle:[buttonTexts objectAtIndex:i] forState:UIControlStateNormal];
        [self.buttons addObject:button];
        [self addSubview:button];
      }
    } else {
      //fixme: reset the array and recreate it
      self.buttons = nil;
      buttonTexts_ = nil;
      self.buttonTexts = buttonTexts;
    }
  }
}

- (CGFloat)XMarginForButtons {
  return ((self.frame.size.width - (self.columns * self.buttonSize.width)) / 2);
}

- (CGFloat)YMarginForButtons {
  return ((self.frame.size.height - (self.rows * self.buttonSize.height)) / 2);
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
    self.buttonSize = buttonSize;
    self.columns = columns;
    self.rows = rows;
    // Initialization code
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)emojiButtonPressed:(UIButton *)button {
  NSLog(@"%@", button.titleLabel.text);
}


@end
