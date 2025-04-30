/* --- Global Variables (Subset relevant to SidebarPanel) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5);
  --background-light-purple: #CFC4D4; /* Avatar, Loading Bar Base, Inactive Nav BG, Dropdown Icon Border */
  /* Note: Figma dump uses specific #C6ACD3 for active elements, using that directly */
  --background-active-purple: #C6ACD3; /* Loading Bar Loaded, Active Nav BG */
  /* --background-dark-purple: #C5B0CF; */ /* Variable definition if needed elsewhere */

  /* Font Colors */
  --font-light-purple: #9E8AA8;    /* Team Name, Widget Header Titles */
  --font-medium-purple: #886699;   /* Consultant Name, Count, Inactive Nav Titles & Icons */
  --font-dark-purple: #6F4D80;     /* Active Nav Titles & Icons */

  /* Font Sizes */
  --font-size-tiny: 13px;    /* Calls Count */
  --font-size-small: 14px;   /* Not used in this file */
  --font-size-medium: 16px;  /* Team Name, Nav Button Titles */
  --font-size-large: 18px;   /* Consultant Name, Widget Header Titles */
  --font-size-huge: 20px;    /* Not used in this file */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Team Name, Count, Nav Button Titles */
  --font-weight-large: 600;  /* Consultant Name, Widget Header Titles */

  /* Border Radius */
  --border-radius-tiny: 8px;     /* Loading Bar */
  --border-radius-small: 16px;   /* Nav Buttons */
  --border-radius-medium: 24px;
  --border-radius-large: 32px;   /* User Widget, Avatar, Nav Bar */
  --border-radius-huge: 40px;

  /* Icon Sizes */
  --icon-size-medium: 24px;   /* All icons in this file */

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
  --button-shadow: 0px 2px 4px rgba(0, 0, 0, 0.2); /* Active Nav Button Shadow */
  --icon-border-thickness: 2px;
}

/* --- Sidebar Layout --- */

.Sidebar { /* The main container for UserWidget and NavigationBar */
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Align widgets to the start */
  padding: 0px;
  gap: var(--medium-gap); /* 16px gap between UserWidget and Nav Bar */
  width: 224px;
  height: 1032px; /* Adjust or use flex */
  flex: none;
  order: 2; /* Assumed order relative to other panels */
  flex-grow: 0;
}

/* --- User Widget --- */

