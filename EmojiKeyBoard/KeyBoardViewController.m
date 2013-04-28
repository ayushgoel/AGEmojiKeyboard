//
//  KeyBoardViewController.m
//  EmojiKeyBoard
//
//  Created by Ayush on 25/04/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "KeyBoardViewController.h"

@interface KeyBoardViewController ()
@property (nonatomic, retain) UILabel *label;
@end

@implementation KeyBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
    self.label.text = @"Text";
    self.label.textColor = [UIColor grayColor];
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view addSubview:self.label];
  self.view.backgroundColor = [UIColor grayColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  self.label = nil;
  [super dealloc];
}
@end
