# Sidebar Pane (sidebarPane.md)

## Descriere Generală

Acest document descrie stilizarea și structura componentei 'Sidebar Pane', panoul lateral de navigație persistent al aplicației. Acesta conține secțiuni distincte pentru informațiile consultantului, funcții rapide, navigare către arii principale și navigare către panouri modulare.

## Layout și Dimensiuni

Componenta principală (`sidebar`) este un container vertical care aliniază elementele pe centru pe orizontală, cu padding interior și spațiu între elemente. Conține patru secțiuni principale: `consultantSection`, `functionSection`, `areaSection` și `paneSection`.

-   **Container Principal (`sidebar`)**:
    -   **Layout**: `Column` (flex-direction: column)
    -   **Aliniere**: Items aliniate pe centru pe axa transversală (crossAxisAlignment: CrossAxisAlignment.center).
    -   **Padding**: 8px pe toate laturile. Se va folosi variabila `$paddingSmall`.
    -   **Gap**: 16px între elementele principale (secțiuni). Se va folosi variabila `$spacingMedium`.
    -   **Dimensiuni**: Lățime fixă de 224px, înălțime fixă de 1032px. Aceste dimensiuni fixe sunt probabil destinate unui layout specific (e.g., desktop/tabletă pe o rezoluție țintă) și sugerează că panoul ocupă o porțiune fixă din lățime și înălțime.
    -   **Flex Properties (în contextul containerului părinte)**: `align-self: stretch` (va încerca să ocupe toată înălțimea disponibilă a containerului părinte), `flex-grow: 0` (nu se va extinde pe verticală peste înălțimea fixă specificată). `order: 2` indică poziția sa în layout-ul părinte.

-   **Secțiuni Interne (`consultantSection`, `functionSection`, `areaSection`, `paneSection`)**:
    -   Toate secțiunile folosesc `align-self: stretch` pentru a ocupa toată lățimea disponibilă în sidebar (224px - 2*8px padding = 208px).
    -   Au `flex-grow: 0`, indicând dimensiuni fixe specificate.
    -   **`consultantSection`**:
        -   **Layout**: `Row` (flex-direction: row)
        -   **Aliniere**: Items aliniate pe centru pe axa transversală (`align-items: center`).
        -   **Padding**: 8px top/bottom/right, 16px left. Se va folosi `EdgeInsets.fromLTRB(AppTheme.paddingMedium, AppTheme.paddingSmall, AppTheme.paddingSmall, AppTheme.paddingSmall)`.
        -   **Gap**: 16px între elemente. Se va folosi variabila `$spacingMedium`.
        -   **Dimensiuni**: Lățime 208px, Înălțime 64px.
        -   Conține un container `about` (Column) și un `button` (Row cu icon). Containerul `about` are `flex-grow: 1` pentru a ocupa spațiul disponibil orizontal.
    -   **`functionSection`**:
        -   **Layout**: `Row` (flex-direction: row)
        -   **Aliniere**: Items aliniate la început pe axa transversală (`align-items: flex-start`). (Notă: CSS-ul arată un singur buton centrat pe verticală în el, deci alinierea `flex-start` pe containerul părinte nu are efect vizibil cu un singur copil).
        -   **Padding**: 0px.
        -   **Gap**: 8px între elemente (dacă ar fi mai multe butoane). Se va folosi variabila `$spacingSmall`.
        -   **Dimensiuni**: Lățime 208px, Înălțime 48px.
        -   Conține un singur `button` care are `flex-grow: 1` și ocupă întreaga lățime.
    -   **`areaSection` și `paneSection`**:
        -   **Layout**: `Column` (flex-direction: column)
        -   **Aliniere**: Items aliniate la început pe axa transversală (`align-items: flex-start`).
        -   **Padding**: 0px.
        -   **Gap**: 8px între elemente. Se va folosi variabila `$spacingSmall`.
        -   **Dimensiuni**: Lățime 208px, Înălțime 248px.
        -   Fiecare conține un `header` (Row) și un container `sizedBox` (Column) care găzduiește lista de butoane. `sizedBox` are gap de 8px între butoane.

