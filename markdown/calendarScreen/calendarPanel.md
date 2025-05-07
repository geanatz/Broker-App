# Calendar Panel (MainPanel / CalendarWidget)

## Descriere
Acest panel afișează calendarul principal al aplicației, permițând vizualizarea și gestionarea programărilor pe zile și ore. Pare a fi o vizualizare săptămânală (Luni-Vineri).

## Apartenență
- Face parte din: `calendarScreen.md`
- Este un tip de: `panel`

## Structură și Elemente

### 1. Container Principal Panel (MainPanel)
- **Descriere**: Containerul rădăcină pentru întregul panel al calendarului.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
- **Dimensionare**:
    - Lățime: `1288px`
    - Înălțime: `1032px`
- **Context Flex (ca item în ecranul părinte)**:
    - `flex: none; order: 1; flex-grow: 1;`

#### 1.1. Widget Calendar (CalendarWidget)
- **Descriere**: Containerul principal vizual al calendarului, cu fundal și bordură.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Center
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `1288px`
    - Înălțime: `1032px`
- **Styling**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)
- **Context Flex (ca item în MainPanel)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

---

### 2. Antet Widget Calendar (WidgetHeader)
- **Descriere**: Antetul widget-ului de calendar, conținând titlul și selectorul de săptămână/perioadă.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Justify Content: Space-between
    - Align Items: Center
    - Padding: Orizontal `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare**:
    - Lățime: `1272px` (Lățimea `CalendarWidget` minus padding-ul acestuia)
    - Înălțime: `24px`
- **Context Flex (ca item în CalendarWidget)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

#### 2.1. Titlu Widget (Title - "Calendar")
- **Text**: "Calendar"
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Align Items: Center
    - Padding: Orizontal `small` (Figma CSS: `padding: 0px 8px;`)
    - Centrare Orizontală în spațiul alocat: Da (Figma CSS: `margin: 0 auto;`)
- **Dimensionare Container Titlu**:
    - Lățime: `97px`
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Culoare Font: `#927B9D` (Variabilă sugerată: `font_light_purple_variant` sau similar)
- **Context Flex (ca item în WidgetHeader)**:
    - `flex: none; order: 0; flex-grow: 0;`

#### 2.2. Selector Perioadă Calendar (CalendarSwitch)
- **Descriere**: Control pentru navigarea între perioadele calendaristice (săptămâni).
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Align Items: Center
    - Centrare Orizontală în spațiul alocat: Da (Figma CSS: `margin: 0 auto;`)
- **Dimensionare**:
    - Lățime: `208px`
    - Înălțime: `24px`
- **Context Flex (ca item în WidgetHeader)**:
    - `flex: none; order: 1; flex-grow: 0;`

##### 2.2.1. Buton Navigare Stânga (Button - Săgeată Stânga)
- **Componentă Tip**: IconButton
- **Layout**:
    - Padding Orizontal: `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare Buton**:
    - Lățime: `40px`
    - Înălțime: `24px`
- **Iconiță**: `Arrow_Left_SM`
    - Dimensionare Iconiță: `icon_medium` (Figma CSS: `width: 24px; height: 24px;`)
    - Styling Vector Iconiță:
        - Bordură: `2px solid #927B9D` (Culoare ca la titlul widget-ului)
        *Notă pentru Cursor AI: Folosiți o iconiță standard, ex: `Icons.arrow_back_ios` sau `Icons.chevron_left`.*

##### 2.2.2. Text Perioadă Afișată (Text - "20-24 Mai")
- **Text Exemplu**: "20-24 Mai" (va fi dinamic)
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
- **Dimensionare Container Text**:
    - Lățime: `128px`
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `small` (Figma CSS: `font-size: 15px;`)
    - Culoare Text: `#927B9D` (Culoare ca la titlul widget-ului)
    - Aliniere Text: Center
- **Context Flex (ca item în CalendarSwitch)**:
    - `flex-grow: 1;` (pentru a ocupa spațiul între butoane)

