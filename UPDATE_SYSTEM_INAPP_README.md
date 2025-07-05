# Sistem de Update-uri In-App pentru Windows (Discord Style)

## Prezentare generală

Sistemul de update-uri in-app pentru aplicația Broker-App funcționează similar cu Discord, oferind o experiență fluidă de actualizare fără a redirecta utilizatorii către site-uri externe. Toate update-urile se descarcă și se instalează direct în aplicație, iar aplicația se restartează automat pentru a aplica modificările.

## Caracteristici principale

### 🔄 Update-uri automate în background
- Verificarea periodică a update-urilor la fiecare 2 ore
- Download automat în background (opțional)
- Notificări subtile când update-ul este gata

### 📥 Download cu progres vizual
- Progres bar cu procente
- Afișarea vitezei de download (MB/s)
- Validarea integrității fișierelor
- Retry logic pentru conexiuni instabile

### 🔧 Instalare seamless
- Backup automat înainte de instalare
- Instalare cu un click
- Restart automat al aplicației
- Rollback în caz de erori

### 🎨 Interfață Discord-style
- Notificare subtilă în partea de sus a aplicației
- Animații fluide
- Butoane intuitive ("Mai târziu" / "Restartează")
- Feedback vizual pentru fiecare etapă

## Structura tehnică

### Servicii principale

1. **UpdateService** (`lib/backend/services/update_service.dart`)
   - Gestionarea logicii de update
   - Comunicarea cu GitHub API
   - Download și instalare

2. **UpdateConfig** (`lib/backend/services/update_config.dart`)
   - Configurarea parametrilor
   - Setările pentru Windows
   - Mesajele și comportamentul

3. **UpdateNotification** (`lib/frontend/components/update_notification.dart`)
   - Componenta UI pentru notificări
   - Animații și interacțiuni
   - Integrarea în main screen

### Fluxul de funcționare

```
1. Aplicația pornește
   ↓
2. Verifică dacă există update gata pentru instalare
   ↓
3. Pornește verificarea periodică în background
   ↓
4. Dacă găsește update nou:
   ↓
5. Afișează dialogul de confirmare
   ↓
6. Descarcă update-ul cu progres
   ↓
7. Afișează notificarea "gata pentru instalare"
   ↓
8. La click pe "Restartează":
   ↓
9. Creează backup → Instalează → Restart
```

## Configurare

### 1. Configurarea GitHub Repository

În `UpdateConfig`, modificați:

```dart
static const String githubOwner = 'your-username';
static const String githubRepo = 'Broker-App';
```

### 2. Setările de comportament

```dart
// Verificare automată la fiecare 2 ore
static const Duration checkInterval = Duration(hours: 2);

// Download automat în background
static const bool backgroundDownloadEnabled = true;

// Instalare automată după download
static const bool autoInstallEnabled = true;

// Instalare silențioasă (fără confirmare)
static const bool silentInstallEnabled = false;
```

### 3. Numele fișierului de update

```dart
static const String windowsAssetName = 'broker-app-windows.zip';
```

## Utilizare

### Verificarea manuală de update-uri

```dart
final updateService = UpdateService();
await updateService.initialize();

final hasUpdate = await updateService.checkForUpdates();
if (hasUpdate) {
  // Afișează dialogul de update
}
```

### Download manual

```dart
final success = await updateService.startDownload();
if (success) {
  // Update-ul a fost descărcat cu succes
}
```

### Instalarea manuală

```dart
if (updateService.isUpdateReady) {
  await updateService.installUpdate();
  // Aplicația se va restarta automat
}
```

### Callbacks pentru UI

```dart
updateService.setDownloadProgressCallback((progress) {
  // Actualizează progres bar: 0.0 - 1.0
});

updateService.setStatusChangeCallback((status) {
  // Afișează mesajul de status
});

updateService.setUpdateReadyCallback((ready) {
  // Arată notificarea când update-ul e gata
});

updateService.setErrorCallback((error) {
  // Gestionează erorile
});
```

