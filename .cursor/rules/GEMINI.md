# Financial Consulting App Development Guide

Înainte de a începe, te rog să citești și să analizezi toate fișierele din folderul `@lib` curent pentru a evalua stadiul actual al dezvoltării.

## Procesul meu de dezvoltare

1. **Planificare și design**:
   - Pentru orice funcționalitate nouă, mai întâi concep structura (fișiere/foldere și interfață)
   - Creez design-ul în Figma
   - Export CSS din Figma în fișiere Markdown în proiect
   - Orice implementare trebuie să urmeze strict design-ul din Figma

2. **Implementare**:
   - Structurăm codul conform arhitecturii clean
   - Păstrăm separarea între frontend și backend
   - Folosim structura de fișiere descrisă în documentație

3. **Principii de calitate**:
   - Cod bine structurat și optimizat
   - Organizat în structuri logice de fișiere
   - Documentat corespunzător pentru mentenanță viitoare
   - Minimalist și eficient
   - Stabil și robust

## Abordarea tehnică

- **Flutter/Dart**: Aplicație cross-platform (Windows, macOS, Android, iOS)
- **Firebase**: Autentificare și stocare
- **Google Vision AI**: OCR avansat pentru extragerea informațiilor clienților
- **Google Drive/Sheets API**: Integrare pentru documente și spreadsheet-uri

## Ce aștept de la tine

Te rog să abordezi această aplicație cu seriozitate, cu gândire de developer senior expert. Doresc să realizăm cea mai bună versiune posibilă a acestei aplicații:
- Stabilă și foarte bine optimizată
- Minimalistă și intuitivă
- Ușor de înțeles și utilizat

FOARTE IMPORTANT: Menține tot codul aplicației bine structurat. Tot ce vom adăuga/modifica trebuie să fie implementat corect, fără a crea dezordine pe parcursul dezvoltării. Prefer cod concis, bine organizat, care respectă toate funcțiile și atribuțiile necesare pentru performanță maximă.

Pentru fiecare task, voi descrie ce vreau să realizez, iar tu mă vei ghida în implementarea corectă, respectând arhitectura și designul aplicației.

## Caracteristici principale

1. **Autentificare**: Multi-agent cu Firebase
2. **Google Vision AI**: Extragere contacte din imagini
3. **Apelare și Speech**: Integrare cu telefonul și sinteză vocală
4. **Formulare dinamice**: Informații credite și venituri
5. **Motor recomandări**: Analiza eligibilității pentru bănci
6. **Calendar întâlniri**: Sistem multi-echipă
7. **Statistici și analize**: Performanță agenți
8. **Google Drive**: Sincronizare automată

Hai să construim împreună o aplicație financiară excepțională!

---

`@about_app`

# Financial Consulting App Development Guide

## Project Overview

This document serves as a comprehensive development guide for a multi-platform financial consulting application using Flutter. The application is designed for financial brokers to manage client information, handle calls, calculate loans, and optimize their workflow.

### Application Purpose
The application will help financial brokers who assist clients in refinancing or obtaining new loans. Brokers contact potential clients from a database and offer them options to increase their credit (up to 40% or beyond of their monthly income).

### Development Philosophy
- **Design First**: Each feature begins with a Figma design that must be strictly followed
- **Structured Development**: Clean architecture with organized file structure and separation of concerns
- **Incremental Approach**: The application is developed in versions, with each adding new features based on user feedback
- **Cross-Platform**: Using Flutter for deployment on Windows, macOS, Android, and iOS

## Technical Framework

### Development Stack
- **Flutter Framework**: For cross-platform compatibility
- **Dart Language**: Primary programming language
- **Firebase**: For authentication and data storage
- **Google Drive API**: For document integration

### Project Structure (you can find it at markdown/code_structure.md)
```
main.dart
/frontend
  /screens
    - authScreen.dart     # Authentication screen with all auth modules
    - mainScreen.dart     # Main application screen with sidebar and areas
  /areas
    - formArea.dart       # Credit and income information forms
    - calendarArea.dart   # Meeting calendar display
    - settingsArea.dart   # Application settings
  /panes
    - sidebarPane.dart    # Navigation and user information
    - clientsPane.dart    # Next and recent clients
    - meetingsPane.dart   # Future meetings
    - returnsPane.dart    # Callbacks management
    - matcherPane.dart    # Bank recommendation engine
  /modules
    - loginModule.dart    # Consultant login functionality
    - registerModule.dart # Account creation
    - tokenModule.dart    # Token generation after registration
    - verifyModule.dart   # Account verification
    - recoveryModule.dart # Password reset functionality
  /popups
    - calculatorPopup.dart # Loan calculator
    - clientsPopup.dart   # Client management with OCR capability
    - meetingPopup.dart   # Meeting creation and editing
/backend
  /services
    - authService.dart      # Authentication logic
    - dashboardService.dart # Dashboard functionality
    - formService.dart      # Form handling logic
    - calendarService.dart  # Calendar management
    - clientsService.dart   # Client data handling
    - calculatorService.dart # Loan calculation logic
    - matcherService.dart   # Bank recommendation logic
    - callService.dart      # Phone integration services
  /vision
    - visionService.dart    # Google Vision AI API integration
    - documentProcessor.dart # Document analysis and processing
    - contactExtractor.dart # Extract contact info from OCR results
    - dataValidator.dart    # Validate and correct extracted data
    - visionConfig.dart     # Configuration for Vision AI
    - nameRecognition.dart  # Romanian name recognition helpers
```

