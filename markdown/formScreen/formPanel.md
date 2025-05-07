# Form Panel (MainPanel - for Loans and Income)

## Descriere
Acest panel principal (`formPanel`) conține două sub-paneluri/widget-uri afișate orizontal: unul pentru gestionarea creditelor clientului (`LoanWidget`) și unul pentru gestionarea veniturilor clientului (`IncomeWidget`). Ambele widget-uri permit adăugarea și vizualizarea mai multor intrări (credite/venituri) printr-un container scrollabil.

## Apartenență
- Face parte din: `formScreen.md`
- Este un tip de: `panel` (conține sub-paneluri)

## Layout General Panel (MainPanel)
- **Tip**: Flex container
- **Direcție Flex**: Row (orizontal)
- **Align Items**: Center (sau Flex-start, dacă widget-urile nu au aceeași înălțime și trebuie aliniate la top)
- **Gap între widget-uri**: `large` (Figma CSS: `gap: 24px;`)
- **Dimensionare**:
    - Lățime: `1288px`
    - Înălțime: `1032px`
- **Context Flex (ca item în `formScreen.md`)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 0;`

## Sub-Componente Panel

### 1. Widget Credite Client (LoanWidget)
- **Descriere**: Widget dedicat pentru afișarea și gestionarea informațiilor despre creditele clientului.
- **Fișier Markdown Dedicat (sugestie)**: Ar putea fi util să existe un `loanWidget.md` separat dacă devine prea complex, dar pentru moment îl includem aici.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Center
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap intern: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare Widget**:
    - Lățime: `632px`
    - Înălțime: `1032px`
- **Styling Widget**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)
- **Context Flex (ca item în `MainPanel`)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 1;`

#### 1.1. Secțiune Internă LoanWidget (Section)
- **Descriere**: Containerul principal în interiorul `LoanWidget` care ține antetul și zona scrollabilă cu formularele.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap intern: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `616px` (Lățimea `LoanWidget` minus padding-ul său)
    - Înălțime: `968px`
- **Context Flex (ca item în `LoanWidget`)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 1;`

##### 1.1.1. Antet Secțiune Loan (Header)
- **Text**: "Credite client"
- **Layout**:
    - Tip: Flex container, Row, Align Items: Center
    - Padding: Orizontal `large` (Figma CSS: `padding: 0px 24px;`)
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**: Lățime `616px`, Înălțime `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Culoare Text: `#927B9D` (Variabilă sugerată: `font_light_purple_variant`)

##### 1.1.2. Container Scrollabil Formulare Credite (Container)
- **Descriere**: Zona care conține multiple instanțe de formulare de credit și permite scroll vertical.
- **Layout**:
    - Tip: Flex container, Column, Align Items: Flex-start
    - Gap între formulare: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**: Lățime `616px`, Înălțime `936px`
- **Comportament**: `overflow-y: scroll;`
- **Styling**: Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)

###### 1.1.2.1. Formular Credit Individual (Form)
- **Descriere**: O secțiune individuală pentru detaliile unui credit. Această structură se poate repeta.
- **Layout**:
    - Tip: Flex container, Column, Align Items: Flex-start
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap intern: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**: Lățime `616px`, Înălțime `168px` (sau `88px` pentru cel necompletat)
- **Styling**:
    - Fundal: `background_light_purple` (Figma CSS: `background: #CFC4D4;`)
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Structură Internă Formular**: Conține rânduri (`Row`) de câmpuri (`Field`).

--------
***Început Structură Repetitivă pentru Câmpuri în Formularul de Credit***

Un formular de credit tipic (completat) conține **două rânduri (Row)**.
Un formular de credit "necompletat" (pentru adăugare nouă) conține **un singur rând (Row)**.

**A. Rând de Câmpuri (Row)**
- **Layout**: Tip: Flex container, Row, Align Items: Center, Gap: `small` (8px)
- **Dimensionare**: Lățime `600px` (Lățimea `Form` minus padding-ul său), Înălțime `72px`

