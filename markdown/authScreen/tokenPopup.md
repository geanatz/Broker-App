# Token Popup (TokenWidget)

## Descriere
Acest popup este folosit pentru a introduce un token de securitate, probabil în cadrul procesului de resetare a parolei sau verificare a contului.

## Apartenență
- Face parte din: `authScreen.md`
- Este un tip de: `popup`

## Structură și Elemente

### 1. Container Principal (TokenWidget)
- **Descriere**: Containerul care înconjoară întreg conținutul popup-ului de introducere token.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `tiny` (Figma CSS: `padding: 8px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare și Poziționare**:
    - Lățime: `360px`
    - Înălțime: `248px`
    - Poziție: Absolută, centrată pe ecran (Figma CSS: `left: calc(50% - 360px/2); top: calc(50% - 248px/2);`)
      *Notă pentru Cursor AI: În Flutter, considerați folosirea `Stack` cu `Align` sau `Center`.*
- **Styling**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Umbră: `widgetShadow` (Figma CSS: `box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)

---

### 2. Antet Token (Header)
- **Descriere**: Secțiunea de antet a popup-ului, conținând titlul, descrierea și logo-ul.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Justify Content: Space-between
    - Align Items: Center
    - Padding: Orizontal `small` (Figma CSS: `padding: 0px 8px;`)
    - Gap între elemente: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `344px` (probabil `stretch` în containerul principal, minus padding-ul acestuia)
    - Înălțime: `48px`
- **Context Flex (ca item în TokenWidget)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

#### 2.1. Titlu și Descriere (Title&Description)
- **Descriere**: Container pentru textul de titlu și descriere.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Flex-start
    - Padding: Orizontal `small` (Figma CSS: `padding: 0px 8px;`)
    - Centrare Orizontală: Da (Figma CSS: `margin: 0 auto;`)
- **Dimensionare**:
    - Lățime: `211px`
    - Înălțime: `48px`
- **Context Flex (ca item în Header)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

##### 2.1.1. Text Titlu (Title - "Ai uitat parola?")
- **Text**: "Ai uitat parola?"
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `133px`
    - Înălțime: `24px` (Figma `height: 24px` pentru containerul `Title`, textul are `height: 24px`)
- **Styling Text**:
    - Familie Font: `'Outfit'` (din `variables.md`)
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Înălțime Linie: `24px`
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)
- **Context Flex (ca item în Title&Description)**:
    - `flex: none; order: 0; flex-grow: 0;`

##### 2.1.2. Text Descriere (Description - "Intai, dovedeste ca esti tu!")
- **Text**: "Intai, dovedeste ca esti tu!"
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `195px`
    - Înălțime: `21px` (Figma `height: 24px` pentru containerul `Description`, textul are `height: 21px`)
- **Styling Text**:
    - Familie Font: `'Outfit'` (din `variables.md`)
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Înălțime Linie: `21px`
    - Culoare Font: `#927B9D` (Variabilă sugerată: `font_light_purple_variant` sau similar; vezi `variables.md`)
- **Context Flex (ca item în Title&Description)**:
    - `flex: none; order: 1; flex-grow: 0;`

#### 2.2. Logo Companie
- **Descriere**: Container pentru logo-ul companiei.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Align Items: Center
    - Centrare Orizontală: Da (Figma CSS: `margin: 0 auto;`)
- **Dimensionare**:
    - Lățime: `48px`
    - Înălțime: `48px`
- **Context Flex (ca item în Header)**:
    - `flex: none; order: 1; flex-grow: 0;`

##### 2.2.1. Element Logo (Logo.svg)
- **Descriere**: Elementul SVG/imagine al logo-ului.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column
    - Justify Content: Center
    - Align Items: Center
    - Padding: `13px 11px` (specific Figma)
- **Dimensionare**:
    - Lățime: `48px`
    - Înălțime: `48px`
