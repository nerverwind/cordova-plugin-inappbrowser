#import "CDVInAppBrowserMenuDialog.h"

static CGFloat const menuButtonHeight = 55.f;
static CGFloat const menuButtonWidth = 55.f;
static CGFloat const menuHeightSpace = 11.f;
static CGFloat const menuCancelButtonHeight = 44.f;
static CGFloat const menuViewPaddingTop = 44.f;
static CGFloat const menuButtonMarginLeft = 11.f;
static CGFloat const menuButtonTitleMarginTop = 3.f;
static CGFloat const menuButtonTitleHeight = 22.f;
static CGFloat const menuButtonMarginBottom = 33.f;

#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CDVInAppBrowserMenuDialog()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView* menuView;
@property (nonatomic,strong) UIView* menuTitleView;
@property (nonatomic,strong) UILabel* menuTitleLabel;
@property (nonatomic,strong) UILabel* menuUrlLabel;
@property (nonatomic,strong) UIImageView* menuIconImageView;
@property (nonatomic,assign) CGFloat menuViewHeight;
@property (nonatomic,strong) NSMutableArray* buttonArray;
@property (nonatomic,assign) SEL menuButtonAction;
@property (nonatomic,assign) id parentId;

@end

@interface MenuButton()
@end

@implementation MenuButton
@end

@implementation CDVInAppBrowserMenuDialog

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonArray = [NSMutableArray array];
        [self initMenuButton];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer addTarget:self action:@selector(closeMenuDialog)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        int columnCount = 5;
        CGFloat rowCount = self.buttonArray.count / columnCount;
        rowCount = rowCount == 0 ? 1 : rowCount;
        self.menuViewHeight = (menuHeightSpace + menuButtonHeight + menuButtonMarginBottom + menuButtonTitleHeight + menuButtonTitleMarginTop) * (rowCount + 1) + menuCancelButtonHeight;
        
        
        for (int i = 0; i < self.buttonArray.count; i++) {
            int colX = i % columnCount;
            int rowY = i / columnCount;
            
            MenuButton * menuButtonObj = self.buttonArray[i];
            CGFloat buttonX = menuButtonMarginLeft + colX * (menuButtonWidth + menuButtonMarginLeft);
            CGFloat buttonY = menuHeightSpace + rowY * (menuButtonHeight + menuHeightSpace) + menuViewPaddingTop;
            if(rowY >= 1) {
                buttonY = buttonY + menuButtonMarginBottom * rowY;
            }
            UIButton * menuButton = [[UIButton alloc] init];
            [menuButton setImage:[UIImage imageNamed:menuButtonObj.iconName] forState:UIControlStateNormal];
            
            [menuButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
            menuButton.tag = menuButtonObj.tag;
            [self.menuView addSubview:menuButton];
            menuButton.frame = CGRectMake(buttonX, buttonY, menuButtonWidth, menuButtonHeight);
            menuButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
            [menuButton.layer setCornerRadius:10.0];
            menuButton.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            [menuButton setImageEdgeInsets:
                       UIEdgeInsetsMake(10, 10, 10, 10)];
            
            UILabel * menuTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonX, buttonY + menuButtonHeight + menuButtonTitleMarginTop, menuButtonWidth, menuButtonTitleHeight)];
            [menuTitleLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
            [menuTitleLabel setFont:[UIFont systemFontOfSize:10]];
            
            [menuTitleLabel setText:menuButtonObj.title];
            [menuTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [menuTitleLabel setNumberOfLines:0];
            [menuTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [menuTitleLabel sizeToFit];
            [menuTitleLabel setFrame:CGRectMake(buttonX, buttonY + menuButtonHeight + menuButtonTitleMarginTop, menuButtonWidth, menuTitleLabel.bounds.size.height)];
            
            if(colX == 0) {
                UILabel * lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, buttonY + menuButtonHeight + menuButtonTitleMarginTop + 12.0 + menuTitleLabel.bounds.size.height , SCREEN_WIDTH - 12.0, 1.0)];
                lineLabel.layer.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:212.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
                [self.menuView addSubview:lineLabel];
            }
            
            
            [self.menuView addSubview:menuTitleLabel];
            [self.menuView addSubview:menuButton];
            
        }
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(0, self.menuViewHeight - menuCancelButtonHeight, SCREEN_WIDTH, menuCancelButtonHeight)];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setTitle: NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [cancelButton addTarget:self action:@selector(closeMenuDialog) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:cancelButton];
        
        
        self.menuTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(menuButtonMarginLeft + 32.0, 11.0f, SCREEN_WIDTH - menuButtonMarginLeft * 2, 10.f)];
        [self.menuTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.menuTitleLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
        [self.menuTitleLabel setText:@""];
        [self.menuTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.menuTitleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [self.menuView addSubview:self.menuTitleLabel];
        
        self.menuUrlLabel = [[UILabel alloc] initWithFrame:CGRectMake(menuButtonMarginLeft + 32.0, 24.0f, SCREEN_WIDTH - menuButtonMarginLeft * 2, 8.f)];
        [self.menuUrlLabel setBackgroundColor:[UIColor clearColor]];
        [self.menuUrlLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
        [self.menuUrlLabel setText:@""];
        [self.menuUrlLabel setFont:[UIFont systemFontOfSize:9]];
        
        [self.menuUrlLabel setTextAlignment:NSTextAlignmentLeft];
        [self.menuView addSubview:self.menuUrlLabel];
        
        self.menuIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(menuButtonMarginLeft, 11.0f, 20.0f, 20.0f)];
        [self.menuView addSubview:self.menuIconImageView];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 44.0, SCREEN_WIDTH - 12.0, 1.0)];
        lineLabel.layer.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:212.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
        [self.menuView addSubview:lineLabel];
        
        [self addSubview:self.menuView];
        
    }
    return self;
}

