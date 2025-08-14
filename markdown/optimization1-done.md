Voi scana serviciile Firebase/Firestore si firestore.rules pentru a extrage schema actuala, relatiile si pattern-urile de query. Apoi voi propune o schema optimizata, reguli si strategii de caching, cu exemple de migrare si indexuri. Incep prin a deschide fisierele relevante si a cauta utilizari Firestore in cod.
Voi livra o harta completa a schemelor Firestore din aplicatia ta, apoi o diagnoza de performanta/securitate si o schema propusa cu reguli, caching si indexuri optimizate. Iti dau si exemple de cod (Dart + Firestore Rules) si un plan de migrare incremental, compatibil cu fluxurile actuale.
Schema actuala (din cod)
consultants (doc id = Firebase Auth UID)
campuri: name, team, token, email, role, createdAt, updatedAt, lastActive, settings
utilizari: lookup token/rol/equipe; ranking si restrictii pe token
referinte: consultants/{uid} in reguli
clients (doc id = phoneNumber) [scoped prin campul consultantToken]
campuri: consultantToken, name, phoneNumber, coDebitorName, status('normal'|'focused'), category('clienti'|'reveniri'|'recente'), createdAt, updatedAt
extra: phoneNumber2, formData, isCompleted, discussionStatus, scheduledDateTime, additionalInfo
subcolectii:
forms (doc id = formId: 'unified_form'|'loan'|'income')
campuri: formId, data, createdAt, updatedAt
meetings (doc id auto)
campuri: dateTime, type('meeting'|'bureauDelete'), description, consultantToken, consultantName, clientName, createdAt, updatedAt, additionalData{...}
stats (inconsistent pathing)
global: stats/global (din NewFirebaseService)
teams: stats/teams/{team}/stats (din NewFirebaseService)
monthly: data/stats/monthly/{yyyy-MM}/consultants/{consultantToken} cu fields: formsCompleted, meetingsHeld, completedClientsForForms[], completedClientsForMeetings[], lastUpdated
daily: data/stats/daily/{yyyy-MM-dd}/consultants/{consultantToken} cu fields similare
security rules (cheie)
clients si subcolectii validate cu consultantToken == getConsultantToken(request.auth.uid)
stats: match /data/stats/{document=**} { allow read, write: if request.auth != null }
unused: match /meetings/{meetingId} (nu se foloseste top-level meetings)
Referinte utile din cod:
Probleme identificate
ID coliziuni: clients foloseste docId = phoneNumber global. Daca acelasi numar apare la 2 consultanti, apare conflict de scriere/acces (nu exista izolarea pe consultant).
Query-uri N+1 scumpe pentru meetings: pentru echipe, se listeaza consultantii → clientii fiecarui consultant → meetings per client (multe citiri). Ar trebui colectie-grup pe meetings.
Indexuri composite gresite/incomplete:
firestore.indexes.json foloseste collectionGroup: "clients" (colectie-grup inexistenta); pentru top-level clients trebuie collectionId: "clients".
Lipsesc indexuri pe (consultantToken, category, updatedAt) si (consultantToken, status, updatedAt) pentru stream-urile cu orderBy.
Duplicare si crestere document:
Date formular dublate in clients.formData si in clients/{id}/forms/{formId}.data → risc apropiere 1 MiB/doc si cost I/O.
Arrays pentru deduplicare stats (completedClientsFor*) cresc lunar necontrolat → risc 1 MiB/doc si costuri.
Race conditions / consistenta:
Stats se actualizeaza prin read-modify-write pe liste + increment, fara tranzactie sau arrayUnion → risc de dublare/pierdere increment la acces concurent.
Inconsistenta path pentru stats: stats/global si stats/teams/... vs data/stats/... pentru monthly/daily. Reguli si cod diferite.
Reguli de securitate prea laxe pentru stats: orice user autentificat poate scrie oriunde in data/stats/**.
Unused rules: match /meetings/{meetingId} (nefolosit).
Sorting pe client side pentru stream-ul principal de clienti (ca ocolire de index) → latenta si CPU in client.
Fara TTL: daily stats si dedup pot ramane indefinit → cost stocare.
Scaling writes: counters la nivel de doc (1 doc/consultant/luna) au limita scrieri/s doc; la load mare trebuie sharded counters.
Schema propusa (compatibila, cu migrare incrementala)
Faza 1: Corecturi fara a schimba logica UI/servicii semnificativ
Pastreaza clients la top-level, dar schimba id-ul noilor clienti la cheie compusa pentru unicitate:
clientId = ${consultantToken}__${phoneNumber}
adauga campuri: phoneNumber (exista), consultantToken (exista), clientId (redundant pentru referinta)
pentru clienti existenti cu id=phoneNumber: pastreaza citire duala (fallback) in servicii
Normalizeaza forms:
elimina treptat clients.formData; foloseste doar clients/{id}/forms/{formId}
Meetings:
pastreaza subcolectia curenta (compatibilitate)
adauga camp phoneNumber in fiecare meeting (deja e in additionalData, oficializeaza-l la radacina) pentru query-uri group
Stats:
unifica root la data/stats/** (si muta stats/global/stats/teams sub data/stats/global si data/stats/teams/{team}/stats)
inlocuieste array-urile completedClientsFor* cu subcolectii:
data/stats/monthly/{ym}/consultants/{token}/countedForms/{clientPhoneNumber}
data/stats/monthly/{ym}/consultants/{token}/countedMeetings/{clientPhoneNumber}
counters shard-uiti (10-50 shards) pentru formsCompleted si meetingsHeld:
.../counters/forms/{shardId} si .../counters/meetings/{shardId}
TTL:
adauga expireAt pe data/stats/daily/{day}/consultants/{token} si defineste TTL policy (ex: 32 de zile)
Indexuri:
composite corecte pentru clients si collectionGroup pentru meetings
Security Rules:
blocheaza modificarea campului consultantToken in updates
limiteaza scrierile la data/stats/... per consultantToken si doar pe resursele proprii
elimina regula nefolosita top-level meetings
Faza 2: Optional (mai strict, dar mai curat)
Mutare full sub consultant:
consultants/{uid or token}/clients/{phoneNumber}/...
foloseste collectionGroup queries pentru liste globale (clients, meetings)
simplifica rules: scoping natural pe path
Daca ramai la top-level: mentine id compus ${token}__${phone} pentru toate entitatile dependente de consultant.
Cod exemplu (Dart + Rules)
CollectionGroup query pentru meetings pe echipa (fara N+1)
Query clienti cu index compus (sort server-side)
Stats cu dedup si sharded counters (no arrays, no RMW race)
Security Rules imbunatatite (top-level clients + collectionGroup meetings)
Indexuri (corect)
Strategii de caching si performanta
Clienti:
foloseste doar query-uri indexate cu orderBy pe server, elimina sortarea locala
pagina cu limit si startAfter daca lista depaseste 500
mentine cache in memorie (deja implementat) + optional Hive pentru offline minimal (id, name, status, category, updatedAt)
Meetings:
inlocuieste colectarea N+1 cu collectionGroup queries si ferestre (data curenta ± N zile)
Stats:
sharded counters si dedup in subcolectii — scrieri paralele scalabile (>=500 ops/sec/colectie)
daily docs cu TTL
Logs si profilare:
reducere log spam (deja aveti filtrare), mosteniti PerformanceMonitor dar agregati medii/percentile la metrici cheie
Plan migrare (fara downtime, compatibil)
1) Indexuri si reguli
publica indexurile corecte pentru clients si collectionGroup meetings
aplica noile reguli (permit si vechiul comportament, doar intaresc token immutabil)
2) Dual-write non‑breaking pentru stats
schimba incrementul in dashboard_service sa scrie:
counted subcollection (dedup)
sharded counter (in tranzactie)
lasa in paralel si vechiul camp formsCompleted/meetingsHeld o vreme (citirea poate prefera noul sistem cand disponibil)
3) Clients ID compus (optional in Faza 1)
la creare de clienti noi: foloseste id ${token}__${phone}
la citire: incearca intai id compus, apoi fallback pe id=phone (pentru clienti vechi)
migrare progresiva: job/admin script care copiaza docurile vechi la noile id-uri si sterge dupa verificare
4) Meetings group query
adauga phoneNumber la radacina fiecarui meeting la scriere (compatibil cu citirea existenta)
inlocuieste getTeamMeetings cu varianta collectionGroup batuta mai sus
5) Normalizare formData
opreste popularea clients.formData
pastreaza doar clients/{id}/forms/{formId}.data
cleanup ulterior pentru a reduce dimensiunea doc-urilor clienti
6) Unificare path stats
muta stats/global si stats/teams/... sub data/stats/...
tine compat fallback pentru citire pana cand toate scrierile merg pe noul path
7) TTL
adauga expireAt pe daily docs si seteaza TTL in consola (ex: 32 zile)
8) Verificare si rollback
ruleaza queries de validare (numar meetings, clienti, stats) comparativ inainte/dupa
mentine feature flags (ex: toggles in service) pentru a reveni la vechiul query daca apare regresie
Monitorizare si backup
Firestore Usage Monitoring
activeaza export catre BigQuery (audit + usage) si urmareste latenta/reads per query
alerte pe crestere brusca reads/write
Backups
programeaza export zilnic in Cloud Storage (Cloud Scheduler + gcloud firestore export) sau foloseste PITR
retenie: 30-90 zile
Observabilitate aplicatie
metrici: durata queries cheie (clients load, team meetings, save form)
track erori rules (permission-denied) cu sampling
Scurt rezumat al impactului:
Eliminam N+1 la meetings (latenta scade drastic, cost reads mai mic)
Query-uri clienti devin 100% indexate (fara sort local)
Stats devin scalabile si rezistente la race (sharded counters + dedup)
Reducem riscul 1 MiB/doc si inconsistente (normalizare formData, fara arrays uriase)
Reguli mai stricte si aliniere paths stats
Am citit integral serviciile din lib/backend/services/ si firestore.rules, am extras schema curenta, problemele de performanta/securitate si am propus o schema compatibila, cu reguli, indexuri corecte si strategii de caching.
Am oferit cod Dart pentru queries optimizate (collectionGroup) si counters shard-uiti, plus rules si indexuri gata de aplicat.
Da, incepe

Voi documenta schema actuala Firestore si fluxurile de date, voi expune problemele de performanta/securitate, apoi voi propune o schema si reguli optimizate, cu strategii de caching si indexuri compuse. Iti ofer si cod Dart + Rules si un plan de migrare incremental, compatibil cu logica actuala.
Schema Actuala
consultants (doc id = Firebase Auth UID)
campuri: name, team, token, email, role, createdAt, updatedAt, lastActive, settings{theme, notifications}
folosit pentru: lookup token/rol/echipa; securitate; clasamente
clients (doc id = phoneNumber) [scoped prin campul consultantToken]
campuri: consultantToken, name, phoneNumber, phoneNumber2?, coDebitorName?, status('normal'|'focused' sau int), category('clienti'|'reveniri'|'recente' sau int), formData (duplicat), discussionStatus?, scheduledDateTime?, additionalInfo?, isCompleted?, createdAt, updatedAt
subcolectii:
forms (doc id = 'unified_form' | 'loan' | 'income')
campuri: formId, data, createdAt, updatedAt
meetings (doc id auto)
campuri: dateTime, type('meeting'|'bureauDelete'), description?, consultantToken, consultantName, clientName, createdAt, updatedAt, additionalData{phoneNumber?, consultantId?, ...}
stats (neuniform)
global: stats/global (doar in NewFirebaseService)
teams: stats/teams/{team}/stats
monthly: data/stats/monthly/{yyyy-MM}/consultants/{consultantToken} cu: formsCompleted, meetingsHeld, completedClientsForForms[], completedClientsForMeetings[], lastUpdated
daily: data/stats/daily/{yyyy-MM-dd}/consultants/{consultantToken} cu campuri similare
reguli securitate (esential)
clients si subcolectii validate cu consultantToken == getConsultantToken(request.auth.uid)
data/stats/: allow read, write: if request.auth != null (prea permisive)
reguli nefolosite pentru meetings top-level (colectia nu exista)
Probleme Identificate
Unicitate/izolare date: clients id = phoneNumber global → conflicte intre consultanti; izolarea este doar prin campul consultantToken, nu prin path/id.
Meetings N+1: pentru echipe se parcurg multi pasi (consultants → clients → meetings), cost mare de citiri si latenta. Lipsesc collectionGroup queries.
Indexuri:
fisierul indexes foloseste collectionGroup: "clients" (inexistent). Pentru top-level trebuie collectionId: "clients".
lipsesc (consultantToken, category, updatedAt) si (consultantToken, status, updatedAt).
Dimensiune document si duplicare: formData duplicata in clients si in forms; risc crestere spre 1 MiB/doc, cost I/O si sync.
Race conditions stats: se folosesc liste de dedup in acelasi document + increment ne-atomic → dublari/pierderi la concurenta.
Inconsistenta cai stats: mix intre stats/... si data/stats/...; reguli nu acopera consistent.
Reguli stats prea permisive (oricine autentificat poate scrie oriunde in data/stats/).
Sortare pe client pentru streams (ocolire de index) → latenta si CPU pe client.
Fara TTL pe daily stats si markers → acumulare necontrolata.
Limite scriere: counters pe doc unic pot atinge limite la volum mare; lipsesc sharded counters.
Schema Propusa (compatibila, incremental)
Clients (Faza 1, compatibila)
mentine top-level, dar pentru clienti noi foloseste doc id compus: clientId = ${consultantToken}__${phoneNumber}
pastreaza campurile: consultantToken, phoneNumber, name, status, category, createdAt, updatedAt
elimina progresiv clients.formData (ramane doar in subcolectia forms)
fallback la citire: daca nu gasesti id compus, incearca id vechi = phoneNumber
Forms
sursa unica: clients/{clientId}/forms/{formId}.data
nu mai scrie formData in documentul clientului
Meetings
pastreaza subcolectia curenta sub client
asigura-te ca setezi phoneNumber si consultantToken la radacina meeting-ului (nu doar in additionalData)
foloseste collectionGroup('meetings') pentru queries pe echipa/interval
Stats (unificare si scalare)
unifica sub data/stats/:
global: data/stats/global
teams: data/stats/teams/{team}/stats
monthly: data/stats/monthly/{yyyy-MM}/consultants/{consultantToken}
dedup markers ca subcolectii:
countedForms/{clientPhoneNumber}
countedMeetings/{clientPhoneNumber}
sharded counters:
counters/forms/shards/{0..N-1}.count
counters/meetings/shards/{0..N-1}.count
daily: data/stats/daily/{yyyy-MM-dd}/consultants/{consultantToken} + expireAt pt TTL
TTL
seteaza TTL pe data/stats/daily/** la 32 zile (sau conform politicii)
Indexuri
compuse corecte pentru clients (consultantToken + category/status + updatedAt)
collectionGroup pe meetings (consultantToken + dateTime)
Reguli
blocheaza modificarea consultantToken la update
scrieri in stats restranse la token-ul utilizatorului (sau Cloud Functions), nu global
Cod Exemplu
Query meetings pe echipa (collectionGroup, fara N+1)
Clients stream cu sort server-side (evita sort local)
Stats cu dedup + sharded counters (atomic)
Firestore Rules (top-level clients + collectionGroup meetings; token imuabil)
Indexuri corecte
Plan Migrare
1) Indexuri si reguli
publica indexurile corecte pentru clients si collectionGroup meetings
aplica noile reguli (blocheaza schimbarea consultantToken, pastreaza compat)
2) Stats dual-write (fara downtime)
la increment, scrie dedup marker + sharded counter in paralel cu vechiul camp
citirea poate prefera noul sistem (daca exista), cu fallback pe vechi
3) Client ID compus
pentru clienti noi: id = ${token}__${phone}
la citire: cauta intai id compus, apoi fallback la id vechi
migrare in fundal: copie clienti vechi in id compus si actualizeaza referinte
4) Meetings
adauga phoneNumber si consultantToken la radacina fiecarui meeting
inlocuieste obtinerea intalnirilor pe echipa cu collectionGroup queries pe intervale
5) Normalizare forms
nu mai scrie clients.formData; foloseste exclusiv subcolectia forms
cleanup ulterior al campului duplicat
6) Unificare cai stats
muta stats/global, stats/teams sub data/stats/..., cu traseu de citire compatibil
adauga expireAt pe daily si configureaza TTL
7) Validare si rollback
compara contorizarile si numarul de documente inainte/dupa
foloseste feature flags pentru a reveni rapid la vechiul flux in caz de regresii
Monitorizare si backup
Monitorizare
activeaza export catre BigQuery (audit/usage), alerte la crestere brusca a reads/writes
metrici: latenta queries cheie, numar citiri per ecran, rate de eroare rules
Backup
programare export zilnic in Cloud Storage (Cloud Scheduler + gcloud firestore export) si/sau PITR
retenie 30-90 zile
Cost/performanta
limiteaza documentele la < 1 MiB prin normalizare (fara formData duplicat)
sharded counters (20-50 shards) asigura >500 ops/sec/colectie
paginare si limite in queries, orderBy pe campuri indexate
Am livrat o harta completa a colectiilor/subcolectiilor cu campuri esentiale, problemele actuale si riscurile principale.
Am propus o schema compatibila, reguli si indexuri corecte, plus cod exemplu (Dart + Rules) si un plan de migrare incremental.
Perfect! Poti incepe, daca esti gata! Lucrează metodic — nu face salturi; explică-ți deciziile și genereaza o livrare finală, completă și ne-grăbită pentru optimizarea Firestore.

Voi livra un plan complet si sigur pentru optimizarea Firestore: documentez schema actuala, explic deciziile de redesign, propun schema si reguli noi (compatibile), indexuri corecte, strategii de caching si agregare, plus un plan de migrare pas-cu-pas, cu cod Dart si Rules. Nu schimb logica de business; reduc latența si costurile, mentinand separarea pe consultantToken.
Schema Actuala (rezumat din cod)
consultants (id = Firebase Auth UID)
campuri: name, team, token, email, role, createdAt, updatedAt, lastActive, settings{theme, notifications}
clients (id = phoneNumber, scoped prin consultantToken)
campuri: consultantToken, name, phoneNumber, phoneNumber2?, coDebitorName?, status, category, formData (duplicat), discussionStatus?, scheduledDateTime?, additionalInfo?, isCompleted?, createdAt, updatedAt
subcolectii:
forms/{formId} cu {formId, data, createdAt, updatedAt}
meetings/{autoId} cu {dateTime, type, description?, consultantToken, consultantName, clientName, createdAt, updatedAt, additionalData{...}}
stats (neuniform):
stats/global; stats/teams/{team}/stats
data/stats/monthly/{yyyy-MM}/consultants/{consultantToken}: formsCompleted, meetingsHeld, completedClientsForForms[], completedClientsForMeetings[], lastUpdated
data/stats/daily/{yyyy-MM-dd}/consultants/{consultantToken}: campuri similare
reguli: validare bazata pe consultantToken (din consultants/{uid}); data/stats/** este prea permisiv
Probleme Identificate (si impact)
clients id=phoneNumber global: coliziuni intre consultanti; izolarea doar prin campul consultantToken (nu prin path/id)
meetings N+1 pentru echipe: iterare consultants → clients → meetings (multi reads, latenta)
indexuri incorecte/incomplete:
collectionGroup: "clients" (inexistent); lipsesc (consultantToken, category/status, updatedAt)
duplicare formData in doc client + forms: risc spre 1 MiB/doc, cost I/O, sync dificil
stats cu arrays si RMW: race conditions si risc depasire 1 MiB pe luna
cai nealiniate stats/... vs data/stats/...: complica reguli si query-uri
reguli prea permisive pentru stats; regula pentru meetings top-level nefolosita
sortare pe client ca workaround de index: CPU si latența pe client
fara TTL pentru daily si markeri: crestere necontrolata a volumului
limita scrieri pe doc singular in stats: scalabilitate redusa fara sharded counters
Schema Propusa (compatibila, incremental)
Clients (ramane top-level; compat)
pentru clienti noi: id compus clientId = ${consultantToken}__${phoneNumber}
pastram campurile actuale; facem formData doar in subcolectia forms (nu in doc client)
fallback la citire: daca nu exista id compus, cauta id=phoneNumber (pentru clienti vechi)
Forms
sursa unica: clients/{clientId}/forms/{formId}.data
Meetings
raman sub clients/{clientId}/meetings/*
asigura campuri plane: consultantToken, phoneNumber la radacina meeting-ului (nu doar in additionalData)
queries pe echipa/interval cu collectionGroup('meetings')
Stats (unificare si scalare)
mutam la data/stats/**:
data/stats/global
data/stats/teams/{team}/stats
data/stats/monthly/{ym}/consultants/{token}:
dedup: countedForms/{clientPhoneNumber}, countedMeetings/{clientPhoneNumber}
sharded counters:
counters/forms/shards/{0..N-1} cu count
counters/meetings/shards/{0..N-1} cu count
data/stats/daily/{day}/consultants/{token} + expireAt pentru TTL (ex. 32 zile)
Indexuri
clients: (consultantToken ASC, updatedAt DESC), (consultantToken ASC, category ASC, updatedAt DESC), (consultantToken ASC, status ASC, updatedAt DESC)
collectionGroup('meetings'): (consultantToken ASC, dateTime ASC/DESC)
Reguli
token imuabil la update pentru clients
scrieri in stats permise doar pentru consultantul curent (match pe tokenOf(uid))
eliminam regula nefolosita pentru /meetings/{} top-level
Cod Exemplu (Dart + Rules)
Helper: id compus client si fallback compatibil
Meetings pe echipa (fara N+1) cu collectionGroup
Clients stream cu sortare server-side (indexata)
Stats: dedup + sharded counters (atomic, scalabil)
Firestore Rules (token imuabil, meetings collectionGroup, stats protejate)
Indexuri corecte (corecteaza collectionId vs collectionGroup)
Strategii de Caching si Performanta
Clients:
foloseste doar queries indexate cu orderBy pe server; elimina sort local
limite/paginare (limit, startAfter) daca lista depaseste 500
cache in memorie (deja implementat) + optional cache local usor (Hive) pentru id, name, status, category, updatedAt
Meetings:
collectionGroup queries pe ferestre de timp (saptamana curenta), fara N+1
whereIn chunking in grupuri de 10 pentru tokeni multi
Stats:
sharded counters (20 sharduri) + dedup subcolectii (atomic, scalabil)
daily cu TTL (expireAt), cleanup automat
Logs/Profilare:
mentine filtrarea log-urilor; masoara latentele pentru 3 operatii cheie: load clients, load team meetings, save form
Limite:
< 1 MiB/document (eliminam formData din doc client; evitam arrays mari)
<= 500 ops/sec/colectie prin sharded counters si scrieri distribuite
Plan Migrare (pas-cu-pas, compatibil)
1) Indexuri si reguli
publica indexurile corecte pt clients si collectionGroup('meetings')
aplica reguli cu token imuabil si meetings collectionGroup; pastrezi compat cu schema actuala
2) Stats dual-write (fara downtime)
la increment: scrie dedup marker + sharded counter (nou) si mentine vechea scriere (temporar)
la citire: prefera noua agregare; fallback pe vechi daca shards lipsesc
3) Client ID compus (fara ruptura)
la creare: foloseste id token__phone
la citire: fallback la id vechi
migrare offline/back-office (script admin): copiaza doc vechi → noul id; apoi sterge vechiul doc dupa verificare; nu afecta subcolectiile (le muti odata cu doc-ul folosind batched read/write)
4) Meetings
la creare/editare: asigura phoneNumber si consultantToken la radacina doc-ului meeting
inlocuieste gradual getTeamMeetings() cu varianta collectionGroup; pastreaza fallback in spate de feature flag
5) Normalizare forms
opreste scrierea in clients.formData
cleanup progresiv: sterge campul duplicat din clients pentru doc-urile mari
6) Unificare cai stats
scrie doar sub data/stats/**
muta citirea pentru global/teams la noul path; mentine fallback o perioada
7) TTL
adauga expireAt pe daily si configureaza TTL in proiect (console)
8) Validare si rollback
compara numarul de meeting-uri si contori inainte/dupa
feature flags pentru revenire rapida in caz de regresii
Monitorizare si Backup
Monitorizare
BigQuery export pentru usage si audit logs; dashboard cu metrice de latenta/reads/writes per ecran
alerte pe crestere brusca reads/writes/hour
Backup
export zilnic catre Cloud Storage (Cloud Scheduler + gcloud firestore export) sau PITR
retenție 30-90 zile
Decizii cheie (de ce)
id compus client: elimina coliziunile si clarifica ownership-ul per consultant, fara a rupe compatibilitatea
collectionGroup pentru meetings: elimina N+1, reduce masiv latenta si costul citirilor pe echipa
sharded counters + dedup: garanteaza consistenta si scalabilitatea contorizarii, fara arrays mari fragile
normalizare formData: reduce dimensiune doc client, imbunatateste sync si elimina risc 1 MiB
reguli mai stricte: protejeaza datele si previn edge cases (ex. schimbarea consultantToken)
Am livrat schema optimizata cu reguli si indexuri corecte, cod Dart pentru queries rapide si counters shard-uiti, strategii de caching si un plan de migrare incremental si sigur.
Impact: latența mai mica (fara N+1, sort server-side), costuri reduse (mai putine reads, fara duplicari), scalare scrieri (counters shard), si securitate consolidata (token imuabil, scope strict).

---

Structura de lucru propusa (faze, fara a rupe business-ul)
Faza 0 — Pregatire si guardrails
Feature flags si fallback-uri in servicii (NewFirebaseService, DashboardService, FormService, MeetingService) pentru a comuta gradual la noile query-uri/agregari.
Audit utilizari: locuri unde se scrie/actualizeaza stats, clients, meetings, forms.
Acceptanta: build curat, comportament neschimbat by default.
Faza 1 — Reguli si indexuri corecte (sigure, non-breaking)
Reguli:
Protejeaza consultantToken la update (immutable).
Restrange data/stats/** la scriere doar pentru consultantul curent sau functii backend.
Elimina regula nefolosita pentru /meetings top-level.
Indexuri:
Inlocuieste collectionGroup: "clients" cu collectionId: "clients".
Adauga composite: (consultantToken ASC, updatedAt DESC), (consultantToken ASC, category ASC, updatedAt DESC), (consultantToken ASC, status ASC, updatedAt DESC).
Acceptanta: toate stream-urile ruleaza fara sort local atunci cand folosim orderBy server-side; niciun deny de la rules in fluxurile curente.
Faza 2 — Query-uri server-side (fara sort local)
getClientsRealTimeStream si getAllClients: folosesc orderBy pe updatedAt si compozite pe category/status cand e nevoie; elimina sortarea locala.
Acceptanta: ordinea ramane identica cu implementarea actuala; latenta CPU client scade; fara erori de index.
Faza 3 — Meetings fara N+1 pentru echipe
Scriere: in fiecare meeting adauga campuri plane phoneNumber si consultantToken la radacina (uneori exista in additionalData, dar facem oficial si consistent).
Citire echipa: inlocuieste N+1 cu collectionGroup('meetings') filtrat pe interval si consultantToken in teamTokens (batch-uri de 10).
Acceptanta: lista de meetings in dashboard/calendar ramane completa si corecta; reads scad semnificativ.
Faza 4 — Stats scalabile si consistente (dual-write, fara downtime)
Dedup per client in subcolectii:
.../monthly/{ym}/consultants/{token}/countedForms/{clientPhone}
.../monthly/{ym}/consultants/{token}/countedMeetings/{clientPhone}
Sharded counters:
.../counters/forms/shards/{0..N-1}.count
.../counters/meetings/shards/{0..N-1}.count
Dual-write: la increment scriem si noul sistem si vechiul camp (formsCompleted, meetingsHeld) o perioada; citirea prefera noul sistem cand disponibil.
Acceptanta: zero duble la concurenta; valori identice fata de sistemul vechi la final de zi; latenta stabila sub incarcare.
Faza 5 — Normalizare forms (sursa unica)
Oprire scriere clients.formData; raman doar clients/{id}/forms/{formId}.data.
Citiri se fac doar din forms; mentinem fallback scurt daca e necesar.
Acceptanta: UI afiseaza aceleasi date; dimensiunea doc client scade; fara regresii in salvare.
Faza 6 — ID compus pentru clients (compat incremental)
Pentru clienti noi: docId = ${consultantToken}__${phoneNumber}; campurile pastreaza phoneNumber si consultantToken.
Citire: fallback la id vechi (phoneNumber) pentru clientii existenti.
Migrare ulterioara offline/admin (copiere + stergere).
Acceptanta: niciun conflict intre consultanti cu acelasi numar; UI si status pane functioneaza identic.
Faza 7 — Unificare paths stats si TTL
Muta stats/global si stats/teams sub data/stats/... pentru consistenta.
daily docs cu expireAt si TTL 32 zile (config in consola).
Acceptanta: dashboard si clasamente citesc corect din noua locatie, cu fallback pe vechi in tranziție.
Faza 8 — Caching si paginare
Server-side orderBy si limit/startAfter pentru liste > 500.
Pastreaza cache-ul existent in SplashService/ClientsService, dar sincronizeaza-l cu noile query-uri.
Acceptanta: memorie stabila, navigare cursiva in liste mari.
Faza 9 — Observabilitate si guardrails
Loguri concise (fara emoji), sampling pentru Firestore errors.
Metrici: duratele pentru clients load, team meetings, save form; rata deny in rules.
Optional: export Firestore catre BigQuery, alerte de usage spikes.
Acceptanta: rapoarte scurte si utile, fara spam.
Faza 10 — Migrare date (offline/admin, fara downtime)
Script admin pentru:
Copiere clienti vechi → id compus.
Mutare stats vechi → noua structura; populare dedup markers initiali.
Acceptanta: numar entitati si agregari egale inainte/dupa; rollback posibil prin feature flag.
Puncte concrete de implementare (cod touchpoints)
Reguli si indexuri:
firestore.rules: token imuabil la update, restrangere data/stats/**, cleanup regula meetings top-level.
firestore.indexes.json: corectare clients ca collectionId, adaugare composite necesare, meetings collectionGroup.
Servicii:
NewFirebaseService: getClientsRealTimeStream, getAllClients, getClientsByCategory/StatusRealTimeStream → orderBy server-side; scriere meeting cu campuri plane; adaugare queries collectionGroup.
DashboardService: in onMeetingCreated/onFormCompleted → dual-write dedup + sharded counters; citire stats prefera noul sistem.
FormService/FirebaseFormService: nu mai scrie clients.formData; citeste/scrie doar in forms.
MeetingService: foloseste noile campuri plane si notificarile raman neschimbate logic.
SplashService: foloseste noile queries (collectionGroup) pentru echipa; mentine cache si invalidate inteligente.
Migrare: MigrationService extins pentru copiere clienti la id compus si seed pentru dedup markers.
Acceptanta si testare pe faze (fara a rula comenzi)
F1 (reguli + indexuri): nul impact vizual; toate listele si salvarea funcționeaza; zero deny neasteptat; queries cu orderBy nu mai necesita sort local.
F3 (meetings group): acelasi set de meetings in calendar si dashboard ca inainte; scad citirile.
F4 (stats dual-write): contadoarele raman corecte sub operatii paralele; nu apar duplicate; dashboard afiseaza aceleasi cifre.
F5 (forms normalizare): formularul salveaza/recupereaza identic; dimensiunile doc scad.
F6 (id compus): creare/listare/actualizare/stergere clienti functioneaza identic; clienti vechi raman accesibili prin fallback.
F7 (stats unificare + TTL): dashboard si clasamente lucreaza pe noile cai; daily se curata automat.
Riscuri si mitigari
Schimbari in reguli pot bloca scrieri: introduc treptat (permit compat) si verific logs de deny.
Dual-write poate dubla costul temporar: limitat la o perioada scurta; masuram si oprim vechiul flux cand validarea trece.
Id compus necesita migrare: rulam fallback la citire pana la migrare completa; script admin testat pe subset.
Ce livrez imediat (Faza 1, non-breaking)
Edit firestore.rules: token imuabil, restrangere data/stats/**, cleanup reguli nefolosite.
Edit firestore.indexes.json: inlocuire collectionGroup: "clients" cu collectionId: "clients", adaugare composite; meetings collectionGroup asc/desc pe dateTime.
Actualizari minime in NewFirebaseService pentru a activa orderBy server-side atunci cand indexurile devin active (fallback sort local pastrat sub flag).
Dupa aprobarea structurii, execut fazele incremental si verific la fiecare pas ca UI si metricile raman stabile.
Am confirmat schema reala si problemele cheie (id=phoneNumber global, meetings N+1, stats cu arrays si write-open, sort local, duplicare formData).
Am propus un plan incremental, sigur: reguli+indexuri corecte, query-uri server-side, meetings collectionGroup, stats cu dedup+shards, normalizare forms, id compus cu fallback, unificare stats si TTL, observabilitate.
Am indicat fisierele de atins si criterii de acceptanta per faza, cu riscuri si mitigari.