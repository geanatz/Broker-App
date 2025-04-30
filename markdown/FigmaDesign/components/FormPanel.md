/* --- Global Variables (Subset relevant to FormPanel, assume others defined elsewhere) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5);
  --background-light-purple: #CFC4D4; /* Data Entry Frame BG */
  /* Note: Figma dump uses specific #C6ACD3 for input fields, using that directly */
  --background-input-field: #C6ACD3;
  /* --background-dark-purple: #C5B0CF; */ /* Variable definition if needed elsewhere */

  /* Font Colors */
  --font-light-purple: #9E8AA8;    /* Widget Header Titles, Remove Icon */
  --font-medium-purple: #886699;   /* Input Field Labels, Inactive Button Icon */
  --font-dark-purple: #6F4D80;     /* Input Field Values, Dropdown Icon, Active Button Icon */

  /* Font Sizes */
  --font-size-small: 14px;   /* Not used in this file */
  --font-size-medium: 16px;  /* Not used in this file */
  --font-size-large: 18px;   /* Widget Header Titles, Input Labels, Input Values */
  --font-size-huge: 20px;    /* Not used in this file */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Input Field Values */
  --font-weight-large: 600;  /* Widget Header Titles, Input Field Labels */

  /* Border Radius */
  --border-radius-tiny: 8px;
  --border-radius-small: 16px;   /* Input Fields, Add/Switch Buttons */
  --border-radius-medium: 24px;  /* Data Entry Frames, Scroll Area */
  --border-radius-large: 32px;   /* Data Widgets (Loan/Income) */
  --border-radius-huge: 40px;

  /* Icon Sizes */
  --icon-size-medium: 24px;   /* All icons in this file */

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1); /* Not specified, but likely used on widget */
  --input-shadow: 0px 2px 4px rgba(0, 0, 0, 0.2); /* Input Field Shadow */
  --icon-border-thickness: 2px;
}

/* --- Main Panel Layout --- */

.MainPanel { /* Container for LoanWidget and IncomeWidget */
  display: flex;
  flex-direction: row;
  align-items: stretch; /* Stretch widgets vertically */
  padding: 0px;
  gap: var(--large-gap); /* 24px gap between Loan and Income widgets */
  width: 1288px; /* Adjust based on content or flex */
  height: 1032px; /* Adjust based on content or flex */
  flex: none;
  order: 1; /* Assumed order relative to other panels */
  align-self: stretch;
  flex-grow: 0; /* Or 1 if it should take remaining horizontal space */
}

/* --- Base Data Widget Styles (for Loan & Income) --- */

.DataWidget { /* Base style for LoanWidget and IncomeWidget */
  display: flex;
  flex-direction: column;
  align-items: center; /* Centers content horizontally within the widget */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 632px;
  height: 1032px; /* Or use flex */
  background: var(--widget-background);
  border-radius: var(--border-radius-large);
  box-shadow: var(--widget-shadow); /* Added shadow assuming consistency */
  flex: none;
  /* order: 0 for Loan, 1 for Income (handled by parent flex layout) */
  align-self: stretch; /* Takes full height of MainPanel */
  flex-grow: 1; /* Allow widgets to potentially share space if MainPanel grows */
}

/* --- Data Widget Header --- */

.DataWidget-Header {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--large-gap); /* 24px horizontal padding */
  gap: var(--medium-gap);
  width: 616px; /* Widget width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.DataWidget-Header-Title {
  /* width: 528px; */ /* Use flex */
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
  flex-grow: 1; /* Title takes available space */
}

.DataWidget-Header-Action { /* Container for the remove icon */
  display: flex;
  align-items: center;
  justify-content: center;
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  padding: 0px;
  gap: var(--medium-gap); /* Check if gap is needed */
  flex: none;
  order: 1;
  flex-grow: 0;
}

/* --- Data Widget Content Area --- */

.DataWidget-ContentContainer { /* Wraps Header, ScrollArea, Footer */
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Align content left */
  padding: 0px;
  gap: var(--default-gap);
  width: 616px; /* Widget width - padding*2 */
  /* height: 968px; */ /* Use flex */
  flex: none;
  order: 0; /* Assuming this is the main content block */
  align-self: stretch;
  flex-grow: 1; /* Takes remaining vertical space */
}

.DataWidget-ScrollArea { /* The scrollable list of data entries */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px; /* Padding is on items inside */
  gap: var(--default-gap);
  width: 616px;
  /* height: 936px; */ /* Use flex */
  overflow-y: scroll;
  border-radius: var(--border-radius-medium); /* Clip content */
  flex: none;
  order: 1; /* After Header */
  flex-grow: 1; /* Takes available vertical space before footer */
  /* Note: The Figma dump had flex-grow: 0 here, but for scrolling list, 1 is better */
}

/* --- Data Entry Frame (Purple Box) --- */

