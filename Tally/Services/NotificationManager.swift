//
//  NotificationManager.swift
//  Tally
//
//  Created by Ninad Mankar on 4/18/26.
//



import NotificationCenter
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    private let notificationIdentifier = "tally.expense.reminder"

    // Requests permission from the user to show notifications.
    // Called once on app launch.
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }

    // Schedules a repeating notification every 5 minutes for testing.
    // TODO:Change interval to 6 * 60 * 60for production.
    func scheduleExpenseReminder() {
        // Cancel any existing reminder first to avoid duplicates.
        cancelExpenseReminder()

        let content = UNMutableNotificationContent()
        content.title = "Tally"
        content.body = "Don't forget to add your expenses!"
        content.sound = .default

        // 5 minutes in seconds for testing.
        // Change to 21600 for production (6 hours).
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1 * 60,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Expense reminder scheduled every 5 minutes.")
            }
        }
    }

    // Cancels the scheduled expense reminder.
    func cancelExpenseReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    // Checks if the reminder is currently scheduled.
    func isReminderScheduled() async -> Bool {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pending.contains { $0.identifier == notificationIdentifier }
    }

    // Checks current authorization status without prompting the user.
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
