## App Optimization Master Plan

Document scope: plan pe faze, complet si executabil, pentru a aduce performanta perceputa la nivel „instant” si latente reale minime, fara a modifica logica de business. Planul mapeaza clar obiectivele, livrabilele, criteriile de acceptare, riscurile si ordinea recomandata. Toate propunerile sunt compatibile cu arhitectura existenta.

Nota: textul este fara diacritice conform cerintei.

### Guiding principles
- Prioritizeaza „cache-first UI”: randare instant din memorie/cache, apoi sync in fundal
- Evita orice fetch/sequencing inutil: batch, debounce, stream, server-side orderBy/where
- Consistenta datelor si siguranta > micro-optimizari locale
- Fiecare faza include „success metrics (ms)”, „acceptance tests” si „rollback”


## Faza 0 — Baseline si Observabilitate 

Obiective
- Masoara punctual timpii critici (clients load, meetings load, forms save, sheets save, dashboard build)
- Reduce zgomotul de log si pastreaza doar semnale utile

Actiuni
- Activeaza „PerformanceMonitor” pe operatiuni critice (daca lipseste) si logeaza mediile la schimbare de ecran:
  - Clients: getAllClients(), stream handlers, _performLoadClients
  - Meetings: getAllMeetings(), getTeamMeetings()
  - Forms: saveAllFormData(), loadAllFormData()
  - Sheets: _findOrCreateSpreadsheet, _findOrCreateSheet, _appendRowToSheet
  - Dashboard: _loadConsultantsRanking, _loadTeamsRanking
- Aliniaza logging-ul pe AppLogger (niveluri: success/warning/error/sync). Dezactiveaza verbose.

Success metrics (ms)
- Stabilire baseline real: log median/avg pentru operatiunile de mai sus (pastreaza in logs.txt)

Acceptance tests
- Raport vizibil in logs cu timpi medii
- Zgomot de log redus (fara spam intern Firestore)

Rollback
- Doar reactivare verbose daca este nevoie de debugging


## Faza 1 — Indexare si corectitudine interogari

Obiective
- Elimina fallback-urile N+1 si asigura ordine server-side peste date mari

Actiuni
- Creeaza/valideaza indexuri Firestore (firestore.indexes.json):
  - clients: composite index (consultantToken ASC, updatedAt DESC)
  - clients: composite index (consultantToken ASC, category ASC, updatedAt DESC)
  - meetings (collectionGroup): composite index (consultantToken ASC, dateTime ASC)
- Revizuieste NewFirebaseService:
  - getAllMeetings() si getTeamMeetings(): foloseste collectionGroup + orderBy si elimina fallback-ul N+1 in build-urile de release (pastreaza fallback doar in debug dev)

Success metrics (ms)
- getAllMeetings(): sub 150–300 ms la echipe medii (fara fallback)

Acceptance tests
- Niciun „failed-precondition” in logs pe interogari meetings
- UI meetings se populeaza rapid, fara freeze

Rollback
- Re-activare fallback temporara doar in debug daca indexul lipseste


## Faza 2 — Eliminarea fetch-urilor redundante

Obiective
- Evita refresh periodic cand exista streamuri realtime active
- Coalesce invalidari cache si evita thrashing

Actiuni
- In ClientUIService._startAutoRefresh(): nu porni timer daca _realTimeSubscription este activ; daca stream cade si retry atinge limita, activeaza un refresh rar (ex. 10 min) ca fallback
- In SplashService si ClientUIService: coalesce invalidarile de cache (pastreaza un singur timer de 100–200 ms si un flag atomic pentru a evita inval/double-load)
- Extinde TTL-uri la cache: meetings/clients 2–5 minute pentru primele paint-uri; rely pe stream pentru actualizari

Implementat
- ClientUIService: auto-refresh oprit cand RT este activ; fallback 10 min doar daca nu exista listeners
- ClientUIService: cacheValidity ridicat la 5 min pentru loadClientsFromFirebase

Success metrics (ms)
- Scadere vizibila a rebuild-urilor si a fetch-urilor in logs; frame-time stabil (sub 16ms)

Acceptance tests
- Niciun dublu fetch in primele 2 minute dupa pornirea listenerelor

Rollback
- Re-activare refresh periodic la 2 minute daca RT cade frecvent (monitorizat)


## Faza 3 — Forms autosave: debounce + batch

Obiective
- Reduce writes si elimine micro-lag in timp ce se tasteaza

Actiuni
- In FormService: introdu un buffer per clientId si un debounce de 600 ms pentru _autoSaveToFirebaseForClient()
- Commit scrierile prin WriteBatch (subcolectie forms + updatedAt client) pentru atomicitate
- Flush pe: dispose(), schimbare pane, navigare away, focus loss prelungit (>2s)
- Evita scrieri identice (hash local al payload-ului; nu trimite daca nu s-a schimbat fata de ultimul commit reusit)

Success metrics (ms)
- -90% numar writes/minut; fiecare commit sub 120–200 ms

