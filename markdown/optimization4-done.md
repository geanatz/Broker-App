## App Optimization Plan (phased, with checkboxes)

Note: text fara diacritice conform cerintei.

### Faza 1 — Observabilitate si stabilitate rapida (safe, non-breaking)
- [ ] Centralizeaza logurile critice pe AppLogger si reduce PII in loguri AI/Sheets
- [x] Adauga metrici (ms) pentru operatiuni cheie: loadClients, getTeamMeetings, createMeeting
- [x] Corecteaza text UI vizibil (Calculator: "Rata lunara")
- [x] Evita dublura pentru "What’s New" (afiseaza doar dupa ce UI este gata)
- [x] Dedup clienti dupa telefon in UI/service pentru a evita aparitia duplicatelor (focus pe finalize+streams)

Testare (astept loguri):
- Deschide app, mergi direct in ecranul principal; asteapta 3–5 secunde.
- Trigger: navigheaza spre Clients si Calendar; creeaza o intalnire de test.
- Colecteaza `logs.txt` (AppLogger) si console (daca rulezi in debug) si trimite-mi.
Loguri asteptate:
- update_service/* doar la startup (daca ruleaza prelaunch)
- main_screen/build_called dedup rar
- metrics: clients_service.load_clients_ms, splash_service.refresh_meetings_cache_ms (sau similar)
- meeting_service: createMeeting flow si validari

### Faza 2 — Securitate LLM proxy (minim necesar, compatibil)
- [x] Client LLM: trimite Authorization: Bearer <idToken>
- [x] Cloud Function: verifica Firebase ID token si respinge 401 daca lipseste/invalid
- [x] CORS pastrat simplu, dar acces conditionat de token valid

Testare:
- Deschide Chat si trimite un mesaj scurt; confirma in logs function `llmGenerate` ca token-ul este validat (200) si ca raspunsul vine.

### Faza 3 — Corectitudine meeting conflicts (quick guard)
 - [x] Verificare remote a conflictului inainte de creare: collectionGroup('meetings') cu isEqualTo pe dateTime + consultantToken

Testare:
- Programeaza doua intalniri pe acelasi minut; a doua trebuie sa esueze cu mesaj de conflict (log clar) si fara scriere.

### Faza 4 — Performanta si curatenie
 - [x] Opreste arrays legacy `completedClientsFor*` (ramane dedup + sharded counters)
 - [x] Reduce verbose logs ramase (AI_DEBUG/GOOGLE_DRIVE_SERVICE) la nivel redus via AppLogger

Testare:
- Navigheaza Dashboard; confirma ca scrierile merg doar in dedup + shards (loguri + inspectie Firestore) si ca nu se mai logheaza PII.

### Faza 5 — Migrare incrementala optionala
- [x] ID compus pentru clienti noi: `${token}__${phone}` (citire fallback pentru vechi)

Testare:
- Creeaza client nou; verifica id compus si acces corect in UI si Firestore.

---

## Ghid testare (pasii si ce loguri cautam)
- Startup: asteapta pana UI incarcat; cauta in `logs.txt` metrici `clients_service.load_clients_ms` si `splash_service.ready_update_found` (daca exista update ready).
- Clients: intra pe Clients si asteapta initializare; cauta `clients_service.load_clients_ms` si `CLIENT_SERVICE: notifyListeners called` (dedup limitat).
- Calendar: creeaza o intalnire; cauta `meeting_service.create_meeting_remote_check` si `meeting_service.meeting_created`.
- Chat: trimite o intrebare; cauta in Cloud Function logs `llmGenerate` 200 si in client `llm_service.proxy_call_ok`.

Trimite-mi `logs.txt` si orice eroare/console. Eu voi bifa checkbox-urile dupa validare.


