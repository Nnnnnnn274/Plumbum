//
//  SileoColors.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "SileoColors.h"

@implementation SileoColors

// Primary colors
+ (UIColor *)sileoBlue {
    return [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
}

+ (UIColor *)sileoPurple {
    return [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:1.0];
}

+ (UIColor *)sileoGreen {
    return [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0];
}

// Background colors
+ (UIColor *)background {
    return [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0];
}

+ (UIColor *)secondaryBackground {
    return [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0];
}

+ (UIColor *)tertiaryBackground {
    return [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0];
}

// Text colors
+ (UIColor *)primaryText {
    return [UIColor whiteColor];
}

+ (UIColor *)secondaryText {
    return [UIColor colorWithWhite:0.7 alpha:1.0];
}

+ (UIColor *)tertiaryText {
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}

// Accent colors
+ (UIColor *)accentColor {
    return [self sileoBlue];
}

+ (UIColor *)warningColor {
    return [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0];
}

+ (UIColor *)errorColor {
    return [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
}

// UI element colors
+ (UIColor *)separatorColor {
    return [UIColor colorWithWhite:0.15 alpha:1.0];
}

+ (UIColor *)cellBackgroundColor {
    return [self secondaryBackground];
}

+ (UIColor *)selectedCellBackgroundColor {
    return [self tertiaryBackground];
}

@end
