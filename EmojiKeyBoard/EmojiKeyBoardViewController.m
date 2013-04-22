//
//  EmojiKeyBoardViewController.m
//  EmojiKeyBoard
//
//  Created by Ayush on 17/04/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "EmojiKeyBoardViewController.h"

@interface EmojiKeyBoardViewController ()

@end

@implementation EmojiKeyBoardViewController
@synthesize segmentsBar = segmentsBar_;
@synthesize pageControl = pageControl_;
@synthesize scrollView = scrollView_;
@synthesize takePhotoButton = takePhotoButton_;
@synthesize selectFromGalleryButton = selectFromGalleryButton_;
@synthesize doodleButton = doodleButton_;

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

@end
