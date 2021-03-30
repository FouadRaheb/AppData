//
//  ADSettings.m
//  AppData
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADSettings.h"

@implementation ADSettings

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static ADSettings *_sharedInstance = nil;
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance initialize];
    });
    return _sharedInstance;
}

- (void)initialize {
    // Load tweak preferences
    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.fouadraheb.appdata"];
    [self.userDefaults registerDefaults:self.class.defaultsDictionary];
    [self.userDefaults addObserver:self forKeyPath:kSwipeUpEnabled options:NSKeyValueObservingOptionNew context:NULL];
    [self.userDefaults addObserver:self forKeyPath:kAppearance options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
    if ([keyPath isEqualToString:kSwipeUpEnabled]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDataSwipeUpPreferencesChangedNotification object:nil];
    } else if ([keyPath isEqualToString:kAppearance]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDataAppearancePreferencesChangedNotification object:nil];
    }
}

+ (NSDictionary *)defaultsDictionary {
    return @{
        kSwipeUpEnabled:            @(YES),
        kForceTouchMenuEnabled:     @(NO),
        kAppearance:                @(ADAppearanceStyleDark)
    };
}

+ (id)objectForKey:(NSString *)key {
    return [[self.sharedInstance userDefaults] objectForKey:key];
}

+ (BOOL)boolForKey:(NSString *)key {
    return [[self.sharedInstance userDefaults] boolForKey:key];
}

+ (NSInteger)integerForKey:(NSString *)key {
    return [[self.sharedInstance userDefaults] integerForKey:key];
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    return [[self.sharedInstance userDefaults] setObject:object forKey:key];
}

+ (void)setInteger:(NSInteger)integer forKey:(NSString *)key {
    return [[self.sharedInstance userDefaults] setInteger:integer forKey:key];
}

#pragma mark - Activation

+ (BOOL)swipeUpEnabled {
    return [self boolForKey:kSwipeUpEnabled];
}

+ (BOOL)forceTouchMenuEnabled {
    return [self boolForKey:kForceTouchMenuEnabled];
}

#pragma mark - Appearance

+ (ADAppearanceStyle)appearanceStyle {
    ADAppearanceStyle currentValue = [ADSettings integerForKey:kAppearance];
    if (@available(iOS 13.0, *)) { } else { // iOS 12 or older
        if (currentValue == ADAppearanceStyleAutomatic) {
            [ADSettings setInteger:ADAppearanceStyleDark forKey:kAppearance];
            return ADAppearanceStyleDark;
        }
    }
    return currentValue;
}

+ (NSArray <NSString *> *)appearanceValues {
    if (@available(iOS 13.0, *)) {
        return @[[NSString stringWithFormat:@"%td",ADAppearanceStyleDark], [NSString stringWithFormat:@"%td",ADAppearanceStyleLight], [NSString stringWithFormat:@"%td",ADAppearanceStyleAutomatic]];
    } else {
        return @[[NSString stringWithFormat:@"%td",ADAppearanceStyleDark], [NSString stringWithFormat:@"%td",ADAppearanceStyleLight]];
    }
}

+ (NSArray <NSString *> *)appearanceTitles {
    if (@available(iOS 13.0, *)) {
        return @[[self titleForAppearanceStyle:ADAppearanceStyleDark], [self titleForAppearanceStyle:ADAppearanceStyleLight], [self titleForAppearanceStyle:ADAppearanceStyleAutomatic]];
    } else {
        return @[[self titleForAppearanceStyle:ADAppearanceStyleDark], [self titleForAppearanceStyle:ADAppearanceStyleLight]];
    }
}

+ (NSString *)titleForAppearanceStyle:(ADAppearanceStyle)style {
    switch (style) {
        case ADAppearanceStyleDark: return @"Dark";
        case ADAppearanceStyleLight: return @"Light";
        case ADAppearanceStyleAutomatic: return @"Automatic";
        default: return @"N/A";
    }
}

#pragma mark - Custom App Names

+ (NSString *)customAppNameForBundleIdentifier:(NSString *)identifier {
    return [[ADSettings.sharedInstance.userDefaults dictionaryForKey:kCustomAppNames] objectForKey:identifier];
}

+ (void)setCustomAppName:(NSString *)name forBundleIdentifier:(NSString *)bundleIdentifier {
    if (!bundleIdentifier) return;
    
    NSDictionary *dictionary = [ADSettings.sharedInstance.userDefaults dictionaryForKey:kCustomAppNames];
    NSMutableDictionary *mutableDictionary = dictionary ? [dictionary mutableCopy] : [NSMutableDictionary new];
    if (name) {
        [mutableDictionary setObject:name forKey:bundleIdentifier];
    } else {
        [mutableDictionary removeObjectForKey:bundleIdentifier];
    }
    [ADSettings.sharedInstance.userDefaults setObject:mutableDictionary forKey:kCustomAppNames];
}

@end
