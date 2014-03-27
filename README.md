AGEmojiKeyboard
==================

[![Version](http://cocoapod-badges.herokuapp.com/v/AGEmojiKeyboard/badge.png)](http://cocoadocs.org/docsets/AGEmojiKeyboard)
[![Platform](http://cocoapod-badges.herokuapp.com/p/AGEmojiKeyboard/badge.png)](http://cocoadocs.org/docsets/AGEmojiKeyboard)

An alternate keyboard for iOS that displays all the emojis supported by iOS.

Additions that need to be done
  * stickers
  * custom emojis (different font)

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Installation

### Via Cocoapods

AGEmojiKeyboard is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    platform :ios, '7.0'
    pod "AGEmojiKeyboard", "~> 0.1.0"

### The old way

Copy the classes in AGEmojiKeyboard/ and resources in Resources/ to your project. Look at the Example/ folder to see how the classes are used for more detail.
```objective-c
AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
emojiKeyboardView.delegate = self;
textView.inputView = emojiKeyboardView;
```

## Author

Ayush Goel, ayushgoel111@gmail.com

## License

AGEmojiKeyboard is available under the MIT license. See the LICENSE file for more info.

