# Contact List Popup

## Descriere
Acest popup servește multiple scopuri legate de gestionarea contactelor:
1.  Afișarea listei de contacte existente.
2.  Editarea unui contact selectat.
3.  Crearea unui nou contact.
4.  Extragerea contactelor din imagini (OCR) și previzualizarea/salvarea lor.

Popup-ul își schimbă layout-ul și conținutul în funcție de starea curentă.

## Apartenență
- Este un tip de: `popup`
- Deschis de: Butonul `OpenRecommendButton` din `sidebar.md` (sau alt buton relevant).

## Layout General Popup (`ContactListPopup` wrapper)
- **Descriere**: Containerul principal al popup-ului, care poate conține unul, două sau trei paneluri verticale.
- **Layout**:
    - Tip: Flex container
    - Direcție Flex: Row (orizontal)
    - Justify Content: Center
    - Align Items: Flex-start
    - Gap între paneluri: `medium` (16px)
- **Dimensionare și Poziționare**:
    - Variază în funcție de stare (ex: `width: 672px`, `width: 296px`, `width: 984px`)
    - Poziție: Absolută, centrată pe ecran.
      *Notă pentru Cursor AI: În Flutter, folosiți `Stack` cu `Align` sau `Center`, sau un `Dialog` standard.*

---

## Stare 1: Vizualizare Listă și Editare/Creare (Layout cu 2 Paneluri)
- **Descriere**: Afișează lista de contacte în stânga și un formular de editare (dacă un contact e selectat) sau creare (dacă se apasă "Adaugă") în dreapta.
- **Dimensionare Totală Popup**: `width: 672px`, `height: 432px`

### 1. Panel Stânga - Lista Contacte (`PopupPanel`)
- **Descriere**: Afișează lista principală de contacte și butoane de acțiune generale.
- **Layout Panel**: Column, Justify: Space-between, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare Panel**: Lățime `360px`, Înălțime `432px`
- **Styling Panel**: Fundal `background_popup` (#D9D9D9), Umbră `widgetShadow`, Rază Bordură `large` (32px)

#### 1.1. Secțiune Superioară Lista (Section)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `344px`, Înălțime `360px`

##### 1.1.1. Antet Lista (Header)
- **Text Titlu ("Lista contacte")**: Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

##### 1.1.2. Container Listă Contacte (List)
- **Descriere**: Zona scrollabilă (presupusă) care conține elementele individuale.
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `344px`, Înălțime `328px`
- **Comportament**: *Ar trebui să fie `overflow-y: scroll`.*

###### 1.1.2.1. Element Listă Contact (Item)
- **Descriere**: Reprezintă un singur contact în listă. Structura se repetă.
- **Layout**: Row, Justify: Space-between, Align Items: Center, Padding: `12px 8px`, Gap: `medium` (16px)
- **Dimensionare**: Lățime `344px`, Înălțime `48px`
- **Styling**:
    - **Stare Selectată**: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px)
        - Text Nume: Culoare `#7C568F (font_dark_purple_variant)`
        - Text Telefon: Culoare `font_medium_purple (#886699)`
    - **Stare Inactivă**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
        - Text Nume: Culoare `font_medium_purple (#886699)`
        - Text Telefon: Culoare `#927B9D (font_light_purple_variant)`
- **Elemente Interne**:
    - **Nume Contact (Name)**: Styling: `font-weight: 600 (large); font-size: 17px (medium);`
    - **Număr Telefon (PhoneNumber)**: Styling: `font-weight: 500 (medium); font-size: 15px (small); text-align: right;`

#### 1.2. Secțiune Inferioară Acțiuni Listă (Section)
- **Layout**: Row, Align Items: Flex-end, Gap: `small` (8px)
- **Dimensionare**: Lățime `344px`, Înălțime `48px`

