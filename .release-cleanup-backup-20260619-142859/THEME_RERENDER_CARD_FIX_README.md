Fixes card rendering during theme changes by removing forced .id rebuilds from cards/lists/detail. Views still observe AppStorage and animate theme color changes without resetting card layout.
