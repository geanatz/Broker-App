/* --- Global Variables (Subset relevant to CallPanel, assume others defined elsewhere) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5);
  --background-light-blue: #C4CFD4;
  --background-light-purple: #CFC4D4;
  --background-light-red: #D4C4C4;
  /* Note: Figma dump uses specific shades for dark backgrounds, using them directly */
  --background-button-blue: #ACC6D3; /* Specific to Next Call Button */
  --background-button-purple: #C6ACD3; /* Specific to Speech Button */
  --background-button-red: #D3ACAC;   /* Specific to Past Call Button */
  /* --background-dark-blue: #B0C5CF; */ /* Variable definition if needed elsewhere */
  /* --background-dark-purple: #C5B0CF; */ /* Variable definition if needed elsewhere */
  /* --background-dark-red: #CFB0B0; */ /* Variable definition if needed elsewhere */

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
  --font-size-tiny: 12px;    /* Not used in this file */
  --font-size-small: 14px;   /* Not used in this file */
  --font-size-medium: 16px;  /* Contact Number, Timer */
  --font-size-large: 18px;   /* Headers, Contact Name */
  --font-size-huge: 20px;    /* Not used in this file */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Header Titles (Next), Contact Number, Timer */
  --font-weight-large: 600;  /* Header Titles (Ongoing, Past), Contact Name */

  /* Border Radius */
  --border-radius-tiny: 8px;
  --border-radius-small: 16px;   /* Buttons */
  --border-radius-medium: 24px;  /* Contact Items */
  --border-radius-large: 32px;   /* Frames (Calls) */
  --border-radius-huge: 40px;

  /* Icon Sizes */
  --icon-size-medium: 24px;   /* All icons in this file */

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px; /* Header padding */
  --contact-item-gap: 20px; /* Specific gap for ongoing/past contacts */
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
  --icon-border-thickness: 2px;
}

/* --- Call Panel Layout & Structure --- */

.SecondaryPanel { /* The main container for the call widgets */
  display: flex;
  flex-direction: row; /* Or column if CallWidget is only child */
  align-items: flex-start; /* Changed from center */
  padding: 0px;
  gap: 10px; /* Check if this gap is needed */
  width: 312px;
  height: 1032px; /* Adjust based on content or flex */
  flex: none;
  order: 0;
  flex-grow: 0;
}

