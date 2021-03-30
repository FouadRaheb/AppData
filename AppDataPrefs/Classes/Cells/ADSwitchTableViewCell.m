//
//  ADSwitchTableViewCell.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADSwitchTableViewCell.h"
#import "ADSettings.h"

@interface ADSwitchTableViewCell ()
@property (nonatomic, strong) UISwitch *theSwitch;
@property (nonatomic, strong) NSString *switchKey;
@end

@implementation ADSwitchTableViewCell

+ (NSString *)reuseIdentifier {
    return @"ADSwitchTableViewCellIdentifier";
}

+ (CGFloat)height {
    return UITableViewAutomaticDimension;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.theSwitch addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.accessoryView = self.theSwitch;
}

- (void)configureWithTitle:(NSString *)title switchKey:(NSString *)key {
    self.textLabel.text = title;
    
    self.switchKey = key;
    
    self.theSwitch.on = [ADSettings boolForKey:self.switchKey];
}

- (void)didChangeSwitch:(UISwitch *)theSwitch {
    [ADSettings setObject:@(theSwitch.isOn) forKey:self.switchKey];
}

@end
