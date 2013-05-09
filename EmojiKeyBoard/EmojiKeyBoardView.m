//
//  EmojiKeyBoardView.m
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardView.h"

@implementation EmojiKeyBoardView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    NSLog(@"asd3, %f", self.frame.size.height);
    self.backgroundColor = [UIColor blueColor];

    UILabel *la = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)] autorelease];
    la.text = @"Hello";
    la.textColor = [UIColor redColor];
    [self addSubview:la];

    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(0, 100, 20, 20);
    but.backgroundColor = [UIColor redColor];
    but.titleLabel.text = @"Touch!";
    [but addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventAllTouchEvents];
    [self addSubview:but];
  }
  return self;
}

- (void)buttonPressed:(UIButton *)button {
  NSLog(@"asd4, %f", self.frame.size.height);
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
