# User Flow Diagrams

## Authentication Flow

```
Start
  │
  ▼
[Login Screen]
  │
  ├──▶ Email/Password ──▶ [Validate] ──▶ [Firebase Auth] ──▶ [Home Screen]
  │
  ├──▶ Google Sign-In ──▶ [Google Auth] ──▶ [Firebase Auth] ──▶ [Home Screen]
  │
  ├──▶ Register ──▶ [Register Screen] ──▶ [Create Account] ──▶ [Home Screen]
  │
  └──▶ Forgot Password ──▶ [Reset Email] ──▶ [Check Email] ──▶ [Login Screen]
```

## Track Management Flow

```
[Home Screen]
  │
  ├──▶ View All Tracks ──▶ [Track List Screen]
  │                          │
  │                          ├──▶ Search/Filter ──▶ [Filtered Results]
  │                          │
  │                          ├──▶ Sort ──▶ [Sorted Results]
  │                          │
  │                          ├──▶ Add Track ──▶ [Add/Edit Screen]
  │                          │                    │
  │                          │                    ├──▶ Record Audio ──▶ [Save]
  │                          │                    │
  │                          │                    └──▶ Select File ──▶ [Save]
  │                          │
  │                          ├──▶ View Details ──▶ [Track Detail Screen]
  │                          │                       │
  │                          │                       ├──▶ Play Audio
  │                          │                       │
  │                          │                       ├──▶ Edit ──▶ [Add/Edit Screen]
  │                          │                       │
  │                          │                       ├──▶ Workflow ──▶ [Workflow Screen]
  │                          │                       │
  │                          │                       └──▶ Toggle Favorite
  │                          │
  │                          └──▶ Delete ──▶ [Confirm] ──▶ [Delete]
  │
  ├──▶ Statistics ──▶ [Statistics Screen] ──▶ [Export CSV/PDF]
  │
  ├──▶ Reports ──▶ [Reporting Screen] ──▶ [Generate Report] ──▶ [Compare] ──▶ [Export]
  │
  └──▶ Admin Panel (Admin Only) ──▶ [Admin Screen]
```

## Workflow Process Flow

```
[Track Created]
  │
  ▼
[Draft Status]
  │
  ├──▶ Submit for Review ──▶ [Review Status]
  │                          │
  │                          ├──▶ Approve (Admin) ──▶ [Approved Status]
  │                          │                          │
  │                          │                          └──▶ Complete ──▶ [Completed Status]
  │                          │
  │                          └──▶ Reject ──▶ [Rejected Status]
  │                                             │
  │                                             └──▶ Back to Draft ──▶ [Draft Status]
  │
  └──▶ Reject ──▶ [Rejected Status] ──▶ [Draft Status]
```

## Cloud Sync Flow

```
[User Action]
  │
  ▼
[Local Database Update]
  │
  ▼
[Check Connectivity]
  │
  ├──▶ Online ──▶ [Sync to Cloud] ──▶ [Firestore Update]
  │                  │
  │                  └──▶ [Conflict Detection]
  │                          │
  │                          ├──▶ No Conflict ──▶ [Update Cloud]
  │                          │
  │                          └──▶ Conflict ──▶ [Resolve Conflict]
  │                                               │
  │                                               ├──▶ Keep Latest
  │                                               ├──▶ Keep Local
  │                                               ├──▶ Keep Cloud
  │                                               └──▶ Ask User
  │
  └──▶ Offline ──▶ [Queue for Sync] ──▶ [Show Offline Indicator]
                                           │
                                           └──▶ [Connection Restored] ──▶ [Auto Sync]
```

## Search Flow

```
[Track List Screen]
  │
  ├──▶ Basic Search ──▶ [Enter Query] ──▶ [Filter Results]
  │
  └──▶ Advanced Search ──▶ [Advanced Search Screen]
                            │
                            ├──▶ Title Filter
                            ├──▶ Artist Filter
                            ├──▶ Duration Range
                            ├──▶ Date Range
                            └──▶ Favorites Only
                                    │
                                    └──▶ [Apply Filters] ──▶ [Filtered Results]
```

## Reporting Flow

```
[Reports Screen]
  │
  ├──▶ Select Period ──▶ [Daily/Weekly/Monthly/Custom]
  │                        │
  │                        └──▶ [Generate Report]
  │                                 │
  │                                 ├──▶ [Display Summary Cards]
  │                                 ├──▶ [Display Actions Table]
  │                                 └──▶ [Display Charts]
  │
  ├──▶ Compare Periods ──▶ [Load Previous Period] ──▶ [Show Comparison]
  │
  └──▶ Export ──▶ [CSV/PDF] ──▶ [Share File]
```

## Admin Flow

```
[Admin Panel]
  │
  ├──▶ View All Users ──▶ [Users List] ──▶ [Manage Roles]
  │
  ├──▶ Cloud Sync Status ──▶ [Sync Dashboard]
  │
  ├──▶ Global Statistics ──▶ [All Users Stats]
  │
  └──▶ System Settings ──▶ [Configuration]
```

## Error Handling Flow

```
[User Action]
  │
  ▼
[Try Operation]
  │
  ├──▶ Success ──▶ [Update UI] ──▶ [Show Success Message]
  │
  └──▶ Error ──▶ [Catch Error]
                    │
                    ├──▶ Network Error ──▶ [Show Offline Message] ──▶ [Queue for Retry]
                    │
                    ├──▶ Validation Error ──▶ [Show Validation Message]
                    │
                    ├──▶ Permission Error ──▶ [Request Permission]
                    │
                    └──▶ Unknown Error ──▶ [Show Error Message] ──▶ [Log Error]
```

## Navigation Flow

```
[App Start]
  │
  ▼
[Check Auth State]
  │
  ├──▶ Not Authenticated ──▶ [Login Screen]
  │
  └──▶ Authenticated ──▶ [Home Screen]
                            │
                            ├──▶ [Track List]
                            ├──▶ [Statistics]
                            ├──▶ [Reports]
                            ├──▶ [Admin Panel] (if admin)
                            └──▶ [Settings] ──▶ [Sign Out] ──▶ [Login Screen]
```

## Real-time Updates Flow

```
[Firestore Listener]
  │
  ▼
[Data Change Detected]
  │
  ├──▶ Track Added ──▶ [Update Local DB] ──▶ [Refresh UI]
  │
  ├──▶ Track Modified ──▶ [Update Local DB] ──▶ [Refresh UI]
  │
  ├──▶ Track Deleted ──▶ [Delete from Local DB] ──▶ [Refresh UI]
  │
  └──▶ Workflow Status Changed ──▶ [Update Status] ──▶ [Show Notification]
```

## Export Flow

```
[Statistics/Reports Screen]
  │
  ├──▶ Export CSV ──▶ [Generate CSV] ──▶ [Save File] ──▶ [Share Dialog]
  │
  └──▶ Export PDF ──▶ [Generate PDF] ──▶ [Preview] ──▶ [Save/Share]
```

## Automated Feedback Flow

```
[App Launch / Periodic Check]
  │
  ▼
[Analyze User Data]
  │
  ├──▶ Low Activity ──▶ [Generate Suggestion]
  │
  ├──▶ High Activity ──▶ [Generate Positive Feedback]
  │
  ├──▶ Pending Reviews ──▶ [Generate Warning]
  │
  └──▶ [Display Feedback] ──▶ [User Action] ──▶ [Dismiss/Act]
```