## Core Features

### 1. Authentication System
- **User Selection**: Dropdown of consultants
- **Security**: Password protection for each account
- **Account Management**: Registration, login, password recovery
- **Access Levels**: Regular agents, supervisors
- **Implementation**: Firebase authentication

### 2. Google Vision AI Integration for Contact Extraction
- **Cloud-Based OCR**: Integration with Google Vision AI for superior text recognition
- **Document Analysis Pipeline**:
  1. Image submission to Vision API (visionService.dart)
  2. Document structure analysis (documentProcessor.dart)
  3. Contact information extraction (contactExtractor.dart)
  4. Data validation and correction (dataValidator.dart)
- **Capabilities**:
  - Table structure recognition
  - Form field detection
  - Multi-language support (Romanian/English)
  - Handwriting recognition
  - Layout analysis for structured documents
- **Features**:
  - Batch processing of multiple images
  - Progress visualization
  - Confidence scoring for extracted data
  - Manual correction interface
  - Data categorization (names, phone numbers, CNPs)
- **Implementation**:
  - Google Cloud Vision API integration
  - Secure credential handling
  - Optimized API usage for cost efficiency
  - Offline queue for processing during connectivity issues

### 3. One-Click Calling
- **Phone Integration**: Direct calling from app
- **Call Tracking**:
  - Status (in progress/started/ended)
  - Duration (minutes:seconds)
  - Outcome (rejected/no answer/completed)
- **UI**: Call popup interface similar to Phone Link

### 4. Automated Speech Playback
- **Functionality**: Pre-recorded introduction (30 seconds)
- **Personalization**: Dynamic name insertion
- **Voice Synthesis**: Match consultant's voice
- **Integration**: Seamless transition to live consultant

### 5. Loan and Income Forms
- **Dual Forms**: Client and co-borrower information
- **Dynamic Fields**:
  - Bank selection dropdown
  - Credit type options (Card de cumparaturi, Nevoi personale, Overdraft, Ipotecar, Prima casa)
  - Conditional fields based on selection
- **Implementation**: Adaptive form that changes based on selections

### 6. Bank Recommendation Engine
- **Analysis**: Client eligibility determination
- **Criteria**:
  - Age verification
  - FICO score assessment
  - Employment history
  - Income levels
- **Configuration**: Adjustable bank parameters in settings

### 7. Loan Calculator
- **Inputs**: Loan amount, interest rate, term
- **Outputs**: Monthly payment, total interest, total payment
- **Visualization**: Amortization table with show/hide function
- **Implementation**: calculatorPopup.dart with calculatorService.dart

### 8. Follow-up Call Management
- **Scheduling**: System for callbacks
- **Categories**:
  - Scheduled callbacks (specific time)
  - Missed calls (no specific time)
- **Implementation**: returnsPane.dart with integrated notifications

### 9. Meeting Calendar
- **Multi-team System**: Visibility across 3 teams
- **Resource Management**: 3 meeting rooms
- **Meeting Types**: Bureau meetings, credit meetings
- **Permissions**: Edit restricted to meeting creators
- **Implementation**: calendarArea.dart with calendarService.dart

### 10. Duty Agent Rotation
- **Tracking**: Cleaning duty rotation
- **Display**: Current duty agent
- **Distribution**: Equal responsibility assignment
- **Implementation**: Integrated in dashboard

### 11. Performance Analytics
- **Metrics**:
  - Calls per day/week/month
  - Client approval/rejection rates
  - Revenue generation
- **Visualization**: Charts and graphs
- **Filtering**: Time period selection

### 12. Dashboard/Home Screen
- **Overview**: Key information at a glance
- **Quick Access**: Essential features
- **Display**:
  - Performance statistics
  - Upcoming calls
  - Current duty agent

### 13. Client Status Tracking
- **Post-call Documentation**: Outcome recording
- **Categories**: Accepted/rejected/postponed
- **Notes**: Discussion summary and action items
- **Implementation**: Integrated in clientsPane.dart

