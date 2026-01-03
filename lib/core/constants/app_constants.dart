/// Application-wide constants
class AppConstants {
  // Database
  static const String databaseName = 'local_music_player.db';
  static const int databaseVersion = 2; // Incremented for workflow and action history
  
  // Table names
  static const String tracksTable = 'tracks';
  static const String usersTable = 'users';
  static const String actionHistoryTable = 'action_history';
  
  // Audio
  static const String audioRecordingsPath = 'recordings';
  
  // UI
  static const int maxSearchResults = 100;
}
