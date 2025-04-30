/* --- Global Variables (Subset relevant to CalendarPanel) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5);
  --background-light-purple: #CFC4D4; /* Calendar Container BG */
  /* Note: Figma dump uses #C6ACD3 for slots, using that directly */
  --background-slot-reserved: #C6ACD3;
  /* --background-dark-purple: #C5B0CF; */ /* Variable defined if needed */

  /* Font Colors */
  --font-light-purple: #9E8AA8;    /* Widget Header Title, Calendar Type, Swap Icon */
  --font-medium-purple: #886699;   /* Day Labels, Hour Labels, Slot Client Name, Slot Create Text */
  --font-dark-purple: #6F4D80;     /* Slot Consultant Name */

  /* Font Sizes */
  --font-size-small: 14px;   /* Not used directly */
  --font-size-medium: 16px;  /* Calendar Type, Day Labels, Hour Labels, Slot Client/Create Text */
  --font-size-large: 18px;   /* Widget Header Title, Slot Consultant Name */
  --font-size-huge: 20px;    /* Not used directly */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Calendar Type, Day Labels, Hour Labels, Slot Client Name */
  --font-weight-large: 600;  /* Widget Header Title, Slot Consultant Name, Slot Create Text */

  /* Border Radius */
  --border-radius-tiny: 8px;     /* Calendar Column (implicit) */
  --border-radius-small: 16px;   /* Calendar Slots */
  --border-radius-medium: 24px;  /* Calendar Container */
  --border-radius-large: 32px;   /* Calendar Widget */
  --border-radius-huge: 40px;

  /* Icon Sizes */
  --icon-size-small: 20px;    /* Swap Icon */
  --icon-size-medium: 24px;

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1); /* Assumed */
  --slot-shadow: 0px 2px 4px rgba(0, 0, 0, 0.25); /* Reserved Slot Shadow */
  --icon-border-thickness: 2px;
  --slot-border-thickness: 4px; /* Available Slot Border */
  --slot-column-width: 240px;   /* Width of a day column */
  --hour-label-width: 48px;     /* Width of the hour label column */
}

/* --- Main Panel Layout (Container for CalendarWidget) --- */

.MainPanel { /* Optional: If this panel exists outside CalendarWidget */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: 10px; /* Gap between potential elements in MainPanel */
  width: 1376px; /* Adjust as needed */
  height: 1032px; /* Adjust as needed */
  flex: none;
  order: 1; /* Assumed order */
  flex-grow: 0;
}

/* --- Calendar Widget --- */

.CalendarWidget { /* The main widget frame */
  display: flex;
  flex-direction: column;
  align-items: center; /* Center header/container horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 1376px;
  height: 1032px; /* Adjust or use flex */
  background: var(--widget-background);
  border-radius: var(--border-radius-large);
  box-shadow: var(--widget-shadow); /* Added */
  flex: none;
  order: 0; /* Within MainPanel */
  align-self: stretch; /* Stretch to fill MainPanel */
  flex-grow: 1; /* Allow to grow if MainPanel grows */
}

/* --- Calendar Widget Header --- */

.CalendarWidget-Header {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between; /* Space between title and switch */
  padding: 0px var(--medium-gap); /* 16px horizontal padding */
  width: 1360px; /* Widget width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CalendarWidget-Header-TitleContainer {
  display: flex; /* Added wrapper */
  flex-direction: row;
  align-items: center;
  padding: 0px;
  /* width: 1176px; */ /* Use flex */
  height: 24px;
  flex: none;
  order: 0;
  flex-grow: 1; /* Title container takes space */
}

.CalendarWidget-Header-Title {
  /* width: 1176px; */ /* Use flex */
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
  flex-grow: 1; /* Title text takes space */
}

