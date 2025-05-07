# Edit Reservation Popup

## Descriere
Acest popup permite utilizatorului să modifice detaliile unei programări existente din calendar, incluzând numele clientului, numărul de telefon (opțional), data, ora și tipul programării. Permite și ștergerea programării.

## Apartenență
- Este un tip de: `popup`
- Deschis de: Probabil prin click pe un `ReservedSlot` din `calendarPanel.md` sau pe butonul de editare din `meetingsPanel.md`.

## Layout General Popup (`EditReservationPopup` wrapper)
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare și Poziționare**:
    - Lățime: `320px`
    - Înălțime: `512px`
    - Poziție: Absolută, centrată pe ecran (Figma CSS: `left: calc(50% - 320px/2); top: calc(50% - 512px/2);`)
      *Notă pentru Cursor AI: În Flutter, folosiți `Stack` cu `Align` sau `Center`, sau un `Dialog` standard.*
- **Styling**:
    - Fundal: `background_popup` (#D9D9D9)
    - Umbră: `widgetShadow`
    - Rază Bordură: `large` (32px)

## Structură și Elemente

### 1. Antet Popup (Header)
- **Layout**: Row, Align Items: Center, Padding Orizontal: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `24px`
- **Text Titlu ("Modifica programare")**:
    - Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

### 2. Formular Editare Programare (Form)
- **Descriere**: Conține câmpurile de input pentru detaliile programării.
- **Layout**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `408px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)

#### 2.1. Câmp Nume Client (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Client")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Input Text (Nume Client)**:
        - Valoare Exemplu: "Introdu numele clientului" (sau valoarea existentă)
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
        - Valoare Exemplu: "Introdu numarul de telefon" (sau valoarea existentă)
        - Styling Identic cu Input Nume Client.

#### 2.3. Câmp Data (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Data")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Input Data (Input)**:
        - Layout: Row, Justify: Space-between, Align Items: Center, Padding Orizontal `small` (8px), Gap: `small` (8px)
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Înălțime `48px`
        - **Text Data ("zz/ll/aa")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`
        - **Buton Deschide Calendar (Button - CalendarIcon.svg)**:
            - Layout: Row, Align Items: Center, Padding Orizontal `small` (8px)
            - Dimensionare Container: `40px` x `24px`
            - Iconiță: `CalendarIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid #7C568F`
            *Notă pentru Cursor AI: Acesta ar trebui să deschidă un Date Picker.*

#### 2.4. Câmp Ora (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Ora")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Input Text (Ora)**: (*Ar putea fi un Time Picker*)
        - Valoare Exemplu: "23:59"
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Padding Orizontal `small` (8px), Înălțime `48px`
        - Styling Text: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`

#### 2.5. Câmp Tip Programare (Field)
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

### 3. Secțiune Butoane Acțiune (ButtonSection)
- **Layout**: Row, Justify Content: Center, Align Items: Center, Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `48px`

#### 3.1. Buton Șterge (Button - DeleteIcon)
- **Layout**: Row, Justify/Align Center, Padding: `0px` (*Are padding specific? CSS-ul nu specifică, dar vizual pare a avea.*), Gap: `medium` (10px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Iconiță**: `DeleteIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`

#### 3.2. Buton Salvează (Button)
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `248px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Text Buton ("Salveaza")**:
    - Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699); text-align: center;`