-   **Header Secțiune (`header` în `areaSection`, `paneSection`)**:
    -   **Layout**: `Row`
    -   **Aliniere**: Items aliniate pe centru vertical.
    -   **Padding**: 0px vertical, 16px orizontal. Se va folosi `EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium)`.
    -   **Dimensiuni**: Înălțime fixă de 24px. Ocupă toată lățimea secțiunii părinte (208px). Conține un container `title` cu `flex-grow: 1`.

-   **Butoane (`button` în diverse secțiuni)**:
    -   Diverse layout-uri interne (`Row` cu justificare/aliniere).
    -   Padding variabil: 16px (User button), 12px vertical/16px orizontal (Function button), 0px vertical/16px orizontal (Area/Pane buttons). Map to `$padding...` or custom values.
    -   Gap variabil între conținutul butonului: 8px sau 16px. Map to `$spacing...`.
    -   Dimensiuni fixe: 48x48px (User button), 208x48px (Function, Area, Pane buttons).
    -   `flex-grow` variabil: 0 (User button), 1 (Function button, Text în Area/Pane buttons).
    -   Au culori de fundal și border radius specifice.

## Elemente de Interfață

Componenta conține următoarele tipuri de elemente:

-   Container principal (Sidebar)
-   Secțiune Consultant (`consultantSection`)
    -   Container Informații Consultant (`about`)
        -   Nume Consultant (Text - `Titlu`)
        -   Descriere Consultant (Text - `Descriere`)
    -   Buton Profil Consultant (cu Icon - `UserIcon`)
-   Secțiune Funcții (`functionSection`)
    -   Buton Funcție (cu Icon - `meetingIcon`. Notă: CSS-ul furnizat arată un singur buton aici, deși secțiunea poate conține logic mai multe butoane pentru diverse funcții rapide ca `clientsPopup`).
-   Secțiuni Listă Navigare (`areaSection`, `paneSection`)
    -   Header Secțiune
        -   Titlu Secțiune (Text - Placeholder "Titlu")
    -   Container Butoane Listă
        -   Butoane Navigare (Text + Icon)
            -   Text Buton Navigare (e.g., "Dashboard", "Clienti")
            -   Icon Buton Navigare (e.g., `DashboardIcon`, `ClientIcon`)

## Stilizare Detaliată

Stilizarea folosește pe cât posibil variabile din `app_theme.dart`.

-   **Container Principal (`sidebar`)**:
    -   **Fundal**: `rgba(255, 255, 255, 0.5)` (Placeholder: `$backgroundColorSidebarSemiTransparent`)
    -   **Umbră**: `0px 0px 15px rgba(0, 0, 0, 0.1)` (Placeholder: `$shadowPane` sau similar)
    -   **Rotunjire colțuri**: `32px` (Placeholder: `$borderRadiusLarge`)
    -   **Padding interior**: `8px` (Placeholder: `$paddingSmall`)
    -   **Spațiu între copii**: `16px` (Placeholder: `$spacingMedium`)

-   **Secțiuni (`consultantSection`, `functionSection`, `areaSection`, `paneSection`)**:
    -   **Fundal**: `#C4C4D4` (Placeholder: `$backgroundColorCard` sau similar)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**: Varibil (vezi secțiunea Layout și Dimensiuni).

-   **Buton Profil Consultant (`button` în `consultantSection`)**:
    -   **Fundal**: `#ACACD3` (Placeholder: `$backgroundColorItem` sau similar)
    -   **Rotunjire colțuri**: `16px` (Placeholder: `$borderRadiusSmall`)
    -   **Padding interior**: `16px` pe toate laturile (Placeholder: `EdgeInsets.all($paddingMedium)`)
    -   **Spațiu între conținut**: `8px` (Placeholder: `$spacingSmall`)

-   **Buton Funcție (`button` în `functionSection`)**:
    -   **Fundal**: `#C4C4D4` (Placeholder: `$backgroundColorCard`)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**: `12px` vertical, `16px` orizontal (Placeholder: `EdgeInsets.symmetric(vertical: $spacing12, horizontal: $paddingMedium)`)
    -   **Spațiu între conținut**: `8px` (Placeholder: `$spacingSmall`)

