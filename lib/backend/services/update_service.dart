import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'update_config.dart';
import 'dart:async';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // State pentru update-uri in-app (Discord-style)
  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  bool _isUpdateReady = false;
  String? _latestVersion;
  String? _currentVersion;
  String? _downloadUrl;
  String? _updateFilePath;
  double _downloadProgress = 0.0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;
  
  // Update callbacks pentru UI
  Function(double)? _onDownloadProgress;
  Function(String)? _onStatusChange;
  Function(bool)? _onUpdateReady;
  Function(String)? _onError;
  
  // Getters
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  bool get isInstalling => _isInstalling;
  bool get isUpdateReady => _isUpdateReady;
  double get downloadProgress => _downloadProgress;
  String? get latestVersion => _latestVersion;
  String? get currentVersion => _currentVersion;
  bool get hasUpdate => _latestVersion != null && _currentVersion != null && _isNewerVersion(_latestVersion!, _currentVersion!);
  String get downloadProgressText => _totalBytes > 0 ? 
    '${(_downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB / ${(_totalBytes / 1024 / 1024).toStringAsFixed(1)} MB' : 
    '${(_downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  
  // Callback setters pentru UI
  void setDownloadProgressCallback(Function(double) callback) => _onDownloadProgress = callback;
  void setStatusChangeCallback(Function(String) callback) => _onStatusChange = callback;
  void setUpdateReadyCallback(Function(bool) callback) => _onUpdateReady = callback;
  void setErrorCallback(Function(String) callback) => _onError = callback;
  
  /// Initializeaza serviciul si obtine versiunea curenta
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isWindows) {
      debugPrint('⚠️ UpdateService: Only Windows platform is supported for in-app updates');
      return;
    }
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      debugPrint('🔄 UpdateService initialized - Current version: $_currentVersion');
    } catch (e) {
      debugPrint('❌ Error initializing UpdateService: $e');
    }
  }
  
  /// Verifica daca exista update-uri disponibile
  Future<bool> checkForUpdates() async {
    if (_isChecking || _currentVersion == null || kIsWeb || !Platform.isWindows) return false;
    
    if (UpdateConfig.skipVersionCheck) {
      debugPrint('🔍 Skipping version check (debug mode)');
      return false;
    }
    
    _isChecking = true;
    _updateStatus('Verificare update-uri...');
    
    int retryCount = 0;
    
    while (retryCount < UpdateConfig.maxRetries) {
      try {
        debugPrint('🔍 Checking for updates... (attempt ${retryCount + 1}/${UpdateConfig.maxRetries})');
        
        final response = await http.get(
          Uri.parse(UpdateConfig.githubApiUrl),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ).timeout(UpdateConfig.timeoutDuration);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _latestVersion = data['tag_name']?.toString().replaceAll('v', '');
          
          if (_latestVersion != null) {
            debugPrint('🔍 Latest version found: $_latestVersion');
            debugPrint('🔍 Current version: $_currentVersion');
            
            if (hasUpdate) {
              debugPrint('✅ Update available!');
              _downloadUrl = _getDownloadUrl(data['assets']);
              
              if (_downloadUrl != null) {
                return true;
              } else {
                debugPrint('❌ No Windows asset found in release');
              }
            } else {
              debugPrint('✅ App is up to date');
            }
          }
          break; // Success, exit retry loop
        } else {
          debugPrint('❌ Failed to check updates: ${response.statusCode}');
          if (response.statusCode == 403) {
            debugPrint('❌ Rate limited by GitHub API');
            break; // Don't retry on rate limit
          }
        }
      } catch (e) {
        debugPrint('❌ Error checking for updates (attempt ${retryCount + 1}): $e');
        if (retryCount < UpdateConfig.maxRetries - 1) {
          await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        }
      }
      retryCount++;
    }
    
    _isChecking = false;
    _updateStatus('');
    return false;
  }
  
  /// Porneste download-ul update-ului (Discord-style)
  Future<bool> startDownload() async {
    if (_isDownloading || !hasUpdate || kIsWeb || !Platform.isWindows) return false;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    
    try {
      debugPrint('📥 Starting update download for Windows...');
      _updateStatus('Se descarca update-ul...');
      
      final success = await _downloadUpdate();
      
      if (success) {
        _isUpdateReady = true;
        _onUpdateReady?.call(true);
        _updateStatus('Update gata de instalare');
        debugPrint('✅ Update download completed successfully');
      } else {
        _onError?.call('Eroare la descarcarea update-ului');
        debugPrint('❌ Update download failed');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error during update download: $e');
      _onError?.call('Eroare neașteptată la download: $e');
      return false;
    } finally {
      _isDownloading = false;
    }
  }
  
  /// Instaleaza update-ul descarcat
  Future<bool> installUpdate() async {
    if (!_isUpdateReady || _updateFilePath == null || kIsWeb || !Platform.isWindows) return false;
    
    _isInstalling = true;
    
    try {
      debugPrint('🔧 Starting update installation...');
      _updateStatus('Se instaleaza update-ul...');
      
      final success = await _installWindowsUpdate(_updateFilePath!);
      
      if (success) {
        debugPrint('✅ Update installed successfully');
        // Application will restart automatically
      } else {
        _onError?.call('Eroare la instalarea update-ului');
        debugPrint('❌ Update installation failed');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error during update installation: $e');
      _onError?.call('Eroare neașteptată la instalare: $e');
      return false;
    } finally {
      _isInstalling = false;
    }
  }
  
  /// Metoda legacy pentru compatibilitate - porneste download automat
  Future<bool> startUpdate() async {
    if (!UpdateConfig.isAutoInstallEnabled()) {
      return await startDownload();
    } else {
      // Download si instaleaza automat
      final downloadSuccess = await startDownload();
      if (downloadSuccess) {
        return await installUpdate();
      }
      return false;
    }
  }
  
  /// Obtine mesajul de update pentru Windows
  String getUpdateMessage() {
    if (kIsWeb || !Platform.isWindows) {
      return 'Update-urile in-app sunt disponibile doar pe Windows.';
    }
    return 'O versiune noua este disponibila. Doriti sa o descarcati si instalati?';
  }
  
  /// Compara doua versiuni
  bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      
      // Normalizeaza lungimea
      while (latestParts.length < currentParts.length) {
        latestParts.add(0);
      }
      while (currentParts.length < latestParts.length) {
        currentParts.add(0);
      }
      
      for (int i = 0; i < latestParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error comparing versions: $e');
      return false;
    }
  }
  
  /// Obtine URL-ul de download pentru Windows
  String? _getDownloadUrl(List<dynamic> assets) {
    if (assets.isEmpty) return null;
    
    final targetName = UpdateConfig.getWindowsAssetName();
    
    for (final asset in assets) {
      final assetName = asset['name']?.toString() ?? '';
      if (assetName.contains(targetName.split('.').first)) {
        return asset['browser_download_url'];
      }
    }
    
    return null;
  }
  
  /// Actualizeaza statusul si notifica UI-ul
  void _updateStatus(String status) {
    _onStatusChange?.call(status);
  }
  
  /// Descarca update-ul cu progress tracking
  Future<bool> _downloadUpdate() async {
    if (_downloadUrl == null) return false;
    
    try {
      // Creaza directorul pentru update-uri
      final appSupportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      if (!await updateDir.exists()) {
        await updateDir.create(recursive: true);
      }
      
      _updateFilePath = '${updateDir.path}/broker_app_update.zip';
      
      debugPrint('📥 Downloading to: $_updateFilePath');
      
      final request = http.Request('GET', Uri.parse(_downloadUrl!));
      final response = await request.send();
      
      if (response.statusCode == 200) {
        _totalBytes = response.contentLength ?? 0;
        final file = File(_updateFilePath!);
        final sink = file.openWrite();
        
        _downloadedBytes = 0;
        int lastLoggedProgress = 0;
        
        await response.stream.listen((chunk) {
          _downloadedBytes += chunk.length;
          sink.add(chunk);
          
          if (_totalBytes > 0) {
            _downloadProgress = _downloadedBytes / _totalBytes;
            final progressPercent = (_downloadProgress * 100).round();
            
            // Update UI callback
            _onDownloadProgress?.call(_downloadProgress);
            
            if (progressPercent > lastLoggedProgress && progressPercent % 10 == 0) {
              debugPrint('📥 Download progress: $progressPercent%');
              _updateStatus('Se descarca: $progressPercent%');
              lastLoggedProgress = progressPercent;
            }
          }
        }).asFuture();
        
        await sink.close();
        debugPrint('📥 Download completed: ${(_downloadedBytes / 1024 / 1024).toStringAsFixed(2)} MB');
        
        // Valideaza fisierul descarcat
        return await _validateDownload(_updateFilePath!);
      } else {
        debugPrint('❌ Download failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error downloading update: $e');
      return false;
    }
  }
  
  /// Valideaza fisierul descarcat
  Future<bool> _validateDownload(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ Downloaded file does not exist');
        return false;
      }
      
      final fileSize = await file.length();
      if (fileSize < 1024) { // Minim 1KB
        debugPrint('❌ Downloaded file is too small: $fileSize bytes');
        return false;
      }
      
      // Verifica daca e un fisier ZIP valid
      try {
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        if (archive.isEmpty) {
          debugPrint('❌ Downloaded ZIP file is empty');
          return false;
        }
        debugPrint('✅ Download validation successful: ${archive.length} files in archive');
        return true;
      } catch (e) {
        debugPrint('❌ Downloaded file is not a valid ZIP: $e');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error validating download: $e');
      return false;
    }
  }
  
  /// Instaleaza update-ul pe Windows
  Future<bool> _installWindowsUpdate(String zipPath) async {
    try {
      debugPrint('🔧 Installing Windows update...');
      
      // Extract ZIP
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Get application directory
      final appDir = Directory.current;
      
      // Create backup if enabled
      if (UpdateConfig.createBackup) {
        final backupSuccess = await _createBackup(appDir);
        if (!backupSuccess) {
          debugPrint('❌ Failed to create backup, aborting update');
          return false;
        }
      }
      
      // Extract new files
      int filesInstalled = 0;
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final newFile = File('${appDir.path}/$filename');
          await newFile.create(recursive: true);
          await newFile.writeAsBytes(data);
          filesInstalled++;
        }
      }
      
      debugPrint('✅ Windows update installed successfully ($filesInstalled files)');
      
      // Cleanup download file
      await _cleanupDownload(zipPath);
      
      // Restart application
      await _restartApplication();
      return true;
    } catch (e) {
      debugPrint('❌ Error installing Windows update: $e');
      await _rollbackUpdate();
      return false;
    }
  }
  
  /// Creaza backup inainte de update
  Future<bool> _createBackup(Directory appDir) async {
    if (kIsWeb) {
      debugPrint('⚠️ Backup not supported on web platform');
      return false;
    }
    
    try {
      debugPrint('💾 Creating backup...');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory('${appDir.path}${UpdateConfig.backupSuffix}_$timestamp');
      
      // Sterge backup-uri vechi
      await _cleanupOldBackups(appDir.parent);
      
      // Creaza backup nou
      await _copyDirectory(appDir, backupDir);
      
      debugPrint('✅ Backup created: ${backupDir.path}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating backup: $e');
      return false;
    }
  }
  
  /// Sterge backup-uri vechi
  Future<void> _cleanupOldBackups(Directory parentDir) async {
    try {
      final backupDirs = <Directory>[];
      
      await for (final entity in parentDir.list()) {
        if (entity is Directory && entity.path.contains(UpdateConfig.backupSuffix)) {
          backupDirs.add(entity);
        }
      }
      
      // Sorteaza dupa data
      backupDirs.sort((a, b) => a.path.compareTo(b.path));
      
      // Sterge backup-uri in plus
      while (backupDirs.length > UpdateConfig.maxBackups) {
        final oldBackup = backupDirs.removeAt(0);
        await oldBackup.delete(recursive: true);
        debugPrint('🗑️ Removed old backup: ${oldBackup.path}');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up old backups: $e');
    }
  }
  
  /// Copiaza un director recursiv
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory('${destination.path}/${entity.uri.pathSegments.last}');
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        final newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
        await entity.copy(newFile.path);
      }
    }
  }
  
  /// Sterge fisierul de download
  Future<void> _cleanupDownload(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Cleaned up download file: $filePath');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up download: $e');
    }
  }
  
  /// Rollback la versiunea anterioara
  Future<bool> _rollbackUpdate() async {
    if (kIsWeb) {
      debugPrint('⚠️ Rollback not supported on web platform');
      return false;
    }
    
    try {
      debugPrint('🔄 Rolling back update...');
      
      final appDir = Directory.current;
      final parentDir = appDir.parent;
      
      // Gaseste cel mai recent backup
      Directory? latestBackup;
      int latestTimestamp = 0;
      
      await for (final entity in parentDir.list()) {
        if (entity is Directory && entity.path.contains(UpdateConfig.backupSuffix)) {
          final timestampStr = entity.path.split('${UpdateConfig.backupSuffix}_').last;
          final timestamp = int.tryParse(timestampStr) ?? 0;
          if (timestamp > latestTimestamp) {
            latestTimestamp = timestamp;
            latestBackup = entity;
          }
        }
      }
      
      if (latestBackup != null) {
        // Sterge directorul curent
        await appDir.delete(recursive: true);
        
        // Restabileste backup-ul
        await _copyDirectory(latestBackup, appDir);
        
        debugPrint('✅ Rollback completed successfully');
        return true;
      } else {
        debugPrint('❌ No backup found for rollback');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during rollback: $e');
      return false;
    }
  }
  
  /// Restarteaza aplicatia
  Future<void> _restartApplication() async {
    if (kIsWeb) {
      debugPrint('⚠️ Restart not supported on web platform');
      return;
    }
    
    try {
      debugPrint('🔄 Restarting application...');
      
      await Process.start('cmd', ['/c', 'start', '', Platform.resolvedExecutable], runInShell: true);
      
      // Exit current process
      await Future.delayed(const Duration(milliseconds: 500));
      exit(0);
    } catch (e) {
      debugPrint('❌ Error restarting application: $e');
    }
  }
  
  /// Reseteaza starea serviciului
  void reset() {
    _isChecking = false;
    _isDownloading = false;
    _isInstalling = false;
    _isUpdateReady = false;
    _latestVersion = null;
    _downloadUrl = null;
    _updateFilePath = null;
    _downloadProgress = 0.0;
    _downloadedBytes = 0;
    _totalBytes = 0;
  }
  
  /// Verifica daca exista un update descarcat si gata pentru instalare
  Future<bool> checkForReadyUpdate() async {
    if (kIsWeb || !Platform.isWindows) return false;
    
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      final updateFile = File('${updateDir.path}/broker_app_update.zip');
      
      if (await updateFile.exists()) {
        // Verifica daca fisierul este valid
        final isValid = await _validateDownload(updateFile.path);
        if (isValid) {
          _updateFilePath = updateFile.path;
          _isUpdateReady = true;
          debugPrint('✅ Found ready update: ${updateFile.path}');
          return true;
        } else {
          // Sterge fisierul corupt
          await updateFile.delete();
          debugPrint('🗑️ Deleted corrupted update file');
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking for ready update: $e');
    }
    
    return false;
  }
  
  /// Verifica periodic daca există update-uri în background (Discord-style)
  void startBackgroundUpdateCheck() {
    if (kIsWeb || !Platform.isWindows || !UpdateConfig.isBackgroundDownloadEnabled()) return;
    
    Timer.periodic(UpdateConfig.checkInterval, (timer) async {
      if (_isChecking || _isDownloading) return;
      
      try {
        debugPrint('🔄 Background update check...');
        final hasUpdate = await checkForUpdates();
        
        if (hasUpdate && UpdateConfig.isAutoInstallEnabled()) {
          debugPrint('📥 Auto-downloading update in background...');
          await startDownload();
        }
      } catch (e) {
        debugPrint('❌ Background update check failed: $e');
      }
    });
  }
  
  /// Opreste verificarea periodica
  void stopBackgroundUpdateCheck() {
    // Timer-ul se va opri automat cand se distruge service-ul
  }
  
  /// Obtine informatii despre update-ul disponibil
  Map<String, dynamic> getUpdateInfo() {
    return {
      'hasUpdate': hasUpdate,
      'currentVersion': _currentVersion,
      'latestVersion': _latestVersion,
      'isDownloading': _isDownloading,
      'isUpdateReady': _isUpdateReady,
      'downloadProgress': _downloadProgress,
      'downloadProgressText': downloadProgressText,
      'canInstall': _isUpdateReady && !_isInstalling,
    };
  }
  
  /// Sterge update-ul descarcat
  Future<void> cancelUpdate() async {
    if (_updateFilePath != null) {
      try {
        final file = File(_updateFilePath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ Canceled update, deleted file: $_updateFilePath');
        }
      } catch (e) {
        debugPrint('❌ Error canceling update: $e');
      }
    }
    
    _isUpdateReady = false;
    _updateFilePath = null;
    _downloadProgress = 0.0;
    _downloadedBytes = 0;
    _totalBytes = 0;
  }
} 