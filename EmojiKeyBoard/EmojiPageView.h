//
//  EmojiPageView.h
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiPageView : UIView

- (id)initWithFrame:(CGRect)frame buttonSize:(CGSize)buttonSize columns:(NSUInteger)columns rows:(NSUInteger)rows;
- (void)setButtonTexts:(NSMutableArray *)buttonTexts;

@end
