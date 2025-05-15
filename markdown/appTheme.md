lightGeneralTheme:
light_widget: rgba(255,255,255,0.5)
light_popup: #D9D9D9

darkGeneralTheme:
dark_widget: rgba(0,0,0,0.5)
dark_popup: #262626

lightRedTheme:
light_red_background: #C2A4C2(topleft)- #C2C2A4(botright)
light_red_container_1: #D4C4C4
light_red_container_2: #D3ACAC
light_red_text_1: #A88A8A
light_red_text_2: #996666
light_red_text_3: #804D4D

darkRedTheme:
dark_red_background: #5C3D5C(topleft)- #5C5C3D(botright)
dark_red_container_1: #3B2B2B
dark_red_container_2: #532D2D
dark_red_text_1: #755757
dark_red_text_2: #996666
dark_red_text_3: #B28080

lightYellowTheme:
light_yellow_background: #C2A4A4(topleft)- #A4C2A4(botright)
light_yellow_container_1: #D4D4C4
light_yellow_container_2: #D3D3AC
light_yellow_text_1: #A8A88A
light_yellow_text_2: #999966
light_yellow_text_3: #80804D

darkYellowTheme:
dark_yellow_background: #5C3D3D(topleft)- #3D5C3D(botright)
dark_yellow_container_1: #3B3B2B
dark_yellow_container_2: #53532D
dark_yellow_text_1: #757557
dark_yellow_text_2: #999966
dark_yellow_text_3: #B2B280

lightGreenTheme:
light_green_background: #C2C2A4(topleft)- #A4C2C2(botright)
light_green_container_1: #C4D4C4
light_green_container_2: #ACD2AC
light_green_text_1: #8AA88A
light_green_text_2: #669966
light_green_text_3: #4D804D

darkGreenTheme:
dark_green_background: #5C5C3D(topleft)- # #3D5C5C(botright)
dark_green_container_1: #2B3B2B
dark_green_container_2: #2D532D
dark_green_text_1: #577557
dark_green_text_2: #669966
dark_green_text_3: #80B280

lightCyanTheme:
light_cyan_background: #A4C2A4(topleft)- #A4A4C2(botright)
light_cyan_container_1: #C4D4D4
light_cyan_container_2: #ACD3D3
light_cyan_text_1: #8AA8A8
light_cyan_text_2: #669999
light_cyan_text_3: #4D8080

darkCyanTheme:
dark_cyan_background: #3D5C3D(topleft)- #3D3D5C(botright)
dark_cyan_container_1: #2B3B3B
dark_cyan_container_2: #2D5353
dark_cyan_text_1: #577575
dark_cyan_text_2: #669999
dark_cyan_text_3: #80B2B2

lightBlueTheme:
light_blue_background: #A4C2C2(topleft)- #C2A4C2(botright)
light_blue_container_1: #C4C4D4
light_blue_container_2: #ACACD3
light_blue_text_1: #8A8AA8
light_blue_text_2: #666699
light_blue_text_3: #4D4D80

darkBlueTheme:
dark_blue_background: #3D5C5C(topleft)- #5C3D5C(botright)
dark_blue_container_1: #2B2B3B
dark_blue_container_2: #2D2D53
dark_blue_text_1: #575775
dark_blue_text_2: #666699
dark_blue_text_3: #8080B2

lightPinkTheme:
light_pink_background: #A4A4C2(topleft)- #C2A4A4(botright)
light_pink_container_1: #D4C4D4
light_pink_container_2: #D3ACD3
light_pink_text_1: #9D7B9D
light_pink_text_2: #996699
light_pink_text_3: #8F568F

darkPinkTheme:
dark_pink_background: #3D3D5C(topleft)- #5C3D3D(botright)
dark_pink_container_1: #3B2B3B
dark_pink_container_2: #532D53
dark_pink_text_1: #755775
dark_pink_text_2: #996699
dark_pink_text_3: #B280B2

