# Calls Panel (SecondaryPanel - for Call Management)

## Descriere
Acest panel (`callsPanel`) gestionează și afișează informații despre apeluri, împărțite în trei secțiuni: apeluri următoare, apel în desfășurare și apeluri anterioare.

## Apartenență
- Face parte din: `formScreen.md`
- Este un tip de: `panel` (lateral, secundar față de `formPanel` principal)

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
- **Context Flex (ca item în `formScreen.md`)**:
    - `flex: none; order: 0; flex-grow: 0;` (sau un alt `order` dacă nu este primul panou secundar)

---

### 2. Widget Apeluri Următoare (NextCallsWidget)
- **Descriere**: Afișează o listă de contacte programate pentru apeluri viitoare.
- **Layout Widget**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Center
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap intern: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare Widget**:
    - Lățime: `312px`
    - Înălțime: `444px` (*Notă: Această înălțime este fixă. Dacă lista depășește, ar trebui să fie scrollabilă, dar `overflow-y: scroll` nu e pe widget, ci probabil pe containerul intern al listei de contacte dacă este necesar.*)
- **Styling Widget**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Umbră: `widgetShadow` (Figma CSS: `box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)
- **Context Flex (ca item în `SecondaryPanel`)**:
    - `flex: none; order: 0; flex-grow: 1;` (*`flex-grow: 1` aici poate fi pentru a distribui spațiul dacă înălțimea `SecondaryPanel` nu este complet umplută de widget-urile cu înălțime fixă. Totuși, `NextCallsWidget` are înălțime fixă.*)

#### 2.1. Antet Widget Apeluri Următoare (Header)
- **Descriere**: Antetul care afișează titlul "Apeluri urmatoare" și numărul acestora.
- **Layout**:
    - Tip: Flex container, Row, Justify Content: Space-between, Align Items: Center
    - Padding: Orizontal `medium` (Figma CSS: `padding: 0px 16px;`)
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**: Lățime `296px`, Înălțime `24px`
- **Elemente Interne**:
    - **Text Titlu ("Apeluri urmatoare")**:
        - Styling: `font-weight: 500; font-size: 19px (large); color: font_light_blue (#8A9EA8);`
        - Layout: Centrat orizontal (margin: 0 auto), flex-grow: 0
    - **Număr Apeluri ("5")**:
        - Styling: `font-weight: 500; font-size: 15px (small); color: font_light_blue (#8A9EA8); text-align: right;`
        - Layout: Centrat orizontal (margin: 0 auto), flex-grow: 0

#### 2.2. Listă Contacte Apeluri Următoare
- **Descriere**: Container pentru elementele individuale de contact. *CSS-ul nu arată un container explicit pentru listă (precum cel din `meetingsPanel`), ci elementele `Contact` sunt direct sub `Header`. Presupunem că `NextCallsWidget` în sine acționează ca și container scrollabil dacă numărul de contacte depășește înălțimea de `444px` minus header.*

##### 2.2.1. Element Contact Apel Următor (Contact)
- **Descriere**: Reprezintă un singur contact programat pentru un apel. Această structură se repetă.
- **Layout**:
    - Tip: Flex container, Row, Align Items: Center
    - Padding: `small` (8px)
    - Gap: `medium` (16px)
- **Dimensionare**: Lățime `296px`, Înălțime `64px`
- **Styling**:
    - Fundal: `background_light_blue` (#C4CFD4)
    - Rază Bordură: `medium` (24px)
- **Context Flex (ca item în `NextCallsWidget` sau un container de listă intern)**:
    - `order: X; align-self: stretch; flex-grow: 0;` (order crește)

###### 2.2.1.1. Detalii Contact (Details)
- **Layout**: Column, Justify Content: Center, Align Items: Center, Padding Stânga: `small` (8px), Gap: `tiny` (4px)
- **Dimensionare**: Lățime `216px`, Înălțime `48px`, `flex-grow: 1`

    - **Nume Contact (Text)**:
        - Text Exemplu: "Contact name 1"
        - Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_blue (#668899);`
    - **Număr Telefon (Text)**:
        - Text Exemplu: "0712 345 678"
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_light_blue (#8A9EA8);`

###### 2.2.1.2. Buton Acțiune (Button - CallIcon.svg)
- **Layout**: Row, Justify/Align Center, Padding: `medium` (16px), Gap: `small` (8px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_dark_blue` (#ACC6D3), Rază Bordură `small` (16px)
- **Iconiță `CallIcon.svg`**: `icon_medium` (24x24px), Bordură `2px solid font_dark_blue (#4D6F80)`
    *Notă pentru Cursor AI: Reprezintă acțiunea de a iniția un apel, ex: `Icons.call`.*

***Notă***: *Structura `Element Contact Apel Următor (Contact)` (2.2.1) se repetă de 5 ori în exemplul CSS, cu nume de contact diferite (Contact name 1-5).*

---

### 3. Widget Apel în Desfășurare (OngoingCallWidget)
- **Descriere**: Afișează informații despre un apel activ curent.
- **Layout Widget**: Identic cu 2. (padding, gap)
- **Dimensionare Widget**: Lățime `312px`, Înălțime `112px` (mult mai mic, pentru un singur apel)
- **Styling Widget**: Identic cu 2. (fundal, umbră, rază bordură)
- **Context Flex (ca item în `SecondaryPanel`)**:
    - `flex: none; order: 1; flex-grow: 0;`

#### 3.1. Antet Widget Apel în Desfășurare (Header)
- **Descriere**: Antetul care afișează titlul "Apel in desfasurare" și durata apelului.
- **Layout, Dimensionare**: Identic cu 2.1.
- **Elemente Interne**:
    - **Text Titlu ("Apel in desfasurare")**:
        - Styling: `font-weight: 500 (medium); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`
    - **Durată Apel ("01:49")**:
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: #927B9D (font_light_purple_variant); text-align: right;`

#### 3.2. Detalii Contact Apel în Desfășurare (Contact)
- **Descriere**: Afișează detaliile contactului apelat și un buton de acțiune (probabil speech).
- **Layout, Dimensionare, Styling**: Identic cu 2.2.1.
    - Fundal: `background_light_purple` (#CFC4D4)
- **Elemente Interne**:
    - **Detalii Contact (Details)**: Identic cu 2.2.1.1.
        - Nume Contact: "Contact name 6", Culoare: `font_medium_purple` (#886699)
        - Număr Telefon: "0712 345 678", Culoare: `#927B9D (font_light_purple_variant)`
    - **Buton Acțiune (Button - SpeechIcon.svg)**: Identic cu 2.2.1.2.
        - Styling Buton: Fundal `background_dark_purple` (#C6ACD3)
        - Iconiță `SpeechIcon.svg`: `icon_medium` (24x24px), Bordură `2px solid #7C568F (font_dark_purple_variant)`
            *Notă pentru Cursor AI: Reprezintă acțiunea de a porni un discurs automat, ex: `Icons.record_voice_over` sau `Icons.campaign`.*

---

### 4. Widget Apeluri Anterioare (PastCallWidget)
- **Descriere**: Afișează o listă de contacte apelate anterior.
- **Layout Widget**: Identic cu 2.
- **Dimensionare Widget**: Lățime `312px`, Înălțime `444px` (similar cu `NextCallsWidget`)
- **Styling Widget**: Identic cu 2.
- **Context Flex (ca item în `SecondaryPanel`)**:
    - `flex: none; order: 2; flex-grow: 1;`

#### 4.1. Antet Widget Apeluri Anterioare (Header)
- **Descriere**: Antetul care afișează titlul "Apeluri anterioare" și numărul acestora.
- **Layout, Dimensionare**: Identic cu 2.1.
- **Elemente Interne**:
    - **Text Titlu ("Apeluri anterioare")**:
        - Styling: `font-weight: 500 (medium); font-size: 19px (large); color: font_light_red (#A88A8A);`
    - **Număr Apeluri ("6")**:
        - Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_light_red (#A88A8A); text-align: right;`

#### 4.2. Listă Contacte Apeluri Anterioare (Frame 168 - container listă)
- **Descriere**: Container pentru elementele individuale de contact apelate anterior.
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `296px`, Înălțime `396px`
- **Styling**: Rază Bordură: `medium` (24px)
- **Comportament**: *Ar trebui să fie `overflow-y: scroll` dacă lista depășește înălțimea.*

##### 4.2.1. Element Contact Apel Anterior (Contact)
- **Descriere**: Reprezintă un singur contact apelat anterior. Această structură se repetă.
- **Layout, Dimensionare**: Identic cu 2.2.1.
- **Styling**:
    - Fundal: `background_light_red` (#D4C4C4)
    - Rază Bordură: `medium` (24px)
- **Elemente Interne**:
    - **Detalii Contact (Details)**: Identic cu 2.2.1.1.
        - Nume Contact: "Contact name 7", Culoare: `font_medium_red` (#996666)
        - Număr Telefon: "0712 345 678", Culoare: `font_light_red` (#A88A8A)
    - **Buton Acțiune (Button - CallIcon.svg rotit)**: Identic cu 2.2.1.2.
        - Styling Buton: Fundal `background_dark_red` (#D3ACAC)
        - Iconiță `CallIcon.svg` (rotită 135deg): `icon_medium` (24x24px), Bordură `2px solid font_dark_red (#804D4D)`
            *Notă pentru Cursor AI: Iconița `CallIcon` rotită la 135 de grade seamănă cu o iconiță de apel încheiat/respins (telefon cu săgeată în jos-stânga). Ex: `Icons.call_end` sau o iconiță personalizată.*

***Notă***: *Structura `Element Contact Apel Anterior (Contact)` (4.2.1) se repetă de 6 ori în exemplul CSS, cu nume de contact diferite (Contact name 7-12).*

---

*Notă Generală pentru Cursor AI*:
*   Fiecare dintre cele trei widget-uri (`NextCallsWidget`, `OngoingCallWidget`, `PastCallWidget`) urmează un model similar: un antet și apoi o listă (sau un singur element) de contacte.
*   **Culorile sunt tematice** pe widget:
    *   `NextCallsWidget`: Nuanțe de albastru (`background_light_blue`, `font_light_blue`, `font_medium_blue`, `font_dark_blue`).
    *   `OngoingCallWidget`: Nuanțe de mov (`background_light_purple`, `#927B9D`, `font_medium_purple`, `#7C568F`).
    *   `PastCallWidget`: Nuanțe de roșu (`background_light_red`, `font_light_red`, `font_medium_red`, `font_dark_red`).
*   **Scroll**: `NextCallsWidget` și `PastCallWidget` au înălțimi fixe și liste de contacte. Aceste liste ar trebui să fie scrollabile dacă conținutul depășește spațiul alocat (CSS-ul pentru `PastCallWidget` are `Frame 168` ca un container de listă, dar fără `overflow-y`).
*   Iconița pentru apelurile anterioare este un `CallIcon` rotit. Asigură-te că implementarea permite rotirea iconiței sau folosește o iconiță dedicată pentru apeluri încheiate/respinse.
*   Culorile specifice `#927B9D` și `#7C568F` din `OngoingCallWidget` ar trebui mapate la variabilele de mov dacă se potrivesc sau adăugate ca noi variante.