**B. Câmp Individual (Field)**
- **Layout**: Tip: Flex container, Column, Align Items: Flex-start (sau Flex-end pentru primul field dintr-un rând de două)
- **Dimensionare**:
    - Lățime: `296px` (dacă sunt 2 câmpuri pe rând, `flex-grow: 1` pentru fiecare)
    - Lățime: `194.67px` (dacă sunt 3 câmpuri pe rând, `flex-grow: 1` pentru fiecare)
    - Lățime: `144px` (dacă sunt 4 câmpuri pe rând, `flex-grow: 1` pentru fiecare)
    - Înălțime: `72px` (sau `69px` pentru unele input-uri simple)
- **Elemente Interne Câmp**:
    1.  **Titlu Câmp (Title)**:
        - Text Exemplu: "Banca", "Tip credit", "Sold", "Consumat", "Perioada", "Rata", "Tip rata"
        - Layout: Row, Align Items: Center, Padding Orizontal: `small` (8px)
        - Dimensionare: Stretch pe lățimea câmpului, Înălțime `24px` (sau `21px` pentru unele)
        - Styling Text Titlu:
            - Familie Font: `'Outfit'`
            - Greutate Font: `large` (600)
            - Mărime Font: `medium` (17px)
            - Culoare Font: `font_medium_purple` (#886699)
    2.  **Element Input (Dropdown sau Input Text)**:
        - **Tip Dropdown**:
            - Text Exemplu: "Alpha Bank", "Card de cumparaturi", "Euribor", "Selecteaza banca"
            - Layout: Row, Justify: Space-between (sau Align Items: Center dacă textul e `flex-grow:1`), Padding: `12px 16px`, Gap: `small` (8px)
            - Dimensionare: Stretch, Înălțime `48px`
            - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px)
            - Styling Text Valoare: `font-weight: 500; font-size: 17px; color: #7C568F (font_dark_purple_variant);`
            - Iconiță Dropdown: `DropdownIcon.svg` (24x24px), Bordură `2px solid #7C568F`
        - **Tip Input Text**:
            - Text Exemplu: "4,000", "3,000", "3 ani", "120,000", "2,000", "5 ani"
            - Layout: Row, Align Items: Center, Padding: `12px 16px`, Gap: `small` (8px)
            - Dimensionare: Stretch, Înălțime `48px`
            - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px)
            - Styling Text Valoare: `font-weight: 500; font-size: 17px; color: #7C568F (font_dark_purple_variant);`

***Sfârșit Structură Repetitivă pentru Câmpuri în Formularul de Credit***
--------

###### 1.1.2.2. Formular Credit "Card de cumparaturi" (Exemplu Completat)
- **Conține**: 2 Rânduri
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Alpha Bank)
        - Câmp 2: Dropdown "Tip credit" (Card de cumparaturi)
    - **Rândul 2**:
        - Câmp 1: Input "Sold" (4,000)
        - Câmp 2: Input "Consumat" (3,000)

###### 1.1.2.3. Formular Credit "Nevoi personale" (Exemplu Completat)
- **Conține**: 2 Rânduri
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Alpha Bank)
        - Câmp 2: Dropdown "Tip credit" (Nevoi personale)
    - **Rândul 2** (3 câmpuri):
        - Câmp 1: Input "Sold" (4,000) - lățime `194.67px`
        - Câmp 2: Input "Consumat" (3,000) - lățime `194.67px`
        - Câmp 3: Input "Perioada" (3 ani) - lățime `194.67px`

###### 1.1.2.4. Formular Credit "Prima casa" (Exemplu Completat)
- **Conține**: 2 Rânduri
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Alpha Bank)
        - Câmp 2: Dropdown "Tip credit" (Prima casa)
    - **Rândul 2** (4 câmpuri):
        - Câmp 1: Input "Sold" (120,000) - lățime `144px`
        - Câmp 2: Input "Rata" (2,000) - lățime `144px`
        - Câmp 3: Dropdown "Tip rata" (Euribor) - lățime `144px`
        - Câmp 4: Input "Perioada" (5 ani) - lățime `144px`

###### 1.1.2.5. Formular Credit Necompletat (Form(uncompleted))
- **Dimensionare Formular**: Înălțime `88px`
- **Conține**: 1 Rând
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Placeholder: "Selecteaza banca")
        - Câmp 2: Dropdown "Tip credit" (Placeholder: "Selecteaza credit")

