# Personal Lockdown Firewall (iOS)

This personal build of Lockdown provides a local, on-device firewall and Safari content blocker. It keeps the packet-tunnel extension, Safari blocker, firewall WidgetKit extension, shared block lists, allowlist, logs, metrics, and local notifications.

It does not include Lockdown's commercial Secure Tunnel, accounts, subscriptions, StoreKit, paywalls, onboarding, CloudKit, APNs, or legacy Today widgets. It makes no Lockdown account, subscription, purchase, or VPN-credential requests.

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

To sign the app for devices, you need an Apple Developer team provisioned for the packet-tunnel Network Extension and the shared App Group. The app embeds exactly three extensions: `LockdownTunnel`, `Lockdown Blocker`, and `LockdownFirewallWidgetExtension`.

### Contact

[team@lockdownprivacy.com](mailto:team@lockdownprivacy.com)

### License

This project is licensed under the GPL License - see the [LICENSE.md](LICENSE.md) file for details.

