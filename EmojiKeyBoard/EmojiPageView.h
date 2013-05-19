//
//  EmojiPageView.h
//  EmojiKeyBoard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmojiPageViewDelegate;

@interface EmojiPageView : UIView

@property (nonatomic, assign) id<EmojiPageViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame buttonSize:(CGSize)buttonSize rows:(NSUInteger)rows columns:(NSUInteger)columns;
- (void)setButtonTexts:(NSMutableArray *)buttonTexts;

@end

@protocol EmojiPageViewDelegate <NSObject>

- (void)emojiPageView:(EmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji;

@end
