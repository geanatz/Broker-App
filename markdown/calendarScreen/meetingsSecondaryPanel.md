---

**Fișier: `markdown_docs/calendarScreen/meetingsSecondaryPanel.md`**

```markdown
# Panou Secundar Întâlniri (meetingsSecondaryPanel.md)

## Descriere Generală
Acest panou servește ca un sidebar în ecranul Calendar, destinat afișării unei liste de întâlniri viitoare sau relevante. Include un titlu și o serie de "câmpuri" (Fields) care reprezintă fiecare întâlnire individuală.
Este plasat în `calendarScreen.md` alături de `calendarMainPanel.md`.

**Referințe CSS principale:** `SecondaryPanel` (pentru contextul în ecran), `MeetingsWidget`, `Header`, `Container` (pentru lista de field-uri), `Field`.

---

### Context în Ecran (`SecondaryPanel` din CSS)

**Scop:** Definește poziționarea și dimensiunile generale ale acestui panou în cadrul ecranului principal `calendarScreen`.

**CSS din Figma (`SecondaryPanel`):**
```css
/* SecondaryPanel */
width: 224px;
height: 1032px;
order: 0; /* Apare înaintea MainPanel-ului calendarului */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme (pentru containerul acestui panou):

Widget Sugerat: Container sau SizedBox.

Stil Container:

width: 224.0.

height: 1032.0 (sau Expanded dacă umple înălțimea părintelui).

Conține MeetingsWidget.

1. Element: MeetingsWidget (Widget-ul principal al panoului)

Scop: Containerul principal pentru conținutul panoului de întâlniri, cu fundal, umbră și colțuri rotunjite.

CSS din Figma:

/* MeetingsWidget */
display: flex;
flex-direction: column;
align-items: flex-start;
padding: 8px;
gap: 8px;
width: 224px;
height: 1032px;
background: rgba(255, 255, 255, 0.5);
box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
border-radius: 32px;
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

borderRadius: BorderRadius.circular(app_theme.borderRadius.large),

boxShadow: [app_theme.shadows.widgetShadow]

).

width: 224.0, height: 1032.0 (sau Expanded).

Layout Intern (Column):

crossAxisAlignment: CrossAxisAlignment.stretch (dedus din align-self: stretch pe copii).

SizedBox(height: app_theme.gap.small) între Header și Container (lista de field-uri).

Componente Conținute în MeetingsWidget:
A. Header
B. Container (pentru lista de Field-uri)

A. Element: Header (în MeetingsWidget)

Scop: Bara de antet a widget-ului de întâlniri, conținând titlul.

CSS din Figma:

/* Header */
display: flex;
flex-direction: row;
align-items: center;
padding: 0px 16px; /* Padding orizontal pentru titlu */
width: 208px; /* Lățimea internă după padding-ul MeetingsWidget */
height: 24px;
align-self: stretch;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Padding conținând Row (sau direct Text dacă titlul e singurul element și e Expanded).

Padding Widget:

padding: EdgeInsets.symmetric(horizontal: app_theme.gap.medium).

Row/Container intern:

height: 24.0.

Componente Conținute în Header:
i. Title (Textul titlului)

Scop: Afișează titlul panoului (ex: "Întâlniri Programate").

CSS din Figma:

/* Title */
/* width: 176px; -- Lățimea e dată de flex-grow */
height: 24px;
font-family: 'Outfit';
font-weight: 600;
font-size: 19px;
color: #927B9D;
flex-grow: 1; /* Titlul se extinde */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Expanded conținând Text.

Text Widget:

text: "Întâlniri" (sau similar, dinamic)

