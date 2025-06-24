# Fix pentru Error 403: access_denied

## 🚨 Problema
Eroarea "Error 403: access_denied" apare pentru că **OAuth consent screen** nu este configurat corect sau aplicația este în "testing mode" și contul vostru nu este adăugat ca test user.

## ✅ Soluția (5 minute)

### 1. Mergeți la OAuth consent screen
1. Deschideți [Google Cloud Console](https://console.cloud.google.com/)
2. Selectați proiectul "ocr-claudiu"
3. Mergeți la **"APIs & Services"** > **"OAuth consent screen"**

### 2. Configurați aplicația pentru External users

#### A. Dacă aplicația este în "Internal" mode:
- Schimbați la **"External"**
- Click "Edit App"

#### B. Configurare completă OAuth consent screen:

**Tab 1: OAuth consent screen**
- **App name**: `Broker App`
- **User support email**: adresa voastră de email
- **App logo**: (opțional - puteți să omiteți)
- **App domain**: (opțional - puteți să omiteți)
- **Developer contact information**: adresa voastră de email
- Click **"Save and Continue"**

**Tab 2: Scopes**
- Click **"Add or Remove Scopes"**
- Selectați următoarele scopuri:
  - ✅ `../auth/userinfo.email` (View your email address)
  - ✅ `../auth/drive.file` (See, edit, create, and delete only the specific Google Drive files you use with this app)
  - ✅ `../auth/drive.readonly` (See and download all your Google Drive files)
  - ✅ `../auth/spreadsheets` (See, edit, create, and delete your spreadsheets in Google Drive)
- Click **"Update"**
- Click **"Save and Continue"**

**Tab 3: Test users** 
- Click **"Add Users"**
- Adăugați adresa voastră de email (contul cu care vreți să vă testați)
- Click **"Save and Continue"**

**Tab 4: Summary**
- Verificați configurația și click **"Back to Dashboard"**

### 3. Alternativa rapidă: Publicarea aplicației
Dacă nu vreți să adăugați test users de fiecare dată:

1. În OAuth consent screen, click **"Publish App"**
2. Confirmați publicarea
3. ⚠️ **Notă**: Va apărea un warning "This app isn't verified" - este normal pentru aplicații în dezvoltare

### 4. Testați din nou
După configurarea OAuth consent screen:

1. **Restart aplicația Flutter**
2. Settings > Google Drive > "Conectează"
3. **Se va deschide browserul**
4. Apare ecranul Google OAuth cu aplicația voastră
5. ⚠️ Poate apărea "This app isn't verified" - click **"Advanced"** > **"Go to Broker App (unsafe)"**
6. Acordați permisiunile
7. Veți fi redirecționați cu "Autentificare reușită!"

## 🔍 Ce să verificați în caz de probleme:

### Verificare 1: Consent screen status
- OAuth consent screen status trebuie să fie "In production" sau "Testing"
- Dacă este "Testing", contul vostru trebuie să fie în lista "Test users"

### Verificare 2: Scopurile sunt adăugate
Verificați că aveți următoarele scopuri în OAuth consent screen:
- `../auth/userinfo.email`
- `../auth/drive.file` 
- `../auth/drive.readonly`
- `../auth/spreadsheets`

### Verificare 3: Redirect URI
În Credentials, verificați că aveți:
- `http://localhost:8080/auth/callback`

## 📋 Checklist final:
- ✅ OAuth consent screen configurat (External)
- ✅ Scopurile adăugate (email, drive, spreadsheets)
- ✅ Contul adăugat ca test user SAU aplicația publicată
- ✅ Redirect URI: `http://localhost:8080/auth/callback`

---

**După această configurare, autentificarea prin browser va funcționa perfect!** 🚀 