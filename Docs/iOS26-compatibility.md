# Home Screen access on iOS 26

On iOS 26.0.1, AppData's menu item appeared but selecting it opened the application. Swipe-up could instead report that SBHTouchPassThroughView was not a valid icon class.

The source repair has two parts:

1. `ADDataViewController` walks image-view ancestors until an object provides the `icon` selector. This preserves the existing presentation path while accommodating the extra wrapper views. An exhausted hierarchy continues into the controller's existing error handling.
2. `ADContextMenuCompatibility.m` intercepts `SBHIconViewApplicationShortcutsContextMenuProvider +activateShortcut:withBundleIdentifier:forIconView:` on the provider's **metaclass**. It handles the exact `com.fouadraheb.appdata` shortcut type and invokes AppData's existing `+presentControllerFromSBIconView:fromContextMenu:` entry point. Other items and unsupported presentation inputs forward to the saved original with unchanged arguments.

The compatibility file is included in the AppData target's Compile Sources phase. It compiles as ordinary Objective-C alongside the existing Logos implementation; the existing menu insertion and older activation hooks continue to serve their original paths.

## Dispatch and ABI

Inspection of iOS 26.0.1 build 23A355 confirmed:

```objc
+ (void)activateShortcut:(id)item withBundleIdentifier:(id)bundleID forIconView:(id)iconView;
- (bool)shouldActivateApplicationShortcutItem:(id)item atIndex:(unsigned long long)index forIconView:(id)iconView;
```

Their runtime encodings were respectively `v40@0:8@16@24@32` and `B40@0:8@16Q24@32`. The latter has an integer index; it is not interchangeable with the three-object activation ABI. The new source hooks only the class activation method and validates both the activation and presentation encodings before installing.

The replacement uses its own original-IMP storage and the already-loaded Substrate-compatible engine. Typed calls let the compiler generate ARM64e pointer authentication. It does not reuse a binary offset, patch a code cave or load a second hook engine. Installation only sets up the hook; it does not invoke a shortcut or construct/present AppData UI.

The existing hook on SBIconView misses the provider's activation path on the tested system. This is why insertion can work while selecting the item falls through to application launch. The provider class-method interception handles selection before that fallback.

## Scope and validation

The provider bridge is deliberately restricted to **iOS 26.0.1 build 23A355**. On other systems, it leaves activation to the existing implementation. The swipe traversal applies wherever the existing swipe gesture is used. Do not interpret either change as a claim of support for every iOS release or every jailbreak layout.

The source of this bridge was used in a separate compatibility dylib together with the same ancestor-traversal behavior in an existing AppData binary. That combination was user-confirmed working on an iPhone 11 Pro Max running iOS 26.0.1 / 23A355 with Dopamine RootHide and ElleKit. The user also reported operation on RootHide iOS 16.6, where the new provider hook remains inactive. A complete rebuild of this public source tree with these integrated changes has **not** been tested on-device. Standard rootless deployment has not been device-verified.

Local validation:

- The new Objective-C file compiles for ARM64 and ARM64e against the existing iOS 11 deployment target with warnings treated as errors.
- Host regressions cover ABI rejection, metaclass targeting, original-pointer storage, installation without activation, exact shortcut matching, argument forwarding, invalid/off-main calls and the actual controller method traversing multiple wrappers or an exhausted hierarchy.
- The Xcode project file parses successfully and includes the new source in the AppData target only.

Run the host regressions from the repository root on macOS with Xcode command-line tools and Python 3:

```sh
python3 Tests/run-tests.py
```

The host uses simulated UIKit objects and a simulated hook engine. It does not reproduce SpringBoard or context-menu dismissal/presentation. The full project still requires its existing MonkeyDev/Theos setup; those tools were not available for a complete build here.

For device acceptance, check normal SpringBoard startup, swipe-up, the AppData menu item, unrelated application/system shortcuts, the menu preference toggle and repeated cancellation/selection. Keep the existing jailbreak recovery route available while testing. Packaging and release metadata are outside this source change.
