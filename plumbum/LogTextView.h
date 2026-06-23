//
//  LogTextView.h
//  plumbum
//
//  Created by seo on 4/7/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LogTextView : UITextView
@end

void log_init(void);
void log_write(const char *msg);
void log_user(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
