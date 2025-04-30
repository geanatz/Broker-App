/* --- Global Variables (Subset relevant to UpcomingPanel, assume others defined elsewhere) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5);
  --background-light-purple: #CFC4D4; /* Used for MeetingField */
  /* --background-dark-purple: #C5B0CF; */ /* Variable definition if needed elsewhere */

  /* Font Colors */
  --font-light-purple: #9E8AA8;    /* Widget Header Title */
  --font-medium-purple: #886699;   /* Meeting Hour, Date, Description */
  --font-dark-purple: #6F4D80;     /* Meeting Title */

  /* Font Sizes */
  --font-size-small: 14px;   /* Meeting Hour, Date */
  --font-size-medium: 16px;  /* Meeting Description */
  --font-size-large: 18px;   /* Widget Header Title, Meeting Title */
  --font-size-huge: 20px;    /* Not used in this file */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Meeting Hour, Date, Description */
  --font-weight-large: 600;  /* Widget Header Title, Meeting Title */

  /* Border Radius */
  --border-radius-tiny: 8px;
  --border-radius-small: 16px;
  --border-radius-medium: 24px;  /* MeetingField */
  --border-radius-large: 32px;   /* UpcomingWidget */
  --border-radius-huge: 40px;

  /* Icon Sizes (Not used in this specific panel file) */
  --icon-size-medium: 24px;

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px; /* Header padding */
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
}

/* --- Upcoming Panel Layout & Structure --- */

.SecondaryPanel { /* The main container for the Upcoming widget */
  display: flex;
  flex-direction: column; /* Contains UpcomingWidget */
  align-items: flex-start;
  padding: 0px;
  /* gap: 10px; */ /* Gap defined by widget */
  width: 224px;
  height: 1032px; /* Adjust based on content or flex */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.UpcomingWidget { /* The widget frame itself */
  display: flex;
  flex-direction: column;
  align-items: center; /* Centers header/list horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 224px;
  height: 1032px; /* Adjust or use flex */
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none;
  order: 0;
  flex-grow: 1; /* Allow widget to fill panel */
}

/* --- Widget Header --- */

.UpcomingWidget-Header {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--medium-gap); /* 16px horizontal padding */
  width: 208px; /* Widget width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.UpcomingWidget-Header-Title {
  /* width: 176px; */ /* Use flex */
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
  flex-grow: 1; /* Takes available space */
}

/* --- Meeting List --- */

.UpcomingMeetingList { /* Container for MeetingField items */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px; /* Padding is on items */
  gap: var(--default-gap);
  width: 208px; /* Widget width - padding*2 */
  /* height: 568px; */ /* Allow to grow/scroll */
  overflow-y: auto; /* Add scroll if content exceeds height */
  flex: none;
  order: 1; /* After header */
  align-self: stretch;
  flex-grow: 1; /* Takes remaining space in widget */
}

/* --- Meeting Item --- */

.MeetingField {
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Aligns content rows to the left */
  padding: var(--default-gap) var(--medium-gap); /* 8px top/bottom, 16px left/right */
  gap: 0px; /* Elements inside manage their spacing */
  width: 208px;
  height: 88px; /* Fixed height */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  order: 0; /* order managed by list */
  align-self: stretch; /* Take full width of list */
  flex-grow: 0;
}

.MeetingField-HourDateRow {
  display: flex;
  flex-direction: row;
  justify-content: space-between; /* Pushes Hour/Date apart */
  align-items: center;
  padding: 0px;
  gap: 10px; /* Maintain gap if desired */
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
  line-height: 18px; /* Adjusted based on font-size */
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
  justify-content: center; /* Vertically center Title/Desc within 48px */
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
  align-items: center; /* Align text vertically within its box */
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.MeetingField-Description {
  width: 176px;
  height: 24px; /* Container height, line-height controls text */
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center; /* Align text vertically */
  color: var(--font-medium-purple);
  flex: none;
  order: 1;
  align-self: stretch; /* Stretch to container width */
  flex-grow: 0;
}