## Integrarea în aplicație

### În SplashScreen

```dart
// Inițializarea serviciului
await updateService.initialize();

// Verificarea update-urilor gata pentru instalare
final hasReadyUpdate = await updateService.checkForReadyUpdate();

// Pornirea verificării periodice
updateService.startBackgroundUpdateCheck();

// Verificarea update-urilor noi
final hasNewUpdate = await updateService.checkForUpdates();
```

### În MainScreen

```dart
return UpdateNotificationWrapper(
  updateService: updateService,
  child: Scaffold(
    // Conținutul aplicației
  ),
);
```

## Gestionarea GitHub Releases

### Structura unui release

1. **Tag Version**: `v1.0.1`
2. **Release Title**: `Broker App v1.0.1`
3. **Assets**: `broker-app-windows.zip`

### Exemplu de release cu GitHub Actions

```yaml
name: Build and Release

on:
  push:
    tags: [ 'v*' ]

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          
      - name: Build Windows
        run: |
          flutter pub get
          flutter build windows --release
          
      - name: Create ZIP
        run: |
          cd build/windows/runner/Release
          7z a ../../../../broker-app-windows.zip .
          
      - name: Upload to Release
        uses: softprops/action-gh-release@v1
        with:
          files: broker-app-windows.zip
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Securitate și backup

### Backup automat

- Se creează backup înainte de fiecare update
- Maxim 5 backup-uri păstrate
- Rollback automat în caz de erori

### Validarea fișierelor

- Verificarea integrității ZIP
- Validarea mărimii fișierelor
- Verificarea structurii arhivei

### Gestionarea erorilor

- Retry logic pentru download-uri
- Timeout configurabil
- Rollback la versiunea anterioară

## Troubleshooting

### Update-ul nu se descarcă

1. Verificați conexiunea la internet
2. Verificați URL-ul GitHub repository
3. Verificați numele asset-ului în release

### Aplicația nu se restartează

1. Verificați permisiunile de execuție
2. Verificați path-ul executabilului
3. Verificați procesele Windows

### Erori la instalare

1. Verificați permisiunile de scriere
2. Verificați spațiul disponibil
3. Verificați backup-urile existente

## Loguri și debugging

### Activarea debug mode

```dart
static const bool debugMode = true;
```

### Loguri specifice

- `🔍` - Verificarea update-urilor
- `📥` - Download-ul fișierelor
- `🔧` - Procesul de instalare
- `💾` - Crearea backup-urilor
- `🔄` - Restart-ul aplicației
- `❌` - Erori
- `✅` - Operațiuni reușite

## Exemple de utilizare

### Verificare simplă

```dart
final updateService = UpdateService();
await updateService.initialize();

if (await updateService.checkForUpdates()) {
  print('Update disponibil: ${updateService.latestVersion}');
  print('Versiune curentă: ${updateService.currentVersion}');
}
```

### Download cu progres

```dart
updateService.setDownloadProgressCallback((progress) {
  print('Progres: ${(progress * 100).toStringAsFixed(1)}%');
});

await updateService.startDownload();
```

### Informații complete

```dart
final info = updateService.getUpdateInfo();
print('Are update: ${info['hasUpdate']}');
print('Este gata: ${info['isUpdateReady']}');
print('Se descarcă: ${info['isDownloading']}');
print('Progres: ${info['downloadProgress']}');
```

## Concluzie

Sistemul de update-uri in-app oferă o experiență modernă și fluidă pentru actualizarea aplicației Broker-App pe Windows. Inspirat de aplicații precum Discord, sistemul gestionează automat toate aspectele tehnice ale update-urilor, oferind utilizatorilor o experiență simplă și sigură.

Sistemul este complet configurat și gata de utilizare, necesitând doar configurarea repository-ului GitHub și publicarea release-urilor cu asset-urile corespunzătoare.