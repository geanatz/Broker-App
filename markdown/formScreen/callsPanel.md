# Calls Panel (for formScreen - Active State)

## Descriere
Acest panel (`callsPanel`), când este activ în `formScreen`, afișează informații despre apeluri, împărțite în două secțiuni principale: "Apeluri" (care sunt de fapt apelurile următoare/programate) și "Recente" (apelurile anterioare). Widget-ul pentru apelul în desfășurare nu este prezent în această configurație specifică.

## Apartenență
- Face parte din: `formScreen.md` (când tab-ul/butonul "Apeluri" din sidebar este activ)
- Este un tip de: `panel` (lateral, secundar)

## Structură și Elemente

### 1. Container Principal Panel (SecondaryPanel)
- **Descriere**: Containerul rădăcină pentru întregul panel de gestionare a apelurilor.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap între widget-uri: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `312px`
    - Înălțime: `1032px`
- **Context Flex (în `formScreen.md`)**:
    - `flex: none; order: X; flex-grow: 0;` (order depinde de celelalte paneluri secundare)

---

### 2. Widget Apeluri (NextCallsWidget - denumire CSS)
- **Descriere**: Afișează o listă de contacte programate pentru apeluri. Titlul afișat este "Apeluri".
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare Widget**:
    - Lățime: `312px`
    - Înălțime: `508px`
- **Styling Widget**:
    - Fundal: `background_widget` (rgba(255, 255, 255, 0.5))
    - Umbră: `widgetShadow`
    - Rază Bordură: `large` (32px)
- **Context Flex (în `SecondaryPanel`)**:
    - `flex: none; order: 0; flex-grow: 1;` (*Chiar dacă înălțimea e fixă, `flex-grow: 1` poate ajuta la distribuirea spațiului dacă înălțimea totală a `SecondaryPanel` nu e atinsă.*)

#### 2.1. Antet Widget Apeluri (Header)
- **Descriere**: Antetul care afișează titlul "Apeluri" și numărul acestora.
- **Layout**: Row, Justify Content: Space-between, Align Items: Center, Padding Orizontal: `medium` (16px), Gap: `medium` (16px)
- **Dimensionare**: Lățime `296px`, Înălțime `24px`
- **Elemente Interne**:
    - **Text Titlu ("Apeluri")**:
        - Styling: `font-weight: 500 (medium); font-size: 19px (large); color: font_light_blue (#8A9EA8);`
    - **Număr Apeluri (Ex: "5")**:
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_light_blue (#8A9EA8); text-align: right;`

#### 2.2. Listă Contacte Apeluri (Container implicit al `NextCallsWidget`)
- **Descriere**: Conține elementele individuale de contact. Scrollabil dacă lista depășește spațiul alocat.
- **Comportament**: *Ar trebui să fie `overflow-y: scroll` pe containerul listei dacă numărul de contacte depășește înălțimea disponibilă.*

##### 2.2.1. Element Contact Apel (Contact)
- **Descriere**: Reprezintă un singur contact programat pentru un apel. Această structură se repetă.
- **Layout**: Row, Align Items: Center, Padding: `small` (8px), Gap: `medium` (16px)
- **Dimensionare**: Lățime `296px`, Înălțime `64px`
- **Styling**: Fundal `background_light_blue` (#C4CFD4), Rază Bordură `medium` (24px)
- **Context Flex**: `order: X; align-self: stretch; flex-grow: 0;`

###### 2.2.1.1. Detalii Contact (Details)
- **Layout**: Column, Justify: Center, Align Items: Center, Padding Stânga: `small` (8px), Gap: `tiny` (4px)
- **Dimensionare**: Lățime `216px`, Înălțime `48px`, `flex-grow: 1`
    - **Nume Contact**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_blue (#668899);`
    - **Număr Telefon**: Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_light_blue (#8A9EA8);`

###### 2.2.1.2. Buton Acțiune Apel (Button - CallIcon.svg)
- **Layout**: Row, Justify/Align Center, Padding: `medium` (16px), Gap: `small` (8px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_dark_blue` (#ACC6D3), Rază Bordură `small` (16px)
- **Iconiță `CallIcon.svg`**: `icon_medium` (24x24px), Bordură `2px solid font_dark_blue (#4D6F80)`
    *Notă pentru Cursor AI: Reprezintă acțiunea de a iniția un apel, ex: `Icons.call`.*

***Notă***: *Structura `Element Contact Apel (Contact)` (2.2.1) se repetă pentru fiecare apel programat.*

---

### 3. Widget Apeluri Recente (PastCallWidget - denumire CSS)
- **Descriere**: Afișează o listă de contacte apelate anterior. Titlul afișat este "Recente".
- **Layout Widget**: Identic cu 2.
- **Dimensionare Widget**: Lățime `312px`, Înălțime `508px`
- **Styling Widget**: Identic cu 2.
- **Context Flex (în `SecondaryPanel`)**:
    - `flex: none; order: 1; flex-grow: 1;`

#### 3.1. Antet Widget Apeluri Recente (Header)
- **Descriere**: Antetul care afișează titlul "Recente" și numărul acestora.
- **Layout, Dimensionare**: Identic cu 2.1.
- **Elemente Interne**:
    - **Text Titlu ("Recente")**:
        - Styling: `font-weight: 500 (medium); font-size: 19px (large); color: font_light_red (#A88A8A);`
    - **Număr Apeluri (Ex: "6")**:
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_light_red (#A88A8A); text-align: right;`

#### 3.2. Listă Contacte Apeluri Recente (List - container CSS)
- **Descriere**: Container pentru elementele individuale de contact apelate anterior.
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `296px`, Înălțime `460px`
- **Styling**: Rază Bordură `medium` (24px)
- **Comportament**: *Ar trebui să fie `overflow-y: scroll`.*

##### 3.2.1. Element Contact Apel Recent (Contact)
- **Descriere**: Reprezintă un singur contact apelat anterior. Această structură se repetă.
- **Layout, Dimensionare**: Identic cu 2.2.1.
- **Styling**: Fundal `background_light_red` (#D4C4C4), Rază Bordură `medium` (24px)
- **Elemente Interne**:
    - **Detalii Contact (Details)**: Identic cu 2.2.1.1.
        - Nume Contact: Styling: Culoare `font_medium_red` (#996666)
        - Număr Telefon: Styling: Culoare `font_light_red` (#A88A8A)
    - **Buton Acțiune Apel (Button - CallIcon.svg rotit)**: Identic cu 2.2.1.2.
        - Styling Buton: Fundal `background_dark_red` (#D3ACAC)
        - Iconiță `CallIcon.svg` (rotită 135deg): `icon_medium` (24x24px), Bordură `2px solid font_dark_red (#804D4D)`
            *Notă pentru Cursor AI: Iconița `CallIcon` rotită la 135 de grade seamănă cu o iconiță de apel încheiat/respins (telefon cu săgeată în jos-stânga). Ex: `Icons.call_end`.*

***Notă***: *Structura `Element Contact Apel Recent (Contact)` (3.2.1) se repetă pentru fiecare apel recent.*