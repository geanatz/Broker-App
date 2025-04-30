/* --- Global Variables (Derived from your list) --- */
:root {
  /* Backgrounds */
  --app-background: linear-gradient(107.56deg, #A4B8C2 0%, #C2A4A4 100%);
  --widget-background: rgba(255, 255, 255, 0.5);
  --popup-background: rgba(255, 255, 255, 0.75); /* Assuming popup uses 75% */
  --background-light-blue: #C4CFD4;
  --background-light-purple: #CFC4D4;
  --background-light-red: #D4C4C4;
  --background-dark-blue: #ACC6D3;  /* Adjusted based on Call Button */
  --background-dark-purple: #C6ACD3; /* Adjusted based on Speech/User/Dropdown Button */
  --background-dark-red: #D3ACAC;    /* Adjusted based on Past Call Button */

  /* Font Colors */
  --font-light-blue: #8A9EA8;
  --font-light-purple: #9E8AA8;
  --font-light-red: #A88A8A;
  --font-medium-blue: #668899;
  --font-medium-purple: #886699;
  --font-medium-red: #996666;
  --font-dark-blue: #4D6F80;
  --font-dark-purple: #6F4D80;
  --font-dark-red: #804D4D;

  /* Font Sizes (Mapping assumed) */
  --font-size-tiny: 13px;    /* CallsCount: 13px */
  --font-size-small: 14px;   /* (Not explicitly used, placeholder) */
  --font-size-medium: 16px;  /* Phone numbers, Button titles, Team, Timer */
  --font-size-large: 18px;   /* Headers, Contact names, Input text, Consultant */
  --font-size-huge: 20px;    /* (Not explicitly used, placeholder) */

  /* Font Weights (Mapping assumed) */
  --font-weight-small: 400;  /* Regular (Not explicitly used, placeholder) */
  --font-weight-medium: 500; /* Phone numbers, Button titles, Input text, Timer, Team, Count */
  --font-weight-large: 600;  /* Headers, Contact names, Input labels, Consultant */

  /* Border Radius */
  --border-radius-tiny: 8px;     /* Loading Bar */
  --border-radius-small: 16px;   /* Buttons, Input Fields, NavButtons */
  --border-radius-medium: 24px;  /* Contact Items, Data Entry Frames */
  --border-radius-large: 32px;   /* Frames (Calls, Data, User, Nav), Avatar */
  --border-radius-huge: 40px;    /* Small Icon Buttons (Add/Switch User) */

  /* Icon Sizes */
  --icon-size-medium: 24px; /* All icons seem to be 24px */

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
  --button-shadow: 0px 2px 4px rgba(0, 0, 0, 0.2); /* Used on Input Fields & Active NavButtons */
  --icon-border-thickness: 2px; /* Common border thickness for icon vectors */
}

/* --- Base Layout & Structure --- */

/* Represents the main screen container */
.FormScreen {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  padding: var(--large-gap);
  gap: var(--large-gap);
  position: relative;
  width: 1920px; /* Consider making this responsive */
  height: 1080px; /* Consider making this responsive */
  background: var(--app-background);
}

/* Represents the left panel holding Call Widgets */
.SecondaryPanel {
  /* Auto layout */
  display: flex;
  flex-direction: row; /* Or column if CallWidget is the only child */
  align-items: center; /* Or flex-start */
  padding: 0px;
  gap: 10px; /* Check if needed */
  width: 312px;
  height: 1032px; /* Adjust based on content or use flex */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* Represents the central panel holding Data Widgets */
.MainPanel {
  /* Auto layout */
  display: flex;
  flex-direction: row; /* Holds LoanWidget and IncomeWidget side-by-side */
  align-items: center; /* Or flex-start */
  padding: 0px;
  gap: var(--large-gap);
  width: 1288px; /* Adjust based on content or use flex */
  height: 1032px; /* Adjust based on content or use flex */
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch; /* Stretches vertically */
  flex-grow: 0; /* Check if it should grow: 1 */
}

/* Represents the right sidebar */
.Sidebar {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap);
  width: 224px;
  height: 1032px; /* Adjust based on content or use flex */
  /* Inside auto layout */
  flex: none;
  order: 2;
  flex-grow: 0;
}

/* --- Generic Widget/Frame Styles --- */

/* Base style for framed sections like Calls, Loans, Income, User, Nav */
.WidgetFrame {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: center; /* Usually centers content within frame */
  padding: var(--default-gap);
  gap: var(--default-gap);
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none; /* Default, override if needed */
  flex-grow: 0; /* Default, override if needed */
}

/* Common header style within Widgets */
.WidgetHeader {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--large-gap); /* Horizontal padding common */
  gap: var(--medium-gap);
  height: 24px; /* Fixed height */
  /* Inside auto layout */
  flex: none;
  order: 0;
  align-self: stretch; /* Takes full width of parent */
  flex-grow: 0;
}

