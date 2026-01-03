# Demo Flow for Local Music Player

This document outlines the recommended demo flow for screen recording.

## Demo Flow Steps

### 1. Launch the App
- Open the app on Android emulator
- You should see the Home Screen with welcome message
- Note the clean Material Design UI

### 2. Add a New Track (Recording)
- Tap "Add New Track" button
- Fill in:
  - Title: "My First Recording"
  - Artist: "Demo Artist"
  - Duration: Leave empty (will be set automatically)
- Tap "Record" button
- Speak or play some audio for 5-10 seconds
- Tap "Stop Recording"
- Verify the file path and duration are populated
- Tap "Add Track" to save

### 3. Add Another Track (Manual Entry)
- Tap the "+" floating action button
- Fill in:
  - Title: "Sample Song"
  - Artist: "Sample Artist"
  - Duration: 180 (3 minutes)
  - File Path: Enter a path (or use "Select File" - note: file picker integration would be needed for production)
- Tap "Add Track"

### 4. View Track List
- Navigate to "View All Tracks"
- Verify both tracks are displayed
- Check that loading states work (if any)
- Verify empty state is shown when no tracks exist

### 5. Search Functionality
- In the search bar, type "Sample"
- Verify only "Sample Song" appears
- Clear the search
- Verify all tracks appear again

### 6. Sort Functionality
- Tap the sort icon in the app bar
- Select "Title" and "Ascending"
- Verify tracks are sorted alphabetically
- Try sorting by "Date Created" descending
- Verify newest tracks appear first

### 7. Play Audio
- Tap on a track in the list
- Verify it starts playing (if file exists)
- Navigate to track details
- Verify playback controls appear
- Test play/pause functionality
- Verify progress slider updates

### 8. Mark as Favorite
- In track list, tap the favorite icon on a track
- Verify the heart icon fills in red
- Navigate to track details
- Tap "Add to Favorites" button
- Verify the favorite status updates

### 9. Edit Track
- Tap the menu (three dots) on a track
- Select "Edit"
- Change the title to "Updated Title"
- Tap "Update Track"
- Verify the change is reflected in the list

### 10. Delete Track
- Tap the menu on a track
- Select "Delete"
- Confirm deletion
- Verify the track is removed from the list
- Verify empty state appears if all tracks are deleted

### 11. Error Handling
- Try to add a track with invalid data (empty title)
- Verify validation error messages appear
- Try to delete a non-existent track
- Verify appropriate error handling

### 12. Offline Functionality
- Turn off network/WiFi
- Verify app still works
- Add/edit/delete tracks
- Verify all operations work offline
- Turn network back on
- Verify data persists

## Key Features to Highlight

1. **Clean UI/UX**: Material Design, intuitive navigation
2. **CRUD Operations**: Add, Edit, Delete, View all working
3. **Local Storage**: SQLite database, works offline
4. **Search & Filter**: Real-time search, multiple sort options
5. **Audio Features**: Playback with progress, recording capability
6. **State Management**: Loading, empty, and error states
7. **Favorite Management**: Mark/unmark favorites

## Notes for Screen Recording

- Keep the demo under 5 minutes
- Focus on smooth transitions between screens
- Highlight key features mentioned above
- Show error handling and validation
- Demonstrate offline capability
- Show the clean, professional UI
