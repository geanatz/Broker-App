/* --- Global Variables (Relevant subset for Popup) --- */
:root {
  /* Backgrounds */
  --widget-background: rgba(255, 255, 255, 0.5); /* Using widget 50% opacity based on Figma */
  /* --popup-background: rgba(255, 255, 255, 0.75); */ /* Variable definition */
  --background-light-purple: #CFC4D4; /* Form container background */
  /* Note: Figma dump uses specific #C6ACD3 for input/button, using that directly */
  --background-interactive-purple: #C6ACD3; /* Input & Button BG */
  /* --background-dark-purple: #C5B0CF; */ /* Variable defined for reference */

  /* Font Colors */
  --font-light-purple: #9E8AA8;    /* Popup Header Title */
  --font-medium-purple: #886699;   /* Field Label */
  --font-dark-purple: #6F4D80;     /* Input Hint/Value, Button Text */

  /* Font Sizes */
  --font-size-small: 14px;   /* Not used here */
  --font-size-medium: 16px;  /* Not used here */
  --font-size-large: 18px;   /* Field Label, Input Text, Button Text */
  --font-size-huge: 20px;    /* Popup Header Title */

  /* Font Weights */
  --font-weight-small: 400;  /* Regular (Placeholder) */
  --font-weight-medium: 500; /* Input Hint/Value, Button Text */
  --font-weight-large: 600;  /* Popup Header Title, Field Label */

  /* Border Radius */
  --border-radius-tiny: 8px;
  --border-radius-small: 16px;   /* Input */
  --border-radius-medium: 24px;  /* Form Container, Button */
  --border-radius-large: 32px;   /* Popup Frame */
  --border-radius-huge: 40px;

  /* Icon Sizes */
  --icon-size-medium: 24px;

  /* Other */
  --default-gap: 8px;
  --medium-gap: 16px;
  --large-gap: 24px;
  --icon-border-thickness: 2px;
  --widget-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1); /* Assumed popup has shadow */
}

/* --- Popup Base Styles --- */

.CreateReservationPopup {
  /* Layout & Positioning */
  display: flex; /* Column layout for header, form, buttons */
  flex-direction: column;
  justify-content: center; /* Center content vertically (in this fixed size) */
  align-items: center; /* Center content horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 320px;
  height: 200px;

  /* Positioning: Indicates centering on screen */
  /* In Flutter, use showDialog() or Stack + Center/Align */
  position: absolute;
  left: calc(50% - 160px); /* 320px / 2 */
  top: calc(50% - 100px); /* 200px / 2 */

  /* Appearance */
  background: var(--widget-background); /* Using 50% opacity per Figma */
  border-radius: var(--border-radius-large);
  box-shadow: var(--widget-shadow); /* Added assumption */

  /* Flex properties */
  flex: none;
  /* order N/A for absolute */
  flex-grow: 0;
}

/* --- Popup Header --- */

.PopupHeader {
  display: flex;
  flex-direction: row;
  justify-content: center; /* Centers title container */
  align-items: center;
  padding: var(--default-gap) var(--medium-gap) 0px; /* Padding: 8px 16px 0px */
  gap: var(--medium-gap); /* Gap between potential elements (like close button) */
  width: 304px; /* Popup width - padding*2 */
  height: 32px;
  flex: none;
  order: 0;
  align-self: stretch; /* Take full width */
  flex-grow: 0;
}

.PopupHeader-TitleContainer { /* Wrapper allows title to grow */
  display: flex;
  flex-direction: column; /* Although only one text element currently */
  justify-content: center;
  align-items: center;
  padding: 0px;
  /* width: 272px; */ /* Use flex */
  height: 24px;
  flex: none;
  order: 0;
  align-self: stretch; /* Vertical stretch */
  flex-grow: 1; /* Allow title container to take space */
}

.PopupHeader-Title { /* "Creeaza programare" text */
  width: 100%; /* Take full width of container */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-large);
  font-size: var(--font-size-huge); /* 20px */
  line-height: 25px; /* Check consistency */
  display: flex;
  align-items: center;
  color: var(--font-light-purple);
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
  text-align: left; /* Assuming text aligns left by default */
}

