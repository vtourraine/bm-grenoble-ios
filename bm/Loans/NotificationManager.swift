//
//  NotificationManager.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 20/07/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI

class NotificationManager {

    static func askPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }

            print("granted: \(granted)")
        }
    }

    static func scheduleNotifications(for items: [Item]) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        var shift = DateComponents()
        shift.day = -16

        removeAllNotifications(from: center)

        guard let item = items.first,
              let formattedReturnDate = item.returnDateComponents.formattedReturnDate(),
              let returnDate = calendar.date(from: item.returnDateComponents),
              let notificationDate = calendar.date(byAdding: shift, to: returnDate) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("You have \(items.count) documents to return soon", comment: "")
        content.subtitle = NSLocalizedString("Due \(formattedReturnDate.localizedDate)", comment: "")
        content.body = items.map({ "• \($0.title)" }).joined(separator: "\n")

        var notificationDateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
        notificationDateComponents.hour = 16
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    static func removeAllNotifications(from center: UNUserNotificationCenter) {
        center.removeAllPendingNotificationRequests()
    }
}
