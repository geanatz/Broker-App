# Calculator Pane (calculatorPane.md)

## Descriere Generală

Acest document descrie stilizarea și structura componentei 'Calculator Pane', o fereastră modală (pane) care conține formulare și elemente pentru efectuarea calculelor, probabil legate de produsele financiare sau de veniturile/cheltuielile clientului. Este concepută ca un panou modular ce poate fi afișat deasupra altui conținut.

## Layout și Dimensiuni

Componenta principală (`calculatorPane`) este un container vertical cu padding interior și spațiu între elemente. Conține mai multe secțiuni (marcate ca `section` și `form`), un header și o zonă pentru butoane.

-   **Container Principal (`calculatorPane`)**:
    -   **Layout**: `Column` (flex-direction: column)
    -   **Aliniere**: Items aliniate la început (start) pe axa transversală (crossAxisAlignment: CrossAxisAlignment.start). Spațiu distribuit între elementele principale pe axa principală (mainAxisAlignment: MainAxisAlignment.spaceBetween).
    -   **Padding**: 8px pe toate laturile. Se va folosi variabila `$paddingSmall`.
    -   **Gap**: 8px între elementele principale. Se va folosi variabila `$spacingSmall`.
    -   **Dimensiuni**: Lățime fixă de 312px, înălțime fixă de 1032px. Aceste dimensiuni fixe sugerează că panoul este destinat unui layout specific, iar conținutul ar putea fi scrollabil dacă depășește înălțimea ecranului.
    -   **Flex Properties**: `align-self: stretch` (va încerca să ocupe toată lățimea disponibilă a containerului părinte) și `flex-grow: 1` (va încerca să ocupe tot spațiul vertical disponibil rămas în containerul părinte).

-   **Secțiuni Interne (`section`, `form`)**:
    -   Sunt organizate vertical (`Column`) cu spațiu între elemente (`gap: 8px`, `$spacingSmall`).
    -   Au lățime fixă de 296px, care este lățimea containerului părinte (`calculatorPane`) minus padding-ul orizontal (312 - 2*8 = 296). Aceste secțiuni `align-self: stretch` pentru a umple lățimea disponibilă.
    -   Unele secțiuni (`form`) au padding interior (`padding: 8px`, `$paddingSmall`).
    -   Secțiunea `section` (containerul principal al formularelor și headerului) este centrată orizontal (`margin: 0 auto`).

-   **Câmpuri de Intrare (`inputField`)**:
    -   Sunt organizate vertical (`Column`) cu spațiu mic între header și input (`gap: 4px`, `$spacingExtraSmall`).
    -   Ocupă toată lățimea disponibilă în containerul părinte (`width: 280px`), care este lățimea `form`-ului minus padding-ul interior (296 - 2*8 = 280).
    -   Pot apărea individual sau în rânduri (`row`) de câte două.

-   **Rânduri de Câmpuri (`row`)**:
    -   Sunt organizate orizontal (`Row`) cu spațiu între elemente (`gap: 8px`, `$spacingSmall`).
    -   Conțin câmpuri de intrare (`inputField`) care folosesc `flex-grow: 1` pentru a distribui uniform spațiul pe orizontală în cadrul rândului.

-   **Butoane (`buttonSection`)**:
    -   Sunt organizate orizontal (`Row`) cu spațiu între butoane (`gap: 8px`, `$spacingSmall`).
    -   Containerul butoanelor este centrat orizontal (`margin: 0 auto`) și are lățime de 296px.
    -   Butoanele din interior folosesc `flex-grow` pentru a ocupa spațiul (primul buton se extinde, al doilea are lățime fixă).

## Elemente de Interfață

Componenta conține următoarele tipuri de elemente:

-   Container principal (Panou)
-   Container Secțiune (pentru header, formulare, butoane)
-   Header de secțiune
-   Titlu secțiune (Text)
-   Form Container
-   Câmp de Intrare Container (cu Header și Input)
-   Header Câmp de Intrare (pentru Titlu și Alt Text)
-   Titlu Câmp de Intrare (Text - Label)
-   Alt Text Câmp de Intrare (Text - e.g., "Optional")
-   Input Container (pentru zona de text/cifre a câmpului)
-   Text/Placeholder Input (Text)
-   Rând Orizontal (pentru gruparea câmpurilor mici)
-   Container Butoane
-   Buton (Lat cu Text + Icon)
-   Buton (Pătrat cu Icon)
-   Text Buton
-   Icon (RetryIcon, ViewIcon)