.DataEntryFrame { /* Container for a single loan/income record (2 rows) */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: var(--medium-gap);
  gap: var(--medium-gap);
  width: 616px;
  /* height varies: 192px for filled, 104px for empty template */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  /* order managed by ScrollArea */
  flex-grow: 0;
}
.DataEntryFrame--filled { height: 192px; }
.DataEntryFrame--empty { height: 104px; } /* For the add new template */

/* --- Row within Data Entry Frame --- */

.DataEntryRow { /* Contains two InputFieldContainers */
  display: flex;
  flex-direction: row;
  align-items: center; /* Align input containers vertically */
  padding: 0px;
  gap: var(--default-gap);
  width: 584px; /* Frame width - padding*2 */
  height: 72px;
  flex: none;
  /* order: 0 or 1 */
  align-self: stretch;
  flex-grow: 0;
}

/* --- Input Field Components --- */

.InputFieldContainer { /* Label + Input field */
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Changed from flex-end */
  padding: 0px;
  gap: var(--default-gap);
  width: 288px; /* Half of row width - gap/2 */
  height: 72px;
  flex: none;
  /* order: 0 or 1 */
  flex-grow: 1; /* Allow containers to share row space */
}

.InputFieldLabelContainer { /* Wrapper for the label text */
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Align label text left */
  align-items: center;
  padding: 0px var(--default-gap); /* Horizontal padding for label */
  gap: 10px;
  width: 288px;
  height: 16px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.InputFieldLabel { /* The label text itself */
  /* width: 272px; */ /* Use flex */
  height: 16px;
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
  flex-grow: 1; /* Label text takes space */
}

.InputField { /* The actual input box/dropdown */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 12px var(--medium-gap);
  gap: var(--default-gap);
  width: 288px;
  height: 48px;
  background: var(--background-input-field);
  box-shadow: var(--input-shadow);
  border-radius: var(--border-radius-small);
  flex: none;
  order: 1; /* After label */
  flex-grow: 0; /* Don't allow input field itself to grow */
}

.InputFieldValue { /* Text inside the input/dropdown */
  /* width: 224px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  flex-grow: 1; /* Value text takes available space */
  overflow: hidden; /* Added for long text */
  text-overflow: ellipsis; /* Added for long text */
  white-space: nowrap; /* Added for long text */
}

.InputFieldIconContainer { /* Wrapper for dropdown arrow */
   width: var(--icon-size-medium);
   height: var(--icon-size-medium);
   display: flex;
   align-items: center;
   justify-content: center;
   flex: none;
   order: 1;
   flex-grow: 0;
}

/* --- Data Widget Footer --- */

.DataWidget-Footer { /* Container for Add/Switch buttons */
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  padding: 0px;
  gap: var(--default-gap); /* Added gap between buttons */
  width: 616px; /* Match content width */
  height: var(--border-radius-huge); /* 40px */
  flex: none;
  order: 2; /* After ScrollArea */
  align-self: stretch;
  flex-grow: 0;
}

/* --- Small Icon Buttons (Add/Switch User) --- */

.IconButton--small {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  padding: var(--default-gap);
  gap: 10px;
  width: var(--border-radius-huge); /* 40px */
  height: var(--border-radius-huge); /* 40px */
  border-radius: var(--border-radius-small); /* 16px */
  flex: none;
  /* order: 0 or 1 */
  flex-grow: 0;
  cursor: pointer; /* Added */
}

/* Determine active/inactive state */
.IconButton--small-active {
  background: var(--background-input-field); /* Same as input field BG */
}
.IconButton--small-inactive {
  background: transparent; /* Or potentially a light grey? Check design */
}

/* --- Icons --- */

.Icon { /* Base Icon Style */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* Specific Icon Styles */
.Icon--remove {
  /* Use Icons.remove or Icons.remove_circle_outline */
  color: var(--font-light-purple);
  /* Vector border: var(--icon-border-thickness) solid var(--font-light-purple); */
}

.Icon--dropdown {
  /* Use Icons.arrow_drop_down or Icons.keyboard_arrow_down */
  color: var(--font-dark-purple);
  /* Vector border: var(--icon-border-thickness) solid var(--font-dark-purple); */
}

.Icon--user-single {
  /* Use Icons.person */
  /* Color depends on active/inactive state */
}

.Icon--user-multiple {
  /* Use Icons.group */
  /* Color depends on active/inactive state */
}

/* Icon color based on button state */
.IconButton--small-active .Icon {
  color: var(--font-dark-purple);
  /* Vector border: var(--icon-border-thickness) solid var(--font-dark-purple); */
}
.IconButton--small-inactive .Icon {
  color: var(--font-medium-purple); /* Assuming inactive color */
  /* Vector border: var(--icon-border-thickness) solid var(--font-medium-purple); */
}

/* Note on Vector Details: As before, map these to appropriate IconData/SVG and color/stroke props in Flutter. */