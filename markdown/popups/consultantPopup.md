# Consultant Popup

## Descriere
Acest popup afișează detaliile contului pentru consultantul logat, cum ar fi numele și echipa din care face parte. Oferă și un buton pentru deconectare.

## Apartenență
- Este un tip de: `popup`
- Deschis de: Probabil prin click pe widget-ul `AboutConsultant` din `sidebar.md`.

## Layout General Popup (`consultantPopup` wrapper)
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `small` (8px)
    - Gap intern: `small` (8px)
- **Dimensionare și Poziționare**:
    - Lățime: `320px`
    - Înălțime: `272px`
    - Poziție: Absolută, centrată pe ecran (Figma CSS: `left: calc(50% - 320px/2); top: calc(50% - 272px/2);`)
      *Notă pentru Cursor AI: În Flutter, folosiți `Stack` cu `Align` sau `Center`, sau un `Dialog` standard.*
- **Styling**:
    - Fundal: `background_popup` (#D9D9D9)
    - Umbră: `widgetShadow`
    - Rază Bordură: `large` (32px)

## Structură și Elemente

### 1. Antet Popup (Header)
- **Layout**: Row, Align Items: Center, Padding Orizontal: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `24px`
- **Text Titlu ("Detalii cont")**:
    - Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

### 2. Formular Detalii Cont (Form)
- **Descriere**: Afișează informațiile despre consultant (nume, echipă) ca text static în câmpuri cu aspect de input.
- **Layout**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `168px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)

#### 2.1. Câmp Nume Consultant (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Consultant")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Valoare Nume (Input - afișaj static)**:
        - Text Exemplu: "Alexandru Popescu"
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Padding Orizontal `medium` (16px), Înălțime `48px`
        - Styling Text: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`

#### 2.2. Câmp Echipă Consultant (Field)
- **Layout**: Column, Align Items: Flex-start
- **Dimensionare**: Lățime `288px`, Înălțime `72px`
- **Elemente**:
    - **Titlu ("Echipa ta")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Valoare Echipă (Input - afișaj static)**:
        - Text Exemplu: "Echipa Andreea"
        - Styling Container: Identic cu Nume Consultant.
        - Styling Text: Identic cu Nume Consultant.

### 3. Secțiune Buton Deconectare (ButtonSection)
- **Layout**: Row, Justify Content: Center, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `48px`

#### 3.1. Buton Deconectare (Button)
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `304px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Text Buton ("Deconectare")**:
    - Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699); text-align: center;`