.UserWidget {
  display: flex;
  flex-direction: column;
  justify-content: center; /* Center content vertically */
  align-items: center; /* Center content horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 224px;
  height: 96px; /* Fixed height */
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-About { /* Row for Avatar + Info */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px; /* Widget width - padding*2 */
  height: 56px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Avatar {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center; /* Center icon inside */
  padding: var(--medium-gap);
  gap: 10px;
  width: 56px;
  height: 56px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-large); /* Should be 50% in Flutter for circle */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Info { /* Column for Name + Team */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  padding: var(--default-gap);
  gap: var(--default-gap);
  /* width: 144px; */ /* Use flex */
  height: 56px;
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 1; /* Take remaining space in row */
}

.UserWidget-Name { /* Consultant */
  /* width: 128px; */ /* Use flex */
  height: 16px; /* Container height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px; /* Check consistency */
  display: flex;
  align-items: center;
  color: var(--font-medium-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Team { /* Team */
  /* width: 128px; */ /* Use flex */
  height: 16px; /* Container height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  color: var(--font-light-purple);
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Progress { /* Row for Bar + Count */
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 176px; /* Specific width from Figma */
  height: 16px;
  flex: none;
  order: 1; /* Below Avatar/Info row */
  flex-grow: 0;
}

.ProgressBar { /* Background bar */
  display: flex; /* Needed for nested Loaded bar */
  align-items: flex-start;
  padding: 0px;
  /* gap: 10px; */ /* Not needed */
  width: 152px;
  height: 16px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-tiny);
  overflow: hidden; /* Clip the loaded part */
  flex: none;
  order: 0;
  flex-grow: 0; /* Or 1 if it should take space */
}

.ProgressBar-Loaded { /* Foreground (filled) bar */
  width: 72px; /* This width determines progress % - Should be dynamic */
  height: 16px;
  background: var(--background-active-purple);
  border-radius: var(--border-radius-tiny) 0px 0px var(--border-radius-tiny); /* Round left corners */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Count { /* Calls count text */
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0px;
  /* gap: 10px; */ /* Not needed */
  width: 16px; /* Fixed width for text */
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-tiny); /* 13px */
  line-height: 16px;
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  flex-grow: 0;
}

/* --- Navigation Bar --- */

.NavigationBar { /* The main container for nav sections */
  display: flex;
  flex-direction: column;
  align-items: center; /* Center nav sections horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap); /* Gap between nav sections if multiple */
  width: 224px;
  /* height: 920px; */ /* Use flex */
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none;
  order: 1; /* After UserWidget */
  flex-grow: 1; /* Takes remaining vertical space in Sidebar */
}

/* --- Navigation Section (e.g., Main, Secondary) --- */
/* Grouping buttons under headers */
.NavSection {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px; /* Nav Bar width - padding*2 */
  /* height varies based on content */
  flex: none;
  /* order determines section order (0=Main, 1=Secondary) */
  align-self: stretch;
  flex-grow: 0;
}
/* Example heights from Figma - might not be needed if using flex */
/* .NavSection--main { height: 192px; } */
/* .NavSection--secondary { height: 248px; } */

.NavSection-Header {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--large-gap); /* 24px horizontal padding */
  gap: var(--medium-gap);
  width: 208px;
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.NavSection-Header-Title {
  /* width: 120px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-light-purple);
  flex: none;
  order: 0;
  flex-grow: 1; /* Title takes space */
}

.NavSection-Header-DropdownButton { /* Container for dropdown icon */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  flex: none;
  order: 1;
  flex-grow: 0;
  cursor: pointer; /* Added */
}

/* --- Navigation Buttons Container --- */

.NavButtonsContainer { /* Holds the list of NavButton items */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px;
  /* height varies based on number of buttons */
  flex: none;
  order: 1; /* After header */
  align-self: stretch;
  flex-grow: 0; /* Or 1 if buttons should expand */
}
/* Example heights from Figma */
/* .NavButtonsContainer--main { height: 160px; } */
/* .NavButtonsContainer--secondary { height: 216px; } */

/* --- Individual Navigation Button --- */

.NavButton {
  display: flex;
  flex-direction: row;
  /* justify-content: center; */ /* Changed to space content */
  align-items: center;
  padding: 12px var(--medium-gap); /* 12px top/bottom, 16px left/right */
  gap: var(--medium-gap); /* 16px gap between icon and text */
  width: 208px;
  height: 48px;
  border-radius: var(--border-radius-small);
  flex: none;
  align-self: stretch;
  flex-grow: 0;
  cursor: pointer;
  transition: background-color 0.2s ease, box-shadow 0.2s ease;
  /* order determined by list position */
  /* Background, shadow, text/icon color varies based on state */
}

/* --- Active/Inactive State --- */
/* Apply these classes to the .NavButton element */
.NavButton--active {
  background: var(--background-active-purple);
  box-shadow: var(--button-shadow);
}
.NavButton--inactive {
  background: var(--background-light-purple);
  box-shadow: none;
}

.NavButton-IconContainer { /* Container for the icon */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0px;
  /* gap: 10px; */ /* Not needed */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.NavButton-TitleContainer { /* Container for the text */
  /* width: 136px; */ /* Use flex */
  /* height: 16px or 24px */
  height: 24px; /* Match figma container */
  display: flex;
  flex-direction: row;
  /* justify-content: center; */ /* Align text left */
  align-items: center;
  padding: 0px;
  /* gap: 10px; */ /* Not needed */
  flex: none;
  order: 1;
  align-self: stretch; /* Stretch vertically */
  flex-grow: 1; /* Title container takes remaining space */
}

.NavButton-Title { /* The text itself */
  /* width: 136px; */ /* Use flex */
  height: 16px; /* Text content height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  /* color set by active/inactive state */
  flex: none;
  order: 0;
  flex-grow: 1; /* Text takes space within its container */
}

/* State-dependent colors for Icon and Title */
.NavButton--active .NavButton-Icon { /* Style the icon itself */
  border-color: var(--font-dark-purple);
  /* In Flutter: Icon(..., color: var(--font-dark-purple)) */
}
.NavButton--active .NavButton-Title {
  color: var(--font-dark-purple);
}
.NavButton--inactive .NavButton-Icon {
  border-color: var(--font-medium-purple);
  /* In Flutter: Icon(..., color: var(--font-medium-purple)) */
}
.NavButton--inactive .NavButton-Title {
  color: var(--font-medium-purple);
}

/* --- Icons --- */

.Icon { /* Base Icon Style */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative; /* For absolute positioned vectors if using CSS */
  border-width: var(--icon-border-thickness);
  border-style: solid;
  /* border-color is state-dependent */
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* Specific Icon Styles (Map to IconData/SVG in Flutter) */
.Icon--user-avatar { border-color: var(--font-medium-purple); }
.Icon--dropdown-nav { border-color: var(--background-light-purple); } /* Note: uses BG color */

/* Nav Icons - Colors handled by .NavButton--active/inactive rules above */
.Icon--form { /* Use Icons.description or similar */ }
.Icon--calendar { /* Use Icons.calendar_today or similar */ }
.Icon--settings { /* Use Icons.settings or similar */ }
.Icon--calls { /* Use Icons.call or similar */ }
.Icon--return { /* Use Icons.replay or similar */ }
.Icon--calculator { /* Use Icons.calculate or similar */ }
.Icon--recommend { /* Use Icons.bar_chart or similar */ }

/* Note on Vector Details: Map to appropriate IconData/SVG and color/stroke props in Flutter. */