---

if themeColor == red && theme == light:
background_color = light_background
container_color_1 = light_red_container_1
container_color_2 = light_red_container_2
text_color_1 = light_red_text_1
text_color_2 = light_red_text_2
text_color_3 = light_red_text_3 

if themeColor == red && theme == dark:
background_color = dark_background
container_color_1 = dark_red_container_1
container_color_2 = dark_red_container_2
text_color_1 = dark_red_text_1
text_color_2 = dark_red_text_2
text_color_3 = dark_red_text_3 

---

if themeColor == yellow && theme == light:
background_color = light_background
container_color_1 = light_yellow_container_1
container_color_2 = light_yellow_container_2
text_color_1 = light_yellow_text_1
text_color_2 = light_yellow_text_2
text_color_3 = light_yellow_text_3 

if themeColor == yellow && theme == dark:
background_color = dark_background
container_color_1 = dark_yellow_container_1
container_color_2 = dark_yellow_container_2
text_color_1 = dark_yellow_text_1
text_color_2 = dark_yellow_text_2
text_color_3 = dark_yellow_text_3

---

if themeColor == green && theme == light:
background_color = light_background
container_color_1 = light_green_container_1
container_color_2 = light_green_container_2
text_color_1 = light_green_text_1
text_color_2 = light_green_text_2
text_color_3 = light_green_text_3 

if themeColor == green && theme == dark:
background_color = dark_background
container_color_1 = dark_green_container_1
container_color_2 = dark_green_container_2
text_color_1 = dark_green_text_1
text_color_2 = dark_green_text_2
text_color_3 = dark_green_text_3 

---

if themeColor == cyan && theme == light:
background_color = light_background
container_color_1 = light_cyan_container_1
container_color_2 = light_cyan_container_2
text_color_1 = light_cyan_text_1
text_color_2 = light_cyan_text_2
text_color_3 = light_cyan_text_3 

if themeColor == cyan && theme == dark:
background_color = dark_background
container_color_1 = dark_cyan_container_1
container_color_2 = dark_cyan_container_2
text_color_1 = dark_cyan_text_1
text_color_2 = dark_cyan_text_2
text_color_3 = dark_cyan_text_3 

---

if themeColor == blue && theme == light:
background_color = light_background
container_color_1 = light_blue_container_1
container_color_2 = light_blue_container_2
text_color_1 = light_blue_text_1
text_color_2 = light_blue_text_2
text_color_3 = light_blue_text_3 

if themeColor == blue && theme == dark:
background_color = dark_background
container_color_1 = dark_blue_container_1
container_color_2 = dark_blue_container_2
text_color_1 = dark_blue_text_1
text_color_2 = dark_blue_text_2
text_color_3 = dark_blue_text_3 

---

if themeColor == pink && theme == light:
background_color = light_background
container_color_1 = light_pink_container_1
container_color_2 = light_pink_container_2
text_color_1 = light_pink_text_1
text_color_2 = light_pink_text_2
text_color_3 = light_pink_text_3 

if themeColor == pink && theme == dark:
background_color = dark_background
container_color_1 = dark_pink_container_1
container_color_2 = dark_pink_container_2
text_color_1 = dark_pink_text_1
text_color_2 = dark_pink_text_2
text_color_3 = dark_pink_text_3 

---

fontFamily:
'Outfit'

fontSize:
tiny = 13
small = 15
medium = 17
large = 19
huge = 21

fontWeight:
small = w400
medium = w500
large = w600

borderRadius:
tiny = 8
small = 16
medium = 24
large = 32
huge = 40

gap:
tiny = 4px
small = 8px
medium = 16px
large = 24px
huge = 32px

shadows:
widgetShadow = x0 y0 blur15 rgba(0, 0, 0, 0.1);
calendarReservedSlotShadow = x0px y2px blur4px rgba(0, 0, 0, 0.2);

