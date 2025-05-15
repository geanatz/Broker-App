main.dart (actualul main.dart)
/frontend
//screens
--authScreen.dart (actualul authScreen) > acest ecran se ocupa autentificarea utilizatorului, adica cu modulele de autetificare(modules). poate sa-si creeze un cont(registerModule+tokenModule), sa se conecteze la contul sau(loginModule) si sa-si schimbe parola(recoverModule+verifyModule). toata logica si functionarea acestui sistem de autentificare se localizeaza in fisierul authService.
--mainScreen.dart (actualele dashboardScreen, formScreen, calendar Screen si settingsScreen) > acest ecran este ecranul principal al aplicatiei, aici sunt afisate majoritatea Areas, Panes, Popups. Acest ecran va avea in permanenta sidebar-ul vizibil in partea dreapta a ecranului
//areas
--formArea.dart (actualul formPanel) > aici va fi afisat formularul fiecarui client din clientsPane. este impartit in 2 sectiuni, in prima sectiune se completeaza informatiile despre creditele clientului/codebitorului. in a doua sectiune se completeaza informatiile despre veniturile clientului/codebitorului.
--calendarArea.dart (actualul calendarPanel) > aici va fi afisat calendarul cu intalniri. meeting-ul poate fi de 2 tipuri. bureauMeeting si creditMeeting. meeting-ul contine: consultant, client, data si ora si tipul de meeting.
--settingsArea.dart (actualul settingsPanel) > aici vor fi niste setari pentru matcherPane, tema aplicatiei, ocr si altele...
//panes
--sidebarPane.dart (actualele navigation_config, navigation_widget, sidebar_widget, user_config, user_widget) > acest pane va fi permanent vizibil pe mainScreen. acest pane permite navigarea utilizatorului + alte alte functii utile.
--clientsPane.dart (actualul callsPanel) > acest pane este impartit in 2 sectiuni. prima sectiune afiseaza clientii urmatori, iar a doua sectiune afiseaza clientii recenti.
--meetingsPane.dart (actualul meetingsPanel) > acest pane afiseaza meeting-urile din viitor ale consultantului.
--returnsPane.dart (nou) > coming soon.
--matcherPane.dart (nou) > coming soon.
//modules
--loginModule.dart (actualul loginPopup) > in acest modul utilizatorul se poate conecta la contul de consultant.
--registerModule.dart (actualul registerPopup) > in acest modul utilizatorul isi poate creea un cont de consultant.
--tokenModule.dart (actualul accountcreatedPopup) > in acest modul utilizatorul primeste un token dupa crearea contului de consultant. acest token ii va permite sa-si schimbe parola.
--verifyModule.dart (actualul tokenPopup) > acest modul este un modul de verificare pentru modulul recoveryModule. utilizatorul trebuie sa dovedeasca ca este contul cu token-ul pe care l-a primit cand a creat contul.
--recoveryModule.dart (actualul resetpasswordPopup) > in acest modul utilizatorul isi poate schimba parola veche cu una noua.
//popups
--calculatorPopup.dart (nou) > acest popup este destinat calcularii creditelor.
--clientsPopup.dart (nou) > acest popup este destinat listei de clienti. aici consultantul poate crea, sterge sau modifica informatii despre clienti. acest popup contine si o functie de extragere a clientilor din niste poze cu ajutorul unui OCR.
--meetingPopup.dart (actualele createreservationPopup si editreservationPopup) > acest popup permite consultantului sa creeze, sa stearga sau sa editeze informatii despre un meeting.

/backend
//services
--authService.dart (actualul authService.dart) > aici se va desfasura toata logica sistemului de autentificare, de la schimbarea popup-urilor in authScreen, pana la integrarea firebaseAuth. toata logica sistemului de autentificare trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--dashboardService.dart (nou) > aici se va desfasura toata logica dashboard-ului. toata logica dashboard-ului trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--formService.dart (nou) > aici se va desfasura toata logica form-ului. toata logica form-ului trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--calendarService.dart (nou) > aici se va desfasura toata logica calendarului. toata logica calendarului trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--clientsService.dart (nou) > aici se va desfasura toata logica clients-ului. toata logica clients-ului trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--calculatorService.dart (nou) > aici se va desfasura toata logica calculatorului. toata logica calculatorului trebuie sa asezata in acest fisier, organizata frumos, simplu si curat.
--matcherService.dart (nou) > coming soon.
--callService.dart (nou) > coming soon.
//ocr
--enchance.dart (nou) > coming soon.
--scanner.dart (nou) > coming soon.
--parser.dart (nou) > coming soon.
--presets.json (nou) > coming soon.
--names.json (nou) > coming soon.
--filter.json (nou) > coming soon.