class UpdateConfig {
  // GitHub Repository Configuration
  static const String githubOwner = 'your-username';
  static const String githubRepo = 'Broker-App';
  static const String githubApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
  
  // In-App Update Settings (Discord-style)
  static const bool inAppUpdatesEnabled = true; // Activeaza update-uri in-app
  static const bool backgroundDownloadEnabled = true; // Download in background
  static const bool autoInstallEnabled = true; // Instaleaza automat dupa download
  static const bool silentInstallEnabled = false; // Instaleaza fara notificare (doar pentru update-uri mici)
  
  // Update Behavior
  static const Duration checkInterval = Duration(hours: 2); // Verifica mai des pentru update-uri
  static const Duration timeoutDuration = Duration(minutes: 5); // Timeout mai mare pentru download-uri
  static const int maxRetries = 5; // Mai multe retry-uri pentru stabilitate
  static const bool autoUpdateEnabled = true; // Activeaza update-ul automat
  static const bool forcedUpdateEnabled = false; // Forteaza update-ul (opreste aplicatia daca nu se updateaza)
  
  // Windows-specific Settings
  static const String windowsAssetName = 'broker-app-windows.zip';
  static const String windowsExecutableName = 'broker_app.exe';
  static const String windowsInstallerName = 'BrokerAppInstaller.exe';
  static const String windowsUpdateDir = 'updates'; // Director pentru update-uri temporare
  
  // Download Settings
  static const int downloadChunkSize = 8192; // Chunk size pentru download (8KB)
  static const Duration progressUpdateInterval = Duration(milliseconds: 500); // Cat de des sa updateze progresul
  static const bool compressUpdates = true; // Comprima fișierele de update
  static const bool validateChecksums = true; // Valideaza checksum-urile fișierelor
  
  // Backup Settings
  static const bool createBackup = true; // Creaza backup inainte de update
  static const int maxBackups = 5; // Numar maxim de backup-uri pastrate
  static const String backupSuffix = '_backup'; // Sufixul pentru directoarele de backup
  
  // Notification Settings
  static const bool showUpdateNotifications = true; // Afiseaza notificari pentru update-uri
  static const bool showProgressNotifications = true; // Afiseaza progres in notificari
  static const bool showCompletionNotification = true; // Notifica cand update-ul e gata
  static const Duration notificationDuration = Duration(seconds: 5); // Durata notificarilor
  
  // Update Messages
  static const String updateAvailableTitle = 'Update disponibil';
  static const String updateAvailableMessage = 'O versiune noua a aplicatiei este disponibila. Doriti sa o descarcati?';
  static const String updateDownloadingTitle = 'Se descarca update-ul';
  static const String updateDownloadingMessage = 'Descarcarea este in progres...';
  static const String updateReadyTitle = 'Update gata de instalare';
  static const String updateReadyMessage = 'Update-ul a fost descarcat. Restartati aplicatia pentru a-l instala.';
  static const String updateInstallingTitle = 'Se instaleaza update-ul';
  static const String updateInstallingMessage = 'Va rugam asteptati...';
  static const String updateSuccessTitle = 'Update complet';
  static const String updateSuccessMessage = 'Aplicatia a fost actualizata cu succes!';
  static const String updateFailedTitle = 'Update esuat';
  static const String updateFailedMessage = 'Nu s-a putut actualiza aplicatia. Incercati din nou.';
  
  // Development Settings
  static const bool debugMode = true; // Activeaza loguri detaliate
  static const bool skipVersionCheck = false; // Sare peste verificarea versiunii (pentru testing)
  static const String testVersion = '999.999.999'; // Versiune de test
  static const bool enableBetaUpdates = false; // Activeaza update-uri beta
  
  /// Obtine numele fisierului pentru Windows
  static String getWindowsAssetName() {
    return windowsAssetName;
  }
  
  /// Verifica daca platforma suporta update-uri in-app
  static bool supportsInAppUpdates(String platform) {
    // Doar Windows deocamdata
    return platform.toLowerCase() == 'windows' && inAppUpdatesEnabled;
  }
  
  /// Verifica daca platforma este suportata pentru update-uri
  static bool isPlatformSupported(String platform) {
    // Doar Windows pentru in-app updates
    return platform.toLowerCase() == 'windows';
  }
  
  /// Obtine directorul pentru update-uri temporare
  static String getUpdateDirectory() {
    return windowsUpdateDir;
  }
  
  /// Obtine numele executabilului principal
  static String getExecutableName() {
    return windowsExecutableName;
  }
  
  /// Obtine numele installer-ului
  static String getInstallerName() {
    return windowsInstallerName;
  }
  
  /// Verifica daca download-ul in background este activat
  static bool isBackgroundDownloadEnabled() {
    return backgroundDownloadEnabled && inAppUpdatesEnabled;
  }
  
  /// Verifica daca instalarea automata este activata
  static bool isAutoInstallEnabled() {
    return autoInstallEnabled && inAppUpdatesEnabled;
  }
  
  /// Verifica daca instalarea silentioasa este activata
  static bool isSilentInstallEnabled() {
    return silentInstallEnabled && inAppUpdatesEnabled;
  }
} 