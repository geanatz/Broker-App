# Sidebar

## Descriere
Sidebar-ul aplicației, afișat în partea stângă (presupunând un layout tipic). Conține informații despre utilizatorul logat, o bară de progres (posibil legată de apeluri) și butoanele principale de navigare către diferitele ecrane și funcționalități ale aplicației.

## Apartenență
- Este o componentă principală a layout-ului general al aplicației (ex: face parte din `mainLayout.md` sau similar).
- Este un tip de: `sidebar`

## Structură și Elemente

### 1. Container Principal Sidebar
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap între `UserWidget` și `NavigationBar`: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `224px`
    - Înălțime: `1032px`
- **Context Flex (în layout-ul principal)**:
    - `flex: none; order: 2; flex-grow: 0;` (*Notă: `order` poate varia în funcție de poziția în layout-ul principal.*)

---

### 2. Widget Informații Utilizator (UserWidget)
- **Descriere**: Afișează avatarul, numele și echipa consultantului logat, plus o bară de progres a apelurilor.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare Widget**: Lățime `224px`, Înălțime `96px`
- **Styling Widget**:
    - Fundal: `background_widget` (rgba(255, 255, 255, 0.5))
    - Umbră: `widgetShadow` (0px 0px 15px rgba(0, 0, 0, 0.1))
    - Rază Bordură: `large` (32px)
- **Context Flex (în `Sidebar`)**: `order: 0; flex-grow: 0;`

#### 2.1. Rând Detalii Consultant (AboutConsultant)
- **Layout**: Row, Align Items: Center, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `56px`

