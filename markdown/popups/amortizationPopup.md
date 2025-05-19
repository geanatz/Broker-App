# Amortization Popup (amortizationPopup.md)

## Descriere Generală

Acest document descrie stilizarea și structura componentei 'Amortization Popup', o fereastră modală (popup) destinată afișării detaliilor unui grafic de amortizare (credit, investiție, etc.). Este activată, conform specificațiilor, de al doilea buton din secțiunea `buttonSection` a `calculatorPopup`-ului.

## Layout și Dimensiuni

Componenta principală (`amortizationPopup`) este un container vertical cu padding interior și spațiu între elemente. Conține un header și o secțiune principală pentru afișarea graficului de amortizare.

-   **Container Principal (`amortizationPopup`)**:
    -   **Layout**: `Column` (flex-direction: column)
    -   **Aliniere**: Items aliniate la început (start) pe axa transversală (crossAxisAlignment: CrossAxisAlignment.start).
    -   **Padding**: 8px pe toate laturile. Se va folosi variabila `$paddingSmall`.
    -   **Gap**: 8px între elementele principale (header și secțiunea de amortizare). Se va folosi variabila `$spacingSmall`.
    -   **Dimensiuni**: Lățime fixă de 584px, înălțime fixă de 608px.
    -   **Poziționare**: Specificată ca `position: absolute` la coordonatele `left: 668px`, `top: 236px`. Aceasta indică o poziționare fixă sau absolută față de un container părinte.
    -   **Flex Properties**: Nu specifică `align-self` sau `flex-grow` direct pentru containerul principal, dar este în sine un element într-un alt layout (cel care afișează popup-ul).

-   **Header (`header`)**:
    -   **Layout**: `Row` (flex-direction: row)
    -   **Aliniere**: Items aliniate pe centru pe ambele axe (`align-items: center`).
    -   **Padding**: 0px vertical, 16px orizontal. Se va folosi `EdgeInsets.symmetric(horizontal: $paddingMedium)`.
    -   **Dimensiuni**: Înălțime fixă de 24px. Ocupă toată lățimea disponibilă (`width: 568px`, care este lățimea panoului minus padding-ul de 2*8px).
    -   **Flex Properties**: `align-self: stretch` (ocupă toată lățimea panoului părinte).

-   **Secțiunea Amortizare (`amortization`)**:
    -   **Layout**: `Column` (flex-direction: column)
    -   **Aliniere**: Items aliniate la început (start) pe axa transversală (`align-items: flex-start`).
    -   **Padding**: 8px pe toate laturile. Se va folosi variabila `$paddingSmall`.
    -   **Gap**: 8px între elementele interne (header-ul listei și lista propriu-zisă). Se va folosi variabila `$spacingSmall`.
    -   **Dimensiuni**: Lățime de 568px (lățimea panoului minus padding), înălțime de 560px.
    -   **Flex Properties**: `align-self: stretch` (ocupă toată lățimea panoului părinte) și `flex-grow: 1` (ocupă tot spațiul vertical rămas în panoul părinte după header).

-   **Rând Header Listă (`row` în amortization)**:
    -   **Layout**: `Row` (flex-direction: row)
    -   **Aliniere**: Items aliniate pe centru pe ambele axe (`align-items: center`).
    -   **Spațiu**: Spațiu distribuit egal între coloane (`justify-content: space-between`).
    -   **Padding**: 0px vertical, 16px orizontal. Se va folosi `EdgeInsets.symmetric(horizontal: $paddingMedium)`.
    -   **Gap**: 16px între elementele coloanelor. Se va folosi variabila `$spacingMedium`.
    -   **Dimensiuni**: Înălțime fixă de 24px. Ocupă toată lățimea disponibilă (`width: 552px`, lățimea secțiunii de amortizare minus padding-ul interior 2*8px).
    -   **Flex Properties**: `align-self: stretch`.

-   **Container Listă (`list`)**:
    -   **Layout**: `Column` (flex-direction: column)
    -   **Aliniere**: Items aliniate la început (start) pe axa transversală (`align-items: flex-start`).
    -   **Padding**: 0px.
    -   **Gap**: 8px între item-urile listei. Se va folosi variabila `$spacingSmall`.
    -   **Dimensiuni**: Înălțime fixă de 512px. Ocupă toată lățimea disponibilă (`width: 552px`, lățimea secțiunii de amortizare minus padding-ul interior 2*8px).
    -   **Overflow**: Scroll vertical (`overflow-y: scroll`).
    -   **Flex Properties**: `align-self: stretch`. `flex-grow: 0` (dimensiune fixă, nu se extinde).

-   **Item Listă (`item`)**:
    -   **Layout**: `Row` (flex-direction: row)
    -   **Aliniere**: Items aliniate pe centru pe ambele axe (`align-items: center`).
    -   **Spațiu**: Spațiu distribuit egal între coloane (`justify-content: space-between`).
    -   **Padding**: 0px vertical, 16px orizontal. Se va folosi `EdgeInsets.symmetric(horizontal: $paddingMedium)`.
    -   **Gap**: 16px între elementele coloanelor. Se va folosi variabila `$spacingMedium`.
    -   **Dimensiuni**: Înălțime fixă de 40px. Ocupă toată lățimea disponibilă (`width: 552px`).
    -   **Flex Properties**: `align-self: stretch`.