### 14. Client Referral System
- **Tracking**: Referrer-referred association
- **Commission**: Calculation for successful referrals
- **Storage**: Referrer contact information
- **Implementation**: Integrated in clientsService.dart

### 15. Google Drive & Sheets Integration
- **Data Export**: Automatic synchronization
- **Information**:
  - Personal details
  - Credit information
  - Income data
  - Status updates
  - Referrals

### 16. Supervisor Oversight
- **Monitoring**: Comprehensive agent activity view
- **Statistics**:
  - Performance metrics
  - Meeting frequency
  - Duty agent schedule
- **Rankings**: Agent performance by time period

## Development Process

### Step 1: Design
- Create UI/UX design in Figma
- Export CSS and place in Markdown file in project
- Reference this file when implementing UI components

### Step 2: Structure Planning
- Define file and folder organization
- Plan component interactions
- Document service responsibilities

### Step 3: Implementation
- Develop incrementally, feature by feature
- Strictly follow Figma designs
- Maintain clean code structure
- Document as you go

### Step 4: Testing
- Test each feature as it's developed
- Gather feedback from broker
- Iterate based on real-world usage

## UI Implementation Guidelines

- **Strict Adherence**: Follow Figma designs exactly
- **CSS Reference**: Use exported CSS from Figma placed in Markdown files
- **Responsiveness**: Ensure proper functioning across platforms
- **Consistency**: Maintain design language throughout the application

## Code Quality Requirements

- **Architecture**: Clean architecture with separation of concerns
- **Organization**: Logical file structure following the project outline
- **Documentation**: Clear comments and documentation
- **Performance**: Optimized for speed and resource usage
- **Maintainability**: Structured for future enhancements

## Technical Integration Points

### Mobile Integration
- **Call Handling**: Integration with device phone system
- **Speech Synthesis**: Voice processing for name insertion
- **Notifications**: Call and meeting reminders

### Google Cloud Services
- **Authentication**: Firebase integration
- **Storage**: Cloud synchronization
- **Sheets**: Data export and import
- **Vision AI**: Document analysis and OCR
  - Service account authentication
  - API usage monitoring
  - Rate limiting and quota management
  - Error handling and retry logic
  - Batch processing optimization

### OCR Implementation with Google Vision AI
- **API Integration**: Secure connection to Google Cloud Vision API
- **Document Analysis**: Advanced document structure understanding
- **Data Processing Flow**:
  1. Submit images to Vision API via visionService.dart
  2. Process document structure with documentProcessor.dart
  3. Extract contacts using contactExtractor.dart
  4. Validate and clean data with dataValidator.dart
- **Setup Requirements**:
  - Google Cloud project configuration
  - API key or service account setup
  - Quota management
  - Cost optimization strategies
- **Features**:
  - Full-page document analysis
  - Table structure recognition
  - Field detection and labeling
  - High accuracy even with poor image quality
  - Romanian language support

## Testing and Quality Assurance

- **Unit Testing**: Core functionality verification
- **Integration Testing**: Component interaction validation
- **User Testing**: Real-world usage by broker
- **Performance Testing**: Cross-platform efficiency
- **Security**: Data protection measures

This system prompt serves as your comprehensive guide for developing the financial consulting application. Follow the structure and requirements outlined here, referencing the Figma designs for UI implementation, and developing with clean architecture principles to create a robust, efficient, and user-friendly application.

---

`@aboutCompany`

# Despre M.A.T Finance

## Prezentare generală

M.A.T Finance este o companie tânără și creativă care activează în domeniul consultanței financiare, specializată în intermedierea de credite pentru persoane fizice. Compania funcționează ca broker independent, fiind remunerată direct de către client și furnizând servicii de consiliere financiară personalizate.

În calitate de intermediar de credite, conform definițiilor din O.U.G nr. 50/2010 (art. 7 pct. 9) și O.U.G nr. 25/2016 (art. 3 pct. 5), M.A.T Finance se dedică identificării celor mai adecvate produse de creditare pentru clienții săi, respectând toate prevederile legale în vigoare.

## Servicii principale

### Intermediere credite

M.A.T Finance oferă servicii complete de intermediere pentru diverse tipuri de credite:

- **Credite de nevoi personale** - Pentru o gamă variată de cheltuieli, inclusiv consolidarea datoriilor sau renovarea locuinței
- **Credite ipotecare** - Pentru achiziționarea de proprietăți imobiliare
- **Refinanțări** - Atât pentru credite ipotecare, cât și pentru credite de nevoi personale

### Servicii de refinanțare specializate

Compania excelează în domeniul refinanțării creditelor, oferind soluții pentru:

