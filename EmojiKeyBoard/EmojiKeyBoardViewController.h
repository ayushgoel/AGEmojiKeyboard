//
//  EmojiKeyBoardViewController.h
//  EmojiKeyBoard
//
//  Created by Ayush on 17/04/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"

@interface EmojiKeyBoardViewController : UIViewController

@property (nonatomic, strong) UISegmentedControl *segmentsBar;
@property (nonatomic, strong) DDPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *selectFromGalleryButton;
@property (nonatomic, strong) UIButton *doodleButton;

@end