## Elemente de Interfață

Componenta conține următoarele tipuri de elemente:

-   Container principal (Popup)
-   Header Popup
-   Titlu Popup (Text)
-   Container Grafic Amortizare (Corpul popup-ului)
-   Rând Header Grafic (pentru coloane: Nr., Suma, Dobanda, Principal, Sold)
-   Text Header Coloană
-   Container Listă Item-uri
-   Rând Item Listă
-   Text Item Listă (pentru fiecare valoare din rând: Nr., Suma, Dobanda, Principal, Sold)

## Stilizare Detaliată

Stilizarea folosește pe cât posibil variabile din `appTheme.dart`.

-   **Container Principal (`amortizationPopup`)**:
    -   **Fundal**: `#D9D9D9` (Placeholder: `$backgroundColorPane` sau similar)
    -   **Umbră**: `0px 0px 15px rgba(0, 0, 0, 0.1)` (Placeholder: `$shadowPane` sau similar)
    -   **Rotunjire colțuri**: `32px` (Placeholder: `$borderRadiusLarge`)
    -   **Padding interior**: `8px` (Placeholder: `$paddingSmall`)
    -   **Spațiu între copii**: `8px` (Placeholder: `$spacingSmall`)

-   **Secțiunea Amortizare (`amortization`)**:
    -   **Fundal**: `#C4C4D4` (Placeholder: `$backgroundColorCard` sau similar, același ca form în calculatorPane)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**: `8px` (Placeholder: `$paddingSmall`)
    -   **Spațiu între copii**: `8px` (Placeholder: `$spacingSmall`)

-   **Item Listă (`item`)**:
    -   **Fundal**: `#ACACD3` (Placeholder: `$backgroundColorItem` sau similar, același ca input în calculatorPane)
    -   **Rotunjire colțuri**: `16px` (Placeholder: `$borderRadiusSmall`)
    -   **Padding interior**: `0px` vertical, `16px` orizontal (Placeholder: `EdgeInsets.symmetric(horizontal: $paddingMedium)`)
    -   **Spațiu între coloane**: `16px` (Placeholder: `$spacingMedium`)

-   **Text/Tipografie**:
    -   **Font Family**: Outfit
    -   **Titlu Popup (`Amortizare` în header)**:
        -   Greutate font: `600` (Placeholder: `$fontWeightSemiBold`)
        -   Mărime font: `19px` (Placeholder: `$fontSizeLarge` sau similar)
        -   Culoare: `#8A8AA8` (Placeholder: `$colorTextSecondary` sau similar, același ca Titlu panou în calculatorPane)
        -   Înălțime linie: `24px`
    -   **Text Header Listă (`Nr.`, `Suma`, `Dobanda`, etc.)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `15px` (Placeholder: `$fontSizeSmall` sau similar, același ca Alt text în calculatorPane)
        -   Culoare: `#666699` (Placeholder: `$colorTextPrimary` sau similar, același ca Titlu câmp în calculatorPane)
        -   Înălțime linie: `19px`
        -   Aliniere text: `text-align: center`
    -   **Text Item Listă (`1`, `424.4`, etc.)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `15px` (Placeholder: `$fontSizeSmall` sau similar)
        -   Culoare: `#4D4D80` (Placeholder: `$colorTextInput` sau similar, același ca Text Input în calculatorPane)
        -   Înălțime linie: `19px`
        -   Aliniere text: `text-align: center`

## Stări

Stilurile CSS furnizate nu includ detalii specifice pentru stări interactive (hover, pressed, disabled). Se va presupune că item-urile listei pot avea stări (e.g., selectat) care vor fi gestionate la nivel de widget Flutter (ex: schimbarea culorii de fundal la selecție) și vor urma ghidurile generale de stilizare din `appTheme.dart`.

## Responsivitate

Panoul are dimensiuni **fixe** (584px lățime, 608px înălțime) și o poziție absolută fixă (`left: 668px`, `top: 236px`) în CSS. Acest lucru indică faptul că nu este conceput să se adapteze fluid la diferite dimensiuni de ecran prin redimensionare sau repoziționare automată bazată pe constrângeri relative.
Lista de item-uri (`list`) are o înălțime fixă și suportă scrolling, permițând afișarea unui număr variabil de rânduri.
Elementele interne (header rânduri, item rânduri) se adaptează la lățimea containerului listei (`align-self: stretch`) și își distribuie spațiul pe orizontală (`justify-content: space-between`, `gap`). Lățimile specificate pentru coloanele individuale (e.g., `width: 40px`, `width: 96px` pentru textele din rânduri) sugerează o lățime fixă a coloanelor, deși `margin: 0 auto` pe acestea indică o intenție de centrare *în spațiul alocat* (care ar fi lățimea fixă specificată). Într-un `Row` Flutter cu `MainAxisAlignment.spaceBetween`, lățimile fixe sau utilizarea `Expanded`/`Flexible` pentru a distribui spațiul sunt metode de implementare. Lățimile fixe din CSS sugerează o implementare cu lățimi fixe pentru fiecare "celulă" text din rând.

