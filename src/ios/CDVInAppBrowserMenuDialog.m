#import "CDVInAppBrowserMenuDialog.h"

static CGFloat const menuButtonHeight = 90.f;
static CGFloat const menuButtonWidth = 76.f;
static CGFloat const menuHeightSpace = 15.f;//竖间距
static CGFloat const menuCancelButtonHeight = 44.f;

#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CDVInAppBrowserMenuDialog()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView* menuView;
@property (nonatomic,assign) CGFloat menuViewHeight;

@end

@implementation CDVInAppBrowserMenuDialog
@end