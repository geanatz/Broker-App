/* LoginScreen */

position: relative;
width: 1920px;
height: 1080px;

background: linear-gradient(107.56deg, #A4B8C2 0%, #C2A4A4 100%);


/* LoginWidget */

/* Auto layout */
display: flex;
flex-direction: column;
justify-content: center;
align-items: center;
padding: 8px;
gap: 8px;

position: absolute;
width: 400px;
height: 344px;
left: calc(50% - 400px/2);
top: calc(50% - 344px/2);

background: rgba(242, 242, 242, 0.5);
border-radius: 32px;


/* LoginHeader */

/* Auto layout */
display: flex;
flex-direction: row;
justify-content: center;
align-items: center;
padding: 0px 0px 0px 8px;
gap: 16px;

width: 384px;
height: 64px;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 0;


/* Title&Description */

/* Auto layout */
display: flex;
flex-direction: column;
justify-content: center;
align-items: center;
padding: 8px;
gap: 4px;

width: 296px;
height: 64px;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 1;


/* E timpul sa facem cifre! */

width: 280px;
height: 22px;

font-family: 'Outfit';
font-style: normal;
font-weight: 600;
font-size: 20px;
line-height: 25px;
display: flex;
align-items: center;

color: #77677E;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 1;


/* Clientii asteapta. */

width: 280px;
height: 22px;

font-family: 'Outfit';
font-style: normal;
font-weight: 500;
font-size: 16px;
line-height: 20px;
display: flex;
align-items: center;

color: #866C93;


/* Inside auto layout */
flex: none;
order: 1;
align-self: stretch;
flex-grow: 1;


/* Logo */

/* Auto layout */
display: flex;
flex-direction: row;
justify-content: center;
align-items: center;
padding: 8px;
gap: 10px;

width: 64px;
height: 64px;

border-radius: 24px;

/* Inside auto layout */
flex: none;
order: 1;
flex-grow: 0;


/* Logo */

width: 48px;
height: 48px;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 0;


/* M */

position: absolute;
width: 48px;
height: 48px;
left: calc(50% - 48px/2);
top: calc(50% - 48px/2);

font-family: 'Urbanist';
font-style: normal;
font-weight: 800;
font-size: 32px;
line-height: 38px;
display: flex;
align-items: center;
text-align: center;

color: #866C93;



/* LoginForm */

/* Auto layout */
display: flex;
flex-direction: column;
justify-content: center;
align-items: center;
padding: 8px;
gap: 8px;

width: 384px;
height: 168px;

background: #CEC7D1;
border-radius: 24px;

/* Inside auto layout */
flex: none;
order: 1;
align-self: stretch;
flex-grow: 0;


/* AgentField */

/* Auto layout */
display: flex;
flex-direction: column;
align-items: flex-end;
padding: 0px;

width: 368px;
height: 72px;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 0;


/* FieldTitle */

/* Auto layout */
display: flex;
flex-direction: row;
justify-content: center;
align-items: center;
padding: 0px 8px;
gap: 10px;

width: 368px;
height: 24px;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 0;


/* Agent */

width: 352px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 600;
font-size: 18px;
line-height: 23px;
display: flex;
align-items: center;

color: #866C93;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;


/* Input */

/* Auto layout */
display: flex;
flex-direction: row;
align-items: center;
padding: 12px 16px;
gap: 8px;

width: 368px;
height: 48px;

background: #C3B6C9;
border-radius: 16px;

/* Inside auto layout */
flex: none;
order: 1;
align-self: stretch;
flex-grow: 0;


/* Selecteaza agent */

width: 304px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 500;
font-size: 18px;
line-height: 23px;
display: flex;
align-items: center;

color: #77677E;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;


/* DropdownButton */

width: 24px;
height: 24px;


/* Inside auto layout */
flex: none;
order: 1;
flex-grow: 0;


/* ArrowDownMD */

position: absolute;
left: 33.33%;
right: 33.33%;
top: 41.67%;
bottom: 41.67%;

border: 2px solid #695C70;


/* PasswordField */

/* Auto layout */
display: flex;
flex-direction: column;
align-items: flex-end;
padding: 0px;

width: 368px;
height: 72px;


/* Inside auto layout */
flex: none;
order: 1;
align-self: stretch;
flex-grow: 0;


/* FieldTitle */

/* Auto layout */
display: flex;
flex-direction: row;
justify-content: center;
align-items: center;
padding: 0px 8px;
gap: 10px;

width: 368px;
height: 24px;


/* Inside auto layout */
flex: none;
order: 0;
align-self: stretch;
flex-grow: 0;


/* Parola */

width: 352px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 600;
font-size: 18px;
line-height: 23px;
display: flex;
align-items: center;

color: #866C93;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;


/* Input */

/* Auto layout */
display: flex;
flex-direction: row;
align-items: center;
padding: 12px 16px;
gap: 8px;

width: 368px;
height: 48px;

background: #C3B6C9;
border-radius: 16px;

/* Inside auto layout */
flex: none;
order: 1;
align-self: stretch;
flex-grow: 0;


/* Introdu parola */

width: 304px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 500;
font-size: 18px;
line-height: 23px;
display: flex;
align-items: center;

color: #77677E;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;


/* InfoButton */

width: 24px;
height: 24px;


/* Inside auto layout */
flex: none;
order: 1;
flex-grow: 0;


/* InfoIcon */

position: absolute;
left: 12.5%;
right: 12.5%;
top: 12.5%;
bottom: 12.5%;

border: 2px solid #77677E;


/* GoToRegister */

/* Auto layout */
display: flex;
flex-direction: row;
justify-content: center;
align-items: center;
padding: 0px 16px;
gap: 10px;

width: 384px;
height: 24px;


/* Inside auto layout */
flex: none;
order: 2;
align-self: stretch;
flex-grow: 0;


/* Nu ai un cont de consultant? Creaza unul! */

width: 352px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 500;
font-size: 16px;
line-height: 20px;
display: flex;
align-items: center;

color: #866C93;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;


/* LoginButton */

/* Auto layout */
display: flex;
flex-direction: row;
align-items: center;
padding: 12px 16px;
gap: 8px;

width: 384px;
height: 48px;

background: #C3B6C9;
border-radius: 24px;

/* Inside auto layout */
flex: none;
order: 3;
align-self: stretch;
flex-grow: 0;


/* Conectare */

width: 352px;
height: 24px;

font-family: 'Outfit';
font-style: normal;
font-weight: 500;
font-size: 18px;
line-height: 23px;
display: flex;
align-items: center;
text-align: center;

color: #77677E;


/* Inside auto layout */
flex: none;
order: 0;
flex-grow: 1;