- Refinanțarea unui singur credit
- Consolidarea mai multor credite într-un singur împrumut
- Obținerea unei sume suplimentare față de creditul refinanțat

Prin serviciile de refinanțare, clienții pot obține:
- Rate lunare mai mici
- Costuri totale reduse
- Sume suplimentare pentru alte nevoi financiare

### Radiere Birou de Credit

M.A.T Finance oferă asistență specializată pentru radierea din Biroul de Credit pentru persoanele care au avut în trecut probleme financiare precum:
- Întârzieri la plată
- Datorii neplătite
- Alte situații care au afectat istoricul de credit

## Procesul de lucru

### Consultanță financiară

Echipa M.A.T Finance oferă consultanță completă în procesul de obținere a creditelor:

1. Evaluarea situației financiare a clientului
2. Analiza opțiunilor disponibile pe piața bancară
3. Preaprobarea financiară (verificare prin Biroul de Credit și ANAF)
4. Întocmirea dosarului de credit
5. Susținerea dosarului în fața instituțiilor financiare
6. Suport până la utilizarea creditului

### Procesul de refinanțare

#### Pentru credite ipotecare:
1. Preaprobarea financiară (verificare prin Biroul de Credit și ANAF)
2. Verificarea actelor imobilului (acte de vânzare-cumpărare, schiță, certificat energetic)
3. Evaluarea imobilului
4. Obținerea acordului de înstrăinare de la banca inițială
5. Aprobarea finală a creditului
6. Semnarea contractului la notar
7. Proces complet în aproximativ 7-14 zile lucrătoare

#### Pentru credite de nevoi personale:
1. Verificarea situației financiare prin Biroul de Credit și ANAF
2. Solicitarea adresei de refinanțare de la instituția inițială
3. Procesarea dosarului de credit
4. Finalizare în aproximativ 1-48 ore, în funcție de banca selectată

## Avantajele oferite clienților

### Avantaje generale:
- Consiliere financiară personalizată
- Colaborare cu multiple instituții bancare
- Identificarea celei mai avantajoase oferte pentru client
- Simplificarea procesului birocratic
- Sprijin în întocmirea și susținerea dosarului de credit

### Avantaje specifice pentru refinanțări:
- Posibilitatea de a refinanța orice tip de credit (nevoi personale, ipotecare, carduri de credit)
- Refinanțare până la 85% din valoarea evaluată a imobilului
- Obținerea unei sume suplimentare față de suma vechilor credite
- Asigurare de viață gratuită pe toată durata creditului (la majoritatea creditelor de refinanțare)

## Caracteristici și condiții credite

### Credite de nevoi personale:
- Perioadă: 6-120 luni
- Vârstă eligibilă: 21-65 ani (salariați), 65-75 ani (pensionari)
- Sume: 630-225.000 lei
- Venit minim: 1350 RON (salariați), 700 RON (pensionari)
- Vechime la locul de muncă: minim 6 luni

### Credite ipotecare/cu garanții:
- Perioadă: 6-360 luni
- Vârstă eligibilă: 20-75 ani
- Sume: 10.000-300.000 euro sau echivalent în lei
- Dobândă fixă sau variabilă

## Abordare și valori

M.A.T Finance se evidențiază prin:

- **Cultură colaborativă** - Echipa de profesioniști lucrează împreună pentru a înțelege și rezolva problemele clienților
- **Creativitate** - Oferă idei proaspete și soluții inovatoare
- **Transparență** - Prezintă clar avantajele și dezavantajele fiecărei opțiuni
- **Personalizare** - Fiecare client primește soluții adaptate nevoilor specifice
- **Eficiență** - Procesul de intermediere este optimizat pentru a economisi timp și resurse

## Performanțe și specializări

M.A.T Finance se mândrește cu expertiză solidă în:
- Consultanță financiară (60%)
- Operațiuni de carieră (50%)
- Strategii pentru reducerea costurilor (40%)

Compania oferă servicii în următoarele domenii:
- Consultanță financiară
- Investiții financiare
- Consultanță privată
- Servicii pentru companii și afaceri

## Integrarea în aplicația Flutter

Pentru dezvoltarea aplicației Flutter, este esențial să se înțeleagă că M.A.T Finance:

1. Lucrează cu multiple bănci și instituții financiare
2. Procesează date personale și financiare sensibile ale clienților
3. Are un flux de lucru specific pentru fiecare tip de credit
4. Necesită instrumente de calcul financiar și comparare a ofertelor
5. Se bazează pe gestionarea eficientă a relațiilor cu clienții
6. Oferă consiliere personalizată bazată pe circumstanțele individuale ale fiecărui client

Aplicația va trebui să integreze toate aceste aspecte într-o interfață intuitivă și eficientă care să faciliteze activitatea brokerilor financiari