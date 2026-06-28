//
//  NutsNewsReminderCenter.swift
//  NutsNews
//

import Foundation
import UserNotifications

enum NutsNewsReminderCenter {
    static let dailyReminderIdentifier = "nutsnews.daily.good-news-reset"

    static func scheduleDailyReminder(hour: Int) async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else {
                await removeDailyReminder()
                return
            }

            await removeDailyReminder()

            var dateComponents = DateComponents()
            dateComponents.hour = min(max(hour, 0), 23)
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "Your NutsNews reset is ready"
            content.body = "Take a minute for today’s calm, positive stories."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: dailyReminderIdentifier,
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        } catch {
            await removeDailyReminder()
        }
    }

    static func removeDailyReminder() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }
}
