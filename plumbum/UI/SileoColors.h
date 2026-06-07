//
//  SileoColors.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SileoColors : NSObject

// Primary colors
+ (UIColor *)sileoBlue;
+ (UIColor *)sileoPurple;
+ (UIColor *)sileoGreen;

// Background colors
+ (UIColor *)background;
+ (UIColor *)secondaryBackground;
+ (UIColor *)tertiaryBackground;

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

@end

NS_ASSUME_NONNULL_END
