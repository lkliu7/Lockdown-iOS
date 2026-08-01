import CocoaLumberjackSwift
import PopupDialog
import UIKit
import UserNotifications

extension PushNotifications.Authorization {
    enum SystemAuthenticationStatus {
        case success
        case deniedPreviously
        case deniedNow
        case undetermined
    }

    static func requestWeeklyUpdateAuthorization(
        presentingDialogOn viewController: UIViewController,
        completion: @escaping (Result<Status, Error>) -> Void
    ) {
        if getUserWantsNotificationsEnabled(forCategory: .weeklyUpdate) {
            authorizeWithSystemAfterUserApproval { result in
                handleSystemResult(result, presentingOn: viewController, completion: completion)
            }
            return
        }

        let popup = PopupDialog(
            title: NSLocalizedString("Stay Protected", comment: ""),
            message: NSLocalizedString(
                "Enable notifications to get a once-a-week local summary. You can disable this anytime.",
                comment: ""
            ),
            image: UIImage(named: "notification_example"),
            buttonAlignment: .horizontal,
            transitionStyle: .bounceDown,
            preferredWidth: 270,
            tapGestureDismissal: false,
            panGestureDismissal: false,
            hideStatusBar: false
        )

        let no = CancelButton(title: NSLocalizedString("No", comment: ""), dismissOnTap: true) {
            setUserWantsNotificationsEnabled(false, forCategory: .weeklyUpdate)
            completion(.success(.notAuthorized))
        }
        let yes = DefaultButton(title: NSLocalizedString("Enable", comment: ""), dismissOnTap: true) {
            setUserWantsNotificationsEnabled(true, forCategory: .weeklyUpdate)
            authorizeWithSystemAfterUserApproval { result in
                handleSystemResult(result, presentingOn: viewController, completion: completion)
            }
        }
        yes.buttonColor = .tunnelsBlue
        yes.titleColor = .white
        popup.addButtons([no, yes])
        viewController.present(popup, animated: true)
    }

    private static func handleSystemResult(
        _ result: Result<SystemAuthenticationStatus, Error>,
        presentingOn viewController: UIViewController,
        completion: @escaping (Result<Status, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(.success):
                completion(.success(.authorized))
            case .success(.deniedPreviously):
                setUserWantsNotificationsEnabled(false, forCategory: .weeklyUpdate)
                showGoToSettingsPopup(on: viewController) {
                    completion(.success(.notAuthorized))
                }
            case .success(.deniedNow), .success(.undetermined):
                setUserWantsNotificationsEnabled(false, forCategory: .weeklyUpdate)
                completion(.success(.notAuthorized))
            }
        }
    }

    static func showGoToSettingsPopup(on viewController: UIViewController, completion: @escaping () -> Void) {
        let popup = PopupDialog(
            title: NSLocalizedString(
                "Enable notifications in iOS Settings > Notifications > Lockdown",
                comment: ""
            ),
            message: nil,
            image: nil,
            buttonAlignment: .vertical,
            transitionStyle: .bounceDown,
            preferredWidth: 270,
            tapGestureDismissal: true,
            panGestureDismissal: false,
            hideStatusBar: false,
            completion: completion
        )
        popup.addButton(DefaultButton(
            title: NSLocalizedString("Okay", comment: ""),
            dismissOnTap: true,
            action: nil
        ))
        viewController.present(popup, animated: true)
    }

    private static func authorizeWithSystemAfterUserApproval(
        completion: @escaping (Result<SystemAuthenticationStatus, Error>) -> Void
    ) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(.success(.success))
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                    granted,
                    error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.success(granted ? .success : .deniedNow))
                    }
                }
            case .denied:
                completion(.success(.deniedPreviously))
            @unknown default:
                completion(.success(.undetermined))
            }
        }
    }
}
