/* Base Font - Assuming 'Outfit' is imported elsewhere */
body {
    font-family: 'Outfit', sans-serif; /* Added default */
}

/* ==========================================================================
   Main Screen Layout
   ========================================================================== */

.CalendarScreen {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 24px;
    gap: 24px;
    position: relative;
    width: 1920px;
    height: 1080px;
    background: linear-gradient(107.56deg, #A4B8C2 0%, #C2A4A4 100%);
}

/* ==========================================================================
   Upcoming Widget (Left Column)
   ========================================================================== */

.UpcomingWidget {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 8px;
    gap: 8px;
    width: 224px;
    height: 1032px;
    background: rgba(242, 242, 242, 0.5);
    box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
    border-radius: 32px;
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
}

.UpcomingWidget .WidgetHeader {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px 16px; /* Specific padding */
    width: 208px;
    height: 24px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
}

.UpcomingWidget .WidgetHeader .Title {
    /* width: 176px; */ /* Let flex-grow handle width */
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px;
    display: flex;
    align-items: center;
    color: #9E8AA8; /* Specific color for this header */
    /* flex: none; order: 0; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1; /* Explicitly set flex-grow */
}

.UpcomingMeetingFields {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 0px;
    gap: 8px;
    width: 208px;
    /* height: 568px; */ /* Height might be dynamic */
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.MeetingField {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 8px 16px;
    width: 208px; /* Use width from container or calc if needed */
    /* height: 88px; */ /* Height can be auto */
    background: #CFC4D4;
    border-radius: 24px;
    /* flex: none; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    /* order: X; */ /* Order is instance specific */
    align-self: stretch;
    box-sizing: border-box; /* Added for consistent padding/border */
}

.MeetingField .HourAndDate { /* Changed & to And for validity */
    display: flex;
    flex-direction: row;
    justify-content: center; /* Original had center, keeping it */
    align-items: center;
    padding: 0px;
    gap: 10px;
    width: 176px;
    height: 24px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.MeetingField .Hour {
    /* width: 83px; */ /* Use flex-grow */
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 14px;
    line-height: 18px;
    display: flex;
    align-items: center;
    color: #886699;
    /* flex: none; order: 0; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

.MeetingField .Date {
    /* width: 83px; */ /* Use flex-grow */
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 14px;
    line-height: 18px;
    display: flex;
    align-items: center;
    text-align: right;
    color: #886699;
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
    justify-content: flex-end; /* Ensure right alignment */
}

.MeetingField .TitleAndDescription { /* Changed & to And for validity */
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center; /* Aligns text center if container wider */
    padding: 0px;
    width: 176px;
    /* height: 48px; */ /* Height can be auto */
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.MeetingField .Title {
    /* width: 176px; */ /* Use align-self from parent */
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px;
    display: flex;
    align-items: center;
    color: #6F4D80; /* Specific color */
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.MeetingField .Description {
    /* width: 176px; */ /* Use align-self from parent */
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    color: #886699; /* Specific color */
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch; /* To take full width */
}


/* ==========================================================================
   Calendar Widget (Center Column)
   ========================================================================== */

.CalendarWidget {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px;
    gap: 8px;
    width: 1376px;
    height: 1032px;
    background: rgba(242, 242, 242, 0.5);
    border-radius: 32px;
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
}

.CalendarWidget .WidgetHeader {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px 16px; /* Specific padding */
    width: 1360px;
    height: 24px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.CalendarWidget .WidgetHeader .Title { /* Scoped Title container */
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px;
    /* width: 1180px; */ /* Use flex-grow */
    height: 24px;
    /* flex: none; order: 0; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

.CalendarWidget .WidgetHeader .CalendarTitle { /* Specific class for Calendar text */
    /* width: 1180px; */ /* Use flex-grow */
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px;
    display: flex;
    align-items: center;
    color: #9E8AA8; /* Specific color */
    /* flex: none; order: 0; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

.CalendarSwitch {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px;
    /* width: 148px; */ /* Width can be auto */
    height: 24px;
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
    flex-grow: 0; /* Explicitly don't grow */
    gap: 8px; /* Added gap for spacing */
}

.CalendarSwitch .SwitchLabel { /* Renamed 'Intalniri cu clientii' */
    /* width: 124px; */ /* Width auto */
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    text-align: right;
    color: #9E8AA8;
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
}

/* Generic Dropdown Button/Icon Styling */
.DropdownButton {
    width: 24px;
    height: 24px;
    position: relative; /* Needed for absolute positioning of icon */
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
    cursor: pointer; /* Indicate interactivity */
}

.DropdownIcon {
    position: absolute;
    left: 33.33%; /* 8px / 24px */
    right: 33.33%;
    top: 41.67%; /* 10px / 24px */
    bottom: 41.67%;
    width: 8px; /* Calculated from percentages */
    height: 4px; /* Calculated from percentages */
    border-left: 2px solid #9E8AA8;
    border-bottom: 2px solid #9E8AA8;
    transform: rotate(-45deg); /* Create arrow shape */
    /* Original border property was unusual for a dropdown icon */
}


.CalendarContainer {
    display: flex;
    flex-direction: column;
    /* justify-content: center; */ /* Should likely be flex-start */
    align-items: flex-start;
    padding: 16px;
    gap: 8px;
    width: 1360px;
    /* height: 984px; */ /* Should likely use flex-grow */
    background: #CFC4D4;
    border-radius: 24px;
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1; /* Takes remaining space */
    box-sizing: border-box;
}

.CalendarDays {
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    padding: 0px; /* Inner padding seems off */
    gap: 16px;
    width: 1328px; /* 1360 - 2*16 padding */
    height: 24px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    box-sizing: border-box;
}

.CalendarDays .HourOffset { /* Was Frame 94, represents the empty space */
    /* display: flex; flex-direction: row; align-items: center; */ /* Not needed if just for spacing */
    /* padding: 0px 0px 0px 64px; */ /* Padding seems wrong, use width */
    /* gap: 16px; */
    width: 48px; /* Matches CalendarHours width */
    height: 24px;
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    flex-shrink: 0; /* Prevent shrinking */
}

.CalendarDays .DaysContainer { /* Was Frame 94 */
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px;
    gap: 16px; /* Gap between day labels */
    /* width: 659px; */ /* Use flex-grow */
    height: 24px;
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    flex-grow: 1; /* Takes up remaining width */
    align-self: stretch;
}

.CalendarDays .DayLabel { /* Consolidated Luni, Marti etc. */
    width: 240px; /* Fixed width per day column */
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    justify-content: center; /* Added for centering text */
    text-align: center;
    color: #886699;
    /* flex: none; flex-grow: 0; */ /* Layout context specific */
    /* order: X; */ /* Order is instance specific */
    flex-shrink: 0; /* Prevent shrinking */
}


.CalendarGrid { /* Renamed 'Calendar' */
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    padding: 0px;
    gap: 16px;
    width: 1328px; /* Matches CalendarDays width */
    /* height: 920px; */ /* Should use flex-grow */
    overflow-y: scroll;
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1; /* Takes remaining vertical space */
}

.CalendarHours {
    display: flex;
    flex-direction: column;
    align-items: flex-start; /* Text aligns left/center based on text-align */
    padding: 8px 0px; /* Padding top/bottom */
    gap: 56px; /* Gap between hour labels (80px total slot height - 24px label height) */
    width: 48px;
    /* height: 1080px; */ /* Height should be auto/scroll */
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    flex-shrink: 0; /* Prevent shrinking */
}

.CalendarHours .HourLabel { /* Consolidated 09:30, 10:00 etc. */
    width: 48px;
    height: 24px;
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    justify-content: center; /* Center text horizontally */
    text-align: center;
    color: #886699;
    /* flex: none; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    /* order: X; */ /* Order is instance specific */
    align-self: stretch;
}


.MeetingSlotsContainer { /* New container for all day columns */
    display: flex;
    flex-direction: row;
    justify-content: flex-start; /* Align columns to the left */
    align-items: flex-start;
    padding: 0px; /* Padding is on individual columns maybe */
    gap: 16px; /* Gap between day columns */
    flex-grow: 1; /* Take remaining space */
}

.MeetingSlots { /* Represents a single day column */
    display: flex;
    /* flex-direction: row; */ /* Original was row, but content (Column) is column. Assuming column needed. */
    flex-direction: column; /* Changed to column */
    /* justify-content: center; */ /* Should be flex-start */
    align-items: flex-start;
    padding: 0px; /* No padding on the container */
    gap: 16px; /* Gap between slots within the column */
    width: 240px;
    /* height: 1104px; */ /* Height is dynamic/scroll */
    border-radius: 8px; /* Applied to column */
    /* flex: none; order: X; flex-grow: 0; */ /* Layout context specific */
}

/* .Column was identical to MeetingSlots, removed */

.ReservedSlot {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center; /* Centers text lines if they are shorter */
    padding: 6px 16px;
    width: 240px; /* Fixed width from parent column */
    height: 64px; /* Fixed height for a 30min slot? */
    background: #C4B3CC;
    border-radius: 16px;
    /* flex: none; order: X; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    box-sizing: border-box;
}

.ReservedSlot .Consultant {
    width: 208px; /* (240 - 2*16 padding) */
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px;
    display: flex;
    align-items: center;
    color: #6F4D80;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.ReservedSlot .Client {
    width: 208px;
    height: 20px;
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    color: #886699;
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.AvailableSlotButton { /* Renamed from AvailableSlot(Button) */
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 6px 16px;
    width: 240px;
    height: 64px;
    border: 4px solid #C4B3CC;
    border-radius: 16px;
    /* flex: none; order: X; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    cursor: pointer; /* Indicate it's clickable */
    background-color: transparent; /* Ensure no accidental background */
}

.AvailableSlotButton:hover { /* Added basic hover effect */
    background-color: rgba(196, 179, 204, 0.2); /* Light hover */
}

.AvailableSlotButton .CreateSlot {
    width: 208px;
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    justify-content: center; /* Center text */
    text-align: center;
    color: #886699;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}


/* ==========================================================================
   Sidebar (Right Column)
   ========================================================================== */

.Sidebar {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 0px;
    gap: 16px;
    width: 224px;
    height: 1032px;
    /* flex: none; order: 2; flex-grow: 0; */ /* Layout context specific */
}

.UserWidget {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 8px;
    gap: 8px;
    width: 224px;
    /* height: 96px; */ /* Height auto */
    background: rgba(242, 242, 242, 0.5);
    box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
    border-radius: 32px;
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    box-sizing: border-box;
}

.AboutConsultant {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px;
    gap: 8px;
    width: 208px;
    height: 56px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.ConsultantAvatar {
    display: flex;
    flex-direction: row; /* Content is usually centered */
    justify-content: center; /* Center icon */
    align-items: center;
    padding: 16px; /* Padding inside */
    gap: 10px; /* Not relevant for single icon */
    width: 56px;
    height: 56px;
    background: #C4B3CC;
    border-radius: 32px; /* Circle */
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    flex-shrink: 0;
    box-sizing: border-box;
}

/* Generic Icon Styling */
.Icon { /* Base class for icons */
    width: 24px;
    height: 24px;
    position: relative; /* For potential absolute positioned children like Vector */
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    display: inline-flex; /* Treat as inline element */
    justify-content: center;
    align-items: center;
}

/* Specific Icon Implementations using Vector */
/* Note: The Vector properties are identical in the source. */
/* Using more specific selectors is safer than a global .Vector class */
.UserIcon .Vector { /* Style for Vector inside UserIcon */
    position: absolute;
    left: 20.83%; right: 20.83%; top: 12.5%; bottom: 12.5%; /* 5px 5px */
    border: 2px solid #886699;
    /* These create a shape - consider using SVG or an icon font instead */
    width: 13.6px; /* Calculated */
    height: 18px; /* Calculated */
    box-sizing: border-box; /* Include border in size */
    /* Complex border usage likely means this was an icon component in Figma */
}

.FormIcon .Vector { /* Style for Vector inside FormIcon */
    position: absolute;
    left: 20.83%; right: 20.83%; top: 12.5%; bottom: 12.5%;
    border: 2px solid #886699;
    width: 13.6px; height: 18px; box-sizing: border-box;
}

.CalendarIcon .Vector { /* Style for Vector inside CalendarIcon */
    position: absolute;
    left: 16.67%; right: 16.67%; top: 8.33%; bottom: 16.67%; /* 4px 4px */
    border: 2px solid #6F4D80; /* Different color */
    width: 16px; height: 18px; box-sizing: border-box;
}

.StatisticsIcon .Vector { /* Style for Vector inside StatisticsIcon */
    position: absolute;
    left: 16.67%; right: 16.66%; top: 29.17%; bottom: 29.17%; /* 4px 7px */
    border: 2px solid #886699;
    width: 16px; height: 10px; box-sizing: border-box;
}

.SettingsIcon .Vector { /* Style for Vector inside SettingsIcon */
    position: absolute;
    left: 8.35%; right: 8.35%; top: 10.72%; bottom: 10.72%; /* 2px 2.5px */
    border: 2px solid #886699;
    width: 19.96px; height: 18.9px; box-sizing: border-box;
}


.ConsultantInfo {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 0px 8px; /* Original had horizontal padding */
    gap: 8px; /* Vertical gap */
    /* width: 144px; */ /* Use flex-grow */
    height: 40px; /* Fixed height? Might need auto */
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

.ConsultantInfo .ConsultantName { /* Renamed from 'Consultant' */
    /* width: 128px; */ /* Use align-self */
    /* height: 16px; */ /* Height from line-height */
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px; /* This makes height > 16px */
    display: flex;
    align-items: center;
    color: #886699;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis; /* Prevent overflow */
}

.ConsultantInfo .Team {
    /* width: 128px; */ /* Use align-self */
    /* height: 16px; */ /* Height from line-height */
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px; /* This makes height > 16px */
    display: flex;
    align-items: center;
    color: #9E8AA8;
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis; /* Prevent overflow */
}

.CallProgress {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding: 0px; /* No padding */
    gap: 8px; /* Gap between bar and count */
    width: 176px; /* Fixed width? */
    /* height: 16px; */ /* Height defined by children */
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
    align-self: center; /* Center within the UserWidget padding */
}

.LoadingBar {
    /* display: flex; flex-direction: column; align-items: flex-start; */ /* Not needed for simple bar */
    /* padding: 0px; gap: 10px; */
    width: 152px;
    height: 16px;
    background: #C4B3CC; /* Background color of the track */
    border-radius: 8px;
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    overflow: hidden; /* Hide overflow of inner bar */
    position: relative; /* For positioning .Loaded */
}

.LoadingBar .Loaded {
    box-sizing: border-box;
    width: 72px; /* Example width - should be dynamic (e.g., 50%) */
    /* width: 47.3%; */ /* Calculated 72/152 */
    height: 16px;
    background: #9E8AA8; /* Color of the progress */
    /* border: 2px solid #C4B3CC; */ /* Border seems redundant with background track */
    border-radius: 8px 0 0 8px; /* Match parent radius, only on left */
    /* flex: none; order: 0; flex-grow: 0; */ /* Layout context specific */
    position: absolute;
    left: 0;
    top: 0;
}

.CallsCount {
    /* display: flex; flex-direction: column; justify-content: center; align-items: center; */ /* Not needed */
    /* padding: 0px; gap: 10px; */
    width: 16px; /* Fixed width */
    height: 16px; /* Matches font size */
    /* flex: none; order: 1; flex-grow: 0; */ /* Layout context specific */
    flex-shrink: 0; /* Prevent shrinking */
}

.CallsCount .Count {
    /* width: 16px; */ /* Inherit */
    height: 16px;
    font-style: normal;
    font-weight: 500;
    font-size: 13px;
    line-height: 16px;
    display: flex;
    align-items: center;
    justify-content: center; /* Center the number */
    color: #886699;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    text-align: center;
}

.NavigationBar {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px;
    gap: 16px; /* Gap between header and buttons */
    width: 224px;
    /* height: 920px; */ /* Use flex-grow */
    background: rgba(242, 242, 242, 0.5);
    box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
    border-radius: 32px;
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1; /* Take remaining sidebar space */
    box-sizing: border-box;
}

.NavigationBar .WidgetHeader {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px 24px; /* Specific padding */
    gap: 16px; /* Gap between title and button */
    width: 208px; /* (224 - 2*8 padding) */
    height: 24px;
    /* flex: none; order: 0; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

.NavigationBar .WidgetHeader .Title {
    /* width: 120px; */ /* Use flex-grow */
    height: 24px;
    font-style: normal;
    font-weight: 600;
    font-size: 18px;
    line-height: 23px;
    display: flex;
    align-items: center;
    color: #9E8AA8; /* Specific color */
    /* flex: none; order: 0; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

/* Uses the generic .DropdownButton and .DropdownIcon defined earlier */
/* .NavigationBar .WidgetHeader .DropdownButton */
/* .NavigationBar .WidgetHeader .DropdownIcon */


.NavigationButtons {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 0px;
    gap: 8px; /* Gap between buttons */
    width: 208px;
    /* height: 216px; */ /* Height auto based on content */
    /* flex: none; order: 1; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
}

/* Generic Navigation Button Style */
.NavButton {
    display: flex;
    flex-direction: row;
    /* justify-content: center; */ /* Align items left */
    align-items: center;
    padding: 12px 16px;
    gap: 16px; /* Gap between icon and text */
    width: 208px;
    height: 48px;
    border-radius: 16px;
    /* flex: none; align-self: stretch; flex-grow: 0; */ /* Layout context specific */
    align-self: stretch;
    box-sizing: border-box;
    text-decoration: none; /* Remove underline if using <a> tags */
    cursor: pointer;
    transition: background-color 0.2s ease; /* Smooth transition */
}

.NavButton .ButtonText { /* Generic class for text in buttons */
    /* width: 136px; */ /* Use flex-grow */
    /* height: 16px; */ /* Defined by line-height */
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 20px;
    display: flex;
    align-items: center;
    /* flex: none; order: 1; flex-grow: 1; */ /* Layout context specific */
    flex-grow: 1;
}

/* Specific Button Styles (Backgrounds and Colors) */

/* GoToFormButton */
.GoToFormButton {
    background: #CFC4D4; /* Default background */
    /* order: 0; */ /* Instance specific */
}
.GoToFormButton .ButtonText {
    color: #886699; /* Default text color */
}
.GoToFormButton:hover {
    background: #C4B3CC; /* Slightly darker hover */
}
/* Uses .FormIcon defined earlier */

/* GoToCalendarButton (Active State) */
.GoToCalendarButton {
    background: #C4B3CC; /* Active background */
    /* order: 1; */ /* Instance specific */
}
.GoToCalendarButton .ButtonText {
    color: #6F4D80; /* Active text color */
}
/* No hover needed if it's the active page */
/* Uses .CalendarIcon defined earlier */


/* GoToStatisticsButton */
.GoToStatisticsButton {
    background: #CFC4D4;
    /* order: 2; */ /* Instance specific */
}
.GoToStatisticsButton .ButtonText {
    color: #886699;
}
.GoToStatisticsButton:hover {
    background: #C4B3CC;
}
/* Uses .StatisticsIcon defined earlier */


/* GoToSettingsButton */
.GoToSettingsButton {
    background: #CFC4D4;
    /* order: 3; */ /* Instance specific */
}
.GoToSettingsButton .ButtonText {
    color: #886699;
}
.GoToSettingsButton:hover {
    background: #C4B3CC;
}
/* Uses .SettingsIcon defined earlier */