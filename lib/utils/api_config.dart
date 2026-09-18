class ApiConfig {
  // ---------------------------------------------------------------------------
  // LOCAL TESTING over the USB cable. Run this once with the phone plugged in:
  //     adb reverse tcp:8080 tcp:8080
  // The phone's own localhost:8080 is then tunnelled to the PC's, so this works
  // regardless of Wi-Fi, firewall rules or the PC's IP changing. Re-run the command
  // after unplugging or rebooting the phone - the tunnel does not survive either.
  // Alternative for testing over USB instead of Wi-Fi. Run this once with the phone
  // plugged in:  adb reverse tcp:8080 tcp:8080
  // Use this if the Wi-Fi address below gives "No route to host" - it bypasses the
  // network and firewall entirely.
  // static const String baseUrl = "http://localhost:8080";

  // LOCAL TESTING over Wi-Fi - the PC's Wi-Fi adapter address from `ipconfig`.
  // Needs the phone on the same network and inbound port 8080 allowed through the
  // Windows firewall. Not the Tailscale address, which has failed here before.
  // static const String baseUrl = "http://192.168.0.102:8080";

  // PRODUCTION - restore this before building a release APK for the factory.
  // No /smo suffix even though the WAR deploys to Tomcat's /smo context: nginx already
  // rewrites the domain root onto it (proxy_pass http://127.0.0.1:8080/smo/), so
  // including it here would double up the path.
  static const String baseUrl = "https://smobza.thegttech.com";
  // ---------------------------------------------------------------------------
}
