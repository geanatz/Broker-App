import 'package:flutter/material.dart'; // For potential Color or IconData usage

/// Enum defining the different types of statistics that can be displayed
/// in the UserWidget's rotating section.
enum UserStatType {
  callsToday,
  callsThisWeek,
  meetingsToday,
  meetingsThisWeek,
  progressToMonthlyGoal, // Example: based on calls, revenue, etc.
}

/// Represents the configuration for a single user statistic display.
class UserStatConfig {
  final UserStatType type;
  final String label;          // Text label (e.g., "Apeluri Azi", "Progres Lunar")
  final String value;          // The formatted value to display (e.g., "15", "75%")
  final double? progress;      // Optional progress value (0.0 to 1.0) for progress bar stats
  final IconData? icon;        // Optional icon to display alongside the stat

  const UserStatConfig({
    required this.type,
    required this.label,
    required this.value,
    this.progress,
    this.icon,
  });
}

// Function to get sample stats (replace with actual data fetching)
List<UserStatConfig> getSampleUserStats() {
  return [
    // Progress bar stat (no label needed as it's shown differently)
    const UserStatConfig(
      type: UserStatType.progressToMonthlyGoal,
      label: '', // Empty label since progress bar doesn't show labels
      value: '68%',
      progress: 0.68,
      icon: Icons.show_chart,
    ),
    // Value stats with concise labels for horizontal display
    const UserStatConfig(
      type: UserStatType.callsToday,
      label: 'Apeluri azi',
      value: '12',
      icon: Icons.call,
    ),
    const UserStatConfig(
      type: UserStatType.meetingsThisWeek,
      label: 'Intalniri sapt.',
      value: '5',
      icon: Icons.calendar_today,
    ),
    const UserStatConfig(
      type: UserStatType.callsThisWeek,
      label: 'Apeluri sapt.',
      value: '42',
      icon: Icons.call,
    ),
  ];
} 