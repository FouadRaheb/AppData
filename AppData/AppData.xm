#import "ADDataViewController.h"

%group SHARED_HOOKS

%hook SBIconImageView

%property (nonatomic, retain) UISwipeGestureRecognizer *adSwipeGestureRecognizer;

- (SBIconImageView *)initWithFrame:(CGRect)arg1 {
    %log;
    SBIconImageView *r = %orig;
    if (![r isKindOfClass:NSClassFromString(@"SBFolderIconImageView")]) {
        [[NSNotificationCenter defaultCenter] addObserver:r selector:@selector(appDataPreferencesChanged) name:kAppDataForceTouchMenuPreferencesChangedNotification object:nil];
        
        // Create Gesture Recognizer
        self.adSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:r action:@selector(appDataDidSwipeUp:)];
        self.adSwipeGestureRecognizer.direction = (UISwipeGestureRecognizerDirectionUp);
        r.userInteractionEnabled = YES;
        
        // Add gesture if enabled
        [self appDataPreferencesChanged];
    }
    return r;
}

%new
- (void)appDataPreferencesChanged {
    if ([ADHelper swipeUpEnabled]) {
        if (![self.gestureRecognizers containsObject:self.adSwipeGestureRecognizer]) {
            [self addGestureRecognizer:self.adSwipeGestureRecognizer];
        }
    } else {
        if ([self.gestureRecognizers containsObject:self.adSwipeGestureRecognizer]) {
            [self removeGestureRecognizer:self.adSwipeGestureRecognizer];
        }
    }
}

%new
- (void)appDataDidSwipeUp:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [ADDataViewController presentControllerFromSBIconImageView:self];
    }
}

%end

%end

#pragma mark - ForceTouch Menu

%group IOS13_AND_NEWER_HOOKS

%hook SBIconView

- (void)setApplicationShortcutItems:(NSArray *)items {
    if ([ADHelper forceTouchMenuEnabled]) {
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:items?:@[]];
        SBSApplicationShortcutItem *shortcutItem = [ADHelper applicationShortcutItem];
        if (shortcutItem) {
            [newItems addObject:shortcutItem];
        }
        %orig(newItems);
    } else {
        %orig;
    }
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {
    if ([item.type isEqualToString:kSBApplicationShortcutItemType]) {
        [ADDataViewController presentControllerFromSBIconView:iconView];
    } else {
        %orig;
    }
}

%end

%end


%group IOS12_AND_OLDER_HOOKS

%hook SBUIAppIconForceTouchControllerDataProvider

- (id)applicationShortcutItems {
    if ([ADHelper forceTouchMenuEnabled]) {
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:%orig?:@[]];
        [newItems addObject:[ADHelper applicationShortcutItem]];
        return newItems;
    }
    return %orig;
}

%end

%hook SBUIAppIconForceTouchController

- (void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem *)item {
    if ([item.type isEqualToString:kSBApplicationShortcutItemType]) {
        [self dismissAnimated:YES withCompletionHandler:nil];
        SBUIAppIconForceTouchControllerDataProvider* _dataProvider = [self valueForKey:@"_dataProvider"];
        SBIconView *iconView = (SBIconView *)_dataProvider.gestureRecognizer.view;
        [ADDataViewController presentControllerFromSBIconView:iconView];
    } else {
        %orig;
    }
}

%end

%end


%ctor {
    [[ADHelper sharedInstance] initialize];
    
    %init(SHARED_HOOKS);
    
    if (@available(iOS 13, *)) {
        %init(IOS13_AND_NEWER_HOOKS);
    } else {
        %init(IOS12_AND_OLDER_HOOKS);
    }
}