-(void)clickMenu:(UIButton *)sender
{
    [self closeMenuDialog];
    [self.parentId performSelector:self.menuButtonAction withObject:sender];
}

-(void) initMenuButton
{
    MenuButton * copyMenuButton = [[MenuButton alloc] init];
    copyMenuButton.iconName = @"copy";
    copyMenuButton.tag = MenuTypeCopy;
    copyMenuButton.title = NSLocalizedString(@"Copy", nil);
    
    MenuButton * refreshMenuButton = [[MenuButton alloc] init];
    refreshMenuButton.iconName = @"refresh";
    refreshMenuButton.tag = MenuTypeRefresh;
    refreshMenuButton.title = NSLocalizedString(@"Refresh", nil);
    
    MenuButton * shareMenuButton = [[MenuButton alloc] init];
    shareMenuButton.iconName = @"share";
    shareMenuButton.tag = MenuTypeShare;
    shareMenuButton.title = NSLocalizedString(@"Share", nil);
    
    
    [self.buttonArray addObject:copyMenuButton];
    [self.buttonArray addObject:refreshMenuButton];
    [self.buttonArray addObject:shareMenuButton];
    
}

-(UIView *)menuView
{
    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, self.menuViewHeight)];
        _menuView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green: 235.0/255.0 blue: 236.0/255.0 alpha:1.00];
        [_menuView.layer setCornerRadius:10.0];
        _menuView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    }
    return _menuView;
}

-(void)closeMenuDialog
{
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.menuView.frame = CGRectMake(0, SCREENH_HEIGHT, SCREEN_WIDTH, self.menuViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showMenuDialog
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.menuView.frame = CGRectMake(0, SCREENH_HEIGHT - self.menuViewHeight, SCREEN_WIDTH, self.menuViewHeight);
    }];
}

- (void)showMenuDialogWithTitle:(NSString *)title url:(NSString*)url iconImage:(UIImage*)iconImage menuButtonAction:(SEL)menuButtonAction parentId:(id)parentId
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.menuTitleLabel.text = title;
    self.menuUrlLabel.text = url;
    [self.menuIconImageView setImage:iconImage];
    self.menuButtonAction = menuButtonAction;
    self.parentId = parentId;
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.menuView.frame = CGRectMake(0, SCREENH_HEIGHT - self.menuViewHeight, SCREEN_WIDTH, self.menuViewHeight);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.menuView]) {
        return NO;
    }
    return YES;
}

@end
