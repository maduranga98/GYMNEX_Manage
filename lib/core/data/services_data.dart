// lib/features/profilles/widgets/services_data.dart
class ServicesData {
  // Predefined services list with indices
  static const List<Map<String, dynamic>> availableServices = [
    {
      "name": "Weight Training",
      "icon": "🏋️‍♂️",
      "description":
          "Full set of free weights and machines for strength training.",
    },
    {
      "name": "Cardio Zone",
      "icon": "🏃‍♂️",
      "description":
          "Treadmills, ellipticals, and stationary bikes for cardio workouts.",
    },
    {
      "name": "Personal Training",
      "icon": "👨‍🏫",
      "description":
          "One-on-one professional coaching to reach your fitness goals.",
    },
    {
      "name": "Group Classes",
      "icon": "👯‍♂️",
      "description": "Zumba, yoga, HIIT, and other group workout sessions.",
    },
    {
      "name": "Sauna",
      "icon": "🔥",
      "description": "Relaxing heat therapy to detox and unwind.",
    },
    {
      "name": "Steam Room",
      "icon": "💨",
      "description": "Moist heat to open pores and improve circulation.",
    },
    {
      "name": "Swimming Pool",
      "icon": "🏊‍♂️",
      "description":
          "Indoor or outdoor pool for lap swimming and water aerobics.",
    },
    {
      "name": "Showers",
      "icon": "🚿",
      "description": "Clean, private showering facilities.",
    },
    {
      "name": "Lockers",
      "icon": "🔒",
      "description": "Secure storage for personal belongings.",
    },
    {
      "name": "Wi-Fi",
      "icon": "📶",
      "description": "Free high-speed internet access throughout the gym.",
    },
    {
      "name": "Parking",
      "icon": "🅿️",
      "description": "On-site parking available for members.",
    },
    {
      "name": "Juice Bar",
      "icon": "🥤",
      "description":
          "Refreshing protein shakes, smoothies, and healthy snacks.",
    },
    {
      "name": "Kids Area",
      "icon": "👶",
      "description": "A play area for children while parents work out.",
    },
    {
      "name": "Yoga Studio",
      "icon": "🧘‍♀️",
      "description": "Dedicated quiet space for yoga and stretching.",
    },
    {
      "name": "CrossFit Area",
      "icon": "🧱",
      "description": "Special zone for CrossFit-style functional workouts.",
    },
    {
      "name": "TRX / Suspension Zone",
      "icon": "🪢",
      "description": "Full-body resistance training equipment.",
    },
    {
      "name": "Cycling Studio",
      "icon": "🚴‍♂️",
      "description": "Indoor spin classes with music and metrics.",
    },
    {
      "name": "Body Composition Test",
      "icon": "⚖️",
      "description": "Analyze fat %, muscle mass, and more.",
    },
    {
      "name": "Shower Towels",
      "icon": "🧼",
      "description": "Fresh towels provided for post-workout use.",
    },
    {
      "name": "Smart Mirrors",
      "icon": "🪞",
      "description":
          "Interactive mirrors for form correction and guided workouts.",
    },
    {
      "name": "Air Conditioning",
      "icon": "❄️",
      "description": "Climate-controlled environment for comfort.",
    },
  ];

  /// Static method to get services by indices
  static List<Map<String, dynamic>> getServicesByIndices(List<int> indices) {
    return indices
        .map((index) {
          if (index >= 0 && index < availableServices.length) {
            return availableServices[index];
          }
          return null;
        })
        .where((service) => service != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Get service by single index
  static Map<String, dynamic>? getServiceByIndex(int index) {
    if (index >= 0 && index < availableServices.length) {
      return availableServices[index];
    }
    return null;
  }

  /// Get total number of available services
  static int get totalServices => availableServices.length;

  /// Get all available services
  static List<Map<String, dynamic>> get allServices =>
      List.from(availableServices);
}