/* --- Popup Form Area --- */

.PopupForm { /* Light purple container for the form fields */
  display: flex;
  flex-direction: column;
  justify-content: center; /* Center field vertically */
  align-items: center; /* Center field horizontally */
  padding: var(--default-gap);
  gap: var(--default-gap);
  width: 304px; /* Popup width - padding*2 */
  height: 88px; /* Adjust if more fields added */
  background: var(--background-light-purple);
  border-radius: var(--border-radius-medium);
  flex: none;
  order: 1; /* Below header */
  align-self: stretch;
  flex-grow: 0;
}

/* --- Form Field (Label + Input) --- */

.FormField { /* Container for a single field (label + input) */
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* Align label/input to the start */
  padding: 0px;
  gap: 0px; /* Let label/input define spacing */
  width: 288px; /* Form width - padding*2 */
  height: 72px;
  flex: none;
  order: 0; /* Only one field shown */
  align-self: stretch;
  flex-grow: 0;
}

.FormField-LabelContainer { /* Wrapper for the label */
  display: flex;
  flex-direction: row;
  justify-content: flex-start; /* Align text left */
  align-items: center;
  padding: 0px var(--default-gap); /* 8px horizontal padding */
  gap: 10px; /* Figma specific gap */
  width: 288px;
  height: 24px; /* Increased from 16px to fit line-height */
  flex: none;
  order: 0;
  align-self: stretch;
  flex-grow: 0;
}

.FormField-Label { /* "Nume client" text */
  /* width: 272px; */ /* Use flex */
  height: 24px;
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
  flex-grow: 1; /* Label text takes available space */
}

.FormInput { /* The actual input field */
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 12px var(--medium-gap); /* 12px top/bottom, 16px left/right */
  gap: var(--default-gap);
  width: 288px;
  height: 48px;
  background: var(--background-interactive-purple);
  border-radius: var(--border-radius-small);
  /* Input shadow might be desired, add if needed: box-shadow: var(--input-shadow); */
  flex: none;
  order: 1; /* After label */
  align-self: stretch;
  flex-grow: 0;
  /* In Flutter: This would be a TextField widget */
}

.FormInput-HintText { /* "Introdu numele clientului" text */
  /* width: 256px; */ /* Use flex */
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
  flex-grow: 1; /* Hint text takes space */
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  /* In Flutter: Set this as the 'hintText' in InputDecoration */
}

/* --- Popup Button Section --- */

.PopupButtonSection { /* Container for the button(s) */
  display: flex;
  flex-direction: row;
  justify-content: center; /* Center button(s) horizontally */
  align-items: flex-start; /* Align button top */
  padding: 0px;
  gap: var(--default-gap); /* Gap between buttons if multiple */
  width: 304px; /* Popup width - padding*2 */
  height: 48px;
  flex: none;
  order: 2; /* Below form */
  align-self: stretch;
  flex-grow: 0;
}

.PopupButton { /* Style for the main action button */
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center; /* Center text inside */
  padding: 12px var(--medium-gap); /* 12px top/bottom, 16px left/right */
  gap: var(--default-gap);
  width: 304px; /* Takes full width in this layout */
  height: 48px;
  background: var(--background-interactive-purple);
  border-radius: var(--border-radius-medium); /* Uses medium radius */
  flex: none;
  order: 0;
  flex-grow: 1; /* Takes full width in ButtonSection */
  cursor: pointer;
  text-align: center;
  /* In Flutter: Use ElevatedButton, TextButton etc. */
}

.PopupButton-Text { /* "Salveaza" text */
  /* width: 272px; */ /* Use flex */
  height: 24px;
  font-family: 'Outfit';
  font-style: normal;
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-large);
  line-height: 23px;
  display: flex;
  align-items: center;
  justify-content: center; /* Center text */
  text-align: center;
  color: var(--font-dark-purple);
  flex: none;
  order: 0;
  flex-grow: 1; /* Text takes space within button */
}