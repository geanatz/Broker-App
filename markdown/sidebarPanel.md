# Sidebar (Redesign for formScreen)

## Descriere
Sidebar-ul reproiectat pentru `formScreen`. Acesta integrează informațiile despre consultant și toate butoanele de navigare într-un singur widget `NavigationBar` vertical. Accentuează vizual starea activă a butoanelor "Formular" și "Apeluri".

## Apartenență
- Este o componentă principală a layout-ului `formScreen.md`.
- Este un tip de: `sidebar`

## Structură și Elemente

### 1. Container Principal Sidebar (`Sidebar` wrapper)
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap (dacă ar exista mai multe elemente directe în `Sidebar` wrapper): `medium` (16px)
- **Dimensionare**:
    - Lățime: `224px`
    - Înălțime: `1032px`
- **Context Flex (în `formScreen.md`)**:
    - `flex: none; order: 2; flex-grow: 0;` (*`order` poate varia*)

#### 1.1. Bară de Navigare Integrată (NavigationBar)
- **Descriere**: Widget-ul principal al sidebar-ului, conținând informații despre consultant, butoane de acțiune rapidă, butoane de navigare principale și butoane pentru funcționalități specifice, plus butonul de setări.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Space-between (pentru a împinge butonul de Settings în jos)
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern între secțiuni principale: `small` (8px)
- **Dimensionare Widget**: Lățime `224px`, Înălțime `1032px`
- **Styling Widget**:
    - Fundal: `background_widget` (rgba(255, 255, 255, 0.5))
    - Umbră: `widgetShadow` (0px 0px 15px rgba(0, 0, 0, 0.1))
    - Rază Bordură: `large` (32px)
- **Context Flex (în `Sidebar` wrapper)**: `order: 0; flex-grow: 1;`

##### 1.1.1. Secțiune Superioară (Section)
- **Descriere**: Conține informațiile consultantului, butoanele de acțiune rapidă și prima grupă de butoane de navigare (Navigare Ecrane).
- **Layout**: Column, Align Items: Flex-start, Gap: `medium` (16px)
- **Dimensionare**: Lățime `208px`, Înălțime `608px` (înălțime fixă pentru această secțiune)
- **Context Flex (în `NavigationBar`)**: `order: 0; align-self: stretch; flex-grow: 0;`