##### 1.2.1. Buton Adaugă Contact (Button - AddUserIcon)
- **Acțiune**: Probabil comută panelul din dreapta în modul "Creează Contact".
- **Layout**: Row, Align Items: Center, Padding: `medium` (12px), Gap: `medium` (10px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Iconiță**: `AddUserIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`

##### 1.2.2. Buton Extrage Contacte (Button - ImageIcon)
- **Acțiune**: Comută popup-ul în Starea 2 (Extracting Contacts).
- **Layout**: Row, Justify/Align Center, Padding: `12px 27px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `232px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Elemente**:
    - **Iconiță**: `ImageIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`
    - **Text ("Extrage contacte")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699);`

##### 1.2.3. Buton Șterge Contact (Button - DeleteIcon)
- **Acțiune**: Șterge contactul selectat din listă (necesită o selecție activă).
- **Layout**: Row, Align Items: Center, Padding: `medium` (12px), Gap: `medium` (10px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Iconiță**: `DeleteIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`

### 2. Panel Dreapta - Formular Editare/Creare (`PopupPanel`)
- **Descriere**: Afișează fie formularul de editare pentru contactul selectat, fie formularul de creare contact nou.
- **Layout Panel**: Column, Justify: Space-between, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare Panel**: Lățime `296px`, Înălțime `432px`
- **Styling Panel**: Fundal `background_popup` (#D9D9D9), Umbră `widgetShadow`, Rază Bordură `large` (32px)

#### 2.1. Secțiune Superioară Formular (Section)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `360px`

##### 2.1.1. Antet Formular (Header)
- **Text Titlu**: "Editeaza contact" SAU "Creeaza contact"
- **Styling**: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

##### 2.1.2. Container Formular (Form)
- **Descriere**: Conține câmpurile de input pentru nume, telefon, CNP, codebitor.
- **Layout**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `328px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)