##### 2.2.3. Buton Navigare Dreapta (Button - Săgeată Dreapta)
- **Componentă Tip**: IconButton
- **Layout**: Identic cu 2.2.1.
- **Dimensionare Buton**: Identic cu 2.2.1.
- **Iconiță**: `Arrow_Right_SM`
    - Dimensionare Iconiță: `icon_medium` (Figma CSS: `width: 24px; height: 24px;`)
    - Styling Vector Iconiță: Identic cu 2.2.1.
        *Notă pentru Cursor AI: Folosiți o iconiță standard, ex: `Icons.arrow_forward_ios` sau `Icons.chevron_right`.*

---

### 3. Container Principal Calendar (CalendarContainer)
- **Descriere**: Zona principală unde sunt afișate zilele, orele și sloturile.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Padding: `medium` (Figma CSS: `padding: 16px;`)
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `1272px`
    - Înălțime: `984px`
- **Styling**:
    - Fundal: `background_light_purple` (Figma CSS: `background: #CFC4D4;`)
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Context Flex (ca item în CalendarWidget)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 1;`

#### 3.1. Rând Nume Zile (CalendarDays)
- **Descriere**: Rândul care afișează numele zilelor săptămânii (Luni, Marți, etc.).
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Align Items: Flex-start
    - Gap între elemente: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `1240px` (Lățimea `CalendarContainer` minus padding-ul acestuia)
    - Înălțime: `24px`
- **Context Flex (ca item în CalendarContainer)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

##### 3.1.1. Spațiu Gol Stânga (Frame 94 - primul)
- **Descriere**: Spațiu gol la începutul rândului, probabil pentru alinierea cu coloana orelor.
- **Layout**:
    - Padding Stânga: `64px` (pare a fi o valoare fixă pentru a alinia cu coloana orelor)
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `48px` (Atenție: `padding-left` este `64px`, lățimea efectivă a conținutului este 0, dar containerul ocupă `48px` + `64px` padding? De clarificat. Presupun că `48px` este lățimea totală a acestui element, incluzând padding-ul intern dacă e cazul, sau este lățimea elementului care urmează după padding-ul de `64px`.)
      *Notă pentru Cursor AI: Probabil un `SizedBox(width: 64 + 48)` sau similar, sau un `Padding` urmat de un `SizedBox`. CSS-ul e puțin ambiguu aici (`width: 48px` și `padding-left: 64px` pe același element).*
      *Alternativ, acest "Frame 94" ar putea fi doar un container pentru coloana de ore, iar `padding-left: 64px` se aplică textului din interiorul său. Vom presupune că e un spacer pentru moment.*
- **Context Flex (ca item în CalendarDays)**:
    - `flex: none; order: 0; flex-grow: 0;`

##### 3.1.2. Container Nume Zile (Frame 94 - al doilea)
- **Descriere**: Container pentru textele cu numele zilelor.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Justify Content: Space-between (sau Space-around, depinde de efectul dorit pentru `width: 224px` pe fiecare zi)
    - Align Items: Center
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `1184px`
    - Înălțime: `24px`
- **Context Flex (ca item în CalendarDays)**:
    - `flex: none; order: 1; flex-grow: 1;`

###### 3.1.2.1. Text Zi (Ex: "Luni 20")
- **Text Exemplu**: "Luni 20" (dinamic)
- **Layout**:
    - Centrare Orizontală: Da (Figma CSS: `margin: 0 auto;`)
- **Dimensionare Text Box**:
    - Lățime: `224px` (fiecare zi are această lățime)
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `small` (Figma CSS: `font-size: 15px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)
    - Aliniere Text: Center
- **Context Flex (ca item în Container Nume Zile)**:
    - `flex: none; order: 0; flex-grow: 0;` (order se schimbă pentru fiecare zi: 0, 1, 2, 3, 4)
- ***Notă***: *Această structură se repetă pentru "Marți 21", "Miercuri 22", "Joi 23", "Vineri 24", cu `order` corespunzător.*

#### 3.2. Grilă Principală Calendar (Calendar - denumire CSS)
- **Descriere**: Containerul care ține coloana de ore și coloanele de sloturi pentru fiecare zi. Permite scroll vertical.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Align Items: Flex-start
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare**:
    - Lățime: `1240px`
    - Înălțime: `920px`
