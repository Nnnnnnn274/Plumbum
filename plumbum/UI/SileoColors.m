//
//  SileoColors.m
//  plumbum
//

#import "SileoColors.h"

@implementation SileoColors

// Primary accent colors
+ (UIColor *)sileoBlue {
    // #00d4e8 — mockup cyan
    return [UIColor colorWithRed:0.0 green:0.831 blue:0.910 alpha:1.0];
}

+ (UIColor *)sileoPurple {
    // #7b6bff
    return [UIColor colorWithRed:0.482 green:0.420 blue:1.0 alpha:1.0];
}

+ (UIColor *)sileoGreen {
    // #00e8b8 — terminal green
    return [UIColor colorWithRed:0.0 green:0.910 blue:0.722 alpha:1.0];
}

// Background colors — deeper near-black
+ (UIColor *)background {
    // #07070f
    return [UIColor colorWithRed:0.027 green:0.027 blue:0.059 alpha:1.0];
}

+ (UIColor *)secondaryBackground {
    // #0f0f1c
    return [UIColor colorWithRed:0.059 green:0.059 blue:0.110 alpha:1.0];
}

+ (UIColor *)tertiaryBackground {
    // #161625
    return [UIColor colorWithRed:0.086 green:0.086 blue:0.145 alpha:1.0];
}

+ (UIColor *)quaternaryBackground {
    // #1e1e30
    return [UIColor colorWithRed:0.118 green:0.118 blue:0.188 alpha:1.0];
}

// Text colors
+ (UIColor *)primaryText {
    return [UIColor whiteColor];
}

+ (UIColor *)secondaryText {
    // #a0a0c0
    return [UIColor colorWithRed:0.627 green:0.627 blue:0.753 alpha:1.0];
}

+ (UIColor *)tertiaryText {
    // #606080
    return [UIColor colorWithRed:0.376 green:0.376 blue:0.502 alpha:1.0];
}

// Accent colors
+ (UIColor *)accentColor {
    return [self sileoBlue];
}

+ (UIColor *)warningColor {
    // #f0a500
    return [UIColor colorWithRed:0.941 green:0.647 blue:0.0 alpha:1.0];
}

+ (UIColor *)errorColor {
    // #ff4757
    return [UIColor colorWithRed:1.0 green:0.278 blue:0.341 alpha:1.0];
}

// UI element colors
+ (UIColor *)separatorColor {
    return [UIColor colorWithWhite:1.0 alpha:0.07];
}

+ (UIColor *)cellBackgroundColor {
    return [self secondaryBackground];
}

+ (UIColor *)selectedCellBackgroundColor {
    return [self tertiaryBackground];
}

// Border colors
+ (UIColor *)borderColor {
    return [UIColor colorWithWhite:1.0 alpha:0.07];
}

+ (UIColor *)accentBorderColor {
    // Cyan at 20% opacity
    return [UIColor colorWithRed:0.0 green:0.831 blue:0.910 alpha:0.2];
}

@end