## Stilizare Detaliată

Stilizarea folosește pe cât posibil variabile din `appTheme.dart`.

-   **Container Principal (`calculatorPane`)**:
    -   **Fundal**: `#D9D9D9` (Placeholder: `$backgroundColorPane` sau similar)
    -   **Umbră**: `0px 0px 15px rgba(0, 0, 0, 0.1)` (Placeholder: `$shadowPane` sau similar)
    -   **Rotunjire colțuri**: `32px` (Placeholder: `$borderRadiusLarge`)
    -   **Padding interior**: `8px` (Placeholder: `$paddingSmall`)
    -   **Spațiu între copii**: `8px` (Placeholder: `$spacingSmall`)

-   **Form Container (`form`)**:
    -   **Fundal**: `#C4C4D4` (Placeholder: `$backgroundColorCard` sau similar)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**: `8px` (Placeholder: `$paddingSmall`)
    -   **Spațiu între copii**: `8px` (Placeholder: `$spacingSmall`)

-   **Input Container (`input`)**:
    -   **Fundal**: `#ACACD3` (Placeholder: `$backgroundColorInput` sau similar)
    -   **Rotunjire colțuri**: `16px` (Placeholder: `$borderRadiusSmall`)
    -   **Padding interior**: `0px` vertical, `16px` orizontal (Placeholder: `EdgeInsets.symmetric(horizontal: $paddingMedium)`)

-   **Buton Container (`button`)**:
    -   **Fundal**: `#C4C4D4` (Same as form background)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**:
        -   Buton Lat: `12px` vertical, `16px` orizontal (Placeholder: `EdgeInsets.symmetric(vertical: $spacing12, horizontal: $paddingMedium)`)
        -   Buton Pătrat: `12px` pe toate laturile (Placeholder: `EdgeInsets.all($spacing12)`)
    -   **Spațiu între copii**:
        -   Buton Lat: `8px` (Placeholder: `$spacingSmall`)
        -   Buton Pătrat: `10px` (Placeholder: `$spacingMediumSmall` sau similar)

-   **Text/Tipografie**:
    -   **Font Family**: Outfit
    -   **Titlu Panou (`Titlu` în header)**:
        -   Greutate font: `600` (Placeholder: `$fontWeightSemiBold`)
        -   Mărime font: `19px` (Placeholder: `$fontSizeLarge` sau similar)
        -   Culoare: `#8A8AA8` (Placeholder: `$colorTextSecondary` sau similar)
        -   Înălțime linie: `24px`
    -   **Titlu Câmp (`Title` în fieldHeader)**:
        -   Greutate font: `600` (Placeholder: `$fontWeightSemiBold`)
        -   Mărime font: `17px` (Placeholder: `$fontSizeMedium` sau similar)
        -   Culoare: `#666699` (Placeholder: `$colorTextPrimary` sau similar)
        -   Înălțime linie: `21px`
    -   **Alt Text Câmp (`Alt` în alt)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `15px` (Placeholder: `$fontSizeSmall` sau similar)
        -   Culoare: `#8A8AA8` (Placeholder: `$colorTextSecondary` sau similar)
        -   Înălțime linie: `19px`
    -   **Text Input (`Text` în input)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `17px` (Placeholder: `$fontSizeMedium` sau similar)
        -   Culoare: `#4D4D80` (Placeholder: `$colorTextInput` sau similar)
        -   Înălțime linie: `21px`
    -   **Text Buton (`Titlu` în buton)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `17px` (Placeholder: `$fontSizeMedium` sau similar)
        -   Culoare: `#666699` (Placeholder: `$colorTextPrimary` sau similar)
        -   Înălțime linie: `21px`

-   **Pictograme (`RetryIcon`, `ViewIcon`)**:
    -   **Dimensiune**: `24px` x `24px` (Placeholder: `$iconSizeMedium` sau similar)
    -   **Culoare (Stroke)**: `#666699` (Placeholder: `$colorTextPrimary` sau similar)
    -   **Grosime contur**: `2px` (Placeholder: `$borderWidthThin` sau similar)

## Stări

Stilurile CSS furnizate nu includ detalii specifice pentru stări interactive (hover, pressed, disabled). Se va presupune că aceste stări vor fi gestionate la nivel de widget Flutter folosind teme (`ElevatedButton.styleFrom`, `TextField.decoration`, etc.) și vor urma ghidurile generale de stilizare din `appTheme.dart` (e.g., opacitate redusă pentru `disabled`, culori alternative/umbre pentru `hover`/`pressed`).

