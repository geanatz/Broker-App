import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'update_config.dart';
import 'app_logger.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';

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
  String? _downloadAssetName;
  String? _checksumUrl;
  String? _updateFilePath;
  String? _releaseDescription; // Adaug variabila pentru descrierea release-ului
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
  String? get releaseDescription => _releaseDescription; // Adaug getter pentru descriere
  bool get hasUpdate => _latestVersion != null && _currentVersion != null && _isNewerVersion(_latestVersion!, _currentVersion!);
  String get downloadProgressText => _totalBytes > 0 ? 
    '${(_downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB / ${(_totalBytes / 1024 / 1024).toStringAsFixed(1)} MB' : 
    '${(_downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  
  // Callback setters pentru UI
  void setDownloadProgressCallback(Function(double)? callback) => _onDownloadProgress = callback;
  void setStatusChangeCallback(Function(String)? callback) => _onStatusChange = callback;
  void setUpdateReadyCallback(Function(bool)? callback) => _onUpdateReady = callback;
  void setErrorCallback(Function(String)? callback) => _onError = callback;

  void clearUICallbacks() {
    _onDownloadProgress = null;
    _onStatusChange = null;
    _onUpdateReady = null;
    _onError = null;
  }
  
  /// Initializeaza serviciul si obtine versiunea curenta
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isWindows) {
      return;
    }
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      // Initialize file logging sink at app directory
      try {
        final appDir = Directory.current;
        final logPath = '${appDir.path}/logs.txt';
        await AppLogger.initFileLogging(logPath);
        AppLogger.setUseEmojis(false);
        AppLogger.setVerboseMode(true);
        AppLogger.lifecycle('update_service', 'initialized', {
          'version': _currentVersion,
          'dir': appDir.path,
        });
        AppLogger.sync('update_service', 'env_snapshot', {
          'cwd': appDir.path,
          'exe': Platform.resolvedExecutable,
          'os': Platform.operatingSystemVersion,
          'dart': Platform.version,
        });
      } catch (e) {
        debugPrint('UPDATE_SERVICE: failed to init file logging: $e');
      }

      // Curata scripturile ramase de la update-uri anterioare
      await cleanupRemainingScripts();
  
    } catch (e) {
      AppLogger.error('update_service', 'initialize failed', e);
    }
  }
  
  /// Verifica daca exista update-uri disponibile
  Future<bool> checkForUpdates() async {
    if (_isChecking || _currentVersion == null || kIsWeb || !Platform.isWindows) return false;
    
    if (UpdateConfig.skipVersionCheck) {
      return false;
    }
    
    _isChecking = true;
    _updateStatus('Verificare update-uri...');
    AppLogger.sync('update_service', 'check_for_updates_start', {
      'current': _currentVersion,
      'url': UpdateConfig.githubApiUrl,
    });
    
    int retryCount = 0;
    
    while (retryCount < UpdateConfig.maxRetries) {
      try {
        
        final response = await http.get(
          Uri.parse(UpdateConfig.githubApiUrl),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ).timeout(UpdateConfig.timeoutDuration);
        
          if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _latestVersion = data['tag_name']?.toString().replaceAll('v', '');
          _releaseDescription = data['body']; // Preia descrierea
            AppLogger.sync('update_service', 'github_release_ok', {
              'latest': _latestVersion,
            });
          
          if (_latestVersion != null) {
            
            if (hasUpdate) {
               AppLogger.sync('update_service', 'has_update', {
                 'current': _currentVersion,
                 'latest': _latestVersion,
               });
               final assets = data['assets'] as List<dynamic>? ?? const [];
               _downloadUrl = _getDownloadUrl(assets);
               _downloadAssetName = _getSelectedAssetName(assets, _downloadUrl);
               _checksumUrl = _getChecksumUrl(assets, _downloadAssetName);
              
               if (_downloadUrl != null) {
                  // Defer persisting release info until after successful installation
                  AppLogger.sync('update_service', 'release_info_deferred');
                  _isChecking = false;
                  _updateStatus('');
                  AppLogger.sync('update_service', 'asset_selected', {
                    'url': _downloadUrl,
                    'name': _downloadAssetName,
                  });
                  if (UpdateConfig.validateChecksums) {
                    AppLogger.sync('update_service', 'checksum_asset', {
                      'url': _checksumUrl ?? 'missing',
                    });
                  }
                  return true;
              } else {
                  AppLogger.warning('update_service', 'no_windows_asset_found');
              }
            } else {
                AppLogger.sync('update_service', 'no_update', {
                  'current': _currentVersion,
                  'latest': _latestVersion,
                });
            }
          }
          break; // Success, exit retry loop
        } else {
          AppLogger.error('update_service', 'check_updates_failed_status', response.statusCode);
          if (response.statusCode == 403) {
            AppLogger.warning('update_service', 'rate_limited');
            break; // Don't retry on rate limit
          }
        }
      } catch (e) {
        AppLogger.error('update_service', 'check_for_updates_exception_attempt_${retryCount + 1}', e);
        if (retryCount < UpdateConfig.maxRetries - 1) {
          await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        }
      }
      retryCount++;
    }
    
    _isChecking = false;
    _updateStatus('');
    AppLogger.sync('update_service', 'check_for_updates_end', {
      'result': false,
    });
    return false;
  }

  Future<void> _persistReleaseInfo() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${supportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      if (!await updateDir.exists()) {
        await updateDir.create(recursive: true);
      }
      final file = File('${updateDir.path}/last_release.json');
      final map = {
        'version': _latestVersion,
        'description': _releaseDescription,
        'ts': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(map));
      AppLogger.sync('update_service', 'release_info_persisted', {'file': file.path});
    } catch (e) {
      AppLogger.error('update_service', 'release_info_persist_exception', e);
    }
  }

  /// Clears the persisted release info file if it exists
  Future<void> clearPersistedReleaseInfo() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${supportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      final file = File('${updateDir.path}/last_release.json');
      if (await file.exists()) {
        await file.delete();
        AppLogger.sync('update_service', 'release_info_cleared_manual');
      }
    } catch (e) {
      AppLogger.error('update_service', 'release_info_clear_exception', e);
    }
  }

  /// Reads persisted release info (version, description) and optionally clears it.
  Future<Map<String, String>?> readPersistedReleaseInfo({bool clearAfterRead = true}) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${supportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      final file = File('${updateDir.path}/last_release.json');
      if (!await file.exists()) {
        AppLogger.sync('update_service', 'release_info_missing', {'path': file.path});
        return null;
      }
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final version = (data['version'] ?? '').toString();
      final description = (data['description'] ?? '').toString();
      AppLogger.sync('update_service', 'release_info_read', {
        'version': version,
        'desc_len': description.length,
      });
      if (clearAfterRead) {
        try { await file.delete(); AppLogger.sync('update_service', 'release_info_cleared'); } catch (_) {}
      }
      return {
        'version': version,
        'description': description,
      };
    } catch (e) {
      AppLogger.error('update_service', 'read_release_info_exception', e);
      return null;
    }
  }
  
  /// Porneste download-ul update-ului (Discord-style)
  Future<bool> startDownload() async {
    if (_isDownloading || !hasUpdate || kIsWeb || !Platform.isWindows) return false;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    
    try {
      
      _updateStatus('Se descarca update-ul...');
      AppLogger.sync('update_service', 'download_start', {
        'url': _downloadUrl,
      });
      
      final success = await _downloadUpdate();
      
      if (success) {
        _isUpdateReady = true;
        _onUpdateReady?.call(true);
        _updateStatus('Update gata de instalare');
        AppLogger.success('update_service', 'download_success', {
          'size_bytes': _downloadedBytes,
        });
        
      } else {
        _onError?.call('Eroare la descarcarea update-ului');
        AppLogger.error('update_service', 'download_failed');
        
      }
      
      return success;
    } catch (e) {
      AppLogger.error('update_service', 'download_exception', e);
      _onError?.call('Eroare neasteptata la download: $e');
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
      
      _updateStatus('Incepand instalarea update-ului...');
      AppLogger.sync('update_service', 'install_start');
      
      // Verifica fisierul de update
      _updateStatus('Verificare fisier update...');
      final updateFile = File(_updateFilePath!);
      if (!await updateFile.exists()) {
        _onError?.call('Fisierul de update nu exista');
        AppLogger.error('update_service', 'update_file_missing', {'path': _updateFilePath});
        return false;
      }
      
      final fileSize = await updateFile.length();
      final modified = await updateFile.lastModified();
      _updateStatus('Fisier update gasit: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      AppLogger.sync('update_service', 'update_file_info', {
        'path': _updateFilePath,
        'size': fileSize,
        'modified': modified.toIso8601String(),
      });
      
      bool success;
      if (_updateFilePath!.toLowerCase().endsWith('.exe')) {
        success = await _installViaInstaller(_updateFilePath!);
      } else {
        _onError?.call('Asset nesuportat pentru instalare (numai installer este acceptat)');
        AppLogger.error('update_service', 'unsupported_asset_for_install');
        return false;
      }
      
      if (success) {
        
        _updateStatus('Instalare finalizata cu succes!');
        AppLogger.success('update_service', 'install_success');
        // Application will restart automatically
      } else {
        _onError?.call('Eroare la instalarea update-ului');
        AppLogger.error('update_service', 'install_failed');
        
      }
      
      return success;
    } catch (e) {
      AppLogger.error('update_service', 'install_exception', e);
      _onError?.call('Eroare neasteptata la instalare: $e');
      return false;
    } finally {
      _isInstalling = false;
    }
  }

  /// Ruleaza installer-ul (preferat) fara CMD si lasa installer-ul sa gestioneze restartul
  Future<bool> _installViaInstaller(String installerPath) async {
    try {
      final exists = await File(installerPath).exists();
      final size = exists ? await File(installerPath).length() : -1;
      final modified = exists ? await File(installerPath).lastModified() : null;
      AppLogger.sync('update_service', 'installer_precheck', {
        'exists': exists,
        'size': size,
        'modified': modified?.toIso8601String() ?? 'n/a',
        'cwd': Directory.current.path,
        'exe': Platform.resolvedExecutable,
      });
      // Build silent args and force installer log file into app support dir
      final appSupportDir = await getApplicationSupportDirectory();
      final installerLogPath = ('${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}/Installer.log').replaceAll('/', '\\');
      // Ensure log directory exists
      try { await Directory('${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}').create(recursive: true); } catch (_) {}
      // Force install directory to per-user LocalAppData to avoid privilege prompts and stale paths
      final desiredInstallDir = (() {
        final lad = Platform.environment['LOCALAPPDATA'] ?? '';
        if (lad.isEmpty) return '';
        final buf = StringBuffer(lad)..write('\\')..write('MAT Finance');
        return buf.toString();
      })();
      final args = <String>[
        ...UpdateConfig.windowsInstallerSilentArgs,
        '/LOG=$installerLogPath',
        if (desiredInstallDir.isNotEmpty) '/DIR=$desiredInstallDir',
      ];
      AppLogger.sync('update_service', 'installer_launch', {
        'path': installerPath,
        'args': args.join(' '),
        'log': installerLogPath,
      });
      _updateStatus('Pornire installer...');
      // Run the installer as a separate process; no cmd window
      final installStartTs = DateTime.now();
      final process = await Process.start(
        installerPath,
        args,
        runInShell: false,
        workingDirectory: Directory.current.path,
      );
      // Capture any stdout/stderr from installer for diagnostics
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();
      unawaited(process.stdout.transform(utf8.decoder).listen((d) { stdoutBuffer.write(d); }).asFuture());
      unawaited(process.stderr.transform(utf8.decoder).listen((d) { stderrBuffer.write(d); }).asFuture());
      AppLogger.sync('update_service', 'installer_started', {'pid': process.pid});

      // New strategy: wait for installer to finish, then launch installed app ourselves.
      // This avoids relying on Inno [Run] in silent mode and guarantees relaunch.
      _updateStatus('Se asteapta finalizarea installer-ului...');
      AppLogger.sync('update_service', 'installer_wait_start');

      int exitCode = -1;
      try {
        // Safety timeout: 10 minutes
        exitCode = await process.exitCode.timeout(const Duration(minutes: 10));
      } on TimeoutException {
        AppLogger.error('update_service', 'installer_timeout');
      }

      AppLogger.sync('update_service', 'installer_finished', {'exit_code': exitCode});

      // If installer failed, try to capture the tail of Installer.log for diagnostics
      if (exitCode != 0) {
        try {
          final appSupportDir = await getApplicationSupportDirectory();
          final installerLogPath = '${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}/Installer.log';
          final logFile = File(installerLogPath);
          if (await logFile.exists()) {
            final content = await logFile.readAsString();
            final lines = content.split(RegExp(r'\r?\n'));
            final tailCount = lines.length >= 60 ? 60 : lines.length; // limit tail size
            final tail = lines.sublist(lines.length - tailCount).join('\n');
            AppLogger.error('update_service', 'installer_log_tail', tail);
          } else {
            // Try fallback: look into system temp for latest "Setup Log*.txt" near install time
            try {
              final tempDir = Directory.systemTemp;
              final entries = tempDir
                  .listSync()
                  .whereType<File>()
                  .where((f) {
                    final name = f.path.toLowerCase();
                    return name.contains('setup log') && name.endsWith('.txt');
                  })
                  .toList();
              File? newest;
              DateTime newestTime = DateTime.fromMillisecondsSinceEpoch(0);
              for (final f in entries) {
                final stat = await f.stat();
                // Only consider logs written after installer started (with small negative tolerance)
                final threshold = installStartTs.subtract(const Duration(seconds: 5));
                if (stat.modified.isAfter(threshold) && stat.modified.isAfter(newestTime)) {
                  newest = f;
                  newestTime = stat.modified;
                }
              }
              if (newest != null) {
                final content = await newest.readAsString();
                final lines = content.split(RegExp(r'\r?\n'));
                final tailCount = lines.length >= 60 ? 60 : lines.length;
                final tail = lines.sublist(lines.length - tailCount).join('\n');
                AppLogger.error('update_service', 'installer_temp_log_tail', {'file': newest.path, 'tail': tail});
              } else {
                AppLogger.warning('update_service', 'installer_log_missing');
              }
            } catch (e) {
              AppLogger.error('update_service', 'installer_temp_log_read_exception', e);
            }
          }
        } catch (e) {
          AppLogger.error('update_service', 'read_installer_log_exception', e);
        }
        // Also include any stdout/stderr captured
        final so = stdoutBuffer.toString().trim();
        if (so.isNotEmpty) { AppLogger.error('update_service', 'installer_stdout', so); }
        final se = stderrBuffer.toString().trim();
        if (se.isNotEmpty) { AppLogger.error('update_service', 'installer_stderr', se); }
      }

      // Try to start the newly installed app from common install locations
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
      final programFiles = Platform.environment['ProgramFiles'] ?? '';
      final programFilesX86 = Platform.environment['ProgramFiles(x86)'] ?? '';

      String buildWinPath(String base, List<String> segments) {
        if (base.isEmpty) return '';
        final buf = StringBuffer(base);
        for (final s in segments) {
          buf.write('\\');
          buf.write(s);
        }
        return buf.toString();
      }

      final candidates = <String>[
        // New naming only
        buildWinPath(localAppData, ['MAT Finance', UpdateConfig.getExecutableName()]),
        buildWinPath(programFiles, ['MAT Finance', UpdateConfig.getExecutableName()]),
        buildWinPath(programFilesX86, ['MAT Finance', UpdateConfig.getExecutableName()]),
      ];

      AppLogger.sync('update_service', 'installed_path_candidates', {
        'LOCALAPPDATA': localAppData,
        'ProgramFiles': programFiles,
        'ProgramFiles(x86)': programFilesX86,
        'candidates': candidates.join(' | '),
      });

      bool started = false;
      for (final candidate in candidates) {
        try {
          if (candidate.isNotEmpty && await File(candidate).exists()) {
            _updateStatus('Pornire versiune actualizata...');
            await Process.start(candidate, [], runInShell: false);
            AppLogger.success('update_service', 'installed_app_started', {'path': candidate});
            started = true;
            break;
          }
        } catch (e) {
          AppLogger.error('update_service', 'installed_start_exception', {'path': candidate, 'error': e.toString()});
        }
      }
      if (!started) {
        AppLogger.error('update_service', 'installed_exe_missing_all');
      }

      // Close current process only if relaunch succeeded; otherwise keep app running
      if (started) {
        // Persist release info only after we successfully started the installed app
        if (_latestVersion != null) {
          try {
            await _persistReleaseInfo();
          } catch (e) {
            AppLogger.error('update_service', 'persist_release_info_exception_post_install', e);
          }
        } else {
          AppLogger.warning('update_service', 'skip_persist_release_info_missing_version');
        }
        try {
          await AppLogger.closeFileLogging();
        } catch (_) {}
        exit(0);
      } else {
        _updateStatus('Nu s-a putut relansa aplicatia dupa instalare');
        return false;
      }
    } catch (e) {
      AppLogger.error('update_service', 'installer_launch_exception', e);
      _onError?.call('Eroare la rularea installer-ului: $e');
      return false;
    }
    // Note: code below is theoretically unreachable because of exit(0).
    // Keeping a return for static analysis.
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
      String stripSuffix(String v) {
        final dash = v.indexOf('-');
        final plus = v.indexOf('+');
        int cut = v.length;
        if (dash != -1) cut = dash;
        if (plus != -1 && plus < cut) cut = plus;
        return v.substring(0, cut);
      }

      final latestCore = stripSuffix(latest);
      final currentCore = stripSuffix(current);

      List<int> toParts(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final latestParts = toParts(latestCore);
      final currentParts = toParts(currentCore);

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
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
  
  /// Obtine URL-ul de download pentru Windows
  String? _getDownloadUrl(List<dynamic> assets) {
    if (assets.isEmpty) return null;

    String? exactMatch(String name) {
      for (final asset in assets) {
        final assetName = asset['name']?.toString() ?? '';
        if (assetName == name) {
          return asset['browser_download_url']?.toString();
        }
      }
      return null;
    }

    // Preferred new installer name
    final preferred = UpdateConfig.getInstallerName();
    // legacy names removed

    // 1) Try preferred exact match
    final preferredUrl = exactMatch(preferred);
    if (preferredUrl != null) return preferredUrl;

    // 2) No legacy exact matches

    // 3) Heuristic fallback: exact match on configured installer name (case-insensitive)
    for (final asset in assets) {
      final assetName = (asset['name']?.toString() ?? '').toLowerCase();
      if (assetName == UpdateConfig.getInstallerName().toLowerCase()) {
        return asset['browser_download_url']?.toString();
      }
    }

    // No acceptable asset found (ZIP fallback disabled)
    AppLogger.warning('update_service', 'no_installer_asset_found');
    return null;
  }

  String? _getSelectedAssetName(List<dynamic> assets, String? url) {
    if (url == null) return null;
    for (final asset in assets) {
      final browserUrl = asset['browser_download_url']?.toString();
      if (browserUrl == url) {
        return asset['name']?.toString();
      }
    }
    return null;
  }

  String? _getChecksumUrl(List<dynamic> assets, String? selectedAssetName) {
    if (assets.isEmpty || selectedAssetName == null) return null;
    final expected1 = '$selectedAssetName.sha256';
    for (final asset in assets) {
      final assetName = asset['name']?.toString() ?? '';
      if (assetName == expected1) {
        return asset['browser_download_url']?.toString();
      }
    }
    // fallback: any .sha256 containing base name
    final base = selectedAssetName.split('.').first;
    for (final asset in assets) {
      final assetName = asset['name']?.toString() ?? '';
      if (assetName.endsWith('.sha256') && assetName.contains(base)) {
        return asset['browser_download_url']?.toString();
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
      
      final isInstaller = _downloadUrl!.toLowerCase().endsWith('.exe');
      // Save using the actual asset name when available, otherwise fall back to configured/new name,
      // and finally to the legacy name to preserve compatibility.
      final fallbackNames = <String>[
        _downloadAssetName ?? '',
        UpdateConfig.getInstallerName(),
      ].where((e) => e.isNotEmpty).toList();
      final saveName = isInstaller ? fallbackNames.first : 'update.unsupported';
      _updateFilePath = '${updateDir.path}/$saveName';
      AppLogger.sync('update_service', 'download_paths', {
        'target_dir': updateDir.path,
        'target_file': _updateFilePath,
        'url': _downloadUrl,
      });
      
      
      final request = http.Request('GET', Uri.parse(_downloadUrl!));
      final response = await request.send();
      
      if (response.statusCode == 200) {
        _totalBytes = response.contentLength ?? 0;
        final file = File(_updateFilePath!);
        final sink = file.openWrite();
        
        _downloadedBytes = 0;
        int lastLoggedProgress = -1;
        AppLogger.sync('update_service', 'download_response', {
          'status': response.statusCode,
          'content_length': _totalBytes,
        });
        
        await response.stream.listen((chunk) {
          _downloadedBytes += chunk.length;
          sink.add(chunk);
          
          if (_totalBytes > 0) {
            _downloadProgress = _downloadedBytes / _totalBytes;
            final progressPercent = (_downloadProgress * 100).round();
            
            // Update UI callback
            _onDownloadProgress?.call(_downloadProgress);
            
            if (progressPercent % 10 == 0 && progressPercent != lastLoggedProgress) {
              AppLogger.sync('update_service', 'download_progress', {
                'percent': progressPercent,
                'downloaded': _downloadedBytes,
                'total': _totalBytes,
              });
              lastLoggedProgress = progressPercent;
            }
          }
        }).asFuture();
        
        await sink.close();
        final mb = (_downloadedBytes / 1024 / 1024).toStringAsFixed(2);
        AppLogger.sync('update_service', 'download_complete', {
          'downloaded_mb': mb,
          'file': _updateFilePath,
        });

        // Optional checksum validation
        if (UpdateConfig.validateChecksums && _checksumUrl != null) {
          final ok = await _validateChecksum(_updateFilePath!, _checksumUrl!);
          if (!ok) {
            AppLogger.error('update_service', 'checksum_mismatch_delete_file');
            try { await File(_updateFilePath!).delete(); } catch (_) {}
            return false;
          }
        }
        
        // Validate downloaded file (only installer supported)
        if (isInstaller) {
          return await _validateInstallerDownload(_updateFilePath!);
        } else {
          AppLogger.error('update_service', 'non_installer_asset_downloaded');
          try { await File(_updateFilePath!).delete(); } catch (_) {}
          return false;
        }
      } else {
        AppLogger.error('update_service', 'download_http_error', {
          'status': response.statusCode,
        });
        return false;
      }
    } catch (e) {
      AppLogger.error('update_service', 'download_exception', e);
      return false;
    }
  }

  Future<bool> _validateChecksum(String filePath, String checksumUrl) async {
    try {
      AppLogger.sync('update_service', 'checksum_start', {'url': checksumUrl});
      final resp = await http.get(Uri.parse(checksumUrl)).timeout(UpdateConfig.timeoutDuration);
      if (resp.statusCode != 200) {
        AppLogger.error('update_service', 'checksum_download_failed', resp.statusCode);
        return false;
      }
      final content = resp.body.trim();
      // common formats: "<sha256>  filename" or just "<sha256>"
      final expected = (content.split(RegExp(r'\s+')).first).toLowerCase();
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes).toString();
      final match = digest.toLowerCase() == expected;
      AppLogger.sync('update_service', 'checksum_result', {'match': match, 'expected': expected, 'actual': digest});
      return match;
    } catch (e) {
      AppLogger.error('update_service', 'checksum_exception', e);
      return false;
    }
  }

  Future<bool> _validateInstallerDownload(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.error('update_service', 'installer_missing_after_download');
        return false;
      }
      final fileSize = await file.length();
      if (fileSize < 1024 * 1024) {
        AppLogger.error('update_service', 'installer_too_small', {'size': fileSize});
        return false;
      }
      final modified = await file.lastModified();
      AppLogger.sync('update_service', 'installer_file_info', {
        'path': filePath,
        'size': fileSize,
        'modified': modified.toIso8601String(),
      });
      return true;
    } catch (e) {
      AppLogger.error('update_service', 'validate_installer_exception', e);
      return false;
    }
  }
  
  // ZIP validation removed (installer-only updates)
  
  // ZIP install path removed (installer-only updates)
  
  // Backup logic removed (installer-only updates)
  
  /// Sterge backup-uri vechi
  // Backup cleanup removed (installer-only updates)
  
  /// Copiaza un director recursiv
  // Directory copy helper removed (installer-only updates)
  
  /// Sterge fisierul de download
  // Download cleanup removed (installer-only updates)
  
  /// Rollback la versiunea anterioara
  // Rollback removed (installer-only updates)
  
  /// Creeaza script pentru actualizarea fisierelor ramase
  // Remaining-files script removed (installer-only updates)
  
  /// Restarteaza aplicatia
  // Restart helper removed (installer handles restart)
  
  
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
    _releaseDescription = null; // Resetare descriere
  }
  
  /// Verifica daca exista un update descarcat si gata pentru instalare
  Future<bool> checkForReadyUpdate() async {
    if (kIsWeb || !Platform.isWindows) return false;
    
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final updateDir = Directory('${appSupportDir.path}/${UpdateConfig.getUpdateDirectory()}');
      AppLogger.sync('update_service', 'ready_check_paths', {
        'support_dir': appSupportDir.path,
        'update_dir': updateDir.path,
      });
      // Look for any known installer file names
      final candidates = <String>[
        '${updateDir.path}/${UpdateConfig.getInstallerName()}',
      ];
      File? installerFile;
      for (final path in candidates) {
        final f = File(path);
        if (await f.exists()) { installerFile = f; break; }
      }
      
      if (installerFile != null && await installerFile.exists()) {
        // Validare minimala installer
        final size = await installerFile.length();
        final modified = await installerFile.lastModified();
        AppLogger.sync('update_service', 'ready_installer_found', {
          'path': installerFile.path,
          'size': size,
          'modified': modified.toIso8601String(),
        });
        final ok = await _validateInstallerDownload(installerFile.path);
        if (ok) {
          _updateFilePath = installerFile.path;
          _isUpdateReady = true;
          AppLogger.sync('update_service', 'ready_update_found', {'type': 'installer'});
          return true;
        } else {
          try {
            await installerFile.delete();
            AppLogger.sync('update_service', 'ready_delete_invalid_installer');
          } catch (e) {
            AppLogger.error('update_service', 'ready_delete_invalid_installer_exception', e);
          }
        }
      }
    } catch (e) {
      AppLogger.error('update_service', 'ready_check_exception', e);
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
      }
      
      if (await cleanupScript.exists()) {
        await cleanupScript.delete();
      }
      
      // Sterge directorul temporar daca exista
      final tempDir = Directory('${appDir.path}/temp_update');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up remaining scripts: $e');
    }
  }
  
  /// Verifica periodic daca exista update-uri in background (Discord-style)
  void startBackgroundUpdateCheck() {
    if (kIsWeb || !Platform.isWindows || !UpdateConfig.isBackgroundDownloadEnabled()) return;
    
    Timer.periodic(UpdateConfig.checkInterval, (timer) async {
      if (_isChecking || _isDownloading) return;
      
      try {
        
        final hasUpdate = await checkForUpdates();
        
        if (hasUpdate && UpdateConfig.isAutoInstallEnabled()) {
          
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
      'releaseDescription': _releaseDescription, // Adaug descrierea la info
    };
  }
  
  /// Sterge update-ul descarcat
  Future<void> cancelUpdate() async {
    if (_updateFilePath != null) {
      try {
        final file = File(_updateFilePath!);
        if (await file.exists()) {
          await file.delete();
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
