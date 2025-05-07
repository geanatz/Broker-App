# Login Popup (LoginWidget)

## Descriere
Acest popup permite agenților existenți să se autentifice în aplicație folosind selecția consultantului și parola.

## Apartenență
- Face parte din: `authScreen.md`
- Este un tip de: `popup`

## Structură și Elemente

### 1. Container Principal (LoginWidget)
- **Descriere**: Containerul care înconjoară întreg conținutul popup-ului de login.
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

### 2. Antet Login (Header)
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
- **Context Flex (ca item în LoginWidget)**:
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
    - Lățime: `216px`
    - Înălțime: `48px`
- **Context Flex (ca item în Header)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

##### 2.1.1. Text Titlu (Title - "E timpul sa facem cifre!")
- **Text**: "E timpul sa facem cifre!"
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `200px`
    - Înălțime: `24px` (Figma `height: 24px` pentru containerul `Title`, textul are `height: 24px`)
- **Styling Text**:
    - Familie Font: `'Outfit'` (din `variables.md`)
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Înălțime Linie: `24px`
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)
- **Context Flex (ca item în Title&Description)**:
    - `flex: none; order: 0; flex-grow: 0;`

##### 2.1.2. Text Descriere (Description - "Clientii asteapta...")
- **Text**: "Clientii asteapta..."
- **Layout**:
    - Tip: Flex container (pentru alinierea textului)
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Text Box**:
    - Lățime: `139px`
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
    *Notă pentru Cursor AI: Acesta va fi probabil un `SvgPicture.asset` sau `Image.asset`. Fundalul specificat aici s-ar putea referi la o parte a SVG-ului sau la un container dacă SVG-ul este transparent.*

---

### 3. Formular Login (Form)
- **Descriere**: Containerul principal pentru câmpurile de input ale formularului de login.
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
- **Context Flex (ca item în LoginWidget)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 0;`

#### 3.1. Câmp Formular (Field - Consultant)
- **Descriere**: Dropdown pentru selectarea consultantului (utilizatorului).
- **Layout General Câmp**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
- **Dimensionare Câmp**:
    - Lățime: `328px` (probabil `stretch` în containerul Form, minus padding)
    - Înălțime: `72px`
- **Context Flex (ca item în Form)**:
    - `order: 0; align-self: stretch;`

##### 3.1.1. Titlu Câmp (Title - "Consultant")
- **Text**: "Consultant"
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

##### 3.1.2. Zonă Dropdown (Dropdown - Consultant)
- **Componentă Tip**: Dropdown (DropdownButtonFormField)
- **Text Implicit/Placeholder**: "Selecteaza consultant"
- **Layout Dropdown**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Space-between
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
    - Gap: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare Dropdown**:
    - Lățime: `328px` (stretch)
    - Înălțime: `48px`
- **Styling Dropdown Container**:
    - Fundal: `background_dark_purple` (Figma CSS: `background: #C6ACD3;`)
    - Rază Bordură: `small` (Figma CSS: `border-radius: 16px;`)
- **Styling Text Afișat/Placeholder**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Text: `#7C568F` (Variabilă sugerată: `font_dark_purple_variant` sau similar; vezi `variables.md`)
- **Elemente Interne Dropdown**:
    - Text Selectat/Placeholder
    - Iconiță Dropdown (la dreapta)

##### 3.1.2.1. Iconiță Dropdown (DropdownIcon)
- **Descriere**: Iconiță care indică funcționalitatea de dropdown.
- **Dimensionare Iconiță**: `icon_medium` (Figma CSS: `width: 24px; height: 24px;`)
- **Styling Iconiță (Vector)**:
    - Bordură: `2px solid #7C568F` (Culoarea `#7C568F` este aceeași ca la textul placeholder)
    *Notă pentru Cursor AI: Aceasta va fi o iconiță standard de dropdown (ex: `Icons.arrow_drop_down`). Stilul bordurii se aplică iconiței însăși.*

#### 3.2. Câmp Formular (Field - Parola)
- **Descriere**: Câmp pentru introducerea parolei.
- **Layout General Câmp**: Identic cu 3.1.
- **Dimensionare Câmp**: Identic cu 3.1.
- **Context Flex (ca item în Form)**:
    - `order: 1; align-self: stretch;`

##### 3.2.1. Titlu Câmp (Title - "Parola")
- **Text**: "Parola"
- **Styling și Layout**: Identic cu 3.1.1, text diferit.

##### 3.2.2. Zonă Introducere Text (Input - Parola)
- **Componentă Tip**: Câmp de text securizat (TextFormField cu obscureText)
- **Placeholder Text**: "Introdu parola"
- **Layout Input**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Space-between
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
    - Gap: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare Input**: Identic cu 3.1.2.
- **Styling Input Container**: Identic cu 3.1.2.
- **Styling Text Placeholder/Input**: Identic cu 3.1.2.
- **Elemente Interne Input**:
    - Text Placeholder/Input (aliniat la stânga/centru în spațiul alocat)
    - Buton Ajutor/Resetare Parolă (la dreapta) - *Interpretare bazată pe "HelpIcon.svg"*

##### 3.2.2.1. Buton Ajutor/Resetare Parolă (HelpIcon.svg / InfoIcon)
- **Descriere**: Iconiță pentru ajutor sau pentru a iniția resetarea parolei (funcționalitatea trebuie clarificată).
- **Dimensionare Iconiță**: `icon_medium` (Figma CSS: `width: 24px; height: 24px;`)
- **Styling Iconiță (InfoIcon)**:
    - Bordură: `2px solid #7C568F`
    *Notă pentru Cursor AI: Aceasta va fi o `IconButton` cu o iconiță specifică (ex: `Icons.help_outline` sau `Icons.lock_reset`). Funcționalitatea exactă va dicta iconița.*

---

### 4. Link către Înregistrare (GoToRegister)
- **Descriere**: Secțiune cu text și un buton/link pentru a naviga la ecranul de înregistrare dacă utilizatorul nu are cont.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Align Items: Center
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare**:
    - Lățime: `344px` (stretch)
    - Înălțime: `24px`
- **Context Flex (ca item în LoginWidget)**:
    - `order: 2; align-self: stretch;`

#### 4.1. Text Întrebare (Text - "Nu ai cont de consultant?")
- **Text**: "Nu ai cont de consultant?"
- **Layout**:
    - Padding Stânga: `small` (Figma CSS: `padding: 0px 0px 0px 8px;`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)

#### 4.2. Buton/Link Text (Button - "Creaza unul!")
- **Text**: "Creaza unul!"
- **Componentă Tip**: TextButton sau similar.
- **Layout**:
    - Padding Orizontal: `tiny` (Figma CSS: `padding: 0px 4px;`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)

---

### 5. Buton Principal Acțiune (Button - "Conectare")
- **Descriere**: Butonul principal pentru a trimite formularul de login.
- **Text**: "Conectare"
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
- **Context Flex (ca item în LoginWidget)**:
    - `order: 3; align-self: stretch;`