/* --- Global Variables (Reusing from previous definition) --- */
:root {
  /* Backgrounds */
  --app-background: linear-gradient(107.56deg, #A4B8C2 0%, #C2A4A4 100%);
  --widget-background: rgba(255, 255, 255, 0.5);
  --popup-background: rgba(255, 255, 255, 0.75);
  --background-light-blue: #C4CFD4;
  --background-light-purple: #CFC4D4;
  --background-light-red: #D4C4C4;
  --background-dark-blue: #ACC6D3; /* Or #B0C5CF if specifically needed */
  --background-dark-purple: #C6ACD3; /* Or #C5B0CF if specifically needed */
  --background-dark-red: #D3ACAC; /* Or #CFB0B0 if specifically needed */

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

  /* Font Sizes */
  --font-size-tiny: 13px;    /* Mapped from 13px */
  --font-size-small: 14px;   /* Meeting Hour/Date */
  --font-size-medium: 16px;  /* Meeting Desc, Calendar Type/Day/Hour Labels, Slot Text, Nav Titles, Team */
  --font-size-large: 18px;   /* Widget Titles, Meeting Title, Slot Consultant, User Name */
  --font-size-huge: 20px;    /* (Not explicitly used, placeholder) */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Meeting Hour/Date/Desc, Calendar Type/Day/Hour Labels, Slot Client, Nav Titles, Team, Count */
  --font-weight-large: 600;  /* Widget Titles, Meeting Title, Slot Create/Consultant, User Name */

  /* Border Radius */
  --border-radius-tiny: 8px;     /* Loading Bar, Calendar Column */
  --border-radius-small: 16px;   /* Calendar Slots, NavButtons */
  --border-radius-medium: 24px;  /* MeetingField, CalendarContainer */
  --border-radius-large: 32px;   /* Widgets (Upcoming, Calendar, User, Nav), Avatar */
  --border-radius-huge: 40px;    /* (Not explicitly used) */

  /* Icon Sizes */
  --icon-size-small: 20px;    /* Swap Icon */
  --icon-size-medium: 24px;   /* User/Nav Icons */

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
  --button-shadow: 0px 2px 4px rgba(0, 0, 0, 0.2); /* Used on Active NavButtons */
  --slot-shadow: 0px 2px 4px rgba(0, 0, 0, 0.25); /* Used on Reserved Calendar Slots */
  --icon-border-thickness: 2px;
  --slot-border-thickness: 4px; /* Used on Available Calendar Slots */
}

/* --- Base Layout & Structure --- */

.CalendarScreen {
  display: flex;
  flex-direction: row;
  align-items: flex-start; /* Changed from center */
  padding: var(--large-gap);
  gap: var(--large-gap);
  position: relative;
  width: 1920px; /* Consider responsiveness */
  height: 1080px; /* Consider responsiveness */
  background: var(--app-background);
}

.SecondaryPanel { /* Left: Upcoming Meetings */
  display: flex;
  flex-direction: column; /* Contains UpcomingWidget */
  align-items: flex-start;
  padding: 0px;
  /* gap: 10px; */ /* Gap defined within UpcomingWidget */
  width: 224px;
  height: 1032px; /* Adjust if needed or use flex */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.MainPanel { /* Center: Calendar */
  display: flex;
  flex-direction: column; /* Contains CalendarWidget */
  align-items: flex-start;
  padding: 0px;
  /* gap: 10px; */ /* Gap defined within CalendarWidget */
  width: 1376px; /* Adjust if needed or use flex */
  height: 1032px; /* Adjust if needed or use flex */
  flex: none;
  order: 1;
  flex-grow: 0; /* Or 1 if it should take remaining space */
}

.Sidebar { /* Right: User Info & Nav */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap);
  width: 224px;
  height: 1032px; /* Adjust if needed or use flex */
  flex: none;
  order: 2;
  flex-grow: 0;
}

/* --- Generic Widget/Frame Styles (Reused) --- */

.WidgetFrame {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: var(--default-gap);
  gap: var(--default-gap);
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none;
  align-self: stretch; /* Widgets typically stretch */
  flex-grow: 0; /* Default, override if widget should grow */
}

.WidgetHeader {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--medium-gap); /* 16px padding */
  height: 24px;
  gap: var(--medium-gap); /* Assume 16px if not specified */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.WidgetHeader-Title {
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
  flex-grow: 1;
}

/* --- Upcoming Meetings Widget (SecondaryPanel) --- */

.UpcomingWidget {
  /* Inherits from WidgetFrame */
  width: 224px;
  height: 1032px; /* Fills panel */
  flex-grow: 1; /* Allow growing if panel height is flexible */
}

.UpcomingMeetingList { /* Container for MeetingField items */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px; /* Padding is on items */
  gap: var(--default-gap);
  width: 208px; /* Widget width - padding*2 */
  /* height: 568px; */ /* Allow to grow/scroll */
  overflow-y: auto; /* Add scroll if needed */
  flex: none;
  order: 1; /* After header */
  align-self: stretch;
  flex-grow: 1; /* Takes remaining space in widget */
}

.MeetingField {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: var(--default-gap) var(--medium-gap);
  gap: 0px; /* Elements inside manage their spacing */
  width: 208px;
  height: 88px; /* Fixed height */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  order: 0; /* order managed by list */
  align-self: stretch;
  flex-grow: 0;
}

.MeetingField-HourDateRow {
  display: flex;
  flex-direction: row;
  justify-content: space-between; /* Pushes Hour/Date apart */
  align-items: center;
  padding: 0px;
  gap: 10px; /* Maintain gap if needed */
  width: 176px; /* Field width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.MeetingField-Hour,
.MeetingField-Date {
  /* width: 83px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-small);
  line-height: 18px; /* Adjusted */
  display: flex;
  align-items: center;
  color: var(--font-medium-purple);
  flex: none;
  order: 0; /* Hour=0, Date=1 */
  flex-grow: 1; /* Allow to take space */
}

.MeetingField-Date {
  text-align: right;
  justify-content: flex-end; /* Align text right */
  order: 1;
}

.MeetingField-Details {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start; /* Align text left */
  padding: 0px;
  gap: 0px; /* Title/Description have own height */
  width: 176px; /* Field width - padding*2 */
  height: 48px;
  flex: none;
  order: 1; /* After Hour/Date */
  align-self: stretch;
  flex-grow: 0;
}

.MeetingField-Title {
  width: 176px;
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.MeetingField-Description {
  width: 176px;
  height: 24px; /* Was 24px, text is 16px/20px line height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  /* align-self: stretch; */ /* Not needed if height fixed */
  flex-grow: 0;
}

/* --- Calendar Widget (MainPanel) --- */

.CalendarWidget {
  /* Inherits from WidgetFrame */
  width: 1376px;
  height: 1032px; /* Fills panel */
  flex-grow: 1; /* Allow growing */
}

.CalendarWidget .WidgetHeader { /* Override padding/gap if needed */
  padding: 0px var(--medium-gap);
  width: 1360px; /* Widget width - padding*2 */
  justify-content: space-between; /* Space between title and switch */
}

.CalendarWidget .WidgetHeader-Title {
  /* Styles already defined */
  width: auto; /* Let flexbox decide */
}

.CalendarSwitch {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  /* width: 152px; */ /* Allow flexible width */
  height: 24px;
  flex: none;
  order: 1; /* After title */
  flex-grow: 0;
}

.CalendarType {
  /* width: 124px; */ /* Allow flexible width */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  text-align: right;
  color: var(--font-light-purple);
  flex: none;
  order: 0;
  flex-grow: 0; /* Or 1 if it should push icon */
}

.SwapIconContainer { /* Wrapper for icon if needed */
  display: flex;
  align-items: center;
  justify-content: center;
  width: var(--icon-size-small);
  height: var(--icon-size-small);
  flex: none;
  order: 1;
  flex-grow: 0;
}

.Icon--swap { /* Specific icon style */
  width: var(--icon-size-small);
  height: var(--icon-size-small);
  /* Vector properties describe path */
  border: var(--icon-border-thickness) solid var(--font-light-purple);
  flex: none;
  order: 0;
  flex-grow: 0;
}

.CalendarContainer {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: var(--medium-gap);
  gap: var(--default-gap);
  width: 1360px; /* Widget width - padding*2 */
  /* height: 984px; */ /* Let flex handle height */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  order: 1; /* After header */
  flex-grow: 1; /* Takes remaining space in widget */
  overflow: hidden; /* Contains scrolling grid */
}

.CalendarDaysRow {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  padding: 0px 0px 0px 64px; /* Left padding to align with hour labels + gap */
  gap: var(--medium-gap);
  width: 1328px; /* Container width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CalendarDayLabel {
  width: 240px; /* Width of a slot column */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  justify-content: center; /* Center text */
  text-align: center;
  color: var(--font-medium-purple);
  flex: none;
  /* order determines day order */
  flex-grow: 0;
}

.CalendarGrid {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap);
  width: 1328px; /* Container width - padding*2 */
  /* height: 920px; */ /* Let flex handle height */
  overflow-y: scroll; /* Enable vertical scroll */
  flex: none;
  order: 1; /* After day labels */
  flex-grow: 1; /* Takes remaining space in container */
}

.CalendarHoursColumn {
  display: flex;
  flex-direction: column;
  align-items: center; /* Center hour text */
  padding: var(--default-gap) 0px; /* Vertical padding */
  gap: 56px; /* Large gap between hours */
  width: 48px;
  /* height: 1080px; */ /* Should match scroll height */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.CalendarHourLabel {
  width: 48px;
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  justify-content: center; /* Center text */
  text-align: center;
  color: var(--font-medium-purple);
  flex: none;
  /* order defines time order */
  align-self: stretch;
  flex-grow: 0;
}

.MeetingSlotsColumn {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap); /* Gap between slots */
  width: 240px;
  /* height: 1104px; */ /* Should match scroll height */
  border-radius: var(--border-radius-tiny); /* Rounded corners for column? */
  flex: none;
  /* order determines day column */
  align-self: stretch; /* Stretch vertically */
  flex-grow: 0;
}

/* Base style for calendar time slots */
.CalendarSlot {
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center; /* Center content */
  padding: 6px var(--medium-gap);
  width: 240px;
  height: 64px; /* Fixed height */
  border-radius: var(--border-radius-small);
  flex: none;
  /* order determines time slot */
  align-self: stretch;
  flex-grow: 0;
  cursor: pointer; /* Indicate interactivity */
}

.CalendarSlot--available {
  border: var(--slot-border-thickness) solid var(--background-dark-purple); /* Use color var directly for border */
  background: transparent; /* No background fill */
}

.CalendarSlot--reserved {
  background: var(--background-dark-purple);
  box-shadow: var(--slot-shadow);
  border: none; /* No border */
}

/* Text within Available Slot */
.CalendarSlot-CreateText {
  /* width: 208px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  justify-content: center; /* Center text */
  text-align: center;
  color: var(--font-medium-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

/* Text within Reserved Slot */
.CalendarSlot-ConsultantName {
  /* width: 208px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: flex-start; /* Align text top/start */
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CalendarSlot-ClientName {
  /* width: 208px; */ /* Use flex */
  height: 20px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: flex-start; /* Align text top/start */
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0;
}


/* --- Sidebar (UserWidget & NavigationBar - Reused Styles) --- */
/* These styles are identical to the FormScreen refactoring */

.UserWidget {
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
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-About {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px;
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
  justify-content: center;
  padding: var(--medium-gap);
  gap: 10px;
  width: 56px;
  height: 56px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-large); /* Circular: 50% */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.Icon--user-avatar {
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  border: var(--icon-border-thickness) solid var(--font-medium-purple);
  /* Vector path details */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Info {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  padding: var(--default-gap);
  gap: var(--default-gap);
  height: 56px;
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 1;
}

.UserWidget-Name { /* Consultant */
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-medium-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UserWidget-Team { /* Team */
  height: 16px;
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

.UserWidget-Progress {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap);
  width: 176px;
  height: 16px;
  flex: none;
  order: 1;
  flex-grow: 0;
}

.ProgressBar {
  display: flex;
  align-items: flex-start;
  padding: 0px;
  width: 152px;
  height: 16px;
  background: var(--background-light-purple);
  border-radius: var(--border-radius-tiny);
  overflow: hidden;
  flex: none;
  order: 0;
  flex-grow: 0;
}

.ProgressBar-Loaded {
  width: 72px; /* Dynamic */
  height: 16px;
  background: var(--background-dark-purple);
  border-radius: var(--border-radius-tiny) 0px 0px var(--border-radius-tiny);
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UserWidget-Count {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0px;
  width: 16px;
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-tiny);
  line-height: 16px;
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  flex-grow: 0;
}

.NavigationBar {
  /* Inherits from WidgetFrame */
  width: 224px;
  /* height: 920px; */ /* Use flex */
  order: 1; /* After UserWidget */
  flex-grow: 1; /* Takes remaining space in sidebar */
}

/* --- NavigationBar specific structure (Simplified if only one section) --- */
.NavSection {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px;
  flex: none;
  order: 0; /* Or adjust if multiple sections */
  align-self: stretch;
  flex-grow: 0;
}

.NavSection .WidgetHeader { /* Header for the Nav section */
   padding: 0px var(--large-gap); /* 24px padding */
   /* Other header styles reused */
}

.Icon--dropdown-nav {
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  border: var(--icon-border-thickness) solid var(--background-light-purple); /* Specific color */
  /* Vector path details */
  flex: none;
  order: 0; /* Or 1 within button */
  flex-grow: 0;
}

.NavButtonsContainer { /* Holds the actual buttons */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--default-gap);
  width: 208px;
  /* height: 160px; */ /* Let content define height */
  flex: none;
  order: 1; /* After header */
  align-self: stretch;
  flex-grow: 0;
}

.NavButton {
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Align icon/text left */
  align-items: center;
  padding: 12px var(--medium-gap);
  gap: var(--medium-gap);
  width: 208px;
  height: 48px;
  border-radius: var(--border-radius-small);
  flex: none;
  align-self: stretch;
  flex-grow: 0;
  cursor: pointer;
  transition: background-color 0.2s ease;
  /* Order defined by list position */
}

/* --- Active/Inactive State --- */
/* Apply these classes to the .NavButton element */
.NavButton--active {
  background: var(--background-dark-purple);
  box-shadow: var(--button-shadow);
}
.NavButton--inactive {
  background: var(--background-light-purple);
  box-shadow: none;
}

.NavButton-IconContainer { /* Container for icon */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  flex: none;
  order: 0;
  flex-grow: 0;
}

.NavButton-Icon { /* The actual icon element/vector */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  border-width: var(--icon-border-thickness);
  border-style: solid;
  /* border-color set by active/inactive state */
  /* Vector path details */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.NavButton-Title { /* Text element */
  height: 16px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  /* color set by active/inactive state */
  flex: none;
  order: 1;
  flex-grow: 1; /* Takes remaining space */
}

/* State-dependent colors for Icon and Title */
.NavButton--active .NavButton-Icon { border-color: var(--font-dark-purple); }
.NavButton--active .NavButton-Title { color: var(--font-dark-purple); }
.NavButton--inactive .NavButton-Icon { border-color: var(--font-medium-purple); }
.NavButton--inactive .NavButton-Title { color: var(--font-medium-purple); }

/* Identify which button is active for THIS screen */
/* Example: Assume Form is active, Calendar/Settings inactive */
.NavButton--form { /* Apply .NavButton--active to this one */ }
.NavButton--calendar { /* Apply .NavButton--inactive to this one */ }
.NavButton--settings { /* Apply .NavButton--inactive to this one */ }