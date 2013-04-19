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

@property (nonatomic, strong) DDPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *takePhotoButton;
@property (nonatomic, strong) UIView *selectFromGalleryButton;


@end
