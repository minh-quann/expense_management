class AppConstants {
  // Google OAuth 2.0 Web Client ID (from Google Cloud Console / Firebase)
  // Required on Android to retrieve the ID Token for backend verification.
  // Example: "xxxxxx-xxxxxxxxx.apps.googleusercontent.com"
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '60389078259-oq4dn3njpjrke1pmi7rfdq8is10fckhh.apps.googleusercontent.com',
  );
}
