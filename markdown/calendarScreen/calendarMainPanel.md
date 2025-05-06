
Fișier: markdown_docs/calendarScreen/calendarMainPanel.md

# Panou Principal Calendar (calendarMainPanel.md)

## Descriere Generală
Acest panou conține widget-ul principal al calendarului, inclusiv header-ul cu titlul, selectorul de săptămână/lună, și grila calendarului. Este componenta centrală a ecranului `calendarScreen.md`.

**Referințe CSS principale:** `MainPanel` (ca și container pentru `CalendarWidget`), `CalendarWidget`, `WidgetHeader`, `Title` (textul "Calendar"), `CalendarSwitch`, `Button` (săgeți), `Text` (interval date), `CalendarContainer`, `CalendarDays`, text nume zile, `Calendar` (grila), `CalendarHours`, text ore, `Slots` (coloană zi), `AvailableSlot(Button)`, `ReservedSlot`.

---

### Element Părinte: Containerul Panoului Principal (`MainPanel` din CSS)

**Scop:** Containerul direct pentru `CalendarWidget`, definind dimensiunile și ordinea în layout-ul ecranului.

**CSS din Figma (fragment relevant):**
```css
/* MainPanel (containerul pentru CalendarWidget) */
display: flex;
flex-direction: column;
align-items: flex-start;
padding: 0px;
width: 1376px;
height: 1032px;
order: 1; /* Apare după SecondaryPanel */


Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Container sau direct CalendarWidget dacă acesta preia toate proprietățile.

Stil Container/Column:

width: 1376.0.

height: 1032.0 (sau Expanded dacă umple spațiul rămas în Row-ul părintelui).

Conține CalendarWidget.

1. Element: CalendarWidget

Scop: Containerul vizual principal pentru funcționalitatea de calendar, cu fundal și colțuri rotunjite. Conține header-ul și grila calendarului.

CSS din Figma:

/* CalendarWidget */
display: flex;
flex-direction: column;
align-items: center; /* Header și container calendar - posibil stretch pentru copii */
padding: 8px;
gap: 8px;
width: 1376px;
height: 1032px;
background: rgba(255, 255, 255, 0.5);
border-radius: 32px;
align-self: stretch;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Container cu Column în interior.

Stil Container:

padding: EdgeInsets.all(app_theme.gap.small).

decoration: BoxDecoration(

color: app_theme.colors.background_widget,

borderRadius: BorderRadius.circular(app_theme.borderRadius.large)

).

width: double.infinity (din align-self: stretch în contextul părintelui său).

height: probabil Expanded sau moștenită.

Layout Intern (Column):

crossAxisAlignment: CrossAxisAlignment.stretch (dedus din align-self: stretch pe copiii WidgetHeader și CalendarContainer).

SizedBox(height: app_theme.gap.small) între WidgetHeader și CalendarContainer.

Componente Conținute în CalendarWidget:
A. WidgetHeader
B. CalendarContainer

A. Element: WidgetHeader (în CalendarWidget)

Scop: Bara de antet a widget-ului calendar, conținând titlul și butoanele de navigare.

CSS din Figma:

/* WidgetHeader */
display: flex;
flex-direction: row;
justify-content: space-between;
align-items: center;
padding: 0px 8px;
width: 1360px; /* CalendarWidget width - 2 * padding */
height: 24px;
align-self: stretch;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Padding conținând Row.

Padding Widget:

padding: EdgeInsets.symmetric(horizontal: app_theme.gap.small).

Row Widget:

height: 24.0.

mainAxisAlignment: MainAxisAlignment.spaceBetween.

crossAxisAlignment: CrossAxisAlignment.center.

Componente Conținute în WidgetHeader:
i. Title (text "Calendar")
ii. CalendarSwitch

Scop: Afișează titlul "Calendar".

CSS din Figma:

/* Title (container) */
padding: 0px 8px;
width: 97px;
height: 24px;

/* Calendar (textul propriu-zis) */
font-family: 'Outfit';
font-weight: 600;
font-size: 19px;
color: #927B9D;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Padding în jurul unui Text widget.

Padding Widget:

padding: EdgeInsets.symmetric(horizontal: app_theme.gap.small).

Text Widget ("Calendar"):

text: "Calendar"

style: TextStyle(

fontFamily: app_theme.fontFamily,

fontWeight: app_theme.fontWeights.large,

fontSize: app_theme.fontSizes.large,

color: app_theme.colors.font_light_purple (sau o nouă variabilă font_title_purple pentru #927B9D)

)

Scop: Container pentru butoanele de navigare (stânga/dreapta) și textul cu intervalul de date.

CSS din Figma:

/* CalendarSwitch */
display: flex;
flex-direction: row;
align-items: center;
width: 208px;
height: 24px;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Row.

Stil Row:

width: 208.0.

height: 24.0.

mainAxisAlignment: MainAxisAlignment.spaceBetween (între butoane și textul central).

crossAxisAlignment: CrossAxisAlignment.center.

Componente Conținute în CalendarSwitch:
a. Button (Săgeată Stânga)
b. Text (Interval Date, ex: "20-24 Mai")
c. Button (Săgeată Dreapta)

Scop: Butoane icon pentru navigarea la săptămâna/luna anterioară/următoare.

CSS din Figma (similar pentru ambele):

/* Button */
padding: 0px 8px;
width: 40px;
height: 24px;

/* Arrow / Arrow_Left_SM (Icon) */
width: 24px;
height: 24px;

/* Vector (stilizare iconiță) */
/* border: 2px solid #927B9D; -- Definește culoarea iconiței */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: IconButton sau InkWell cu Icon.

Container Buton/IconButton:

padding: EdgeInsets.symmetric(horizontal: app_theme.gap.small) (dacă e pe containerul InkWell).

constraints: BoxConstraints(minWidth: 40.0, minHeight: 24.0).

Icon Widget:

icon: Icons.arrow_back_ios (sau arrow_forward_ios, sau icon custom).

size: app_theme.iconSizes.medium (24px).

color: app_theme.colors.font_light_purple (pentru #927B9D).

Scop: Afișează intervalul de date curent vizualizat în calendar.

CSS din Figma:

/* Text (container pentru data) */
width: 128px;
height: 24px;
justify-content: center; /* Aliniază textul intern la centru */

/* 20-24 Mai (textul propriu-zis) */
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
text-align: center;
color: #927B9D;
flex-grow: 1; /* Textul umple containerul său */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Expanded conținând un Container (pentru aliniere și dimensiuni) care conține Text. Sau SizedBox(width: 128.0, child: Center(child: Text(...))).

Container Text (dacă este folosit):

width: 128.0.

height: 24.0.

alignment: Alignment.center.

Text Widget (ex: "20-24 Mai"):

text: Dinamic, ex: "20-24 Mai"

textAlign: TextAlign.center.

style: TextStyle(

fontFamily: app_theme.fontFamily,

fontWeight: app_theme.fontWeights.medium,

fontSize: app_theme.fontSizes.small,

color: app_theme.colors.font_light_purple

)

B. Element: CalendarContainer (în CalendarWidget)

Scop: Containerul principal pentru grila calendarului, incluzând zilele săptămânii și sloturile orare.

CSS din Figma:

/* CalendarContainer */
display: flex;
flex-direction: column;
align-items: flex-start;
padding: 16px;
gap: 8px;
width: 1360px;
height: 984px;
background: #CFC4D4;
border-radius: 24px;
flex-grow: 1; /* Se întinde vertical */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Expanded conținând un Container cu Column în interior.

Container Stil:

padding: EdgeInsets.all(app_theme.gap.medium).

decoration: BoxDecoration(

color: app_theme.colors.background_light_purple,

borderRadius: BorderRadius.circular(app_theme.borderRadius.medium)

).

Layout Intern (Column):

crossAxisAlignment: CrossAxisAlignment.stretch (dedus din align-self: stretch pe CalendarDays și Calendar).

SizedBox(height: app_theme.gap.small) între CalendarDays și Calendar (grila).

Componente Conținute în CalendarContainer:
I. CalendarDays (Header-ul cu numele zilelor)
II. Calendar (Grila principală cu ore și sloturi)

Scop: Rândul de antet care afișează numele zilelor săptămânii.

CSS din Figma:

/* CalendarDays */
display: flex;
flex-direction: row;
gap: 16px; /* Spațierea între placeholder-ul orelor și prima zi */
width: 1328px;
height: 24px;
align-self: stretch;

/* Frame 94 (primul, placeholder pentru coloana orelor) */
/* padding: 0px 0px 0px 64px; -- Complex. Probabil un SizedBox pentru aliniere */
/* width: 48px; */

/* Frame 94 (al doilea, container pentru textele zilelor) */
/* display: flex; flex-direction: row; gap: 16px; */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Row.

Stil Row:

height: 24.0.

Elemente în Row:

SizedBox(width: 48.0) (Placeholder pentru a alinia cu coloana de ore CalendarHours).

SizedBox(width: app_theme.gap.medium) (Gap-ul de 16px).

Expanded(child: Row(children: [...lista de texte pentru zile...]))

Row intern pentru zile:

mainAxisAlignment: MainAxisAlignment.spaceBetween (sau start cu SizedBox între ele).

Fiecare text de zi este într-un SizedBox(width: 240.0) sau Expanded.

CSS din Figma (exemplu):

/* Luni 20 */
width: 240px;
height: 24px;
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
text-align: center;
color: #886699;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: SizedBox (sau Expanded dacă zilele sunt flexibile) conținând Text.

SizedBox (dacă e cu lățime fixă):

width: 240.0.

Text Widget:

text: "Luni 20" (dinamic)

textAlign: TextAlign.center.

style: TextStyle(

fontFamily: app_theme.fontFamily,

fontWeight: app_theme.fontWeights.medium,

fontSize: app_theme.fontSizes.small,

color: app_theme.colors.font_medium_purple

)

Scop: Containerul scrollabil care afișează coloana orelor și coloanele cu sloturile pentru fiecare zi.

CSS din Figma:

/* Calendar (grila scrollabilă) */
display: flex;
flex-direction: row;
gap: 16px; /* Spațiu între coloana orelor și prima coloană de zi */
width: 1328px;
height: 920px; /* Înălțimea efectivă. Va fi scrollabilă dacă e necesar. */
overflow-y: scroll;
flex-grow: 1; /* Se întinde vertical în CalendarContainer */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Expanded (din flex-grow: 1) conținând un SingleChildScrollView(scrollDirection: Axis.vertical) care la rândul său conține un Row.

Row (pentru ore și coloanele zilelor):

crossAxisAlignment: CrossAxisAlignment.start.

Elemente în Row:

CalendarHours widget.

SizedBox(width: app_theme.gap.medium) (Gap-ul de 16px).

Expanded(child: Row(children: [...lista de coloane Slots...]))

Row intern pentru coloanele de zile (Slots):

mainAxisAlignment: MainAxisAlignment.spaceBetween (sau start cu SizedBox).

Fiecare element este un widget Slots (coloană de zi).

Scop: Coloana din stânga care afișează intervalele orare.

CSS din Figma:

/* CalendarHours */
display: flex;
flex-direction: column;
padding: 8px 0px;
gap: 56px; /* Spațierea mare între textele orelor */
width: 48px;
/* height: 1080px; -- Înălțimea va fi dată de conținut în contextul scroll-ului */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Container cu Padding și Column în interior.

Container:

width: 48.0.

Padding:

padding: EdgeInsets.symmetric(vertical: app_theme.gap.small).

Column (pentru lista de ore):

crossAxisAlignment: CrossAxisAlignment.center (deoarece textul orelor e centrat).

Elementele sunt texte de ore, separate de SizedBox(height: 56.0) (valoare mare, poate app_theme.gap.huge + app_theme.gap.large sau o nouă variabilă gap_xlarge).

Textele Orelor (ex: "09:30"):

CSS:

/* 09:30 */
width: 48px;
height: 24px;
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
text-align: center;
color: #886699;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare Flutter:

SizedBox(width: 48.0, height: 24.0, child: Center(child: Text(...))).

Text widget: "09:30" (dinamic), textAlign: TextAlign.center, stil app_theme.fontFamily, app_theme.fontWeights.medium, app_theme.fontSizes.small, app_theme.colors.font_medium_purple.

Scop: Reprezintă o coloană verticală pentru o singură zi, conținând sloturi disponibile sau rezervate.

CSS din Figma (structura unei coloane):

/* Slots (container pentru o coloană de zi) */
/* width: 240px; -- Lățimea unei coloane de zi */
/* height: 920px; -- Înălțimea totală a zonei de sloturi, va fi dată de conținutul scrollabil */

/* Column (containerul real al sloturilor pentru o zi) */
display: flex;
flex-direction: column;
gap: 16px; /* Spațierea verticală între sloturi */
width: 240px;
border-radius: 8px; /* Colțuri rotunjite pentru întreaga coloană de sloturi */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat pentru o coloană de zi (Slots): Container (pentru lățime și border-radius) conținând un Column (sau ListView.builder dacă sloturile individuale ar putea deveni scrollabile în cadrul coloanei, deși scroll-ul principal e pe întreaga grilă).

Container Stil:

width: 240.0.

decoration: BoxDecoration(borderRadius: BorderRadius.circular(app_theme.borderRadius.tiny)).

Layout Intern (Column):

Elementele sunt widget-uri AvailableSlot sau ReservedSlot.

SizedBox(height: app_theme.gap.medium) între sloturi.

Scop: Un interval orar disponibil, acționabil ca un buton.

CSS din Figma:

/* AvailableSlot(Button) */
padding: 6px 16px;
width: 240px;
height: 64px;
border: 4px solid #C6ACD3;
border-radius: 16px;
align-self: stretch;

/* CreateSlot (Textul din AvailableSlot) */
font-family: 'Outfit';
font-weight: 600;
font-size: 17px;
color: #886699;
text-align: center;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: SizedBox (pentru dimensiuni) conținând un OutlinedButton sau InkWell cu Container stilizat.

Container/Stil Buton:

width: double.infinity (din align-self: stretch).

height: 64.0.

padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: app_theme.gap.medium). (6.0 e app_theme.gap.tiny + 2px).

Stil OutlinedButton.styleFrom sau BoxDecoration:

side: BorderSide(color: app_theme.colors.background_dark_purple, width: 4.0) (4.0 e app_theme.gap.tiny).

shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(app_theme.borderRadius.small)).

Text Widget ("CreateSlot" etc.):

text: "Creează Programare" (dinamic)

textAlign: TextAlign.center.

Stil: app_theme.fontFamily, app_theme.fontWeights.large, app_theme.fontSizes.medium, app_theme.colors.font_medium_purple.

Scop: Un interval orar rezervat, afișând detalii.

CSS din Figma:

/* ReservedSlot */
padding: 6px 16px;
width: 240px;
height: 64px;
background: #C6ACD3;
box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.25);
border-radius: 16px;
align-self: stretch;

/* Consultant (Text) */
font-family: 'Outfit';
font-weight: 600;
font-size: 17px;
color: #7C568F;

/* Client (Text) */
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
color: #886699;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Container cu Column în interior.

Stil Container:

width: double.infinity (din align-self: stretch).

height: 64.0.

padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: app_theme.gap.medium).

decoration: BoxDecoration(

color: app_theme.colors.background_dark_purple,

borderRadius: BorderRadius.circular(app_theme.borderRadius.small),

boxShadow: [app_theme.shadows.calendarReservedSlotShadow]

).

Layout Intern (Column):

mainAxisAlignment: MainAxisAlignment.center.

crossAxisAlignment: CrossAxisAlignment.start (sau center dacă textele sunt centrate).

Text Widget ("Consultant"):

Stil: app_theme.fontFamily, app_theme.fontWeights.large, app_theme.fontSizes.medium, app_theme.colors.font_dark_purple (sau o nuanță specifică pentru #7C568F).

Text Widget ("Client"):

Stil: app_theme.fontFamily, app_theme.fontWeights.medium, app_theme.fontSizes.small, app_theme.colors.font_medium_purple.
