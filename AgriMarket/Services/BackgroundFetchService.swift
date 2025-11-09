//
//  BackgroundFetchService.swift
//  AgriMarket
//
//  Background data fetching and updates
//

import Foundation
import BackgroundTasks
import UIKit

class BackgroundFetchService {
    static let shared = BackgroundFetchService()

    private let syncService = DataSyncService.shared

    // Background task identifiers
    private let refreshTaskIdentifier = "com.agrimarket.refresh"
    private let cleanupTaskIdentifier = "com.agrimarket.cleanup"

    private init() {}

    // MARK: - Register Background Tasks

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: cleanupTaskIdentifier,
            using: nil
        ) { task in
            self.handleCleanup(task: task as! BGProcessingTask)
        }

        print("✅ Background tasks registered")
    }

    // MARK: - Schedule Tasks

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ App refresh scheduled")
        } catch {
            print("❌ Could not schedule app refresh: \(error)")
        }
    }

    func scheduleCleanup() {
        let request = BGProcessingTaskRequest(identifier: cleanupTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60) // 24 hours
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Cleanup scheduled")
        } catch {
            print("❌ Could not schedule cleanup: \(error)")
        }
    }

    // MARK: - Handle Background Tasks

    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("🔄 Background refresh started")

        // Schedule next refresh
        scheduleAppRefresh()

        let refreshTask = Task {
            do {
                try await syncService.performFullSync()
                task.setTaskCompleted(success: true)
                print("✅ Background refresh completed")

                // Send notification if there are important updates
                await self.checkForImportantUpdates()
            } catch {
                task.setTaskCompleted(success: false)
                print("❌ Background refresh failed: \(error)")
            }
        }

        // Handle expiration
        task.expirationHandler = {
            refreshTask.cancel()
            print("⚠️ Background refresh expired")
        }
    }

    private func handleCleanup(task: BGProcessingTask) {
        print("🧹 Background cleanup started")

        // Schedule next cleanup
        scheduleCleanup()

        let cleanupTask = Task {
            do {
                await syncService.clearOldData()
                task.setTaskCompleted(success: true)
                print("✅ Background cleanup completed")
            } catch {
                task.setTaskCompleted(success: false)
                print("❌ Background cleanup failed")
            }
        }

        // Handle expiration
        task.expirationHandler = {
            cleanupTask.cancel()
            print("⚠️ Background cleanup expired")
        }
    }

    // MARK: - Check for Important Updates

    private func checkForImportantUpdates() async {
        // Check for significant price changes
        let repository = CommodityRepository.shared

        do {
            let commodities = try await repository.fetchFavoriteCommodities()

            for commodity in commodities {
                // If price changed more than 5%
                if abs(commodity.dayChangePercent) >= 5.0 {
                    sendPriceAlertNotification(for: commodity)
                }
            }
        } catch {
            print("Error checking for updates: \(error)")
        }
    }

    // MARK: - Notifications

    private func sendPriceAlertNotification(for commodity: Commodity) {
        let content = UNMutableNotificationContent()
        content.title = "Price Alert: \(commodity.name)"
        content.body = String(format: "%@ %+.2f%%",
                            commodity.dayChange >= 0 ? "Up" : "Down",
                            abs(commodity.dayChangePercent))
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PRICE_ALERT"
        content.userInfo = ["commodityId": commodity.id]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Price alert sent for \(commodity.name)")
            }
        }
    }

    // MARK: - App Lifecycle

    func handleAppDidEnterBackground() {
        // Schedule background tasks
        scheduleAppRefresh()

        // Check if periodic cleanup is needed
        let lastCleanup = UserDefaults.standard.object(forKey: "lastCleanupDate") as? Date
        let shouldScheduleCleanup = lastCleanup == nil ||
            Date().timeIntervalSince(lastCleanup!) > 24 * 60 * 60

        if shouldScheduleCleanup {
            scheduleCleanup()
        }
    }

    func handleAppWillEnterForeground() {
        // Cancel scheduled tasks as app is now active
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: refreshTaskIdentifier)

        // Perform immediate sync if needed
        Task {
            if syncService.isSyncNeeded() {
                try? await syncService.performFullSync()
            }
        }
    }

    // MARK: - Request Notification Permission

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }

        // Register notification categories
        registerNotificationCategories()
    }

    private func registerNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: .foreground
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: .destructive
        )

        let priceAlertCategory = UNNotificationCategory(
            identifier: "PRICE_ALERT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([priceAlertCategory])
    }
}

// MARK: - App Delegate Integration

extension BackgroundFetchService {
    func setupForAppDelegate() {
        registerBackgroundTasks()
        requestNotificationPermission()
    }
}
