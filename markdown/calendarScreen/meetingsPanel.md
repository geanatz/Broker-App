# Meetings Panel (SecondaryPanel / MeetingsWidget)

## Descriere
Acest panel (`meetingsPanel`) afișează o listă a programărilor viitoare pentru utilizator. Fiecare programare arată numele contactului, timpul rămas până la întâlnire și un buton de acțiune (ex: marcare ca finalizată, editare).

## Apartenență
- Face parte din: `calendarScreen.md`
- Este un tip de: `panel` (lateral, secundar)

## Structură și Elemente

### 1. Container Principal Panel (SecondaryPanel)
- **Descriere**: Containerul rădăcină pentru panelul de întâlniri.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal) - *Deși conține un singur widget principal, `MeetingsWidget`, acest `SecondaryPanel` ar putea fi un wrapper.*
    - Align Items: Center
    - Gap: `medium` (Figma CSS: `gap: 10px;`) - *Acest gap ar fi relevant dacă ar exista mai multe elemente direct în `SecondaryPanel`.*
- **Dimensionare**:
    - Lățime: `312px`
    - Înălțime: `1032px`
- **Context Flex (ca item în `calendarScreen.md`)**:
    - `flex: none; order: 0; flex-grow: 0;` (sau `order: 2` dacă urmează după `calendarPanel`)

#### 1.1. Widget Întâlniri (MeetingsWidget)
- **Descriere**: Containerul principal vizual al listei de întâlniri.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Padding: `small` (Figma CSS: `padding: 8px;`)
    - Gap între elemente (Header și Container listă): `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `312px`
    - Înălțime: `1032px`
- **Styling**:
    - Fundal: `background_widget` (Figma CSS: `background: rgba(255, 255, 255, 0.5);`)
    - Umbră: `widgetShadow` (Figma CSS: `box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);`)
    - Rază Bordură: `large` (Figma CSS: `border-radius: 32px;`)
- **Context Flex (ca item în `SecondaryPanel`)**:
    - `flex: none; order: 0; flex-grow: 1;`

---

### 2. Antet Widget Întâlniri (Header)
- **Descriere**: Antetul widget-ului, afișând un titlu (ex: "Programările Mele", "Următoarele Întâlniri" - textul nu e specificat în CSS, dar `Title` există).
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Align Items: Center
    - Padding: Orizontal `medium` (Figma CSS: `padding: 0px 16px;`)
- **Dimensionare**:
    - Lățime: `296px` (Lățimea `MeetingsWidget` minus padding-ul acestuia)
    - Înălțime: `24px`
- **Context Flex (ca item în `MeetingsWidget`)**:
    - `flex: none; order: 0; align-self: stretch; flex-grow: 0;`

#### 2.1. Text Titlu Antet (Title)
- **Text Exemplu**: "Programări" (dedus, CSS-ul nu specifică textul exact)
- **Dimensionare Text Box**:
    - Lățime: `264px`
    - Înălțime: `24px`
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (Figma CSS: `font-weight: 600;`)
    - Mărime Font: `large` (Figma CSS: `font-size: 19px;`)
    - Culoare Font: `#927B9D` (Variabilă sugerată: `font_light_purple_variant`)
- **Context Flex (ca item în `Header`)**:
    - `flex: none; order: 0; flex-grow: 1;` (ocupă spațiul disponibil pe lățime)

---

### 3. Container Listă Întâlniri (Container)
- **Descriere**: Zona care conține lista scrollabilă a întâlnirilor individuale.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Align Items: Flex-start
    - Gap între elementele de contact: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `296px`
    - Înălțime: `352px` (*Notă: Această înălțime este fixă. Dacă lista de întâlniri depășește această înălțime, ar trebui specificat `overflow-y: scroll;` pe acest container, dar nu este în CSS-ul furnizat. Presupunem că va fi scrollabil dacă este necesar.*)
- **Context Flex (ca item în `MeetingsWidget`)**:
    - `flex: none; order: 1; align-self: stretch; flex-grow: 0;` (*Dacă `flex-grow` este 0 și înălțimea e fixă, nu se va extinde. Dacă se dorește umplerea spațiului rămas, `flex-grow` ar trebui să fie `1`.*)

#### 3.1. Element Întâlnire Individuală (Contact)
- **Descriere**: Reprezintă o singură întâlnire/programare în listă. Această structură se repetă pentru fiecare întâlnire.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Align Items: Center
    - Padding: `small` (Figma CSS: `padding: 8px;`)
- **Dimensionare**:
    - Lățime: `296px`
    - Înălțime: `64px`
- **Styling**:
    - Fundal: `background_dark_purple` (Figma CSS: `background: #C6ACD3;`) SAU `background_light_purple` (Figma CSS: `background: #CFC4D4;`) - *CSS-ul arată ambele variante. Poate indica stări diferite (ex: următoarea, celelalte) sau o inconsistență.*
    - Rază Bordură: `medium` (Figma CSS: `border-radius: 24px;`)
- **Context Flex (ca item în `Container`)**:
    - `flex: none; order: X; align-self: stretch; flex-grow: 0;` (order crește pentru fiecare întâlnire)

