//
//  AGEmojiKeyboardView.h
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//
// Set as inputView to textfields, this view class gives an
// interface to the user to enter emoji characters.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AGEmojiKeyboardViewCategoryImage) {
  AGEmojiKeyboardViewCategoryImageRecent,
  AGEmojiKeyboardViewCategoryImageFace,
  AGEmojiKeyboardViewCategoryImageBell,
  AGEmojiKeyboardViewCategoryImageFlower,
  AGEmojiKeyboardViewCategoryImageCar,
  AGEmojiKeyboardViewCategoryImageCharacters
};

@protocol AGEmojiKeyboardViewDelegate;
@protocol AGEmojiKeyboardViewDataSource;

@interface AGEmojiKeyboardView : UIView

@property (nonatomic, weak) id<AGEmojiKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<AGEmojiKeyboardViewDataSource> dataSource;

- (id)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource;

@end


@protocol AGEmojiKeyboardViewDataSource <NSObject>

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;

@end


@protocol AGEmojiKeyboardViewDelegate <NSObject>

/**
 Delegate method called when user taps an emoji button
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 @param emoji Emoji used by user
 */
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji;

/**
 Delegate method called when user taps on the backspace button
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView;

@end
