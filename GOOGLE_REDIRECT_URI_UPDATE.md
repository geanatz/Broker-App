# Actualizare Redirect URI în Google Console

## ⚠️ IMPORTANT: Actualizare necesară în Google Console

Credențialele au fost configurate în aplicație, dar trebuie să actualizați **Redirect URI** în Google Console.

## Pașii pentru actualizare:

### 1. Mergeți la Google Cloud Console
- Deschideți [Google Cloud Console](https://console.cloud.google.com/)
- Selectați proiectul "ocr-claudiu"

### 2. Accesați Credentials
- Mergeți la "APIs & Services" > "Credentials"
- Găsiți credențialele OAuth 2.0 create (cu numele aplicației desktop)

### 3. Editați credențialele
- Click pe credențiale (icon de edit/pencil)
- În secțiunea **"Authorized redirect URIs"**

### 4. Adăugați URI-ul corect
În plus față de `http://localhost` (care există deja), adăugați:
```
http://localhost:8080/auth/callback
```

Astfel veți avea AMBELE URI-uri:
- ✅ `http://localhost` (existent)
- ✅ `http://localhost:8080/auth/callback` (nou - de adăugat)

### 5. Salvați modificările
- Click "Save"
- Așteptați 5-10 minute pentru propagarea modificărilor

## Testare rapidă
După actualizare, testați:
1. Restart aplicația Flutter
2. Settings > Google Drive > "Conectează"
3. **Se va deschide browserul** pentru autentificare Google
4. După autentificare, veți fi redirecționați cu "Autentificare reușită!"

---

**Status credențiale în aplikație:** ✅ CONFIGURATE
**Status redirect URI:** ⚠️ TREBUIE ACTUALIZAT în Google Console 