Acceptance tests
- Tastarea rapida nu mai introduce lag si nu mai produce rafale de scrieri
- Datele raman consistente dupa inchiderea rapida a app-ului (flush functioneaza)

Rollback
- Reduce debounce la 300 ms daca utilizatorii raporteaza pierderi rare de editari


## Faza 4 — Google Sheets pipeline turbo

Obiective
- Micsoreaza de 3–8x timpul de salvare in Sheets; elimina duplicate check costisitor per save

Actiuni
- Cache telefoane per spreadsheetId+sheetTitle: o singura incarcare/luna
  - _checkIfClientExistsInSheet(): incarca telefoanele o data in Set<String>; apoi membership O(1)
- Foloseste spreadsheets.values.append cu insertDataOption=INSERT_ROWS (nu update la randul calculat manual) pentru a evita values.get secund
- In caz de esec de append din duplicat (rara cursa concurenta): marcheaza telefonul in Set si reia (sau skip)
- Token refresh/ensure in background inainte de salvare; reduce logs si latch-uri

Implementat
- sheets_service: _appendRowToSheet foloseste acum spreadsheets.values.append(INSERT_ROWS) cu majorDimension=ROWS; eliminat get(range=A:Z)

Success metrics (ms)
- Save complet sub ~250–400 ms in loc de 1.5–3.5 s

Acceptance tests
- Salvare consecutiva a 5 clienti diferiti: total < 2.5s
- Duplicatele sunt ignorate corect fara a re-citi foaia integral

Rollback
- Revino temporar la duplicate-check direct prin get(A:Z) doar pentru sesiuni de test


## Faza 5 — Dashboard eficient

Obiective
- Reduce round-trips pentru clasamente si statistici

Actiuni
- Chunked whereIn pe monthly docs: in loc sa citesti shards per consultant, citeste doc-urile in bucati de cate 10 (FieldPath.documentId, whereIn)
- Cache lunar per consultantToken in SplashService; invalidare la evenimente critice (onMeetingCreated/onFormCompleted)
- Optional (ulterior): agregari precalculate „leaderboards/{ym}” (Cloud Functions) pentru timpi ~10–30 ms

Success metrics (ms)
- Timp total dashboard initial -200..-600 ms la echipe medii

Acceptance tests
- Navigarea intre luni este fluida (<200 ms dupa cache)

Rollback
- Revenire la citiri individuale daca whereIn e limitativ (mentine chunking 10 pentru siguranta)


## Faza 6 — Meetings/Calendar consistency

Obiective
- Asigura queries stabile si batch writes

Actiuni
- CreateMeeting/UpdateMeeting/DeleteMeeting: foloseste WriteBatch impreuna cu update la updatedAt client

Implementat
- NewFirebaseService: createMeeting/updateMeeting/deleteMeeting scriu acum in batch (meeting + clients.updatedAt)
- Valideaza existenta indexului collectionGroup si elimina fallback-ul N+1 din release

Success metrics (ms)
- Create+update timestamp atomic sub 120–200 ms

Acceptance tests
- Calendar reflecta mutarile in <300 ms fara re-fetch masiv

Rollback
- Secventializeaza temporar scrierile daca apar conflicte


## Faza 7 — LLMService pe cache si securitate

Obiective
- Evita fetch live greoi; elimina API key hardcodat

Actiuni
- In _sendMessageToLLM/buildPromptWithContext: foloseste SplashService.getCachedClients()/getCachedMeetings() si DashboardService cache; evita acces direct Firestore in LLM
- Mutare API key din cod: foloseste .env / Secret Manager / platform secure storage; fallback test-only
- Reduce log-urile AI la minim (fara date sensibile)

Implementat
- LLMService: contextul este construit cache-first din SplashService; API key citit din environment (GEMINI_API_KEY), fallback doar pentru debug

Success metrics (ms)
- Timp pregatire prompt -300..-1200 ms; zero blocaj UI

Acceptance tests
- Chat raspunde fara hickup si fara trafic suplimentar excesiv

Rollback
- Re-enable live fetch doar in mod debug investigativ


## Faza 8 — Paginare si lazy UI

Obiective
- Asigura fluiditate la 100x date

Actiuni
- ClientsPane: afiseaza doar primii N (ex. 100) si adauga paginare/lazy load pentru rest (limit + startAfter in NewFirebaseService; UI cu loader discret)
- Pastreaza stream full pentru consistenta, dar UI renderizeaza incremental si stabil (ordine server-side)

Success metrics (ms)
- Build lists sub 20 ms la loturi, scroll fluid 60 fps

Acceptance tests
- Scroll pe liste mari fara jank

Rollback
- Revino la randare integrala daca loturile sunt mici in practica


## Faza 9 — Coherenta invalidari si TTL

Obiective
- Opreste thrashing si rebuild-uri duble

Actiuni
- Unifica invalidarile de cache (meetings, clients) intr-un singur scheduler in SplashService; foloseste un singur flag atomic „_hasPendingInvalidation” (deja partial implementat) si timpi 50–200 ms
- TTL pentru cache clients/meetings 2–5 minute; rely pe stream pentru actualizare

