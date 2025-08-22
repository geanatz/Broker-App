Restarted application in 1,546ms.
UPDATE_SERVICE: initialized | version=0.1.9, dir=D:\Repositories\Broker-App
UPDATE_SERVICE: env_snapshot | cwd=D:\Repositories\Broker-App, exe=D:\Repositories\Broker-App\build\windows\x64\runner\Debug\mat_finance.exe, os="Windows 10 Pro" 10.0 (Build 26100), dart=3.8.1 (stable) (Wed May 28 00:47:25 2025 -0700) on "windows_x64"
🔄 SPLASH_SERVICE: Attempt 1/3 to fetch meetings
CLIENTS_SERVICE: load_clients_ms | ms=88
[ERROR:flutter/shell/common/shell.cc(1064)] The 'plugins.flutter.io/firebase_firestore/query/f06a8e5a-2d0e-429b-9d7e-65c01163882b' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
See https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading for more information.
[ERROR:flutter/shell/common/shell.cc(1064)] The 'plugins.flutter.io/firebase_firestore/query/cca6ecda-659b-42e0-b19d-b8cfef3f5213' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
See https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading for more information.
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: null
➕ CLIENT: added - 0777888222 → Catalin
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: null
🔍 FIREBASE_SERVICE: Fetching team meetings for team: Echipa Andreea
📊 DASHBOARD_SERVICE: Loading consultants ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loading teams ranking | isSupervisor: false
👥 FIREBASE_SERVICE: Found 2 consultants in team Echipa Andreea
📦 FIREBASE_SERVICE: Processing chunk 1 with 2 tokens
[FIREBASE] MEETINGS: getAllMeetings loaded 1 in 323ms
📊 DASHBOARD_SERVICE: Loaded 3 consultants | isSupervisor: false | Teams excluded: 0
📊 DASHBOARD_SERVICE: Found teams (with base): [Echipa Andreea, Echipa Cristina, Echipa Scarlat]
📊 DASHBOARD_SERVICE: Loaded 3 teams | isSupervisor: false
📥 FIREBASE_SERVICE: Chunk 1 returned 7 meetings
✅ FIREBASE_SERVICE: Successfully fetched 7 meetings from 1 chunks in 1461ms
FIREBASE_SERVICE: team_meetings_ms | ms=1461, tokens=2
✅ SPLASH_SERVICE: Successfully fetched 7 meetings on attempt 1 (1671ms)
SPLASH_SERVICE: refresh_meetings_cache_ms | ms=1671
! SPLASH_SERVICE: No current team set for caching meetings
✅ SPLASH_SERVICE: Successfully refreshed meetings cache: 7 meetings
📊 DASHBOARD_SERVICE: Loading consultants ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loading teams ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loaded 3 teams from cache | isSupervisor: false
[FIREBASE] MEETINGS: getAllMeetings loaded 1 in 204ms
🎯 CLIENT_SERVICE: Client found at index: 0
🎯 CLIENT_SERVICE: Cleared focus from: Catalin
🎯 CLIENT_SERVICE: All focus states cleared
✅ CLIENT_SERVICE: Client focused successfully: 0777888222
✅ CLIENT_SERVICE: New focused client: Catalin
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=1, coborrower=1
✅ [FIREBASE_SUCCESS] getClient found matching client
[FIREBASE] GD_VERIFY: getClientForms called for 0777888222
[FIREBASE] GD_VERIFY: loaded 1 forms for 0777888222
📊 SPLASH_SERVICE: Performance Metrics:
  Initializare servicii...: 20ms
  Preincarcare date...: 2573ms
  Sincronizare servicii...: 28ms
  Optimizare cache...: 2ms
  Finalizare...: 0ms
