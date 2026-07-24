class ApiConfig {
  // PC's LAN Wi-Fi IP. Only reachable when the phone is on the same Wi-Fi network
  // as the PC. If the PC reconnects to Wi-Fi or changes networks, re-check with
  // `ipconfig` (look for the Wi-Fi adapter's IPv4 address) and update this.
  static const String baseUrl = "http://192.168.1.13:8080";
}
