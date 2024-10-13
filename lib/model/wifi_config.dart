class WiFiConfig {
  String wifiSSID;
  String wifiPassword;
  String username;
  String userPassword; // New field added

  WiFiConfig({
    required this.wifiSSID,
    required this.wifiPassword,
    required this.username,
    required this.userPassword, // Include in constructor
  });

  // Factory method to create a WiFiConfig object from JSON
  factory WiFiConfig.fromJson(Map<String, dynamic> json) {
    return WiFiConfig(
      wifiSSID: json['WiFi_SSID'] ?? '',
      wifiPassword: json['WiFi_Password'] ?? '',
      username: json['Username'] ?? '',
      userPassword: json['userPassword'] ?? '', // Handle userPassword
    );
  }

  // Method to convert a WiFiConfig object to JSON
  Map<String, dynamic> toJson() {
    return {
      'WiFi_SSID': wifiSSID,
      'WiFi_PASSWORD': wifiPassword,
      'Username': username,
      'Password': userPassword, // Include userPassword in JSON
    };
  }
}