SPLASH: Current role: Consultant
🔄 SPLASH: Consultant/team changed, resetting state
🔧 SPLASH: Old consultant: null, New: d4bdf2f4-d95a-4937-ac51-2934f015ec5d
🔧 SPLASH: Old team: null, New: Echipa Andreea
🔄 SPLASH: Reloading services for new consultant
📊 DASHBOARD_SERVICE: Loading consultants ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loading teams ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loaded 3 teams from cache | isSupervisor: false
CLIENTS_SERVICE: load_clients_ms | ms=109
[ERROR:flutter/shell/common/shell.cc(1064)] The 'plugins.flutter.io/firebase_firestore/query/36129b59-4a91-4fd1-91cc-9a7fdc081bce' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
See https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading for more information.
[ERROR:flutter/shell/common/shell.cc(1064)] The 'plugins.flutter.io/firebase_firestore/query/5817bf25-e244-4f39-8886-63f15f19e54d' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
See https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading for more information.
➕ CLIENT: added - 0777888222 → Catalin
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
[FIREBASE] MEETINGS: getAllMeetings loaded 1 in 149ms
🔄 SPLASH: Invalidating cache with enhanced state management
✅ SPLASH: Cache invalidation completed successfully
✅ SPLASH: Services reloaded successfully for new consultant
✅ SPLASH: Consultant reset completed successfully
MAIN_SCREEN: init_state
MAIN_SCREEN: build_called
ANIM_METRICS: start | label=area_change to AreaType.dashboard
ANIM_METRICS: end | reason=incoming_completed totalMs=1 frames=0 avgBuildMs=0.00 avgRasterMs=0.00 maxBuildMs=0.00 maxRasterMs=0.00 jankBuild=0 jankRaster=0
MAIN_SCREEN: post_frame_callback
MAIN_SCREEN: whats_new_check_start
UPDATE_SERVICE: release_info_missing | path=C:\Users\Home\AppData\Roaming\com.example\MAT Finance/updates/last_release.json
MAIN_SCREEN: whats_new_info_result | is_null=true
MAIN_SCREEN: whats_new_missing
ANIM_METRICS: start | label=area_change to AreaType.dashboard
🤖 LLM_SERVICE: Conversation loaded for consultant: d4bdf2f4... (2 messages)
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
MAIN_SCREEN: build_called
🔄 FORM: Found focused client at initialization: 0777888222
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
⚡ CLIENTS: Preloading form data for 1 clients
CLIENTS_SERVICE: load_clients_ms | ms=0
🤖 LLM_SERVICE: Conversation loaded for consultant: d4bdf2f4... (2 messages)
🤖 LLM_SERVICE: Reset completed for new consultant
ANIM_METRICS: end | reason=incoming_completed totalMs=13283 frames=913 avgBuildMs=1.04 avgRasterMs=0.59 maxBuildMs=164.20 maxRasterMs=5.11 jankBuild=5 jankRaster=0
🤖 CHATBOT_WIDGET: Reset completed for new consultant
MAIN_SCREEN: build_called
ANIM_METRICS: start | label=area_change to AreaType.calendar
CALENDAR_METRICS: filterWeek offset=0 total=0 week=0 filterMs=0
CALENDAR_METRICS: loadFromCacheInstantly totalMs=0 cacheMs=0 filterMs=0 allMeetings=0 weekMeetings=0
🔄 SPLASH_SERVICE: Attempt 1/3 to fetch meetings
🔍 FIREBASE_SERVICE: Fetching team meetings for team: Echipa Andreea
👥 FIREBASE_SERVICE: Found 2 consultants in team Echipa Andreea
📦 FIREBASE_SERVICE: Processing chunk 1 with 2 tokens
📥 FIREBASE_SERVICE: Chunk 1 returned 7 meetings
✅ FIREBASE_SERVICE: Successfully fetched 7 meetings from 1 chunks in 182ms
FIREBASE_SERVICE: team_meetings_ms | ms=182, tokens=2
✅ SPLASH_SERVICE: Successfully fetched 7 meetings on attempt 1 (312ms)
SPLASH_SERVICE: refresh_meetings_cache_ms | ms=312
💾 SPLASH_SERVICE: Cached 7 meetings for team Echipa Andreea
CALENDAR_METRICS: filterWeek offset=0 total=7 week=4 filterMs=0
✅ SPLASH_SERVICE: Successfully refreshed meetings cache: 7 meetings
ANIM_METRICS: end | reason=incoming_completed totalMs=322 frames=22 avgBuildMs=4.33 avgRasterMs=1.72 maxBuildMs=54.17 maxRasterMs=2.58 jankBuild=1 jankRaster=0
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 0s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
CALENDAR_METRICS: filterWeek offset=0 total=7 week=4 filterMs=0
CALENDAR_METRICS: loadWeek totalMs=155 fetchMs=155 filter+setStateMs=0 allMeetings=7 weekMeetings=4
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 0s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
CALENDAR_METRICS: filterWeek offset=1 total=7 week=1 filterMs=0
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 3s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 3s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 8s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
✅ [FIREBASE_SUCCESS] getClient found matching client
🔄 CLIENT: category_change - 0777888222 → clienti
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
MAIN_SCREEN: build_called
ANIM_METRICS: start | label=area_change to AreaType.calendar
📉 Meeting deleted - dashboard notified
CALENDAR_METRICS: filterWeek offset=1 total=6 week=0 filterMs=0
✅ MEETING_SERVICE: Meeting deleted successfully
🔄 SPLASH_SERVICE: Starting cross-platform cache invalidation and refresh
💾 SPLASH_SERVICE: Cleared team cache for Echipa Andreea (had 6 meetings)
🛤️ SPLASH_SERVICE: Cache cleared (had 6 meetings)
🔄 SPLASH_SERVICE: Attempt 1/3 to fetch meetings
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: nulls, Meetings: 0, Stale: true
🔄 SPLASH_SERVICE: Cache is stale, attempting refresh...
✅ SPLASH_SERVICE: Cache refreshed successfully: 0 meetings
! SPLASH_SERVICE: Warning - returning 0 meetings
📊 SPLASH_SERVICE: Team: Echipa Andreea, Cache time: null
CALENDAR_METRICS: filterWeek offset=1 total=0 week=0 filterMs=0
CALENDAR_METRICS: loadWeek totalMs=143 fetchMs=142 filter+setStateMs=0 allMeetings=0 weekMeetings=0
🔍 FIREBASE_SERVICE: Fetching team meetings for team: Echipa Andreea
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: nulls, Meetings: 0, Stale: true
🔄 SPLASH_SERVICE: Cache is stale, attempting refresh...
✅ SPLASH_SERVICE: Cache refreshed successfully: 0 meetings
! SPLASH_SERVICE: Warning - returning 0 meetings
📊 SPLASH_SERVICE: Team: Echipa Andreea, Cache time: null
👥 FIREBASE_SERVICE: Found 2 consultants in team Echipa Andreea
📦 FIREBASE_SERVICE: Processing chunk 1 with 2 tokens
📥 FIREBASE_SERVICE: Chunk 1 returned 6 meetings
✅ FIREBASE_SERVICE: Successfully fetched 6 meetings from 1 chunks in 189ms
FIREBASE_SERVICE: team_meetings_ms | ms=189, tokens=2
✅ SPLASH_SERVICE: Successfully fetched 6 meetings on attempt 1 (331ms)
SPLASH_SERVICE: refresh_meetings_cache_ms | ms=331
💾 SPLASH_SERVICE: Cached 6 meetings for team Echipa Andreea
CALENDAR_METRICS: filterWeek offset=1 total=6 week=0 filterMs=0
✅ SPLASH_SERVICE: Successfully refreshed meetings cache: 6 meetings
✅ SPLASH_SERVICE: Cache refresh completed: 6 meetings loaded
CALENDAR_METRICS: filterWeek offset=1 total=6 week=0 filterMs=0
✅ SPLASH_SERVICE: Cross-platform cache invalidation completed successfully
🔄 SPLASH_SERVICE: Refreshing client service in background
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
✅ SPLASH_SERVICE: Client service refreshed successfully
CLIENTS_SERVICE: load_clients_ms | ms=0
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 0s, Meetings: 6, Stale: false
✅ SPLASH_SERVICE: Returning 6 meetings
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 0s, Meetings: 6, Stale: false
✅ SPLASH_SERVICE: Returning 6 meetings
🔍 MEETING_DATA: Constructor called
🔍 MEETING_DATA: clientName = "Catalin"
🔍 MEETING_DATA: phoneNumber = "0777888222"
🔍 MEETING_DATA: consultantToken = "d4bdf2f4-d95a-4937-ac51-2934f015ec5d"
🔍 MEETING_DATA: consultantName = "Claudiu"
🔍 MEETING_DATA: dateTime = 2025-08-28 09:30:00.000
🔍 MEETING_DATA: type = MeetingType.meeting
✅ MEETING_DATA: Constructor completed successfully
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 2s, Meetings: 6, Stale: false
✅ SPLASH_SERVICE: Returning 6 meetings
🔄 CLIENT: category_change - 0777888222 → clienti
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
✅ MEETING_SERVICE: Meeting created successfully | Client: Catalin | Date: 2025-08-28 09:30:00.000
🔔 MEETING_SERVICE: Notifying meeting created for consultant: d4bdf2f4 for client: 0777888222
MEETING_SERVICE: create_meeting_ms | ms=413
🔄 FIREBASE_SERVICE: Meeting cache invalidated after creation
🔄 SPLASH_SERVICE: Starting cross-platform cache invalidation and refresh
💾 SPLASH_SERVICE: Cleared team cache for Echipa Andreea (had 6 meetings)
🛤️ SPLASH_SERVICE: Cache cleared (had 6 meetings)
🔄 SPLASH_SERVICE: Attempt 1/3 to fetch meetings
📈 DASHBOARD_SERVICE: Recording meeting for consultant d4bdf2f4... in 2025-08 for client 0777888222
DASHBOARD_SERVICE: desktop detected → using non-transactional path for meetings
📱 MEETING_SERVICE: Skipped auto-move client after meeting creation; caches invalidated
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MAIN_SCREEN: build_called
[PERF] PERFORMANCE REPORT:
=====================================
⚡ resetForNewConsultant: 212.60ms avg
⚡ loadFormData: 160.00ms avg
⚡ mainScreenInit: 2.00ms avg
⚡ formAreaInit: 0.00ms avg
=====================================
Total operations tracked: 4
Active timers: 0
🔍 FIREBASE_SERVICE: Fetching team meetings for team: Echipa Andreea
✅ DASHBOARD_SERVICE: Successfully incremented meetings for consultant in 2025-08
✅ MEETING_SERVICE: Dashboard notified successfully
👥 FIREBASE_SERVICE: Found 2 consultants in team Echipa Andreea
📦 FIREBASE_SERVICE: Processing chunk 1 with 2 tokens
📥 FIREBASE_SERVICE: Chunk 1 returned 7 meetings
✅ FIREBASE_SERVICE: Successfully fetched 7 meetings from 1 chunks in 156ms
FIREBASE_SERVICE: team_meetings_ms | ms=156, tokens=2
✅ SPLASH_SERVICE: Successfully fetched 7 meetings on attempt 1 (256ms)
SPLASH_SERVICE: refresh_meetings_cache_ms | ms=256
💾 SPLASH_SERVICE: Cached 7 meetings for team Echipa Andreea
CALENDAR_METRICS: filterWeek offset=1 total=7 week=1 filterMs=0
✅ SPLASH_SERVICE: Successfully refreshed meetings cache: 7 meetings
✅ SPLASH_SERVICE: Cache refresh completed: 7 meetings loaded
CALENDAR_METRICS: filterWeek offset=1 total=7 week=1 filterMs=0
✅ SPLASH_SERVICE: Cross-platform cache invalidation completed successfully
🔄 SPLASH_SERVICE: Refreshing client service in background
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
✅ SPLASH_SERVICE: Client service refreshed successfully
CLIENTS_SERVICE: load_clients_ms | ms=0
📊 DASHBOARD_SERVICE: Loading consultants ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loading teams ranking | isSupervisor: false
📊 DASHBOARD_SERVICE: Loaded 3 teams from cache | isSupervisor: false
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 0s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
[FIREBASE] MEETINGS: getAllMeetings loaded 1 in 90ms
CALENDAR_METRICS: filterWeek offset=0 total=7 week=4 filterMs=0
MAIN_SCREEN: build_called
🔄 FORM: Found focused client at initialization: 0777888222
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
CALENDAR_METRICS: filterWeek offset=0 total=7 week=4 filterMs=0
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
⚡ CLIENTS: Preloading form data for 1 clients
CLIENTS_SERVICE: load_clients_ms | ms=0
ANIM_METRICS: end | reason=incoming_completed totalMs=25836 frames=335 avgBuildMs=2.26 avgRasterMs=0.94 maxBuildMs=90.80 maxRasterMs=4.40 jankBuild=7 jankRaster=0
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 22s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
CALENDAR_METRICS: loadWeek totalMs=158 fetchMs=158 filter+setStateMs=0 allMeetings=7 weekMeetings=4
SPLASH: Current role: Consultant
✅ SPLASH: Consultant/team unchanged, no reset needed
📊 SPLASH_SERVICE: Cache status - Age: 22s, Meetings: 7, Stale: false
✅ SPLASH_SERVICE: Returning 7 meetings
🚨 ULTRA_URGENT: Cleared ALL form cache for INSTANT update after credit form change
🚨 ULTRA_URGENT: TRIPLE notifyListeners called for INSTANT UI update
FormService: schedule autosave for 0777888222 in 600ms
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
[FIREBASE] FORMS: saveAllFormDataBatched start for 0777888222
🔄 CLIENT: category_change - 0777888222 → clienti
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MAIN_SCREEN: build_called
ANIM_METRICS: start | label=area_change to AreaType.form
✅ [FIREBASE_SUCCESS] FORMS: saveAllFormDataBatched success for 0777888222 in 161ms
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
FormService: commit autosave start for 0777888222
FormService: skip commit (no changes) for 0777888222
🚨 ULTRA_URGENT: Cleared ALL form cache for INSTANT update after income form change
🚨 ULTRA_URGENT: TRIPLE notifyListeners called for INSTANT UI update
FormService: schedule autosave for 0777888222 in 600ms
MATCHER: Using clientKey="0777888222" for income cache and lookups
MATCHER: Found income forms client=2, coborrower=1
[FIREBASE] FORMS: saveAllFormDataBatched start for 0777888222
🔄 CLIENT: category_change - 0777888222 → clienti
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
MAIN_SCREEN: build_called
✅ [FIREBASE_SUCCESS] FORMS: saveAllFormDataBatched success for 0777888222 in 172ms
🎯 CLIENT_SERVICE: notifyListeners called
🎯 CLIENT_SERVICE: Current focused client: Catalin
FormService: commit autosave start for 0777888222
FormService: skip commit (no changes) for 0777888222