**Notă pentru Implementare**: Poziționarea absolută cu coordonate fixe (`left`, `top`) este neobișnuită pentru un popup într-o aplicație mobilă sau web responsivă și ar putea face ca popup-ul să nu fie vizibil sau să fie poziționat incorect pe ecrane de diferite dimensiuni sau orientări. Este mai probabil ca intenția de design să fie centrarea popup-ului pe ecran sau într-un container specific. Cursor AI ar trebui să interpreteze această poziționare ca o sugestie de *unde* să apară popup-ul într-un layout specific de design (probabil un layout desktop/tabletă), dar să folosească mecanisme standard Flutter pentru popup-uri (e.g., centrare) dacă nu există un context de poziționare absolută definit de containerul părinte.

## Animații

Nu sunt specificate animații sau tranziții în CSS-ul furnizat.

## Relații cu alte Componente

-   Este o componentă de tip `popup`, destinată să fie afișată modal sau într-o suprapunere (overlay) deasupra altui conținut.
-   Este activată specific de al doilea buton (cu iconița `ViewIcon`) din secțiunea de butoane a `calculatorPopup`-ului.
-   Afișează date (graficul de amortizare) calculate pe baza input-urilor din `calculatorPopup`.
-   Nu pare să conțină butoane proprii pentru acțiuni, sugerând că interacțiunea principală (închidere, etc.) ar putea fi gestionată de containerul care afișează popup-ul (e.g., apăsarea în afara popup-ului).

## Implementare Flutter (sugestie)

Popup-ul poate fi afișat folosind `showDialog` sau `showGeneralDialog` pentru a gestiona suprapunerea și închiderea ușoară. Poziționarea exactă specificată în CSS (`left`, `top`) este dificil de replicat fidel cu widget-urile standard de popup/dialog Flutter. O abordare mai comună ar fi centrarea popup-ului pe ecran sau wrap-uirea sa într-un widget de poziționare (ex: `Positioned` într-un `Stack` sau `Overlay`) dacă este strict necesară poziționarea absolută într-un anumit context.

Containerul principal poate fi un `Container` cu `BoxDecoration` (color, radius, shadow) și padding-ul `AppTheme.paddingSmall`. Layout-ul intern va fi un `Column` cu `crossAxisAlignment: CrossAxisAlignment.start` și spațiu între copii (`SizedBox(height: AppTheme.spacingSmall)`).

Header-ul (`header`) va fi un `Row` cu `padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium)` și un widget `Text` pentru titlu cu stilizarea corespunzătoare.

Secțiunea de amortizare (`amortization`) va fi un `Container` cu `BoxDecoration` (background color, radius) și padding-ul `AppTheme.paddingSmall`. Conținutul său va fi un `Column`.

Rândul header al listei (`row`) va fi un `Row` cu `mainAxisAlignment: MainAxisAlignment.spaceBetween`, `crossAxisAlignment: CrossAxisAlignment.center`, `padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium)` și `spacing: AppTheme.spacingMedium`. Textele de header vor fi widget-uri `Text` cu `TextStyle` și `textAlign: TextAlign.center`. Lățimile fixe din CSS (40px, 96px) pot fi implementate cu `SizedBox` wrap-uind `Text`-ul sau cu `Flexible`/`Expanded` și un `flex` specific dacă se dorește o anumită distribuție a spațiului.

Containerul listei (`list`) va fi un `Container` cu `BoxDecoration` (doar border radius aici, background-ul este pe item-uri). Deoarece are înălțime fixă (`height: 512px`) și `overflow-y: scroll`, se va folosi un widget cu suport pentru scrolling și înălțime fixă, cum ar fi `ListView.builder` wrap-uit într-un `SizedBox` cu înălțimea specificată sau într-un `Expanded` dacă containerul părinte (`amortization` section) gestionează scrolling-ul.

Item-urile listei (`item`) vor fi generate în `ListView.builder`. Fiecare item va fi un `Container` cu `BoxDecoration` (background color, radius) și o înălțime fixă de 40px. Conținutul va fi un `Row` cu `mainAxisAlignment: MainAxisAlignment.spaceBetween`, `crossAxisAlignment: CrossAxisAlignment.center`, `padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium)` și `spacing: AppTheme.spacingMedium`. Textele valorilor din item vor fi widget-uri `Text` cu `TextStyle` și `textAlign: TextAlign.center`, folosind structura de lățime a coloanelor similară cu rândul header.

Toate dimensiunile, culorile, spațierile, rotunjirile și greutățile fonturilor vor fi preluate din `appTheme.dart`.