style: TextStyle(

fontFamily: app_theme.fontFamily,

fontWeight: app_theme.fontWeights.large,

fontSize: app_theme.fontSizes.large,

color: app_theme.colors.font_light_purple (sau font_title_purple pentru #927B9D)

)

overflow: TextOverflow.ellipsis.

B. Element: Container (Lista de Field-uri în MeetingsWidget)

Scop: Containerul care ține lista scrollabilă de elemente individuale de întâlnire (Field).

CSS din Figma:

/* Container (pentru lista de field-uri) */
display: flex;
flex-direction: column;
gap: 8px; /* Spațiere între Field-uri */
width: 208px; /* Lățimea internă după padding-ul MeetingsWidget */
height: 472px; /* Înălțime specifică; dacă e mai mult conținut, ar trebui scrollabil */
align-self: stretch;
/* flex-grow: 0; -- Poate fi 1 dacă trebuie să umple spațiul vertical rămas */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: SizedBox (dacă înălțimea e fixă 472.0) sau Expanded (dacă flex-grow:1) conținând un ListView.builder sau SingleChildScrollView cu Column.

SizedBox/Expanded:

width: double.infinity (din align-self: stretch).

Layout Intern (ListView sau Column în SingleChildScrollView):

itemBuilder pentru ListView va returna widget-uri Field.

separatorBuilder pentru ListView (sau SizedBox în Column) pentru SizedBox(height: app_theme.gap.small).

Componente Conținute (repetitiv):
- Multiple Field (elemente de întâlnire)

Scop: Reprezintă un card individual pentru o întâlnire, afișând ora, data, titlul și descrierea.

CSS din Figma (pentru un singur Field):

/* Field */
display: flex;
flex-direction: column;
align-items: flex-start;
padding: 8px 16px;
width: 208px;
height: 88px;
background: #CFC4D4;
border-radius: 24px;
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

padding: EdgeInsets.symmetric(vertical: app_theme.gap.small, horizontal: app_theme.gap.medium).

width: double.infinity (din align-self: stretch).

height: 88.0.

decoration: BoxDecoration(

color: app_theme.colors.background_light_purple,

borderRadius: BorderRadius.circular(app_theme.borderRadius.medium)

).

Layout Intern (Column):

crossAxisAlignment: CrossAxisAlignment.stretch.

Conține Hour&Date și apoi Title&Description. Spațierea dintre ele e probabil 0 sau gestionată de padding-ul intern al acestora.

Componente Conținute în Field:
i. Hour&Date
ii. Title&Description

Scop: Rândul superior din cardul Field, afișând ora și data întâlnirii.

CSS din Figma:

/* Hour&Date */
display: flex;
flex-direction: row;
/* justify-content: center; -- E mai degrabă space-between dat de flex-grow pe copii */
gap: 10px; /* Spațiu între Hour și Date, gestionat de Row și Expanded */
width: 176px; /* Lățimea internă a Field (208 - 2*16) */
height: 24px;
align-self: stretch;
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

mainAxisAlignment: MainAxisAlignment.spaceBetween.

crossAxisAlignment: CrossAxisAlignment.center.

Elemente: Expanded(child: Text(Hour)) și Expanded(child: Text(Date, textAlign: TextAlign.end)).

Text Hour:

/* Hour */
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
color: #927B9D;
flex-grow: 1;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare Text Hour:

Expanded(child: Text("10:00", style: TextStyle(fontFamily: app_theme.fontFamily, fontWeight: app_theme.fontWeights.medium, fontSize: app_theme.fontSizes.small, color: app_theme.colors.font_light_purple)))

Text Date:

/* Date */
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
text-align: right;
color: #927B9D;
flex-grow: 1;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare Text Date:

Expanded(child: Text("23 Mai", textAlign: TextAlign.end, style: TextStyle(fontFamily: app_theme.fontFamily, fontWeight: app_theme.fontWeights.medium, fontSize: app_theme.fontSizes.small, color: app_theme.colors.font_light_purple)))

Scop: Secțiunea inferioară din cardul Field, afișând titlul și descrierea întâlnirii.

CSS din Figma:

/* Title&Description */
display: flex;
flex-direction: column;
justify-content: center; /* Centrează vertical cele două texte */
/* align-items: center; -- Mai degrabă stretch/start */
width: 176px; /* Lățimea internă a Field */
height: 48px; /* Înălțimea rămasă în Field */
align-self: stretch;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare pentru Flutter / Variabile AppTheme:

Widget Sugerat: Column.

Stil Column:

height: 48.0.

mainAxisAlignment: MainAxisAlignment.center.

crossAxisAlignment: CrossAxisAlignment.stretch.

Elemente: Text Title și Text Description.

Text Title (al întâlnirii):

/* Title (meeting) */
font-family: 'Outfit';
font-weight: 600;
font-size: 17px;
color: #886699;
/* align-self: stretch; -- implicit într-un Column cu crossAxis.Stretch */
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare Text Title:

Text("Nume Client / Tip Întâlnire", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: app_theme.fontFamily, fontWeight: app_theme.fontWeights.large, fontSize: app_theme.fontSizes.medium, color: app_theme.colors.font_medium_purple))

Text Description (al întâlnirii):

/* Description (meeting) */
font-family: 'Outfit';
font-weight: 500;
font-size: 15px;
color: #927B9D;
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Css
IGNORE_WHEN_COPYING_END

Interpretare Text Description:

Text("Detalii scurte / Nume agent", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: app_theme.fontFamily, fontWeight: app_theme.fontWeights.medium, fontSize: app_theme.fontSizes.small, color: app_theme.colors.font_light_purple))