.CalendarSwitch { /* Container for type label and swap icon */
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

.CalendarType { /* Text label (e.g., "Intalniri cu clientii") */
  /* width: 124px; */ /* Allow flexible width */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  justify-content: flex-end; /* Align text right */
  text-align: right;
  color: var(--font-light-purple);
  flex: none;
  order: 0;
  flex-grow: 0; /* Or 1 if it should push icon */
}

.SwapIconContainer { /* Wrapper for the swap icon */
  display: flex;
  align-items: center;
  justify-content: center;
  width: var(--icon-size-small); /* 20px */
  height: var(--icon-size-small); /* 20px */
  padding: 0px;
  /* gap: 10px; */ /* Not needed */
  flex: none;
  order: 1;
  flex-grow: 0;
  cursor: pointer; /* Added */
}

/* --- Calendar Grid Area --- */

.CalendarContainer { /* The purple background area holding the grid */
  display: flex;
  flex-direction: column; /* Stacks Days Row and Grid */
  align-items: flex-start;
  padding: var(--medium-gap);
  gap: var(--default-gap);
  width: 1360px; /* Widget width - padding*2 */
  /* height: 984px; */ /* Use flex */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  order: 1; /* After header */
  flex-grow: 1; /* Takes remaining space in widget */
  overflow: hidden; /* Contains scrolling grid */
}

.CalendarDaysRow { /* Row containing day labels */
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  /* padding: 0px 0px 0px calc(var(--hour-label-width) + var(--medium-gap)); */ /* Align with start of day columns */
  padding-left: calc(var(--hour-label-width) + var(--medium-gap)); /* Simpler padding */
  gap: var(--medium-gap);
  width: 100%; /* Take full width of container */
  /* width: 1328px; */ /* Container width - padding*2 */
  box-sizing: border-box; /* Include padding in width */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CalendarDayLabel { /* Label for a single day (e.g., "Luni 20") */
  width: var(--slot-column-width); /* Matches slot column width */
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
  /* order managed by parent Row */
  flex-grow: 0;
}

.CalendarGrid { /* Container for hours column and day columns (scrollable) */
  display: flex;
  flex-direction: row; /* Hours column + Day columns */
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap);
  width: 100%; /* Take full width of container */
  /* width: 1328px; */ /* Container width - padding*2 */
  box-sizing: border-box;
  /* height: 920px; */ /* Use flex */
  overflow-y: scroll; /* Enable vertical scroll */
  flex: none;
  order: 1; /* After day labels */
  flex-grow: 1; /* Takes remaining space in CalendarContainer */
}

/* --- Hour Labels Column --- */

.CalendarHoursColumn {
  display: flex;
  flex-direction: column;
  align-items: center; /* Center hour text */
  padding: var(--default-gap) 0px; /* Vertical padding */
  gap: 56px; /* Large gap between hours (64px slot height + 16px gap - 24px text height) */
  width: var(--hour-label-width); /* 48px */
  /* height matches scroll content */
  flex: none;
  order: 0; /* First column in the grid */
  flex-grow: 0;
}

.CalendarHourLabel { /* Label for a single hour (e.g., "09:30") */
  width: var(--hour-label-width);
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
  /* order managed by parent Column */
  align-self: stretch;
  flex-grow: 0;
}

/* --- Meeting Slots Column (One per day) --- */

.MeetingSlotsColumn { /* A single day's worth of time slots */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap); /* Gap between slots */
  width: var(--slot-column-width); /* 240px */
  /* height matches scroll content */
  border-radius: var(--border-radius-tiny); /* Optional rounding for column */
  flex: none;
  /* order managed by parent Row */
  align-self: stretch; /* Stretch vertically */
  flex-grow: 0;
}

/* --- Individual Time Slot --- */

.CalendarSlot { /* Base style for both available and reserved slots */
  box-sizing: border-box; /* Include border in size */
  display: flex;
  flex-direction: column;
  justify-content: center; /* Center content vertically */
  align-items: center; /* Center content horizontally */
  padding: 6px var(--medium-gap); /* 6px top/bottom, 16px left/right */
  width: var(--slot-column-width);
  height: 64px; /* Fixed height */
  border-radius: var(--border-radius-small);
  flex: none;
  /* order managed by parent Column */
  align-self: stretch;
  flex-grow: 0;
  cursor: pointer; /* Indicate interactivity */
}

.CalendarSlot--available {
  border: var(--slot-border-thickness) solid var(--background-slot-reserved); /* Use BG color for border */
  background: transparent; /* No background fill */
}

.CalendarSlot--reserved {
  background: var(--background-slot-reserved);
  box-shadow: var(--slot-shadow);
  border: none; /* No border */
}

/* --- Text inside Slots --- */

.CalendarSlot-CreateText { /* Text in available slots */
  /* width: 208px; */ /* Use flex */
  height: 24px; /* Container height */
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

.CalendarSlot-ConsultantName { /* Top text in reserved slots */
  /* width: 208px; */ /* Use flex */
  height: 24px; /* Container height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center; /* Vertically center */
  justify-content: flex-start; /* Align text left */
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CalendarSlot-ClientName { /* Bottom text in reserved slots */
  /* width: 208px; */ /* Use flex */
  height: 20px; /* Container height */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center; /* Vertically center */
  justify-content: flex-start; /* Align text left */
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0;
}


/* --- Icons --- */
.Icon { /* Base Icon Style */
  width: var(--icon-size-small); /* Default to small for SwapIcon */
  height: var(--icon-size-small);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  border-width: var(--icon-border-thickness);
  border-style: solid;
  flex: none;
  order: 0; /* Default */
  flex-grow: 0;
}

.Icon--swap {
  /* Use Icons.swap_horiz or Icons.sync */
  border-color: var(--font-light-purple);
  /* Vector details define path */
}