## Responsivitate

Panoul are dimensiuni **fixe** (312px lățime, 1032px înălțime) în CSS. Acest lucru sugerează că nu este conceput pentru a se adapta fluid la diferite dimensiuni de ecran *prin redimensionare*, ci mai degrabă este destinat să fie afișat într-un container cu spațiu suficient sau să fie scrollabil dacă nu încape pe ecran. Proprietățile `align-self: stretch` și `flex-grow: 1` pe containerul principal `calculatorPane` vor face panoul să se extindă pentru a ocupa spațiul disponibil în containerul *părinte*, dar dimensiunile sale *intrinsice* sunt fixe. Elementele interne (formulare, inputuri) se adaptează la lățimea containerului panoului folosind `align-self: stretch` și `flex-grow: 0` (pentru lățime) sau `flex-grow: 1` (pentru elemente în rânduri orizontale).

## Animații

Nu sunt specificate animații sau tranziții în CSS-ul furnizat.

## Relații cu alte Componente

-   Este o componentă de tip `pane`, destinată să fie afișată modal sau într-o suprapunere (overlay).
-   Conține multiple `form` secțiuni, `inputField`-uri și butoane, sugerând o interacțiune intensă cu utilizatorul (introducere date, declanșare calcule).
-   Probabil interacționează cu logica de business pentru a procesa datele introduse și a afișa rezultatele calculelor.
-   Butoanele (`RetryIcon`, `ViewIcon`) sugerează acțiuni precum reluarea unui calcul sau vizualizarea rezultatelor.

## Implementare Flutter (sugestie)

Se va folosi un widget `Container` pentru `calculatorPane` cu `BoxDecoration` (color, borderRadius, boxShadow) și `padding: EdgeInsets.all(AppTheme.paddingSmall)`.
Layout-ul intern va fi un `Column` cu `mainAxisAlignment: MainAxisAlignment.spaceBetween` și `crossAxisAlignment: CrossAxisAlignment.start`. Spațiul între elementele principale poate fi adăugat cu `SizedBox(height: AppTheme.spacingSmall)` sau prin setarea `spacing` dacă se folosește un widget custom Column cu suport pentru gap.

Secțiunile interne (`section`, `form`) pot fi tot `Container`-e sau `Padding` + `Column`. `margin: 0 auto` pentru centrarea orizontală a `section` poate fi obținut prin wrap-uirea `Column`-ului interior într-un `Center` sau `Align(alignment: Alignment.topCenter)`.
`form`-ul va avea `BoxDecoration` cu culorile și rotunjirile specificate.

`header`, `row` și `buttonSection` vor fi `Row`-uri. Elementele cu `flex-grow: 1` (containerul titlului în header, inputField-urile în rânduri, butonul lat) vor fi wrap-uite în widget-uri `Expanded` sau `Flexible`.

Câmpurile de intrare (`inputField`) vor fi `Column`-uri. Textul (`Title`, `Alt`, `Text`) va folosi widget-uri `Text` cu `TextStyle` setat folosind `AppTheme.fontOutfit`, `AppTheme.fontWeight...`, `AppTheme.fontSize...`, `AppTheme.color...`.
Zona de input (`input`) poate fi un `Container` cu `BoxDecoration` care conține un `TextField` sau `TextFormField`. Padding-ul input-ului se aplică containerului exterior.

Butoanele pot fi implementate folosind `InkWell` sau `GestureDetector` wrap-uit pe un `Container` cu `BoxDecoration` și un `Row` interior pentru text și icon. Alternativ, pot fi folosite `ElevatedButton` sau `TextButton` cu un `ButtonStyle` customizat pentru a corespunde stilului dorit (padding, forma, culori), deși replicarea exactă a umbrelor și formelor poate necesita un widget custom.

Icoanele vor fi widget-uri `Icon` (dacă sunt din seturi predefinite) sau `SvgPicture.asset` (dacă sunt SVG-uri custom) cu dimensiunea setată la `AppTheme.iconSizeMedium` și culoarea la `AppTheme.colorTextPrimary`.

Toate dimensiunile, culorile, spațierile, rotunjirile și greutățile fonturilor vor fi preluate din `appTheme.dart`.