-   **Butoane Navigare (`button` în `areaSection`, `paneSection`)**:
    -   **Fundal**: `#C4C4D4` (Placeholder: `$backgroundColorCard`)
    -   **Rotunjire colțuri**: `24px` (Placeholder: `$borderRadiusMedium`)
    -   **Padding interior**: `0px` vertical, `16px` orizontal (Placeholder: `EdgeInsets.symmetric(horizontal: $paddingMedium)`)
    -   **Spațiu între text și icon**: `16px` (Placeholder: `$spacingMedium`)

-   **Text/Tipografie**:
    -   **Font Family**: Outfit (`AppTheme.fontOutfit`)
    -   **Nume Consultant (`Titlu` în `about`)**:
        -   Greutate font: `600` (Placeholder: `$fontWeightSemiBold`)
        -   Mărime font: `17px` (Placeholder: `$fontSizeMedium` sau similar)
        -   Culoare: `#666699` (Placeholder: `$colorTextPrimary`)
        -   Înălțime linie: `21px`
    -   **Descriere Consultant (`Descriere` în `about`)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `15px` (Placeholder: `$fontSizeSmall` sau similar)
        -   Culoare: `#8A8AA8` (Placeholder: `$colorTextSecondary`)
        -   Înălțime linie: `19px`
    -   **Titlu Secțiune Navigare (`Titlu` în header)**:
        -   Greutate font: `600` (Placeholder: `$fontWeightSemiBold`)
        -   Mărime font: `19px` (Placeholder: `$fontSizeLarge` sau similar)
        -   Culoare: `#8A8AA8` (Placeholder: `$colorTextSecondary`)
        -   Înălțime linie: `24px`
    -   **Text Buton Navigare (`Dashboard`, `Clienti`, etc.)**:
        -   Greutate font: `500` (Placeholder: `$fontWeightMedium`)
        -   Mărime font: `17px` (Placeholder: `$fontSizeMedium` sau similar)
        -   Culoare: `#666699` (Placeholder: `$colorTextPrimary`)
        -   Înălțime linie: `21px`

-   **Pictograme (`UserIcon`, `meetingIcon`, `DashboardIcon`, etc.)**:
    -   **Dimensiune**: `24px` x `24px` (Placeholder: `$iconSizeMedium` sau similar)
    -   **Culoare (Stroke)**: `#4D4D80` (UserIcon) sau `#666699` (celelalte iconițe). (Placeholders: `$colorTextInput` și `$colorTextPrimary` sau similar).
    -   **Grosime contur**: `2px` (Placeholder: `$borderWidthThin` sau similar)

## Stări

Stilurile CSS furnizate nu includ detalii specifice pentru stări interactive (hover, pressed, selected, disabled). Se va presupune că butoanele vor avea stări vizuale (e.g., schimbarea culorii de fundal sau a textului/iconiței când sunt selectate sau apăsate) care vor fi gestionate la nivel de widget Flutter (ex: `ButtonStyle` pentru `ElevatedButton`, gestionarea manuală pentru `InkWell`) și vor urma ghidurile generale de stilizare din `app_theme.dart`.

## Responsivitate

Sidebar-ul are dimensiuni **fixe** (224px lățime, 1032px înălțime). Aceasta îl face potrivit pentru layout-uri cu spațiu orizontal suficient (e.g., desktop, tablete în mod landscape). Pe ecrane mai mici (telefoane, tablete în mod portrait), un sidebar fix cu lățime considerabilă ar ocupa prea mult spațiu. Implementarea pe ecrane mici ar trebui să folosească probabil un `Drawer` (sertar lateral) care se deschide peste conținutul principal.
Înălțimea fixă de 1032px este destul de mare și sugerează că sidebar-ul ar putea fi scrollabil pe verticală dacă conținutul său total depășește înălțimea reală a containerului părinte pe ecran. Proprietatea `align-self: stretch` pe sidebar-ul însuși (în contextul părinte) și pe secțiunile interne (în contextul sidebar-ului) ajută la umplerea spațiului vertical disponibil.

## Animații

Nu sunt specificate animații sau tranziții în CSS-ul furnizat. Tranzitiile standard de hover/press pentru butoane vor fi implementate în Flutter.