Success metrics (ms)
- Mai putine re-notify si rebuild; frame time stabil

Acceptance tests
- Niciun loop de invalidate/load vizibil in logs

Rollback
- Ajusteaza TTL si debounce pentru medii cu refresh frecvent


## Faza 10 — Batching transversal si consistenta

Obiective
- Maximizeaza WriteBatch in locuri cu 2+ writes secventiale

Actiuni
- Meeting create + client.updatedAt in acelasi batch
- Form save (forms subcolectie + client.updatedAt) in acelasi batch
- Dashboard counters: dedupe marker + shard increment in acelasi batch daca raman in acelasi grup logic (sau sequential microtask)

Success metrics (ms)
- -80..-150 ms pe operatiuni compuse

Acceptance tests
- Nicio inconsecventa partiala (ex: meeting fara updatedAt)

Rollback
- Revino la scrieri secventiale daca apare un conflict rar


## Faza 11 — Testare, masurare, rollout

Obiective
- Valideaza imbunatatirile si stabilitatea

Checklist testare manuala
- Startup: pana la primul frame util < 150 ms perceput (UI din cache)
- Clients: focus instant, fara lag la tastare; autosave la 600 ms; flush on navigate
- Meetings: creare/editare/stergere instant (optimistic), sync < 300 ms
- Sheets: salvare ~250–400 ms; duplicate skip corect
- Dashboard: navigare intre luni < 200 ms (dupa cache)
- LLM: raspuns fara fetchuri live suplimentare

KPI post-implementare
- Numarul de reads/writes Firestore scade
- Timp mediu Sheets save scade de 3–8x
- Caderea frame time sub 16 ms in panes principale

Rollout
- Activeaza modificarile in feature flags (unde e cazul) sau incremental by module
- Monitorizeaza logs.txt si PerformanceMonitor print pentru 2–3 zile

Rollback
- Toate modificarile sunt guardate: poti dezactiva debounce/paginare/append caching dintr-un singur loc de config


## Ap. A — Modificari punctuale de cod (to-do exact)

1) ClientUIService
- _startAutoRefresh(): nu porni cand _realTimeSubscription != null; fallback 10 min doar daca listeners se opresc definitiv
- focusClient(): deja preincarca form-ul in background (ok)

2) SplashService
- Coalesce invalidate pentru clients/meetings intr-un singur timer; TTL 2–5 min
- Preload form data: max 1–2 clienti per categorie, doar daca nu exista in cache

3) NewFirebaseService
- getAllMeetings/getTeamMeetings: collectionGroup + orderBy, elimina fallback N+1 in release
- Foloseste WriteBatch pentru createMeeting + updatedAt client

4) FormService
- Debounce 600 ms pe _autoSaveToFirebaseForClient; buffer per clientId; flush pe dispose/navigate; WriteBatch pentru form + updatedAt
- Evita scrieri identice (hash payload)

5) GoogleDriveService (sheets_service)
- Introdu Set<String> telefoane per (spreadsheetId|sheetTitle) incarcat o singura data pe luna
- Foloseste spreadsheets.values.append (insert) in loc de values.update la rand calculat
- Token ensure in background; logs reduse

6) DashboardService
- Chunked whereIn pe monthly docs in loturi de 10 pentru citirea rapida a consultantilor
- Cache lunar per consultant in SplashService

7) LLMService
- Foloseste SplashService cache pentru context; elimina API key hardcodat si muta in secure storage/ENV

8) UI liste
- ClientsPane: paginare/lazy; limiteaza la 100 in prima pagina; load on demand


## Ap. B — Indici Firestore recomandati (conceptual)

- clients: (consultantToken ASC, updatedAt DESC)
- clients: (consultantToken ASC, category ASC, updatedAt DESC)
- meetings (collectionGroup): (consultantToken ASC, dateTime ASC)


## Ap. C — Riscuri si mitigari

- Debounce forms: risc de pierdere la inchidere in fereastra debounce → flush in dispose si onNavigate
- Cache telefoane Sheets: desincronizare in sesiuni paralele → on-append error, marcheaza telefonul in cache si skip retry
- Dezactivare auto-refresh: daca RT cade, foloseste backoff existent si fallback rar


## Ap. D — Timeline si impact estimativ

- Ziua 1: Faza 1, 2, 9 (impact imediat)
- Ziua 2: Faza 3, 4 (UX, Sheets)
- Ziua 3: Faza 5, 6, 7, 8 (rafinare si scalare)

Impact total (estimativ)
- Meetings: -1..-3 s → <300 ms
- Sheets: -1..-2.5 s → ~250–400 ms
- Forms: -90% writes, 0 lag la tastare
- Dashboard: -200..-600 ms
- UI: frame-time stabil, randare instant din cache


## Ap. E — Criterii finale de acceptare

- Toate ecranele afiseaza date din cache instant; sync in fundal fara glitch
- Niciun loader vizibil in fluxurile principale (doar in cazuri rare)
- Latentele medii conforme cu success metrics din fiecare faza