##### 2.1.1. Avatar Consultant (ConsultantAvatar)
- **Layout**: Row, Align Items: Center, Padding: `medium` (16px), Gap: `medium` (10px)
- **Dimensionare**: `56px` x `56px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `large` (32px - cerc perfect)
- **Iconiță Utilizator (UserIcon)**: `icon_medium` (24x24px)
    - Styling Vector: Bordură `2px solid font_medium_purple (#886699)`

##### 2.1.2. Informații Text Consultant (ConsultantInfo)
- **Layout**: Column, Justify Content: Center, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `144px`, Înălțime `56px`, `align-self: stretch; flex-grow: 1;`
- **Elemente Text**:
    - **Nume Consultant (Consultant)**:
        - Text Exemplu: "Nume Consultant"
        - Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
        - Dim: Înălțime `16px`
    - **Nume Echipă (Team)**:
        - Text Exemplu: "Nume Echipă"
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: #927B9D (font_light_purple_variant);`
        - Dim: Înălțime `16px`

#### 2.2. Rând Progres Apeluri (CallProgress)
- **Layout**: Row, Justify Content: Space-between, Align Items: Center, Gap: `small` (8px)
- **Dimensionare**: Lățime `176px`, Înălțime `16px`

##### 2.2.1. Bară de Progres (LoadingBar)
- **Layout**: Column (probabil pentru a ține elementul `Loaded` în interior), Align Items: Flex-start
- **Dimensionare**: Lățime `152px`, Înălțime `16px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `tiny` (8px)

###### 2.2.1.1. Secțiune Încărcată (Loaded)
- **Descriere**: Partea colorată a barei de progres, indicând progresul.
- **Dimensionare**: Lățime `72px` (dinamică, în funcție de progres), Înălțime `16px`
- **Styling**: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură Stânga-Sus/Jos: `tiny` (8px)

##### 2.2.2. Număr Apeluri (CallsCount)
- **Layout**: Column, Justify/Align Center
- **Dimensionare**: `16px` x `16px`

###### 2.2.2.1. Text Număr (Count)
- **Text Exemplu**: "X" (numărul de apeluri, ex: 50)
- **Styling**: `font-weight: 500 (medium); font-size: 13px (tiny); color: font_medium_purple (#886699);`

---

### 3. Bară de Navigare Principală (NavigationBar)
- **Descriere**: Conține butoanele principale de navigare și acțiuni rapide.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Space-between (pentru a împinge butonul de Settings în jos)
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare Widget**: Lățime `224px`, Înălțime `920px`
- **Styling Widget**:
    - Fundal: `background_widget` (rgba(255, 255, 255, 0.5))
    - Umbră: `widgetShadow` (0px 0px 15px rgba(0, 0, 0, 0.1))
    - Rază Bordură: `large` (32px)
- **Context Flex (în `Sidebar`)**: `order: 1; flex-grow: 1;` (ocupă spațiul rămas pe înălțime)

#### 3.1. Secțiune Superioară Navigare (Section - prima)
- **Layout**: Column, Align Items: Flex-start, Gap: `medium` (16px)
- **Dimensionare**: Lățime `208px`, Înălțime `520px` (*Notă: Înălțime fixă, poate conține mai multe sub-secțiuni*)
- **Context Flex (în `NavigationBar`)**: `order: 0; align-self: stretch; flex-grow: 0;`

##### 3.1.1. Panou Secundar (Butoane Acțiuni Rapide) (SecondaryPanel)
- **Descriere**: Conține butoane orizontale pentru acțiuni rapide (Recomandare, Calculator/Reveniri).
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `48px`

###### 3.1.1.1. Rând Butoane Acțiuni (Row)
- **Layout**: Row, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `48px`

    - **Buton Deschide Recomandări (OpenRecommendButton)**:
        - **Acțiune**: Deschide `contactlistPopup` (conform descrierii tale).
        - Layout: Row, Justify/Align Center, Padding: `12px 24px`, Gap: `medium` (16px)
        - Dimensionare: Lățime `100px`, Înălțime `48px`, `flex-grow: 1`
        - Styling: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
        - Iconiță `Users_Group`: `icon_medium` (24x24px), Bordură `2px solid #7C568F (font_dark_purple_variant)`

    - **Buton Deschide Calculator/Reveniri (OpenReturnsButton)**:
        - **Acțiune**: Deschide `calculatorPopup` (conform descrierii tale).
        - Layout: Identic cu celălalt buton.
        - Dimensionare: Identic cu celălalt buton.
        - Styling: Identic cu celălalt buton.
        - Iconiță `ReturnIcon / CalculatorIcon`: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

##### 3.1.2. Panou Principal (Navigare Ecrane) (MainPanel)
- **Descriere**: Secțiunea cu butoanele principale de navigare între ecrane (Dashboard, Formular, Calendar).
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `192px`

###### 3.1.2.1. Antet Panou Principal (WidgetHeader)
- **Text Titlu**: "Navigare" (dedus, CSS-ul nu specifică)
- **Layout**: Row, Align Items: Center, Padding: Orizontal `medium` (16px), Gap: `medium` (16px)
- **Dimensionare**: Lățime `208px`, Înălțime `24px`
- **Elemente**:
    - **Text Titlu**: Styling: `font-weight: 500 (medium); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`, `flex-grow: 1`
    - **Buton Dropdown (opțional)**: Iconiță `DropdownIcon` (24x24px), Bordură `2px solid #927B9D`

###### 3.1.2.2. Container Butoane Navigare (NavigationButtons)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `160px`

    - **Buton Navigare (Ex: OpenCalendarButton - pt Dashboard)**:
        - **Acțiune**: Navighează la `dashboardScreen`.
        - Layout: Row, Justify/Align Center, Padding: `12px 24px`, Gap: `medium` (16px)
        - Dimensionare: Lățime `208px`, Înălțime `48px`
        - Styling: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
        - **Text Buton ("Dashboard")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699);`, `flex-grow: 1`
        - **Iconiță ("DashboardIcon / Command")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

    - **Buton Navigare (Ex: OpenFormButton)**:
        - **Acțiune**: Navighează la `formScreen`.
        - Layout, Dimensionare, Styling: Identic cu butonul Dashboard.
        - **Text Buton ("Formular")**: Styling Identic.
        - **Iconiță ("FormIcon")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

    - **Buton Navigare (Ex: OpenCalendarButton)**:
        - **Acțiune**: Navighează la `calendarScreen`.
        - Layout, Dimensionare: Identic cu celelalte.
        - Styling: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px) - ***Stil diferit, indică starea activă/selectată***
        - **Text Buton ("Calendar")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`, `flex-grow: 1`
        - **Iconiță ("CalendarIcon")**: `icon_medium` (24x24px), Bordură `2px solid #7C568F (font_dark_purple_variant)`

##### 3.1.3. Panou Secundar (Navigare Funcționalități) (SecondaryPanel - al doilea)
- **Descriere**: Secțiunea cu butoanele de navigare către funcționalități specifice (Întâlniri, Apeluri, Reveniri, Recomandări).
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `248px`

###### 3.1.3.1. Antet Panou Secundar (WidgetHeader)
- **Text Titlu**: "Functionalitati" (dedus)
- **Styling și Layout**: Identic cu 3.1.2.1.

###### 3.1.3.2. Container Butoane Funcționalități (NavigationButtons)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `208px`, Înălțime `216px`

    - **Buton Navigare (Ex: OpenCallsButton - pt Întâlniri)**:
        - **Acțiune**: Afișează `meetingsPanel` (probabil, deși numele CSS e "OpenCalls").
        - Layout, Dimensionare: Identic cu butoanele din 3.1.2.2.
        - Styling: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px) - ***Stil activ/selectat***
        - **Text Buton ("Intalniri")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`, `flex-grow: 1`
        - **Iconiță ("CallsIcon / Users_Group")**: `icon_medium` (24x24px), Bordură `2px solid #7C568F (font_dark_purple_variant)`

    - **Buton Navigare (Ex: OpenCallsButton)**:
        - **Acțiune**: Afișează `callsPanel`.
        - Layout, Dimensionare, Styling: Identic cu butoanele inactive din 3.1.2.2 (fundal #CFC4D4, etc.).
        - **Text Buton ("Apeluri")**: Styling inactiv (culoare #886699).
        - **Iconiță ("CallsIcon / Call Icon")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

    - **Buton Navigare (Ex: OpenReturnsButton)**:
        - **Acțiune**: Afișează `returnsPanel`.
        - Layout, Dimensionare, Styling: Inactiv (#CFC4D4).
        - **Text Buton ("Reveniri")**: Styling inactiv (#886699).
        - **Iconiță ("ReturnIcon")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

    - **Buton Navigare (Ex: OpenRecommendButton)**:
        - **Acțiune**: Afișează `recommendationPanel`.
        - Layout, Dimensionare, Styling: Inactiv (#CFC4D4).
        - **Text Buton ("Recomandare")**: Styling inactiv (#886699).
        - **Iconiță ("RecommendIcon / Chart_Bar_Vertical_01")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`

#### 3.2. Secțiune Inferioară Navigare (Settings)
- **Descriere**: Conține butonul pentru a naviga la ecranul de setări. Este împins în jos de `justify-content: space-between` pe `NavigationBar`.
- **Context Flex (în `NavigationBar`)**: `order: 1; align-self: stretch; flex-grow: 0;`

##### 3.2.1. Buton Navigare Setări (GoToSettingsButton)
- **Acțiune**: Navighează la `settingsScreen`.
- **Layout**: Row, Justify/Align Center, Padding: `12px 24px`, Gap: `medium` (16px)
- **Dimensionare**: Lățime `208px`, Înălțime `48px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Text Buton ("Setari")**: Styling inactiv (#886699).
- **Iconiță ("SettingsIcon")**: `icon_medium` (24x24px), Bordură `2px solid font_medium_purple (#886699)`