.WidgetHeader-Title {
  height: 24px;
  font-family: 'Outfit'; /* Keep font family if needed */
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px; /* Adjust if needed */
  display: flex;
  align-items: center;
  /* Color is specific to widget type */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 1; /* Takes available space */
}

.WidgetHeader-Subtitle { /* e.g., Timer */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px; /* Adjust if needed */
  display: flex;
  align-items: center;
  text-align: right;
   /* Color is specific to widget type */
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 1; /* Takes available space if title allows */
}

/* --- Call Widget Specific Styles --- */

.CallWidget { /* Container for all call frames */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap);
  width: 312px;
  height: 1032px; /* Or adjust */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.CallsFrame { /* Specific instance of WidgetFrame */
  width: 312px;
  /* height varies */
}
.CallsFrame--next { height: 440px; }
.CallsFrame--ongoing { height: 120px; }
.CallsFrame--past { height: 440px; }

.CallsFrame .WidgetHeader-Title--next { color: var(--font-light-blue); }
.CallsFrame .WidgetHeader-Title--ongoing { color: var(--font-light-purple); }
.CallsFrame .WidgetHeader-Title--past { color: var(--font-light-red); }

.CallsFrame .WidgetHeader-Subtitle--ongoing { color: var(--font-light-purple); } /* Timer */

/* Common Contact Item styling */
.ContactItem {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: var(--default-gap);
  gap: var(--medium-gap); /* Default, check Contact 1 (16px) vs others (20px) */
  width: 296px;
  height: 72px;
  border-radius: var(--border-radius-medium);
  /* Background color varies */
  /* Inside auto layout */
  flex: none;
  /* order varies */
  align-self: stretch;
  flex-grow: 0;
}
.ContactItem--next { background: var(--background-light-blue); }
.ContactItem--ongoing { background: var(--background-light-purple); }
.ContactItem--past { background: var(--background-light-red); }

.ContactItem-Details {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start; /* Adjusted from center to align text left */
  padding: 0px 0px 0px var(--default-gap); /* Left padding */
  gap: 4px;
  /* width varies slightly (208px vs 204px), use flex */
  height: 47px;
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 1; /* Takes available space */
}

.ContactItem-Name {
  /* width varies slightly, use flex */
  height: 23px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  /* Color varies */
  /* Inside auto layout */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}
.ContactItem-Name--next { color: var(--font-dark-blue); }
.ContactItem-Name--ongoing { color: var(--font-dark-purple); }
.ContactItem-Name--past { color: var(--font-dark-red); }

.ContactItem-Number {
  /* width varies slightly, use flex */
  height: 20px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  /* Color varies */
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0;
}
.ContactItem-Number--next { color: var(--font-medium-blue); }
.ContactItem-Number--ongoing { color: var(--font-medium-purple); }
.ContactItem-Number--past { color: var(--font-medium-red); }

