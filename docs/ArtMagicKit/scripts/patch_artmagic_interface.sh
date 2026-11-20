#!/bin/sh
# IosArtMagic.xcframework is built with Swift 6.4: its .swiftinterface files print module selectors
# (`Swift::String`, `IosArtMagic::UpgradeProfile`) that Xcode 26.x (Swift 6.2) cannot parse
# ("expected dictionary value type"). Dropping the `Module::` prefixes gives an equivalent interface.
# Only the text interfaces change; the binary is untouched. Safe to re-run. Run it again after
# replacing the xcframework with a new vendor build (or delete it once the vendor ships a Swift 6.2 build).
set -e
cd "$(dirname "$0")/../IosArtMagic.xcframework"
find . -name '*.swiftinterface' -exec perl -pi -e 's/\b[A-Za-z_]\w*:://g' {} +
echo "patched $(find . -name '*.swiftinterface' | wc -l | tr -d ' ') interface files"
