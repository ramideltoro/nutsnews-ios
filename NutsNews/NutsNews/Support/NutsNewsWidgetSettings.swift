//
//  NutsNewsWidgetSettings.swift
//  NutsNews
//

import Foundation
import WidgetKit

enum NutsNewsWidgetSettings {
    static let appGroupID = "group.com.nutsnews.app"

    static let themeRawValueKey = "nutsnews.widget.selectedTheme"
    static let readingStatsRawValueKey = "nutsnews.widget.readingStatsRawValue"
    static let dailyGoalKey = "nutsnews.widget.dailyGoal"
    static let showStatsOnLargeWidgetKey = "nutsnews.widget.showStatsOnLargeWidget"

    static let defaultShowStatsOnLargeWidget = true

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func sync(
        themeRawValue: String,
        readingStatsRawValue: String,
        dailyGoal: Int,
        reloadWidget: Bool = true
    ) {
        let defaults = sharedDefaults
        defaults.set(themeRawValue, forKey: themeRawValueKey)
        defaults.set(readingStatsRawValue, forKey: readingStatsRawValueKey)
        defaults.set(max(1, min(dailyGoal, 5)), forKey: dailyGoalKey)

        if defaults.object(forKey: showStatsOnLargeWidgetKey) == nil {
            defaults.set(defaultShowStatsOnLargeWidget, forKey: showStatsOnLargeWidgetKey)
        }

        if reloadWidget {
            WidgetCenter.shared.reloadTimelines(ofKind: "NutsNewsDailyWidget")
        }
    }

    static func syncTheme(_ themeRawValue: String, reloadWidget: Bool = true) {
        sharedDefaults.set(themeRawValue, forKey: themeRawValueKey)

        if reloadWidget {
            WidgetCenter.shared.reloadTimelines(ofKind: "NutsNewsDailyWidget")
        }
    }

    static func syncReadingStats(_ readingStatsRawValue: String, reloadWidget: Bool = true) {
        sharedDefaults.set(readingStatsRawValue, forKey: readingStatsRawValueKey)

        if reloadWidget {
            WidgetCenter.shared.reloadTimelines(ofKind: "NutsNewsDailyWidget")
        }
    }

    static func syncDailyGoal(_ dailyGoal: Int, reloadWidget: Bool = true) {
        sharedDefaults.set(max(1, min(dailyGoal, 5)), forKey: dailyGoalKey)

        if reloadWidget {
            WidgetCenter.shared.reloadTimelines(ofKind: "NutsNewsDailyWidget")
        }
    }

    static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "NutsNewsDailyWidget")
    }
}