.CallWidget { /* Wrapper inside SecondaryPanel */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0px;
  gap: var(--medium-gap); /* Gap between Next/Ongoing/Past frames */
  width: 312px;
  height: 1032px; /* Adjust based on content or flex */
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* --- Generic Call Frame Styles --- */

.CallsFrame {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 312px;
  background: var(--widget-background);
  box-shadow: var(--widget-shadow);
  border-radius: var(--border-radius-large);
  flex: none;
  flex-grow: 0;
  /* order is managed by CallWidget layout */
}
.CallsFrame--next { height: 440px; }
.CallsFrame--ongoing { height: 120px; }
.CallsFrame--past { height: 440px; }

/* --- Generic Header Styles within Call Frames --- */

.CallsFrame-Header {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0px var(--large-gap); /* 24px horizontal padding */
  gap: var(--medium-gap);
  width: 296px; /* Frame width - padding*2 */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.CallsFrame-Header-Title {
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  /* font-weight varies */
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  /* color varies */
  flex: none;
  order: 0;
  flex-grow: 1; /* Default: takes space */
}
.CallsFrame-Header-Title--next {
  color: var(--font-light-blue);
  font-weight: var(--font-weight-medium); /* Note: Next calls title is medium weight */
  width: 206px; /* Fixed width from figma */
  flex-grow: 0; /* Override flex-grow due to fixed width */
}
.CallsFrame-Header-Title--ongoing {
  color: var(--font-light-purple);
  font-weight: var(--font-weight-large);
  width: 168px; /* Fixed width */
  flex-grow: 0; /* Override flex-grow */
}
.CallsFrame-Header-Title--past {
  color: var(--font-light-red);
  font-weight: var(--font-weight-large);
  width: 206px; /* Fixed width */
  flex-grow: 0; /* Override flex-grow */
}

.CallsFrame-Header-Subtitle { /* e.g., Timer */
  width: 64px; /* Fixed width */
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
  order: 1;
  flex-grow: 1; /* Takes remaining space */
}

.CallsFrame-Header-IconContainer { /* For View Icon */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex; /* Added */
  align-items: center; /* Added */
  justify-content: center; /* Added */
  flex: none;
  order: 1;
  flex-grow: 0;
}

/* --- Contact Item Styles --- */

.ContactItem {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: var(--default-gap);
  /* gap varies: 16px for next, 20px for ongoing/past */
  width: 296px; /* Frame width - padding*2 */
  height: 72px;
  border-radius: var(--border-radius-medium);
  /* background varies */
  flex: none;
  /* order varies */
  align-self: stretch;
  flex-grow: 0;
}
.ContactItem--next {
  background: var(--background-light-blue);
  gap: var(--medium-gap); /* 16px */
}
.ContactItem--ongoing {
  background: var(--background-light-purple);
  gap: var(--contact-item-gap); /* 20px */
}
.ContactItem--past {
  background: var(--background-light-red);
  gap: var(--contact-item-gap); /* 20px */
}

.ContactItem-Details {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start; /* Align text left */
  padding: 0px 0px 0px var(--default-gap); /* Left padding */
  gap: 4px;
  /* width varies slightly (208px vs 204px), use flex */
  height: 47px;
  flex: none;
  order: 0;
  flex-grow: 1; /* Takes available space */
}

.ContactItem-Name {
  height: 23px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  /* color varies */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0; /* Name takes full width */
  /* width is implicitly controlled by align-self: stretch */
}
.ContactItem-Name--next { color: var(--font-dark-blue); }
.ContactItem-Name--ongoing { color: var(--font-dark-purple); }
.ContactItem-Name--past { color: var(--font-dark-red); }

.ContactItem-Number {
  height: 20px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-medium);
  line-height: 20px;
  display: flex;
  align-items: center;
  /* color varies */
  flex: none;
  order: 1;
  align-self: stretch;
  flex-grow: 0; /* Number takes full width */
  /* width is implicitly controlled by align-self: stretch */
}
.ContactItem-Number--next { color: var(--font-medium-blue); }
.ContactItem-Number--ongoing { color: var(--font-medium-purple); }
.ContactItem-Number--past { color: var(--font-medium-red); }

/* --- Button Styles within Contact Items --- */

.CallButton { /* Base style for Call/Speech buttons */
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  padding: var(--medium-gap);
  gap: var(--default-gap);
  width: 56px;
  height: 56px;
  border-radius: var(--border-radius-small);
  /* background varies */
  flex: none;
  order: 1;
  flex-grow: 0;
}
.CallButton--next { background: var(--background-button-blue); }
.CallButton--ongoing { background: var(--background-button-purple); } /* This is the Speech Button */
.CallButton--past { background: var(--background-button-red); }

/* --- Icon Styles --- */

.Icon { /* Base Icon Style */
  width: var(--icon-size-medium);
  height: var(--icon-size-medium);
  display: flex; /* Needed for potential transforms/alignment */
  align-items: center;
  justify-content: center;
  position: relative; /* For absolute positioned vectors if using CSS approach */
  /* In Flutter, use Icon(iconData, size, color) */
  flex: none;
  order: 0;
  flex-grow: 0;
}

/* Specific Icon Styles (Color, Transformation) */
/* In Flutter, you'd select the IconData and apply color/transform */

.Icon--view { /* Used in Next Calls Header */
  /* Use appropriate IconData (e.g., Icons.visibility) */
  color: var(--font-light-blue); /* Apply color to Flutter Icon */
  /* Vector border color: var(--font-light-blue); */
}
.Icon--view-past { /* Used in Past Calls Header */
  /* Use appropriate IconData */
  color: var(--font-light-red); /* Apply color to Flutter Icon */
  /* Vector border color: var(--font-light-red); */
}

.Icon--call-next { /* Used in Next Calls Button */
  /* Use appropriate IconData (e.g., Icons.call) */
  color: var(--font-dark-blue); /* Apply color to Flutter Icon */
  /* Vector border color: var(--font-dark-blue); */
}

.Icon--speech { /* Used in Ongoing Call Button */
  /* Use appropriate IconData (e.g., Icons.mic or custom) */
  color: var(--font-dark-purple); /* Apply color to Flutter Icon */
  /* Vector border color: var(--font-dark-purple); */
}

.Icon--call-past { /* Used in Past Calls Button */
  /* Use appropriate IconData (e.g., Icons.call_missed or custom) */
  color: var(--font-dark-red); /* Apply color to Flutter Icon */
  transform: rotate(135deg); /* Apply Transform.rotate in Flutter */
  /* Vector border color: var(--font-dark-red); */
}

/* Note on Icon Vectors:
   The 'Vector' properties (position, left, right, top, bottom, border)
   describe the icon's visual path/shape in Figma's CSS export.
   In Flutter, you would typically:
   1. Use a predefined `IconData` from `Icons`.
   2. Use a custom `IconData` generated from an icon font.
   3. Use an `SvgPicture` widget with an SVG asset.
   The color is applied via the `color` property of the `Icon` widget
   or through the SVG's fill/stroke properties. The `border: 2px`
   likely corresponds to the stroke width in the icon design.
*/