##### 1.1.3. Secțiune Comutare Client/Codebitor (Section - sub containerul scrollabil)
- **Descriere**: Butoane pentru a comuta vizualizarea între client și codebitor.
- **Layout**: Tip: Flex container, Row, Justify Content: Center, Align Items: Center
- **Dimensionare**: Lățime `616px`, Înălțime `40px`
- **Elemente Interne**:
    - **Buton Client (Button - UserIcon.svg)**:
        - Layout: Row, Justify/Align Center, Padding: `small` (8px), Gap: `medium` (10px)
        - Dimensionare: `40px` x `40px`
        - Styling: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px)
        - Iconiță `UserIcon.svg`: 24x24px, Bordură `2px solid #7C568F (font_dark_purple_variant)`
    - **Buton Codebitor (Button - CodebitorIcon.svg)**:
        - Layout: Identic cu Buton Client
        - Dimensionare: Identic cu Buton Client
        - Styling: Fundal `transparent` (sau altă culoare pentru starea inactivă/activă - nu e specificat, dar de obicei diferă)
        - Iconiță `CodebitorIcon.svg`: 24x24px, Bordură `2px solid #886699 (font_medium_purple)`

---

### 2. Widget Venituri Client (IncomeWidget)
- **Descriere**: Widget dedicat pentru afișarea și gestionarea informațiilor despre veniturile clientului.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Center
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap intern: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare Widget**:
    - Lățime: `632px`
    - Înălțime: `1032px`
- **Styling Widget**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)
- **Context Flex (ca item în `MainPanel`)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 1;`

#### 2.1. Secțiune Internă IncomeWidget (Frame 25)
- **Descriere**: Containerul principal în interiorul `IncomeWidget`.
- **Layout**: Identic cu 1.1.
- **Dimensionare**: Identic cu 1.1.
- **Context Flex**: Identic cu 1.1.

##### 2.1.1. Antet Secțiune Income (Header)
- **Text**: "Venit client"
- **Styling și Layout**: Identic cu 1.1.1, text diferit.

##### 2.1.2. Container Scrollabil Formulare Venituri (Frame 42)
- **Descriere**: Zona care conține multiple instanțe de formulare de venit.
- **Layout, Dimensionare, Comportament, Styling**: Identic cu 1.1.2.

###### 2.1.2.1. Formular Venit Individual (Form)
- **Descriere**: O secțiune individuală pentru detaliile unui venit. Structura este foarte similară cu `Formular Credit Individual`.
- **Layout, Dimensionare, Styling**: Identic cu 1.1.2.1.
- **Structură Internă Formular**: Conține rânduri (`Row`) de câmpuri (`Field`).

--------
***Structura Repetitivă pentru Câmpuri în Formularul de Venit (similară cu cea de Credit)***

Un formular de venit tipic (completat) conține **două rânduri (Row)**.
Un formular de venit "necompletat" (pentru adăugare nouă) conține **un singur rând (Row)**.

Folosește aceeași structură **A. Rând de Câmpuri (Row)** și **B. Câmp Individual (Field)** ca la credite.

**Exemple de câmpuri specifice pentru Venit:**
- Titluri: "Banca", "Tip venit", "Venit", "Vechime"
- Valori Dropdown: "Raiffeisen Bank", "Salariu", "Selecteaza banca", "Selecteaza venit"
- Valori Input Text: "4,500", "5 ani"
--------

###### 2.1.2.2. Formular Venit "Salariu" (Exemplu Completat)
- **Conține**: 2 Rânduri
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Raiffeisen Bank)
        - Câmp 2: Dropdown "Tip venit" (Salariu)
    - **Rândul 2**:
        - Câmp 1: Input "Venit" (4,500)
        - Câmp 2: Input "Vechime" (5 ani)

###### 2.1.2.3. Formular Venit Necompletat (Form)
- **Dimensionare Formular**: Înălțime `88px`
- **Conține**: 1 Rând
    - **Rândul 1**:
        - Câmp 1: Dropdown "Banca" (Placeholder: "Selecteaza banca")
        - Câmp 2: Dropdown "Tip venit" (Placeholder: "Selecteaza venit")

##### 2.1.3. Secțiune Comutare Client/Codebitor (Section - sub containerul scrollabil)
- **Descriere, Layout, Dimensionare, Elemente Interne**: Identic cu 1.1.3.