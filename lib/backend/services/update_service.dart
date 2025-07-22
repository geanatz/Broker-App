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
      
      // Curata scripturile ramase de la update-uri anterioare
      await cleanupRemainingScripts();
  
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
      _updateStatus('Incepand instalarea update-ului...');
      
      // Verifica fisierul de update
      _updateStatus('Verificare fisier update...');
      final updateFile = File(_updateFilePath!);
      if (!await updateFile.exists()) {
        _onError?.call('Fisierul de update nu exista');
        return false;
      }
      
      final fileSize = await updateFile.length();
      _updateStatus('Fisier update gasit: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      final success = await _installWindowsUpdate(_updateFilePath!);
      
      if (success) {
        debugPrint('✅ Update installed successfully');
        _updateStatus('Instalare finalizata cu succes!');
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
        final sizeMB = (_downloadedBytes / 1024 / 1024).toStringAsFixed(2);
        debugPrint('✅ Download completed: ${sizeMB}MB | File: $_updateFilePath');
        
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
        debugPrint('✅ Download validation successful | Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB | Files: ${archive.length}');
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
      _updateStatus('Citire fisier ZIP...');
      
      // Extract ZIP
      final bytes = await File(zipPath).readAsBytes();
      _updateStatus('Decodare arhiva ZIP...');
      final archive = ZipDecoder().decodeBytes(bytes);
      _updateStatus('Arhiva decodata: ${archive.length} fisiere gasite');
      
      // Get application directory
      final appDir = Directory.current;
      _updateStatus('Director aplicatie: ${appDir.path}');
      
      // Create backup if enabled
      if (UpdateConfig.createBackup) {
        _updateStatus('Creare backup...');
        final backupSuccess = await _createBackup(appDir);
        if (!backupSuccess) {
          debugPrint('❌ Failed to create backup, aborting update');
          _onError?.call('Eroare la crearea backup-ului');
          return false;
        }
      }
      
      // Extract new files with smart replacement strategy
      _updateStatus('Extragere fisiere (strategie inteligenta)...');
      int filesInstalled = 0;
      int filesSkipped = 0;
      int totalFiles = archive.where((file) => file.isFile).length;
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final newFile = File('${appDir.path}/$filename');
          
          // Create directory if needed
          final parentDir = newFile.parent;
          if (!await parentDir.exists()) {
            await parentDir.create(recursive: true);
          }
          
          // Check if file is in use (only for DLL and EXE files)
          bool shouldSkip = false;
          if (filename.endsWith('.dll') || filename.endsWith('.exe')) {
            try {
              // Try to open file for writing to check if it's in use
              final testFile = await newFile.open(mode: FileMode.write);
              await testFile.close();
            } catch (e) {
              _updateStatus('Fisier in uz, va fi actualizat la restart: $filename');
              shouldSkip = true;
              filesSkipped++;
            }
          }
          
          if (!shouldSkip) {
            try {
              await newFile.writeAsBytes(data);
              filesInstalled++;
            } catch (e) {
              _updateStatus('Eroare la scrierea fisierului $filename: $e');
              filesSkipped++;
            }
          }
          
          if ((filesInstalled + filesSkipped) % 10 == 0 || (filesInstalled + filesSkipped) == totalFiles) {
            _updateStatus('Fisiere procesate: ${filesInstalled + filesSkipped}/$totalFiles (instalate: $filesInstalled, sarite: $filesSkipped)');
          }
        }
      }
      
      _updateStatus('Instalare finalizata: $filesInstalled fisiere instalate, $filesSkipped sarite');
      debugPrint('✅ Windows update installed successfully | Files: $filesInstalled | Skipped: $filesSkipped | Archive: ${archive.length}');
      
      // Create update script for files that couldn't be replaced
      if (filesSkipped > 0) {
        _updateStatus('Creare script pentru fisierele ramase...');
        await _createUpdateScript(appDir, archive, filesSkipped);
      }
      
      // Cleanup download file
      _updateStatus('Curatare fisiere temporare...');
      await _cleanupDownload(zipPath);
      
      // Restart application
      _updateStatus('Pregatire restart aplicatie...');
      await _restartApplication();
      return true;
    } catch (e) {
      debugPrint('❌ Error installing Windows update: $e');
      _onError?.call('Eroare la instalare: $e');
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
      _updateStatus('Creare backup...');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory('${appDir.path}${UpdateConfig.backupSuffix}_$timestamp');
      _updateStatus('Backup path: ${backupDir.path}');
      
      // Sterge backup-uri vechi
      _updateStatus('Curatare backup-uri vechi...');
      await _cleanupOldBackups(appDir.parent);
      
      // Creaza backup nou
      _updateStatus('Copiere fisiere in backup...');
      await _copyDirectory(appDir, backupDir);
      
      debugPrint('✅ Backup created successfully | Path: ${backupDir.path}');
      _updateStatus('Backup creat cu succes');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating backup: $e');
      _onError?.call('Eroare la crearea backup-ului: $e');
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
        try {
          await entity.copy(newFile.path);
        } catch (e) {
          // Daca fisierul este in uz, incearca sa-l copiezi cu nume temporar
          if (e.toString().contains('being used by another process')) {
            final tempFile = File('${newFile.path}.tmp');
            await entity.copy(tempFile.path);
            // Rename-ul se va face la restart
            debugPrint('⚠️ File in use, copied as temp: ${newFile.path}');
          } else {
            rethrow;
          }
        }
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
      _updateStatus('Rollback la versiunea anterioara...');
      
      final appDir = Directory.current;
      final parentDir = appDir.parent;
      _updateStatus('Cautare backup...');
      
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
        _updateStatus('Backup gasit: ${latestBackup.path}');
        
        // In loc sa stergem directorul curent (care poate fi in uz),
        // copiem fisierele din backup peste cele existente
        _updateStatus('Restaurare fisiere din backup...');
        
        try {
          await _copyDirectory(latestBackup, appDir);
          debugPrint('✅ Rollback completed successfully');
          _updateStatus('Rollback finalizat cu succes');
          return true;
        } catch (e) {
          _updateStatus('Eroare la restaurare, se incearca stergerea...');
          
          // Daca copierea esueaza, incearca stergerea
          try {
            await appDir.delete(recursive: true);
            await _copyDirectory(latestBackup, appDir);
            debugPrint('✅ Rollback completed successfully (with deletion)');
            _updateStatus('Rollback finalizat cu succes (cu stergere)');
            return true;
          } catch (deleteError) {
            debugPrint('❌ Error during rollback deletion: $deleteError');
            _onError?.call('Eroare la stergerea fisierelor: $deleteError');
            return false;
          }
        }
      } else {
        debugPrint('❌ No backup found for rollback');
        _onError?.call('Nu s-a gasit backup pentru rollback');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during rollback: $e');
      _onError?.call('Eroare la rollback: $e');
      return false;
    }
  }
  
  /// Creeaza script pentru actualizarea fisierelor ramase
  Future<void> _createUpdateScript(Directory appDir, Archive archive, int skippedFiles) async {
    try {
      _updateStatus('Creare script batch pentru fisierele ramase...');
      
      final scriptPath = '${appDir.path}/update_remaining.bat';
      final tempDir = '${appDir.path}/temp_update';
      
      // Extract remaining files to temp directory
      _updateStatus('Extragere fisiere in director temporar...');
      final tempDirObj = Directory(tempDir);
      if (!await tempDirObj.exists()) {
        await tempDirObj.create(recursive: true);
      }
      
      // Extract files that were skipped
      int extractedCount = 0;
      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          if (filename.endsWith('.dll') || filename.endsWith('.exe')) {
            final data = file.content as List<int>;
            final tempFile = File('$tempDir/$filename');
            await tempFile.writeAsBytes(data);
            extractedCount++;
            _updateStatus('Extras in temp: $filename');
          }
        }
      }
      
      final scriptContent = StringBuffer();
      scriptContent.writeln('@echo off');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('echo ACTUALIZARE BROKER APP');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('echo Se actualizeaza aplicatia...');
      scriptContent.writeln('echo Nu inchide aceasta fereastra!');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('timeout /t 2 /nobreak > nul');
      
              // Copy files from temp directory
        int fileCount = 0;
        int totalFiles = archive.where((file) => file.isFile && (file.name.endsWith('.dll') || file.name.endsWith('.exe'))).length;
        for (final file in archive) {
          if (file.isFile) {
            final filename = file.name;
            if (filename.endsWith('.dll') || filename.endsWith('.exe')) {
              fileCount++;
              scriptContent.writeln('echo Actualizare fisier $fileCount/$totalFiles...');
              scriptContent.writeln('copy /Y "$tempDir\\$filename" "$filename" > nul 2>&1');
              scriptContent.writeln('if errorlevel 1 (');
              scriptContent.writeln('  echo Eroare la actualizarea: $filename');
              scriptContent.writeln(') else (');
              scriptContent.writeln('  echo Fisier actualizat: $filename');
              scriptContent.writeln(')');
            }
          }
        }
      
      scriptContent.writeln('echo.');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('echo Curatare fisiere temporare...');
      scriptContent.writeln('rmdir /S /Q "$tempDir" > nul 2>&1');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('echo Pornire aplicatie...');
      scriptContent.writeln('timeout /t 1 /nobreak > nul');
      scriptContent.writeln('start "" "${appDir.path}\\broker_app.exe"');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('echo ACTUALIZARE FINALIZATA!');
      scriptContent.writeln('echo Aplicatia a fost actualizata si pornita cu succes.');
      scriptContent.writeln('echo ========================================');
      scriptContent.writeln('del "%~f0" > nul 2>&1');
      scriptContent.writeln(':end');
      
      final scriptFile = File(scriptPath);
      await scriptFile.writeAsString(scriptContent.toString());
      
      // Verify script was created
      if (await scriptFile.exists()) {
        final scriptSize = await scriptFile.length();
        _updateStatus('Script creat cu succes: $scriptPath ($scriptSize bytes)');
        _updateStatus('Fisiere extrase in temp: $extractedCount');
      } else {
        throw Exception('Script file was not created');
      }
    } catch (e) {
      _updateStatus('Eroare la crearea script-ului: $e');
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
      _updateStatus('Restart aplicatie...');
      
      final executablePath = Platform.resolvedExecutable;
      _updateStatus('Executable path: $executablePath');
      
      // Check if we have an update script
      final updateScript = File('${Directory.current.path}/update_remaining.bat');
      if (await updateScript.exists()) {
        _updateStatus('Executare script pentru fisierele ramase...');
        await Process.start('cmd', ['/c', 'start', '', updateScript.path], runInShell: true);
        
        // Don't start the app here, let the script do it
        _updateStatus('Script pornit, inchidere aplicatie curenta...');
        await Future.delayed(const Duration(milliseconds: 1000));
        exit(0);
      } else {
        // No update script, start normally
        await Process.start('cmd', ['/c', 'start', '', executablePath], runInShell: true);
        _updateStatus('Aplicatie noua pornita, inchidere aplicatie curenta...');
        await Future.delayed(const Duration(milliseconds: 500));
        exit(0);
      }
    } catch (e) {
      debugPrint('❌ Error restarting application: $e');
      _onError?.call('Eroare la restart: $e');
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
  
  /// Curata scripturile ramase de la update-uri anterioare
  Future<void> cleanupRemainingScripts() async {
    if (kIsWeb || !Platform.isWindows) return;
    
    try {
      final appDir = Directory.current;
      final updateScript = File('${appDir.path}/update_remaining.bat');
      final cleanupScript = File('${appDir.path}/cleanup_temp.bat');
      
      // Sterge scripturile ramase
      if (await updateScript.exists()) {
        await updateScript.delete();
        debugPrint('🗑️ Cleaned up remaining update script');
      }
      
      if (await cleanupScript.exists()) {
        await cleanupScript.delete();
        debugPrint('🗑️ Cleaned up remaining cleanup script');
      }
      
      // Sterge directorul temporar daca exista
      final tempDir = Directory('${appDir.path}/temp_update');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        debugPrint('🗑️ Cleaned up remaining temp directory');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up remaining scripts: $e');
    }
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