- **Comportament**:
    - Scroll Vertical: Da (Figma CSS: `overflow-y: scroll;`)
- **Context Flex (ca item în CalendarContainer)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 1;`

##### 3.2.1. Coloană Ore (CalendarHours)
- **Descriere**: Coloana din stânga care afișează intervalele orare.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Padding: Vertical `small` (Figma CSS: `padding: 8px 0px;`)
    - Gap între ore: `56px` (gap mare, probabil pentru a se potrivi cu înălțimea sloturilor de 64px + gap între ele)
- **Dimensionare**:
    - Lățime: `40px`
    - Înălțime: `1080px` (mai mare decât containerul vizibil, pentru scroll)
- **Context Flex (ca item în Grilă Principală Calendar)**:
    - `flex: none; order: 0; flex-grow: 0;`

###### 3.2.1.1. Text Oră (Ex: "9:30")
- **Text Exemplu**: "9:30" (dinamic, se repetă pentru fiecare interval)
- **Dimensionare Text Box**:
    - Lățime: `40px`
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (Figma CSS: `font-weight: 500;`)
    - Mărime Font: `small` (Figma CSS: `font-size: 15px;`)
    - Culoare Font: `font_medium_purple` (Figma CSS: `color: #886699;`)
    - Aliniere Text: Center
- **Context Flex (ca item în CalendarHours)**:
    - `flex: none; order: X; align-self: stretch; flex-grow: 0;` (order crește: 0, 1, 2, ...)
- ***Notă***: *Această structură se repetă pentru toate orele (10:00, 10:30, ..., 16:00).*

##### 3.2.2. Coloană Sloturi pentru o Zi (Slots / Column)
- **Descriere**: O coloană verticală reprezentând sloturile orare pentru o singură zi. Se repetă pentru fiecare zi a săptămânii (Luni, Marți, etc.).
- **Layout Container "Slots" (wrapper pentru "Column")**:
    - Tip: Flex container
    - Direcție Flex: Row (deși conține o singură coloană, poate pentru aliniere sau viitoare extinderi)
    - Align Items: Center
    - Gap: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare Container "Slots"**:
    - Lățime: `224px`
    - Înălțime: `920px` (match cu înălțimea vizibilă a grilei)
- **Layout Container "Column" (interior "Slots")**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap între sloturi: `medium` (Figma CSS: `gap: 16px;`)
- **Dimensionare Container "Column"**:
    - Lățime: `224px`
    - Înălțime: `920px`
- **Styling Container "Column"**:
    - Rază Bordură: `tiny` (Figma CSS: `border-radius: 8px;`)
- **Context Flex (ca item în Grilă Principală Calendar)**:
    - `flex: none; order: Y; align-self: stretch; flex-grow: 1;` (order crește: 1, 2, 3, 4, 5 pentru fiecare zi)
- ***Notă Importantă***: *Structura de mai jos (AvailableSlot, ReservedSlot) se repetă de mai multe ori în cadrul fiecărei "Column" pentru a umple ziua.*

###### 3.2.2.1. Slot Disponibil (AvailableSlot - Button)
- **Componentă Tip**: Buton sau zonă click-abilă
- **Descriere**: Reprezintă un interval orar disponibil pentru programare.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center
    - Padding: `6px 16px` sau `medium` (Figma CSS: `padding: 6px 16px;` sau `padding: 16px;` - pare a varia ușor, folosim cel mai comun)
- **Dimensionare**:
    - Lățime: `224px`
    - Înălțime: `64px`
- **Styling**:
    - Bordură: `4px solid background_dark_purple` (Figma CSS: `border: 4px solid #C6ACD3;`)
    - Rază Bordură: `small` (Figma CSS: `border-radius: 16px;`)
- **Text Interior (CreateSlot)**:
    - Text: "Crează Programare" (sau similar, dedus din "CreateSlot")
    - Dimensionare Text Box: Lățime `192px`, Înălțime `24px`
    - Styling Text:
        - Familie Font: `'Outfit'`
        - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
        - Mărime Font: `medium` (Figma CSS: `font-size: 17px;`)
        - Culoare Text: `font_medium_purple` (Figma CSS: `color: #886699;`)
        - Aliniere Text: Center
