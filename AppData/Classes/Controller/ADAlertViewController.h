//
//  ADAlertViewController.h
//  AppData
//
//  Created by Fouad Raheb on 7/2/20.
//

#import <UIKit/UIKit.h>
#import "ADDataPresentationManager.h"

typedef void(^ADAlertButtonActionHandler)(UIButton *button);

typedef NS_ENUM(NSInteger, ADAlertButtonStyle) {
    ADButtonStyleDefault = 0,
    ADButtonStyleCancel = 1,
    ADButtonStyleDestructive = 2
};

@interface ADAlertButton : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) ADAlertButtonStyle style;
@property (nonatomic, strong) ADAlertButtonActionHandler actionHandler;
+ (ADAlertButton *)buttonWithTitle:(NSString *)title style:(ADAlertButtonStyle)style handler:(ADAlertButtonActionHandler)handler;
@end

@interface ADAlertViewController : UIViewController

@property (nonatomic, strong) ADDataPresentationManager *presentationManager;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSArray <ADAlertButton *> *buttons;

@property (nonatomic, strong) UITextField *textfield;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;

- (CGFloat)requiredHeight;

@end