###### 2.1.2.1. Câmp Formular (Field)
- **Structură Generală**: Column, Align Items: Flex-start, Lățime `264px`, Înălțime `72px`
    - **Titlu Câmp (Title)**:
        - Layout: Row, Align Items: Center, Padding Orizontal `small` (8px), Înălțime `24px`
        - Text Titlu: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
        - Text Opțional ("(optional)"): Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_medium_purple (#886699);` (pentru CNP, Codebitor)
    - **Input Text/Dropdown**:
        - Styling Container: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Padding Orizontal `small` (8px), Înălțime `48px`
        - Styling Text (Valoare/Placeholder): `font-weight: 500/600; font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`

- **Câmpuri Specifice**:
    - Nume client (Input Text)
    - Numar de telefon (Input Text)
    - CNP (Input Text/Dropdown, opțional)
    - Nume codebitor (Input Text, opțional)

#### 2.2. Secțiune Inferioară Acțiuni Formular (Section)
- **Layout**: Row, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `48px`

##### 2.2.1. Acțiuni Formular Editare:
- **Buton Copiere CNP (Button - CopyIcon)**: Lățime `168px`, `flex-grow: 1`. Conține iconiță + text "Copy CNP".
- **Buton Șterge (Button - DeleteIcon)**: Lățime `48px`. Doar iconiță.
- **Buton Salvează (Button - SaveIcon)**: Lățime `48px`. Doar iconiță.

##### 2.2.2. Acțiuni Formular Creare:
- **Buton Șterge/Clear (Button - Trash_Full Icon)**: Lățime `48px`. Doar iconiță.
- **Buton Salvează (Button - Save Icon)**: Lățime `224px`, `flex-grow: 1`. Conține iconiță + text "Salveaza contact".

---

## Stare 2: Extragere Contacte - Încărcare (Layout cu 1 Panel + Image Strip)
- **Descriere**: Afișat când utilizatorul a selectat imagini și procesul OCR rulează.
- **Dimensionare Totală Popup**: `width: 296px`, `height: 432px` (352px widget + 72px imagini + 8px gap)

### 1. Panel Extragere (`ContactExtractionWidget`)
- **Descriere**: Panelul principal care arată starea de încărcare.
- **Layout Panel**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare Panel**: Lățime `296px`, Înălțime `352px`
- **Styling Panel**: Fundal `background_popup` (#D9D9D9), Umbră `widgetShadow`, Rază Bordură `large` (32px)

#### 1.1. Secțiune Superioară Încărcare (Section)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `280px`, `flex-grow: 1`

##### 1.1.1. Antet Încărcare (Header)
- **Text Titlu ("Extragere contacte")**: Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

##### 1.1.2. Zonă Conținut Încărcare (Extracting)
- **Layout**: Column, Justify/Align Center, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `248px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Elemente**:
    - **Indicator Încărcare (LoadingCircle)**: `40px` x `40px`, Rază Bordură `medium+` (24px) - *Notă: Probabil un `CircularProgressIndicator`.*
    - **Text Stare ("Extrag contactele...")**: Styling: `font-weight: 500 (medium); font-size: 15px (small); color: font_medium_purple (#886699); text-align: center;`

#### 1.2. Secțiune Inferioară Acțiuni Încărcare (Section)
- **Layout**: Row, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `48px`

##### 1.2.1. Buton Anulează (Button - CancelIcon)
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Elemente**:
    - **Iconiță**: `CancelIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`
    - **Text ("Anuleaza")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: font_medium_purple (#886699);`

### 2. Container Imagini (`ImageContainer`)
- **Descriere**: Afișează orizontal imaginile selectate pentru extragere.
- **Layout**: Column, Align Items: Flex-start, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare**: Lățime `296px`, Înălțime `72px`
- **Styling**: Fundal `background_popup` (#D9D9D9), Rază Bordură `medium` (24px) (*Notă: CSS are umbră aici, dar pare parte din panelul principal*)

#### 2.1. Listă Scrollabilă Imagini (Images)
- **Layout**: Row, Align Items: Center, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `56px`
- **Styling**: Rază Bordură `small` (16px)
- **Comportament**: `overflow-x: scroll;`

##### 2.1.1. Imagine Individuală (Image X)
- **Dimensionare**: `56px` x `56px`
- **Styling**: Fundal imagine (`background: url(...)`), Rază Bordură `small` (16px)

---

## Stare 3: Previzualizare Contacte Extrase (Layout cu 3 Paneluri)
- **Descriere**: Afișat după finalizarea OCR. Arată rezultatele pe imagine (stânga), lista contactelor extrase (centru) și un formular de editare (dreapta).
- **Dimensionare Totală Popup**: `width: 984px`, `height: 432px`

### 1. Panel Stânga - Rezultate Extragere (`Panel` -> `ContactExtractionWidget`)
- **Descriere**: Similar cu Starea 2, dar afișează rezultatele per imagine și butoane diferite.
- **Layout Panel**: Column, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare Panel**: Lățime `296px`, Înălțime `432px` (nu `352px` ca în CSS-ul specific)
- **Styling Panel**: Fundal `background_popup` (#D9D9D9), Rază Bordură `large` (32px)

#### 1.1. Secțiune Superioară Rezultate (Section)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `280px`

##### 1.1.1. Antet Rezultate (Header)
- **Text Titlu ("Contacte extrase")**: Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

##### 1.1.2. Listă Rezultate per Imagine (Form -> Fields)
- **Descriere**: Listă scrollabilă care arată câte contacte au fost extrase din fiecare imagine.
- **Layout Container**: Column, Padding: `small` (8px), Gap: `small` (8px), Lățime `280px`, Înălțime `248px`, Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Layout Listă Internă (`Fields`)**: Column, Gap: `small` (8px), `overflow-y: scroll;`

###### 1.1.2.1. Element Rezultat Imagine (Field)
- **Layout**: Column, Lățime `264px`, Înălțime `72px`
    - **Titlu ("Imaginea X")**: Styling: `font-weight: 600 (large); font-size: 17px (medium); color: font_medium_purple (#886699);`
    - **Buton Vizualizare (Button)**:
        - Layout: Row, Align Items: Center, Padding: `0px 16px`, Gap: `medium` (10px), Înălțime `48px`, Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px)
        - **Text ("X contacte")**: Styling: `font-weight: 500 (medium); font-size: 17px (medium); color: #7C568F (font_dark_purple_variant);`
        - **Iconiță (`LookupIcon.svg`)**: `icon_medium` (24x24px), Bordură `2px solid #7C568F`

#### 1.2. Secțiune Inferioară Acțiuni Rezultate (Section)
- **Layout**: Row, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `280px`, Înălțime `48px`

##### 1.2.1. Buton Reîncearcă (Button - ReturnIcon)
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `224px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Elemente**: Iconiță + Text ("Reincearca")

##### 1.2.2. Buton Terminat (Button - DoneIcon)
- **Layout**: Row, Justify/Align Center, Padding: `medium` (12px), Gap: `medium` (10px)
- **Dimensionare**: `48px` x `48px`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Iconiță**: `DoneIcon.svg` (`icon_medium` - 24x24px), Bordură `2px solid font_medium_purple (#886699)`

#### 1.3. Container Imagini (`ImageContainer`)
- **Descriere și Structură**: Identic cu cel din Starea 2 (Secțiunea 2).

### 2. Panel Centru - Previzualizare Contacte (`Panel`)
- **Descriere**: Afișează lista contactelor extrase din imaginea selectată în panelul stâng.
- **Layout Panel**: Column, Justify: Space-between, Padding: `small` (8px), Gap: `small` (8px)
- **Dimensionare Panel**: Lățime `360px`, Înălțime `432px`
- **Styling Panel**: Fundal `background_popup` (#D9D9D9), Rază Bordură `large` (32px)

#### 2.1. Secțiune Superioară Previzualizare (Section)
- **Layout**: Column, Align Items: Flex-start, Gap: `small` (8px)
- **Dimensionare**: Lățime `344px`, Înălțime `360px`

##### 2.1.1. Antet Previzualizare (Header)
- **Text Titlu ("Previzualizare contacte")**: Styling: `font-weight: 600 (large); font-size: 19px (large); color: #927B9D (font_light_purple_variant);`

##### 2.1.2. Listă Contacte Previzualizare (List)
- **Descriere**: Listă scrollabilă (presupusă) similară cu cea din Starea 1 (1.1.2), dar cu text `font-weight: 500` pentru nume.
- **Styling Iteme**:
    - **Selectat**: Fundal `background_dark_purple` (#C6ACD3), Rază Bordură `small` (16px), Text Nume/Telefon Culoare `#7C568F / #886699`
    - **Inactiv**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px), Text Nume/Telefon Culoare `#886699 / #927B9D`

#### 2.2. Secțiune Inferioară Acțiuni Previzualizare (Section)
- **Layout**: Row, Align Items: Flex-end, Gap: `small` (8px)
- **Dimensionare**: Lățime `344px`, Înălțime `48px`

##### 2.2.1. Buton Adaugă Contact (Button - AddUserIcon)
- **Acțiune**: Adaugă un rând gol în listă pentru creare manuală?
- **Styling și Layout**: Identic cu 1.2.1.

##### 2.2.2. Buton Șterge Contact (Button - DeleteIcon)
- **Acțiune**: Șterge contactul selectat din lista de previzualizare.
- **Styling și Layout**: Identic cu 1.2.3.

##### 2.2.3. Buton Salvează Lista (Button - SaveIcon)
- **Acțiune**: Salvează contactele din lista de previzualizare în lista principală.
- **Layout**: Row, Justify/Align Center, Padding: `12px 16px`, Gap: `small` (8px)
- **Dimensionare**: Lățime `232px`, Înălțime `48px`, `flex-grow: 1`
- **Styling**: Fundal `background_light_purple` (#CFC4D4), Rază Bordură `medium` (24px)
- **Elemente**: Iconiță + Text ("Salveaza lista")

### 3. Panel Dreapta - Editare Contact Extras (`Panel`)
- **Descriere**: Identic cu panelul de editare/creare din Starea 1 (Secțiunea 2), folosit pentru a edita un contact selectat din lista de previzualizare (Panel Centru).
- **Layout Panel, Dimensionare, Styling**: Identic cu Starea 1, Panel Dreapta.
- **Acțiuni Butoane**: Doar "Șterge contact" și "Salvează" sunt relevanți în acest context (fără "Copy CNP").