- **Context Flex (ca item în "Column")**:
    - `flex: none; order: Z; align-self: stretch; flex-grow: 0;` (order crește în cadrul coloanei)

###### 3.2.2.2. Slot Rezervat (ReservedSlot)
- **Descriere**: Reprezintă un interval orar care este deja rezervat.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Flex-start (sau Center, CSS-ul variază puțin între exemple)
    - Padding: `6px 16px`
- **Dimensionare**:
    - Lățime: `224px`
    - Înălțime: `64px`
- **Styling**:
    - Fundal: `background_dark_red` (Figma CSS: `background: #D3ACAC;`) SAU `background_dark_purple` (Figma CSS: `background: #C6ACD3;`) - *CSS-ul arată ambele variante. Va trebui să clarifici care e corectă sau dacă sunt tipuri diferite de rezervări.*
    - Umbră: `calendarReservedSlotShadow` (Figma CSS: `box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.25);`)
    - Rază Bordură: `small` (Figma CSS: `border-radius: 16px;`)
- **Texte Interioare (Exemplul 1 - specific)**:
    - **Nume Consultant (ConsultantName - "Claudiu")**:
        - Text: "Claudiu"
        - Styling: `font-weight: 600; font-size: 17px; color: font_dark_red (#804D4D);`
    - **Nume Client (ClientName - "Vasile Morodan")**:
        - Text: "Vasile Morodan"
        - Styling: `font-weight: 500; font-size: 15px; color: font_medium_red (#996666);`
- **Texte Interioare (Exemplul 2 - generic)**:
    - **Text Consultant**:
        - Styling: `font-weight: 600; font-size: 17px; color: #7C568F (font_dark_purple_variant);`
    - **Text Client**:
        - Styling: `font-weight: 500; font-size: 15px; color: font_medium_purple (#886699);`
- **Context Flex (ca item în "Column")**:
    - `flex: none; order: Z; align-self: stretch; flex-grow: 0;`

---

*Notă Generală pentru Cursor AI*:
*   Coloana `Slots / Column` (3.2.2) se repetă de 5 ori (pentru Luni, Marți, ..., Vineri) în cadrul `Grilă Principală Calendar` (3.2), fiecare având `order` de la 1 la 5.
*   În interiorul fiecărei `Column` (3.2.2), elementele `AvailableSlot` (3.2.2.1) și `ReservedSlot` (3.2.2.2) se repetă pentru a umple intervalele orare ale zilei. Numărul acestor sloturi corespunde numărului de intervale orare (ex: 14 intervale de la 9:30 la 16:00, fiecare de 30 min, înălțime slot 64px + gap 16px = 80px per interval. Total 14 * 80px = 1120px, ce depășește înălțimea vizibilă de 920px, confirmând scroll-ul).
*   Există variații în CSS pentru `ReservedSlot`:
    *   Fundal: `#D3ACAC` (roșu închis) vs `#C6ACD3` (mov închis).
    *   Aliniere text intern: `align-items: flex-start` vs `align-items: center`.
    *   Culori text intern: set roșu vs set mov.
    Aceste variații ar putea indica diferite tipuri de programări sau stări. Trebuie definite clar. Pentru moment, ambele variante sunt prezentate.
*   Culoarea `#927B9D` pentru titlul widget-ului și selectorul de perioadă, și `#7C568F` pentru textul din sloturile mov, ar trebui adăugate ca variabile în `variables.md` dacă sunt folosite consistent (ex: `font_light_purple_accent`, `font_dark_purple_accent`).
*   Padding-ul pentru `AvailableSlot` variază între `6px 16px` și `16px`. Este important să se standardizeze.
*   Valoarea `gap: 56px` pentru `CalendarHours` este cheia pentru alinierea orelor cu sloturile de 64px + gap de 16px (total 80px). `56px + 24px (înălțime text oră) = 80px`.