## Relații cu alte Componente

-   Este un panou `pane` permanent, parte a structurii principale a ecranului (`screen`).
-   Secțiunea `consultantSection` interacționează probabil cu paginile/pop-up-urile legate de profilul și setările consultantului.
-   Secțiunea `functionSection` (cu un singur buton `meetingIcon` în CSS) ar putea extinsă pentru a include butoane de acces rapid la funcționalități comune (e.g., adaugă client nou, creează întâlnire rapidă). Menționarea `clientsPopup` în descriere sugerează că aici ar putea fi un buton pentru a deschide acel popup.
-   Secțiunile `areaSection` și `paneSection` conțin butoane care servesc drept navigație principală către diverse `areas` (Formular, Calendar, Setări, Dashboard) și `panes`/`popups` (Clienti, Intalniri, Calculator, Recomandare). Apăsarea acestor butoane va schimba conținutul principal al ecranului sau va afișa panouri/popup-uri suprapuse.

## Implementare Flutter (sugestie)

Sidebar-ul poate fi implementat ca un widget `Container` wrap-uit într-un widget de layout (e.g., `SizedBox` cu lățimea `224.0`) plasat într-un `Row` sau `Stack` (pentru popup-uri) al ecranului principal. `Container`-ul va avea `BoxDecoration` pentru fundal (`AppTheme.backgroundColorSidebarSemiTransparent`), umbră (`AppTheme.shadowPane`) și rotunjire (`AppTheme.borderRadiusLarge`), precum și padding-ul `EdgeInsets.all(AppTheme.paddingSmall)`.
Layout-ul intern va fi un `Column` cu `crossAxisAlignment: CrossAxisAlignment.center` și `spacing: AppTheme.spacingMedium` între elementele principale. Dacă înălțimea totală a secțiunilor depășește înălțimea fixă a sidebar-ului, `Column`-ul trebuie wrap-uit într-un `SingleChildScrollView`.

Fiecare secțiune (`consultantSection`, `functionSection`, `areaSection`, `paneSection`) va fi un `Container` (sau widget de layout corespunzător) cu lățime fixă (`208.0`), înălțime fixă, `BoxDecoration` (background, radius) și padding-ul specificat. Se va folosi `Align(alignment: Alignment.topCenter, child: ...)` sau similar pentru a centra conținutul secțiunilor pe orizontală în cadrul sidebar-ului (sau pur și simplu lăsați `crossAxisAlignment: CrossAxisAlignment.center` pe `Column`-ul părinte).

Secțiunea `consultantSection` va fi un `Row` cu `mainAxisAlignment: MainAxisAlignment.spaceBetween` și `crossAxisAlignment: CrossAxisAlignment.center`. Conține un `Expanded` (pentru containerul `about`) și un `Container` sau `SizedBox` cu un widget `InkWell` sau `GestureDetector` pentru butonul cu iconița. Containerul `about` va fi un `Column` cu text widgets.

Secțiunile `areaSection` și `paneSection` vor fi `Column`-uri. Header-ul va fi un `Row` cu un `Expanded` wrap-uind textul titlului. Containerul butoanelor (`sizedBox`) va fi un `Column` cu spațiu (`spacing: AppTheme.spacingSmall`) între butoane.

Butoanele de navigare (`button` în `areaSection`, `paneSection`) vor fi implementate ca `InkWell` sau `GestureDetector` wrap-uit pe un `Container` cu `BoxDecoration` (background, radius, padding) și un `Row` interior. `Row`-ul interior va avea `mainAxisAlignment: MainAxisAlignment.spaceBetween`, `crossAxisAlignment: CrossAxisAlignment.center` și `spacing: AppTheme.spacingMedium`. Textul butonului va fi un `Expanded` `Text` widget, iar iconița va fi un widget `Icon` sau `SvgPicture.asset` cu dimensiunea `AppTheme.iconSizeMedium` și culoarea corespunzătoare (`AppTheme.colorTextInput` sau `AppTheme.colorTextPrimary`).

Toate dimensiunile, culorile, spațierile, rotunjirile și greutățile fonturilor vor fi preluate din `app_theme.dart`.