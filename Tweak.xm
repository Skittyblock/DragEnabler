// DragEnabler, by Skitty
// Enable iPad drag and drop features on iPhones

static NSMutableDictionary *settings;
static bool enabled;

// Preference Updates
static void refreshPrefs() {
  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.dragenabler"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    settings = (NSMutableDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("xyz.skitty.dragenabler"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
  } else {
    settings = nil;
  }
  if (!settings) {
    settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.dragenabler.plist"];
  }
  enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

// Enable Dragging
%hook UIDragInteraction
- (bool)isEnabled {
  if (enabled) {
    return YES;
  }
  return %orig;
}
%end

// Allow Interprocess Dragging
%hook _UIInternalDraggingSession
- (bool)shouldCancelOnAppDeactivation {
  if (enabled) {
    return NO;
  }
  return %orig;
}
%end

%hook _UIInternalDraggingSessionSource
- (bool)shouldCancelOnAppDeactivation {
  if (enabled) {
    return NO;
  }
  return %orig;
}
%end

// Fix Photos App
%hook PXDragAndDropSettings
- (bool)dragOutEnabled {
  if (enabled) {
    return YES;
  }
  return %orig;
}
%end

// Support For Twitter App
%hook TFNTwitterAccount
- (bool)isDragAndDropEnabled {
  if (enabled) {
    return YES;
  }
  return %orig;
}
%end


%ctor {
  refreshPrefs();
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.skitty.dragenabler.update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