.CallButton { /* Base button style on ContactItem */
  /* Auto layout */
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  padding: var(--medium-gap);
  gap: var(--default-gap);
  width: 56px;
  height: 56px;
  border-radius: var(--border-radius-small);
  /* Background varies */
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 0;
}
.CallButton--next { background: var(--background-dark-blue); }
.CallButton--ongoing { background: var(--background-dark-purple); } /* Speech button */
.CallButton--past { background: var(--background-dark-red); }

/* --- Data Widget (Loan/Income) Specific Styles --- */

.DataWidget { /* Specific instance of WidgetFrame for Loan/Income */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: center; /* Content starts left, but frame is centered? Check Figma */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 632px;
  height: 1032px;
  background: var(--widget-background);
  border-radius: var(--border-radius-large);
  /* Inside auto layout */
  flex: none;
  order: 0; /* Loan=0, Income=1 */
  align-self: stretch;
  flex-grow: 0; /* Should likely be 1 if MainPanel uses flex */
}

.DataWidget .WidgetHeader-Title { color: var(--font-light-purple); }

.DataWidget-ContentContainer { /* Holds Header and ScrollArea */
    /* Auto layout */
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 0px;
    gap: var(--default-gap);
    width: 616px; /* Frame width - padding*2 */
    /* height: 968px; */ /* Should likely use flex */
    flex-grow: 1; /* Make content take space */
    /* Inside auto layout */
    flex: none;
    order: 0;
    align-self: stretch;
    /* flex-grow: 1; */ /* Already set above */
}

.DataWidget-ScrollArea {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px; /* Content inside has padding */
  gap: var(--default-gap);
  width: 616px;
  /* height: 936px; */ /* Should use flex */
  flex-grow: 1; /* Allow scroll area to take space */
  overflow-y: scroll;
  border-radius: var(--border-radius-medium); /* Clip scrolling content */
  /* Inside auto layout */
  flex: none;
  order: 1;
  /* flex-grow: 0; */ /* Changed to 1 */
}

/* Container for a single loan/income entry */
.DataEntryFrame {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: var(--medium-gap);
  gap: var(--medium-gap);
  width: 616px;
  /* height varies (192px or 104px) */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  /* Inside auto layout */
  flex: none;
  /* order varies */
  flex-grow: 0;
}
.DataEntryFrame--full { height: 192px; }
.DataEntryFrame--empty { height: 104px; } /* Check if this frame is needed */

/* Row containing two input fields */
.DataEntryFrame-Row {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center; /* Align input containers vertically */
  padding: 0px;
  gap: var(--default-gap);
  width: 584px; /* Frame width - padding*2 */
  height: 72px;
  /* Inside auto layout */
  flex: none;
  /* order varies */
  align-self: stretch;
  flex-grow: 0;
}

/* Container for label + input field */
.InputFieldContainer {
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Align label left */
  padding: 0px;
  gap: var(--default-gap);
  width: 288px; /* Half of the row width minus gap */
  height: 72px;
  /* Inside auto layout */
  flex: none;
  order: 0; /* or 1 */
  flex-grow: 0; /* Can set to 1 if row should distribute space */
}

.InputField-Label {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Text aligns left */
  align-items: center;
  padding: 0px var(--default-gap); /* Horizontal padding for label */
  gap: 10px;
  width: 288px; /* Full width of container */
  height: 16px; /* Fixed height */
  /* Label Text Style */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large); /* Was 18px, mapped to large */
  line-height: 23px; /* Check if line-height matches font-size */
  color: var(--font-medium-purple);
  /* Inside auto layout */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0; /* Label text uses flex-grow: 1 within this box */
}

.InputField { /* The actual input box/dropdown */
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 12px var(--medium-gap);
  gap: var(--default-gap);
  width: 288px;
  height: 48px;
  background: var(--background-dark-purple);
  box-shadow: var(--button-shadow); /* Has shadow */
  border-radius: var(--border-radius-small);
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 0;
}

.InputField-Text { /* Text inside the input/dropdown */
  /* width: 224px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-large); /* Was 18px, mapped to large */
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-dark-purple);
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 1; /* Allow text to take space */
}

