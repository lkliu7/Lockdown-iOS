# Lockdown Privacy (iOS)

Lockdown is an open source firewall that blocks trackers, ads, and badware in all apps. Product details at [lockdownprivacy.com](https://lockdownprivacy.com).

### Feature Requests + Bugs

Create an issue on Github for feature requests and bug reports.

### Openly Operated

Lockdown achieves the highest level of transparency for both client and server via the Openly Operated standard. It has also been audited multiple times, the latest audit in July 2020. See the full reports here: [Audit Kits](https://openlyoperated.org/report/confirmedvpn)

### Contributing

Pull requests are welcome - please document any changes and potential bugs.

### Build Instructions

1. Install Xcode 26.6 or newer with the iOS 26.5 SDK.

2. Install CocoaPods and the acknowledgements plugin required by the `Podfile`:

   ```sh
   brew install cocoapods
   "$(brew --prefix ruby)/bin/gem" install cocoapods-acknowledgements --user-install --no-document
   ```

3. Install the locked dependencies:

   ```sh
   pod install --deployment
   ```

4. Open `LockdowniOS.xcworkspace` and build the `Lockdown` scheme.

The Carthage-built dependencies are checked in as XCFrameworks under `ThirdPartyFrameworks`; do not run `carthage update` for a normal build.

To sign the app for devices, you need an Apple Developer team provisioned for the app's Network Extension, App Group, iCloud, push notification, and associated-domain capabilities. If you do not belong to the existing team, replace the bundle IDs and shared container identifiers with identifiers owned by your team.

### Limitations to Building Locally

If you build Lockdown locally, you will not be able to access Secure Tunnel, because that requires a Production app store receipt. We will soon enable a DEV environment for Secure Tunnel with limited capacity and regions, designed only for testing.

To use Secure Tunnel, you must download Lockdown from the [App Store](https://lockdownprivacy.com).

### Contact

[team@lockdownprivacy.com](mailto:team@lockdownprivacy.com)

### License

This project is licensed under the GPL License - see the [LICENSE.md](LICENSE.md) file for details.