##### 3.1.1. Detalii Întâlnire (Details)
- **Descriere**: Partea stângă a elementului, conținând numele și timpul.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Column (vertical)
    - Justify Content: Center
    - Align Items: Center (sau Flex-start, dacă textul trebuie aliniat la stânga în containerul său)
    - Padding: Orizontal `small` (Figma CSS: `padding: 0px 8px;`)
- **Dimensionare**:
    - Lățime: `232px`
    - Înălțime: `48px`
- **Context Flex (ca item în `Contact`)**:
    - `flex: none; order: 0; flex-grow: 1;` (ocupă spațiul rămas pe lățime, lăsând loc butonului)

###### 3.1.1.1. Nume Contact (Text - ex: "Bogdan Marius")
- **Text Exemplu**: "Bogdan Marius"
- **Dimensionare Text Box**: Lățime `216px`, Înălțime `21px` (containerul textului are `height: 24px`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `large` (600)
    - Mărime Font: `medium` (17px)
    - Culoare Text: `#7C568F` (Variabilă: `font_dark_purple_variant`) SAU `#886699` (Variabilă: `font_medium_purple`) - *Variază în exemplele CSS.*
- **Context Flex (ca item în `Details`)**:
    - `order: 0; align-self: stretch;`

###### 3.1.1.2. Timp Până la Întâlnire (Text - ex: "in 23 minute")
- **Text Exemplu**: "in 23 minute"
- **Dimensionare Text Box**: Lățime `216px`, Înălțime `19px` (containerul textului are `height: 24px`)
- **Styling Text**:
    - Familie Font: `'Outfit'`
    - Greutate Font: `medium` (500)
    - Mărime Font: `small` (15px)
    - Culoare Text: `#886699` (Variabilă: `font_medium_purple`) SAU `#927B9D` (Variabilă: `font_light_purple_variant`) - *Variază în exemplele CSS.*
- **Context Flex (ca item în `Details`)**:
    - `order: 1; align-self: stretch;`

##### 3.1.2. Buton Acțiune Întâlnire (Button)
- **Descriere**: Butonul din dreapta elementului, pentru acțiuni specifice întâlnirii.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row
    - Justify Content: Center
    - Align Items: Center
    - Padding: `medium` (Figma CSS: `padding: 16px;`)
    - Gap: `small` (Figma CSS: `gap: 8px;`)
- **Dimensionare**:
    - Lățime: `48px`
    - Înălțime: `48px`
- **Styling**:
    - Fundal: `transparent` (pentru "DoneIcon") SAU `background_dark_purple` (#C6ACD3) (pentru "EditIcon") - *Variază în funcție de iconiță/stare.*
    - Rază Bordură: `small` (Figma CSS: `border-radius: 16px;`)
- **Context Flex (ca item în `Contact`)**:
    - `flex: none; order: 1; flex-grow: 0;`

###### 3.1.2.1. Iconiță Buton
- **Tipuri Iconițe (exemple din CSS)**:
    - **DoneIcon.svg**:
        - Dimensionare: `icon_medium` (24x24px)
        - Styling Vector: Bordură `2px solid #7C568F (font_dark_purple_variant)`
        *Notă pentru Cursor AI: Reprezintă o acțiune de finalizare, ex: `Icons.check_circle_outline` sau `Icons.done`.*
    - **EditIcon / LookupIcon.svg**:
        - Dimensionare: `icon_medium` (24x24px)
        - Styling Vector: Bordură `2px solid #7C568F (font_dark_purple_variant)`
        *Notă pentru Cursor AI: Reprezintă o acțiune de editare sau vizualizare detalii, ex: `Icons.edit` sau `Icons.search`.*

---

*Notă Generală pentru Cursor AI*:
*   Structura `Element Întâlnire Individuală (Contact)` (3.1) se repetă pentru fiecare programare din listă în cadrul `Container Listă Întâlniri` (3).
*   **Variații de Stil în Listă**:
    *   Fundalul elementului `Contact`: `#C6ACD3` (mov închis, pare a fi pentru prima/următoarea întâlnire) vs `#CFC4D4` (mov deschis, pentru celelalte).
    *   Culoarea numelui contactului: `#7C568F` (pentru prima) vs `#886699` (pentru celelalte).
    *   Culoarea textului "timp până la": `#886699` (pentru prima) vs `#927B9D` (pentru celelalte).
    *   Fundalul butonului de acțiune și iconița: Prima întâlnire are `DoneIcon` cu fundal transparent, celelalte au `EditIcon` cu fundal `#C6ACD3`.
    Aceste variații sugerează o diferențiere vizuală pentru următoarea întâlnire iminentă față de celelalte programări.
*   **Scroll**: Containerul listei (`Container` - 3) are o înălțime fixă (`352px`). Dacă numărul de întâlniri depășește această capacitate, containerul ar trebui să devină scrollabil (`overflow-y: scroll`). Această proprietate lipsește din CSS-ul furnizat pentru `Container`, dar este esențială pentru funcționalitate.
*   **Culori Ne-variabile**: Culorile `#927B9D` (titlu header, text timp) și `#7C568F` (nume contact, iconițe) ar trebui mapate la variabile sau adăugate la `variables.md`.