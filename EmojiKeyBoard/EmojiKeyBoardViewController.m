//
//  EmojiKeyBoardViewController.m
//  EmojiKeyBoard
//
//  Created by Ayush on 17/04/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardViewController.h"
#import "EmojiKeyBoardView.h"

@interface EmojiKeyBoardViewController ()

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) EmojiKeyBoardView *emojiKeyboardView;

@end

@implementation EmojiKeyBoardViewController
@synthesize textView = textView_;
@synthesize emojiKeyboardView = emojiKeyboardView_;

- (void)loadView {
  [super loadView];
  self.textView = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
  self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.emojiKeyboardView = [[[EmojiKeyBoardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)] autorelease];
  [self.view addSubview:self.textView];
  NSLog(@"asd");
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.textView.inputView = self.emojiKeyboardView;
  NSLog(@"asd2");
}

@end