###### 1.1.1.1. Detalii Consultant (AboutConsultant)
- **Layout**: Row, Align Items: Center, Padding: `small` (8px), Gap: `medium` (16px)
- **Dimensionare**: Lățime `208px`, Înălțime `72px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)

    - **Avatar Consultant (ConsultantAvatar)**:
        - Layout: Row, Align Items: Center, Padding: `medium` (16px), Gap: `medium` (10px)
        - Dimensionare: `56px` x `56px`
        - Styling: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `large` (32px)
        - Iconiță Utilizator (UserIcon): `icon_medium` (24x24px), Styling Vector: Bordură `2px solid font_medium_purple (#886699)`

    - **Informații Text Consultant (ConsultantInfo)**:
        - Layout: Column, Justify: Center, Align Items: Flex-start, Gap: `small` (8px)
        - Dimensionare: Lățime `120px`, Înălțime `56px`, `align-self: stretch; flex-grow: 1;`
        - **Nume Consultant (Consultant)**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
        - **Nume Echipă (Team)**: Styling: `font-weight: 500 (medium); font-size: 15px (small); color: #927B9D (font_light_purple_variant);`

###### 1.1.1.2. Panou Secundar (Butoane Acțiuni Rapide) (SecondaryPanel)
- **Descriere**: Conține butoane orizontale pentru popup-uri (Recomandare, Calculator).
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `48px`

    - **Rând Butoane Acțiuni (Row)**:
        - Layout: Row, Align Items: Flex-start, Gap: `small` (8px)
        - Dimensionare: Lățime `208px`, Înălțime `48px`
        - **Buton Deschide Recomandări (OpenRecommendButton)**:
            - **Acțiune**: Deschide `contactlistPopup`.
            - Layout, Dimensionare, Styling: Conform secțiunii 3.1.1.1 din `sidebar.md` original.
            - Iconiță: `Users_Group`, Bordură `2px solid #7C568F (font_dark_purple_variant)`
        - **Buton Deschide Calculator (OpenReturnsButton)**:
            - **Acțiune**: Deschide `calculatorPopup`.
            - Layout, Dimensionare, Styling: Conform secțiunii 3.1.1.1 din `sidebar.md` original.
            - Iconiță: `CalculatorIcon`, Bordură `2px solid font_medium_purple (#886699)`

###### 1.1.1.3. Panou Principal (Navigare Ecrane) (MainPanel)
- **Descriere**: Secțiunea cu butoanele principale de navigare între ecrane.
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `192px`

    - **Antet Panou Principal (WidgetHeader)**:
        - Text Titlu: "Navigare" (dedus)
        - Styling Titlu: `font-weight: 500 (medium); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`
        - *Notă: Iconița Dropdown din CSS-ul anterior pare să fi fost eliminată din acest header.*

    - **Container Butoane Navigare (NavigationButtons)**:
        - Layout: Column, Align Items: Flex-start, Gap: `small` (8px)
        - Dimensionare: Lățime `208px`, Înălțime `160px`

        - **Buton Dashboard (OpenCalendarButton - denumire CSS)**:
            - **Acțiune**: Navighează la `dashboardScreen`.
            - Styling: Inactiv (Fundal `background_light_purple` (#CFC4D4), Text/Iconiță `font_medium_purple` (#886699)).
            - Structură internă (Text "Dashboard", Iconiță "DashboardIcon"): Conform secțiunii 3.1.2.2 din `sidebar.md` original.

        - **Buton Formular (OpenFormButton)**:
            - **Acțiune**: Navighează la `formScreen` (ecranul curent).
            - Styling: **Activ** (Fundal `background_dark_purple` (#C6ACD3), Text/Iconiță `#7C568F (font_dark_purple_variant)`).
            - Structură internă (Text "Formular", Iconiță "FormIcon"): Conform secțiunii 3.1.2.2 din `sidebar.md` original, dar cu stiluri active.

        - **Buton Calendar (OpenCalendarButton)**:
            - **Acțiune**: Navighează la `calendarScreen`.
            - Styling: Inactiv (Fundal `background_light_purple` (#CFC4D4), Text/Iconiță `font_medium_purple` (#886699)).
            - Structură internă (Text "Calendar", Iconiță "CalendarIcon"): Conform secțiunii 3.1.2.2 din `sidebar.md` original.

###### 1.1.1.4. Panou Secundar (Navigare Funcționalități - pentru formScreen) (SecondaryPanel)
- **Descriere**: Secțiunea cu butoane de navigare către sub-panelurile din `formScreen` (Apeluri, Întâlniri - deși textul e Întâlniri, iconița e pentru Apeluri, Reveniri, Recomandări).
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `248px`

    - **Antet Panou Funcționalități (WidgetHeader)**:
        - Text Titlu: "Functionalitati" (dedus)
        - Styling Titlu: `font-weight: 500 (medium); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

    - **Container Butoane Funcționalități (NavigationButtons)**:
        - Layout: Column, Align Items: Flex-start, Gap: `small` (8px)
        - Dimensionare: Lățime `208px`, Înălțime `216px`

        - **Buton Apeluri (OpenCallsButton)**:
            - **Acțiune**: Afișează `callsPanel` în `formScreen`.
            - Styling: **Activ** (Fundal `background_dark_purple` (#C6ACD3), Text/Iconiță `#7C568F (font_dark_purple_variant)`).
            - Structură internă (Text "Apeluri", Iconiță "Call Icon"): Conform secțiunii 3.1.3.2 din `sidebar.md` original (butonul Apeluri), dar cu stiluri active.

        - **Buton Întâlniri (OpenCallsButton - denumire CSS, funcționalitate Intalniri)**:
            - **Acțiune**: Afișează `meetingsPanel` în `formScreen`.
            - Styling: Inactiv (Fundal `background_light_purple` (#CFC4D4), Text/Iconiță `font_medium_purple` (#886699)).
            - Structură internă (Text "Intalniri", Iconiță "Users_Group"): Conform secțiunii 3.1.3.2 din `sidebar.md` original (butonul Întâlniri).

        - **Buton Reveniri (OpenReturnsButton)**:
            - **Acțiune**: Afișează `returnsPanel` în `formScreen`.
            - Styling: Inactiv.
            - Structură internă (Text "Reveniri", Iconiță "ReturnIcon"): Conform secțiunii 3.1.3.2 din `sidebar.md` original.

        - **Buton Recomandare (OpenRecommendButton)**:
            - **Acțiune**: Afișează `recommendationPanel` în `formScreen`.
            - Styling: Inactiv.
            - Structură internă (Text "Recomandare", Iconiță "Chart_Bar_Vertical_01"): Conform secțiunii 3.1.3.2 din `sidebar.md` original.

##### 1.1.2. Secțiune Inferioară (Settings)
- **Descriere**: Conține butonul pentru a naviga la ecranul de setări.
- **Context Flex (în `NavigationBar`)**: `order: 1; align-self: stretch; flex-grow: 0;`

###### 1.1.2.1. Buton Navigare Setări (GoToSettingsButton)
- **Acțiune**: Navighează la `settingsScreen`.
- **Styling și Structură**: Conform secțiunii 3.2.1 din `sidebar.md` original.