.DataWidget-Footer { /* Container for Add/Switch buttons */
    /* Auto layout */
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    padding: 0px;
    gap: var(--default-gap); /* Added gap */
    width: 616px;
    height: var(--border-radius-huge); /* Same as button height */
    /* Inside auto layout */
    flex: none;
    order: 1; /* Assumed order after ScrollArea */
    align-self: stretch;
    flex-grow: 0;
}

.IconButton--small { /* Style for Add/Switch User buttons */
    /* Auto layout */
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    padding: var(--default-gap);
    gap: 10px;
    width: var(--border-radius-huge); /* 40px */
    height: var(--border-radius-huge); /* 40px */
    border-radius: var(--border-radius-small);
    /* Background varies slightly */
    /* Inside auto layout */
    flex: none;
    /* order: 0 or 1 */
    flex-grow: 0;
}
.IconButton--small-active { background: var(--background-dark-purple); }
.IconButton--small-inactive { background: transparent; } /* Assuming inactive has no background */

/* --- Sidebar Specific Styles --- */

.UserWidget { /* Top part of sidebar */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 224px;
  height: 96px;
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-About { /* Row for Avatar + Info */
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px; /* Widget width - padding*2 */
  height: 56px;
  /* Inside auto layout */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Avatar {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center; /* Center icon */
  padding: var(--medium-gap);
  gap: 10px;
  width: 56px;
  height: 56px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-large); /* Should be 50% for circle */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Info { /* Column for Name + Team */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  padding: var(--default-gap);
  gap: var(--default-gap);
  /* width: 144px; */ /* Use flex */
  height: 56px;
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 1;
}

.UserWidget-Name { /* Consultant */
  /* width: 128px; */ /* Use flex */
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-medium-purple);
  /* Inside auto layout */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Team { /* Team */
  /* width: 128px; */ /* Use flex */
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  color: var(--font-light-purple);
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Progress { /* Row for Bar + Count */
  /* Auto layout */
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 176px; /* Specific width */
  height: 16px;
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 0;
}

.ProgressBar {
  /* Auto layout */
  display: flex; /* Needed for nested Loaded bar */
  flex-direction: column; /* Or row */
  align-items: flex-start;
  padding: 0px;
  /* gap: 10px; */ /* Gap likely not needed */
  width: 152px;
  height: 16px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-tiny);
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0; /* Can set to 1 if needed */
  position: relative; /* For absolute positioning of loaded bar if needed */
  overflow: hidden; /* Clip loaded bar */
}

.ProgressBar-Loaded {
  width: 72px; /* This width determines progress % */
  height: 16px;
  background: var(--background-dark-purple);
  border-radius: var(--border-radius-tiny) 0px 0px var(--border-radius-tiny); /* Left corners rounded */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Count { /* Calls count */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 0px;
  gap: 10px; /* Gap likely not needed */
  width: 16px;
  height: 16px;
  /* Count Text Style */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-tiny);
  line-height: 16px;
  color: var(--font-medium-purple);
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 0;
}

.NavigationBar { /* Main navigation area in sidebar */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: center; /* Centers sections inside */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 224px;
  /* height: 920px; */ /* Use flex */
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  /* Inside auto layout */
  flex: none;
  order: 1;
  flex-grow: 1; /* Allow nav to take remaining space */
}

.NavSection { /* Groups like Main / Secondary nav items */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px; /* Nav width - padding*2 */
  /* height varies */
  /* Inside auto layout */
  flex: none;
  /* order varies */
  align-self: stretch;
  flex-grow: 0;
}
.NavSection--main { height: 192px; }
.NavSection--secondary { height: 248px; }

.NavSection .WidgetHeader-Title { color: var(--font-light-purple); }

.NavButtonsContainer { /* Holds the actual buttons */
  /* Auto layout */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px;
  /* height varies */
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0; /* Or 1 if buttons should fill space */
}
.NavButtonsContainer--main { height: 160px; }
.NavButtonsContainer--secondary { height: 216px; }


/* Base style for navigation buttons */
.NavButton {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Align icon/text left */
  align-items: center;
  padding: 12px var(--medium-gap);
  gap: var(--medium-gap);
  width: 208px;
  height: 48px;
  border-radius: var(--border-radius-small);
  /* Background, shadow, text/icon color varies based on state */
  /* Inside auto layout */
  flex: none;
  /* order varies */
  align-self: stretch;
  flex-grow: 0;
  cursor: pointer; /* Add pointer */
  transition: background-color 0.2s ease; /* Smooth transition */
}

.NavButton--active {
  background: var(--background-dark-purple);
  box-shadow: var(--button-shadow);
}
.NavButton--inactive {
  background: var(--background-light-purple);
  box-shadow: none;
}

.NavButton-IconContainer {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px;
  gap: 10px; /* Default gap */
  width: var(--icon-size-medium); /* Fixed width for icon */
  height: var(--icon-size-medium); /* Fixed height for icon */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.NavButton-TitleContainer {
  /* Auto layout */
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Align text left */
  align-items: center;
  padding: 0px;
  gap: 10px; /* Default gap */
  /* width: 136px; */ /* Use flex */
  /* height: 16px or 24px, depends on content */
  /* Inside auto layout */
  flex: none;
  order: 1;
  align-self: stretch; /* Stretch vertically */
  flex-grow: 1; /* Take remaining space */
}

.NavButton-Title {
  /* width: 136px; */ /* Use flex */
  height: 16px; /* Common height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  /* Color varies based on state */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 1; /* Take space within title container */
}

.NavButton--active .NavButton-Title { color: var(--font-dark-purple); }
.NavButton--inactive .NavButton-Title { color: var(--font-medium-purple); }

/* --- Icon Styles --- */
/* Base styles - In Flutter, you'd use Icon(iconData, size, color) */
.Icon {
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  /* The 'Vector' properties define the visual shape and stroke */
  /* border: var(--icon-border-thickness) solid [color]; */
  /* position, left, right, top, bottom define path bounds */
  /* transform: rotate(135deg); for past calls */
  /* Inside auto layout */
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* Specific Icon Colors (apply to the icon itself) */
.Icon--view { border-color: var(--font-light-blue); }
.Icon--view-past { border-color: var(--font-light-red); } /* Past Calls View Icon */
.Icon--call-next { border-color: var(--font-dark-blue); }
.Icon--speech { border-color: var(--font-dark-purple); }
.Icon--call-past { border-color: var(--font-dark-red); transform: rotate(135deg); }
.Icon--remove { border-color: var(--font-light-purple); }
.Icon--dropdown { border-color: var(--font-dark-purple); }
.Icon--dropdown-nav { border-color: var(--background-light-purple); } /* Nav dropdown arrow */
.Icon--adduser-active { border-color: var(--font-dark-purple); }
.Icon--adduser-inactive { border-color: var(--font-medium-purple); } /* Assuming inactive color */
.Icon--switchuser-active { border-color: var(--font-dark-purple); }
.Icon--switchuser-inactive { border-color: var(--font-medium-purple); }
.Icon--user-avatar { border-color: var(--font-medium-purple); } /* Consultant Avatar */

/* Nav Icons */
.NavButton--active .Icon { border-color: var(--font-dark-purple); }
.NavButton--inactive .Icon { border-color: var(--font-medium-purple); }

/* .Icon-Form */
/* .Icon-Calendar */
/* .Icon-Settings */
/* .Icon-Calls */
/* .Icon-Return */
/* .Icon-Calculator */
/* .Icon-Recommend */

/* Note: The 'Vector' details (position, left, right, top, bottom, border) describe the *path* of the icon.
   In Flutter, you'd typically use predefined Icons (like Icons.call, Icons.visibility) or SVG assets.
   The color comes from the variables above. The border: 2px likely means stroke-width for SVG or inherent icon design.
*/