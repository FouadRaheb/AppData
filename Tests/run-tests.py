#!/usr/bin/env python3
"""Compile/run host regressions without building or installing the tweak.
Requires macOS, Xcode command-line tools and Python 3. No third-party modules.
"""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
source = (root / "AppData/Classes/Controller/ADDataViewController.m").read_text()
signature = "+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView fromContextMenu:(BOOL)contextMenu {"
start = source.index(signature)
end = source.index("\n}", start) + 2
method = source[start:end]

with tempfile.TemporaryDirectory(prefix="appdata-tests-") as temporary:
    work = Path(temporary)
    header = """@interface SBIconImageView : UIView
@end
@implementation SBIconImageView
@end
static id swipeImage, swipeIcon;
static BOOL swipeContext;
@interface ADSwipeTestController : NSObject
+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)image fromContextMenu:(BOOL)context;
+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)image iconView:(SBIconView *)icon fromContextMenu:(BOOL)context;
@end
@implementation ADSwipeTestController
""" + method + """
+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)image iconView:(SBIconView *)icon fromContextMenu:(BOOL)context {
    swipeImage = image;
    swipeIcon = icon;
    swipeContext = context;
}
@end
"""
    (work / "SwipeTraversalImplementation.h").write_text(header)
    executable = work / "AppDataMenuTests"
    subprocess.run([
        "xcrun", "clang", "-fobjc-arc", "-Wall", "-Wextra", "-Werror",
        "-I", str(root / "Tests"), "-I", str(work),
        "-framework", "Foundation", "-Wl,-export_dynamic",
        str(root / "Tests/AppDataMenuTests.m"), "-o", str(executable)
    ], check=True)
    subprocess.run([str(executable)], check=True)
