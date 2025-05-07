# Create Reservation Popup

## Descriere
Acest popup permite utilizatorului să creeze o nouă programare în calendar, introducând numele clientului, opțional numărul de telefon și selectând tipul programării.

## Apartenență
- Este un tip de: `popup`
- Deschis de: Probabil prin click pe un `AvailableSlot` din `calendarPanel.md`.

## Layout General Popup (`CreateReservationPopup` wrapper)
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare și Poziționare**:
    - Lățime: `320px`
    - Înălțime: `352px`
    - Poziție: Absolută, centrată pe ecran (Figma CSS: `left: calc(50% - 320px/2); top: calc(50% - 352px/2);`)
      *Notă pentru Cursor AI: În Flutter, folosiți `Stack` cu `Align` sau `Center`, sau un `Dialog` standard.*
- **Styling**:
    - Fundal: `background_popup` (#D9D9D9)
    - Umbră: `widgetShadow`
    - Rază Bordură: `large` (32px)

## Structură și Elemente

### 1. Antet Popup (Header)
- **Layout**: Row, Align Items: Center, Padding Orizontal: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `24px`
- **Text Titlu ("Creeaza programare")**:
    - Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

### 2. Formular Creare Programare (Form)
- **Descriere**: Conține câmpurile de input pentru detaliile programării.
- **Layout**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `248px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)

#### 2.1. Câmp Nume Client (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Client")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Input Text (Nume Client)**:
        - Placeholder: "Introdu numele clientului"
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Padding Orizontal `small` (8px), Înălțime `48px`
        - Styling Text/Placeholder: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`

#### 2.2. Câmp Număr Telefon (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu (Container)**: Row, Justify: Space-between, Align Items: Center, Padding Orizontal `small` (8px), Înălțime `24px`
        - **Text Titlu ("Numar de telefon")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
        - **Text Opțional ("(optional)")**: Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_medium_purple (#886699);`
    - **Input Text (Număr Telefon)**:
        - Placeholder: "Introdu numarul de telefon" (dedus din placeholder-ul numelui)
        - Styling Identic cu Input Nume Client.

#### 2.3. Câmp Tip Programare (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Tip programare")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Dropdown (Tip Programare)**:
        - Valoare Exemplu: "Intalnire"
        - Layout: Row, Justify: Space-between, Align Items: Center, Padding Orizontal `small` (8px), Gap: `small` (8px)
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Înălțime `48px`
        - Styling Text Valoare: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`
        - Iconiță Dropdown: `DropdownIcon` (`icon_medium` - 24x24px), Bordură `2px solid #7C568F`

### 3. Secțiune Buton Salvare (ButtonSection)
- **Layout**: Row, Justify Content: Center, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `48px`

#### 3.1. Buton Salvare (Button)
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Text Buton ("Salveaza")**:
    - Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699); text-align: center;`