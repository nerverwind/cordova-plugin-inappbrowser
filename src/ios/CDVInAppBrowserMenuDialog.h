#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , MenuType) {
    MenuTypeRefresh = 1,
    MenuTypeCopy = 2,
    MenuTypeShare = 3
};

@interface MenuButton : NSObject
@property (nonatomic, copy) NSString* iconName;
@property (nonatomic, assign) MenuType tag;
@property (nonatomic, copy) NSString* title;
@end

@interface CDVInAppBrowserMenuDialog : UIView
- (void)showMenuDialog;
- (void)showMenuDialogWithTitle:(NSString *)title url:(NSString*)url iconImage:(UIImage*)iconImage menuButtonAction:(SEL)menuButtonAction parentId:(id)parentId;
@end
