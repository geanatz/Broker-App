# Reset Password Popup (ResetPasswordWidget)

## Descriere
Acest popup permite utilizatorului să introducă și să confirme o nouă parolă după ce identitatea i-a fost verificată (probabil printr-un token).

## Apartenență
- Face parte din: `authScreen.md`
- Este un tip de: `popup`

## Structură și Elemente

### 1. Container Principal (ResetPasswordWidget)
- **Descriere**: Containerul care înconjoară întreg conținutul popup-ului de resetare a parolei.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `tiny` (Figma CSS: `padding: 8px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare și Poziționare**:
    - Lățime: `360px`
    - Înălțime: `328px`
    - Poziție: Absolută, centrată pe ecran (Figma CSS: `left: calc(50% - 360px/2); top: calc(50% - 328px/2);`)
      *Notă pentru Cursor AI: În Flutter, considerați folosirea `Stack` cu `Align` sau `Center`.*
- **Styling**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Umbră: `widgetShadow` (Figma CSS: `box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)

---

### 2. Antet Resetare Parolă (Header)
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
- **Context Flex (ca item în ResetPasswordWidget)**:
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
    - Lățime: `273px`
    - Înălțime: `48px`
- **Context Flex (ca item în Header)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

##### 2.1.1. Text Titlu (Title - "Gandeste o parola noua")
- **Text**: "Gandeste o parola noua"
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `206px`
    - Înălțime: `24px` (Figma `height: 24px` pentru containerul `Title`, textul are `height: 24px`)
- **Styling Text**:
    - Familie Font: `'Outfit'` (din `variables.md`)
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Înălțime Linie: `24px`
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)
- **Context Flex (ca item în Title&Description)**:
    - `flex: none; order: 0; flex-grow: 0;`

##### 2.1.2. Text Descriere (Description - "Una calumea, nu ziua de nastere...")
- **Text**: "Una calumea, nu ziua de nastere..."
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `257px`
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

### 3. Formular Resetare Parolă (RegisterForm - denumire CSS, ar trebui să fie ResetPasswordForm)
- **Descriere**: Containerul principal pentru câmpurile de introducere a noii parole.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `344px`
    - Înălțime: `168px`
- **Styling**:
    - Fundal: `background_light_purple` (Figma CSS: `background: #CFC4D4;`)
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Context Flex (ca item în ResetPasswordWidget)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 0;`

#### 3.1. Câmp Formular (Field - Parola Noua)
- **Descriere**: Câmp pentru introducerea noii parole.
- **Layout General Câmp**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
- **Dimensionare Câmp**:
    - Lățime: `328px` (probabil `stretch` în containerul Form, minus padding)
    - Înălțime: `72px`
- **Context Flex (ca item în Form)**:
    - `order: 0; align-self: stretch;`

##### 3.1.1. Titlu Câmp (Title - "Parola noua")
- **Text**: "Parola noua"
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

##### 3.1.2. Zonă Introducere Text (Input - Parola Noua)
- **Componentă Tip**: Câmp de text securizat (TextFormField cu obscureText)
- **Placeholder Text**: "Introdu parola"
- **Layout Input**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Space-between
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
    - Gap: `small` (Figma CSS: `gap: 8px;`)
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
- **Elemente Interne Input**:
    - Text Placeholder/Input
    - Buton Afișare/Ascundere Parolă

##### 3.1.2.1. Buton Afișare/Ascundere Parolă (ShowButton / ShowIcon)
- **Descriere**: Iconiță pentru a comuta vizibilitatea parolei.
- **Dimensionare Iconiță**: `icon_medium` (Figma CSS: `width: 24px; height: 24px;`)
- **Styling Iconiță (ShowIcon)**:
    - Bordură: `2px solid #7C568F`
    *Notă pentru Cursor AI: Aceasta va fi o `IconButton` cu o iconiță specifică (ex: `Icons.visibility` / `Icons.visibility_off`).*

#### 3.2. Câmp Formular (Field - Repeta Parola)
- **Descriere**: Câmp pentru confirmarea noii parole.
- **Layout General Câmp**: Identic cu 3.1.
- **Dimensionare Câmp**: Identic cu 3.1.
- **Context Flex (ca item în Form)**:
    - `order: 1; align-self: stretch;`

##### 3.2.1. Titlu Câmp (Title - "Repeta parola")
- **Text**: "Repeta parola"
- **Styling și Layout**: Identic cu 3.1.1, text diferit.

##### 3.2.2. Zonă Introducere Text (Input - Repeta Parola)
- **Componentă Tip**: Câmp de text securizat
- **Placeholder Text**: "Introdu parola iar"
- **Styling și Layout**: Identic cu 3.1.2 (inclusiv butonul ShowButton/ShowIcon).

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
- **Context Flex (ca item în ResetPasswordWidget)**:
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

### 5. Buton Principal Acțiune (RegisterButton - denumire CSS, ar trebui să fie ResetPasswordButton)
- **Descriere**: Butonul principal pentru a salva noua parolă.
- **Text**: "Schimba parola"
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
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Text: `font_medium_purple` (Figma CSS: `color: #886699;`)
    - Aliniere Text: Center
- **Context Flex (ca item în ResetPasswordWidget)**:
    - `order: 3; align-self: stretch;`