# Usage Scenarios

## Scenario 1: New User Registration and First Track

**Actor**: New User  
**Goal**: Register account and add first music track

**Steps**:
1. User opens app
2. Sees login screen
3. Taps "Register"
4. Enters email, password, display name
5. Taps "Register" button
6. Account created, redirected to home
7. Taps "Add New Track"
8. Enters track title: "My First Song"
9. Enters artist: "John Doe"
10. Enters duration: 180
11. Records audio or selects file
12. Taps "Add Track"
13. Track saved, appears in track list

**Expected Result**: User account created, first track added successfully

**Alternative Flow**: User uses Google Sign-In instead of email registration

---

## Scenario 2: Advanced Search and Filtering

**Actor**: Regular User  
**Goal**: Find specific tracks using multiple criteria

**Steps**:
1. User navigates to Track List
2. Taps search icon
3. Opens Advanced Search screen
4. Enters title: "Jazz"
5. Sets duration range: 120-300 seconds
6. Checks "Favorites only"
7. Sets date range: Last month
8. Views filtered results
9. Finds desired tracks

**Expected Result**: Only tracks matching all criteria are displayed

**Alternative Flow**: User clears filters and starts over

---

## Scenario 3: Workflow Management (Admin)

**Actor**: Admin User  
**Goal**: Review and approve tracks through workflow

**Steps**:
1. Admin logs in
2. Views track list
3. Sees track with "Draft" status
4. Opens track details
5. Taps "Workflow" button
6. Reviews track information
7. Taps "Approve" button
8. Track status changes to "Approved"
9. Action history updated
10. Original user receives notification (if implemented)

**Expected Result**: Track approved, workflow status updated, history recorded

**Alternative Flow**: Admin rejects track, provides comment

---

## Scenario 4: Cloud Sync with Conflict Resolution

**Actor**: Regular User  
**Goal**: Sync data across devices, resolve conflicts

**Steps**:
1. User adds track on Device A (offline)
2. User adds same track on Device B (online, synced to cloud)
3. User goes online on Device A
4. Taps sync button
5. System detects conflict
6. Shows conflict resolution dialog
7. User chooses "Keep Latest"
8. System resolves conflict automatically
9. Data synced successfully

**Expected Result**: Conflicts resolved, data consistent across devices

**Alternative Flow**: User manually chooses which version to keep

---

## Scenario 5: Generate and Export Weekly Report

**Actor**: Regular User  
**Goal**: View weekly statistics and export report

**Steps**:
1. User navigates to Reports screen
2. Selects "Weekly" period
3. Report generates automatically
4. Views summary cards (tracks added, favorites, etc.)
5. Views actions table
6. Taps "Compare with Previous Period"
7. Views comparison metrics
8. Taps export icon
9. Chooses "PDF"
10. PDF generates with preview
11. Shares PDF via system share dialog

**Expected Result**: Weekly report generated, exported, and shared

**Alternative Flow**: User exports as CSV instead

---

## Scenario 6: Offline Mode Usage

**Actor**: Regular User  
**Goal**: Use app without internet connection

**Steps**:
1. User opens app (online)
2. Views track list
3. Loses internet connection
4. Sees "Offline mode" indicator
5. Adds new track
6. Edits existing track
7. Marks track as favorite
8. All changes saved locally
9. Connection restored
10. App automatically syncs changes
11. "Synced successfully" message appears

**Expected Result**: App works offline, changes synced when online

**Alternative Flow**: User manually triggers sync when online

---

## Scenario 7: Automated Feedback

**Actor**: Regular User  
**Goal**: Receive automated insights about music library

**Steps**:
1. User opens app
2. System analyzes user data in background
3. Detects low activity (few tracks added this week)
4. Generates feedback: "Low Activity - Consider exploring new music!"
5. Shows feedback card on home screen
6. User views feedback
7. User taps "Dismiss" or takes suggested action

**Expected Result**: User receives helpful feedback, improves engagement

**Alternative Flow**: System detects high activity, shows positive feedback

---

## Scenario 8: Multi-Step Workflow Process

**Actor**: Regular User → Admin  
**Goal**: Complete full workflow from draft to completion

**Steps**:
1. User creates track (status: Draft)
2. User submits for review
3. Status changes to "Review"
4. Admin reviews track
5. Admin approves track
6. Status changes to "Approved"
7. User marks track as complete
8. Status changes to "Completed"
9. All transitions recorded in action history
10. User views action history timeline

**Expected Result**: Track progresses through workflow, all actions tracked

**Alternative Flow**: Admin rejects track, user revises and resubmits

---

## Scenario 9: Statistics and Charts

**Actor**: Regular User  
**Goal**: View visual statistics about music library

**Steps**:
1. User navigates to Statistics screen
2. Views summary cards (total tracks, favorites, duration)
3. Views bar chart of top artists
4. Views data table of top artists
5. Taps export button
6. Chooses export format (CSV or PDF)
7. File generated and shared

**Expected Result**: Visual statistics displayed, data exported

**Alternative Flow**: User filters statistics by date range

---

## Scenario 10: Role-Based Access

**Actor**: Regular User vs Admin  
**Goal**: Different UI and features based on role

**Regular User**:
- Sees standard features
- Can manage own tracks
- Cannot access admin panel

**Admin User**:
- Sees admin badge on home screen
- Can access admin panel
- Can view all users' data
- Can manage user roles
- Can view global statistics

**Expected Result**: UI adapts based on user role

---

## Scenario 11: Real-time Updates

**Actor**: Multiple Users  
**Goal**: See updates in real-time

**Steps**:
1. User A adds new track
2. Track synced to cloud
3. User B has app open
4. Firestore listener detects change
5. User B's app updates automatically
6. New track appears in User B's list
7. No manual refresh needed

**Expected Result**: Changes propagate in real-time across devices

**Alternative Flow**: User B is offline, receives update when online

---

## Scenario 12: Accessibility Usage

**Actor**: User with Visual Impairment  
**Goal**: Use app with screen reader

**Steps**:
1. User enables screen reader
2. Opens app
3. Screen reader announces UI elements
4. User navigates using gestures
5. All buttons have semantic labels
6. Forms are accessible
7. User can complete all tasks

**Expected Result**: App fully accessible via screen reader

---

## Scenario 13: Responsive Layout (Tablet)

**Actor**: Tablet User  
**Goal**: Use app on larger screen

**Steps**:
1. User opens app on tablet
2. App detects larger screen
3. Layout adapts (more columns, larger padding)
4. Track list shows 2-3 columns
5. Statistics show side-by-side charts
6. Better use of screen space

**Expected Result**: Optimized layout for tablet screen size

---

## Scenario 14: Performance with Large Dataset

**Actor**: Power User  
**Goal**: Use app with 1000+ tracks

**Steps**:
1. User has 1000+ tracks
2. Opens track list
3. App uses pagination/virtualization
4. Only visible items rendered
5. Smooth scrolling performance
6. Search remains fast
7. Filters apply quickly

**Expected Result**: App performs well with large datasets

---

## Scenario 15: Error Recovery

**Actor**: Regular User  
**Goal**: Recover from errors gracefully

**Steps**:
1. User performs action
2. Network error occurs
3. App shows error message
4. Provides retry option
5. User taps retry
6. Operation succeeds
7. Success message shown

**Expected Result**: Errors handled gracefully, recovery options provided

---

These scenarios cover the main use cases and demonstrate how the app handles various situations, user types, and edge cases.