- **Styling Vector Imagine (bazat pe `Vector` nested):**
    - Fundal Vector: `font_medium_purple` (Figma CSS: `background: #886699;`)
    - Dimensiuni interne vector: `26.58px` lățime, `22.4px` înălțime.
    *Notă pentru Cursor AI: Acesta va fi probabil un `SvgPicture.asset` sau `Image.asset`.*

---

### 3. Formular Token (Form)
- **Descriere**: Containerul principal pentru câmpul de introducere a tokenului.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `344px`
    - Înălțime: `88px`
- **Styling**:
    - Fundal: `background_light_purple` (Figma CSS: `background: #CFC4D4;`)
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Context Flex (ca item în TokenWidget)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 0;`

#### 3.1. Câmp Formular (Field - Token Secret)
- **Descriere**: Câmp pentru introducerea tokenului secret.
- **Layout General Câmp**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
- **Dimensionare Câmp**:
    - Lățime: `328px` (probabil `stretch` în containerul Form, minus padding)
    - Înălțime: `72px`
- **Context Flex (ca item în Form)**:
    - `order: 0; align-self: stretch;`

##### 3.1.1. Titlu Câmp (Title - "Token secret")
- **Text**: "Token secret"
- **Layout**:
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare Titlu**:
    - Lățime: `328px` (stretch)
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)

##### 3.1.2. Zonă Introducere Text (Input - Token)
- **Componentă Tip**: Câmp de text (TextFormField)
- **Placeholder Text**: "Introdu token-ul tau"
- **Layout Input**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
    - Gap: `small` (Figma CSS: `gap: 8px;`) (probabil pentru o viitoare iconiță, deși nu este prezentă acum)
- **Dimensionare Input**:
    - Lățime: `328px` (stretch)
    - Înălțime: `48px`
- **Styling Input Container**:
    - Fundal: `background_dark_purple` (Figma CSS: `background: #C6ACD3;`)
    - Rază Bordură: `small` (Figma CSS: `border-radius: 16px;`)
- **Styling Text Placeholder/Input**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Text: `#7C568F` (Variabilă sugerată: `font_dark_purple_variant` sau similar; vezi `variables.md`)

---

### 4. Link către Login (GoToLogin)
- **Descriere**: Secțiune cu text și un buton/link pentru a naviga înapoi la ecranul de login.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare**:
    - Lățime: `344px` (stretch)
    - Înălțime: `24px`
- **Context Flex (ca item în TokenWidget)**:
    - `order: 2; align-self: stretch;`

#### 4.1. Text Întrebare (Text - "Ti-a revenit memoria?")
- **Text**: "Ti-a revenit memoria?"
- **Layout**:
    - Padding Stânga: `small` (Figma CSS: `padding: 0px 0px 0px 8px;`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)

#### 4.2. Buton/Link Text (Button - "Conecteaza-te!")
- **Text**: "Conecteaza-te!"
- **Componentă Tip**: TextButton sau similar.
- **Layout**:
    - Padding Orizontal: `tiny` (Figma CSS: `padding: 0px 4px;`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)

---

### 5. Buton Principal Acțiune (Button - "Continua")
- **Descriere**: Butonul principal pentru a trimite tokenul introdus.
- **Text**: "Continua"
- **Componentă Tip**: ElevatedButton sau similar.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
    - Padding Orizontal: `medium` (Figma CSS: `padding: 0px 16px;`)
- **Dimensionare**:
    - Lățime: `344px` (stretch)
    - Înălțime: `48px`
- **Styling Buton**:
    - Fundal: `background_light_purple` (Figma CSS: `background: #CFC4D4;`)
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Styling Text Buton**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 18px;`) <!-- Notă: 18px aici, diferit de 17px la alte butoane similare -->
    - Înălțime Linie: `23px`
    - Culoare Text: `font_medium_purple` (Figma CSS: `color: #886699;`)
    - Aliniere Text: Center
- **Context Flex (ca item în TokenWidget)**:
    - `order: 3; align-self: stretch;`