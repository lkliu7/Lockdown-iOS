# Personal Firewall-Only Cleanup Verification

Verified on July 19, 2026 with Xcode 26.6 and the iOS 26.5 SDK.

## Result

The application is now a local firewall and Safari blocker with Firewall and Settings tabs. The Xcode application target embeds exactly these three extensions:

- `LockdownTunnel`
- `Lockdown Blocker`
- `LockdownFirewallWidgetExtension`

The legacy Today extensions and commercial Secure Tunnel, account, subscription, StoreKit, paywall, onboarding, questionnaire, CloudKit, APNs, review, share, and promotional implementations have been removed.

## Build and test verification

- Generic iOS Simulator Debug build: passed.
- Generic iOS device Debug build with signing disabled: passed.
- Unit and snapshot tests on an iOS 17.5 iPhone 15 simulator: 14 passed, 0 failed.
  - 7 domain validator tests
  - 1 application smoke test
  - 4 firewall/settings snapshot tests
  - 2 tracker metadata tests
- `pod install`: passed with 4 application dependencies and 5 total pods, including the test-only SnapshotTesting pod.
- `git diff --check`: passed.

The final test result bundle is:

`/tmp/LockdownPersonalTestsDerived/Logs/Test/Test-Lockdown-2026.07.19_00-40-46--0700.xcresult`

## Debug simulator bundle comparison

Both bundles were clean, unsigned, universal arm64 + x86_64 builds made with the same Xcode, SDK, scheme, configuration, and generic simulator destination. The baseline was reconstructed from Git `HEAD` in a temporary directory with its locked pod versions.

| Measurement | Baseline | Firewall-only | Reduction |
|---|---:|---:|---:|
| Complete `.app` disk usage | 172,932 KiB | 51,864 KiB | 121,068 KiB (70.0%) |
| Embedded frameworks | 14,620 KiB | 7,552 KiB | 7,068 KiB (48.3%) |
| Embedded extension count | 5 | 3 | 2 |
| Legacy VPN Today extension | 19,348 KiB | 0 | 19,348 KiB |
| Legacy firewall Today extension | 19,448 KiB | 0 | 19,448 KiB |
| WidgetKit extension | 20,492 KiB | 768 KiB | 19,724 KiB (96.3%) |

Rounded complete-bundle sizes are 169 MiB before and 51 MiB after, a reduction of about 118 MiB for this universal Debug build.

Additional measured source/resource removals:

- Duplicate main-target blocker JSON: 9,232,384 bytes (8.8 MiB). The files remain only in the Safari extension.
- Deleted commercial/onboarding/paywall/VPN/promotional assets: 15,747,817 bytes (15.0 MiB) in the repository.
  - Onboarding: 12,318,846 bytes
  - Paywall: 2,405,961 bytes
  - VPN asset group: 295,063 bytes
  - The remainder is subscription-plan, questionnaire, review/share, welcome, and related promotional artwork.
- Deleted unused fonts: 3,719,580 bytes (3.55 MiB).

## Resource and dependency audit

- The main app contains only `tracker_info.json`; it contains none of the five Safari blocker JSON files.
- `Lockdown Blocker.appex` contains all five blocker files: `adBlockList.json`, `adBlockListTwo.json`, `adBlockListThree.json`, `privacyBlockList.json`, and `socialBlockList.json`.
- The final bundle contains no paths named for VPN, paywall, onboarding, subscription, StoreKit, CloudKit, PromiseKit, KeychainAccess, or SwiftyStoreKit.
- The application pods are only SwiftMessages, PopupDialog/DynamicBlurView, and SwiftCSV. SnapshotTesting is test-only.
- The packet tunnel and firewall widget do not use CocoaPods.
- The firewall widget compiles only `Defaults.swift`, `LoadingCircle.swift`, `LockdownFirewallWidget.swift`, `Metrics.swift`, and `UserDefaults.swift`, and links only SwiftUI and WidgetKit.

## Capability audit

The application and packet tunnel entitlements contain only the packet-tunnel Network Extension and `group.com.confirmed`. The Safari blocker and WidgetKit extension contain only the shared app group. No entitlement file or project setting contains APNs, iCloud, ubiquity, associated-domain, or keychain-group capabilities.

The application background mode is fetch only. Local notifications remain implemented through `UNUserNotificationCenter`; the app does not register with APNs.

## Runtime follow-up

The build and automated UI snapshot coverage verify startup and the firewall/settings screens. Network Extension permission, live tunnel enable/disable and repair, Safari blocker reload, widget gallery/link behavior, and notification delivery still require a signed fresh install on a physical device because those system integrations cannot be exercised by the unsigned generic build or unit-test host.
