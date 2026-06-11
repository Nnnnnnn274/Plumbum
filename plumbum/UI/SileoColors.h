//
//  SileoColors.h
//  plumbum
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SileoColors : NSObject

// Primary accent colors
+ (UIColor *)sileoBlue;
+ (UIColor *)sileoPurple;
+ (UIColor *)sileoGreen;

// Background colors
+ (UIColor *)background;
+ (UIColor *)secondaryBackground;
+ (UIColor *)tertiaryBackground;
+ (UIColor *)quaternaryBackground;

// Text colors
+ (UIColor *)primaryText;
+ (UIColor *)secondaryText;
+ (UIColor *)tertiaryText;

// Accent colors
+ (UIColor *)accentColor;
+ (UIColor *)warningColor;
+ (UIColor *)errorColor;

// UI element colors
+ (UIColor *)separatorColor;
+ (UIColor *)cellBackgroundColor;
+ (UIColor *)selectedCellBackgroundColor;
+ (UIColor *)borderColor;
+ (UIColor *)accentBorderColor;

@end

NS_ASSUME_NONNULL_END
