========================
STRICT CONSTRAINTS
========================
- Do NOT modify, create, or delete any files inside:
  /android
  /ios
  /.idea
  /.gradle
- Do NOT touch Gradle, platform configs, permissions, or native code.
- Do NOT run or assume build commands.
- Only work inside:
  /lib/**
  pubspec.yaml (dependencies section ONLY, and only when explicitly asked)

If a requested feature requires platform-specific configuration, STOP and EXPLAIN instead of changing anything.

========================
PROJECT SCOPE
========================
This is a LOCAL music player application:
- Music is loaded from local storage or user-selected files
- No streaming
- No server-side backend
- No cloud sync unless explicitly requested later

========================
ARCHITECTURE RULES
========================
- Use MVVM-style separation:
  - UI (screens/widgets): presentation only
  - ViewModel: state & business logic
  - Service: audio, storage, auth, data access
- No business logic inside widgets
- No direct plugin calls from UI
- Keep code readable, simple, and suitable for a university project

========================
FEATURE LEVELS (ACADEMIC)
========================
The app is developed in progressive levels:
🔹 Easy(Dễ) Level – Minimum Required Features

At the Easy level, the Local Music Player application focuses on providing essential functionalities to ensure basic usability and offline operation.

Key features include:

Designing a clean and intuitive user interface with proper navigation between main screens; supporting loading, empty, and error states.

Implementing Create, Read, Update, Delete (CRUD) operations and detailed views for core entities (e.g., songs, playlists), with input validation.

Storing data locally using SQLite or an equivalent solution, allowing the application to function without an internet connection.

Supporting basic search and filtering, and sorting lists by at least one appropriate criterion (e.g., song name or date added).

Writing at least three unit tests for data processing logic; preparing a short demo video to illustrate the main usage flow.

Allowing users to play and record audio, display playback progress, and manage favorite items.

🔹 Medium Level(Trung bình) – Feature Expansion and Data Synchronization

At the Medium level, the system is extended to support multi-device usage, user management, and basic data analysis, improving practical applicability.

This level includes:

Adding cloud data synchronization to share data across multiple devices, with proper handling of offline scenarios and re-synchronization.

Integrating user authentication via email or Google; providing screens for sign-in, sign-up, and password recovery.

Implementing role-based access control with at least two roles (regular user and administrator), each having different behaviors and UI permissions.

Supporting advanced search, multiple filtering criteria, and pagination or infinite scrolling for large datasets.

Creating basic statistical dashboards using charts and tables; enabling data export to CSV or PDF as required.

Integrating speech recognition or basic audio processing using appropriate services (if applicable).

🔹 Advanced Level(Khá) – Workflow Completion and Performance Optimization

The Advanced level focuses on business workflows, performance optimization, and system evaluation, bringing the application closer to a real-world product.

Key features include:

Designing multi-step business workflows (e.g., approval, confirmation, completion) and recording operation history.

Generating time-based reports (daily, weekly, monthly) with before-and-after comparisons, allowing users to download or share results.

Optimizing performance for large lists, minimizing unnecessary UI rebuilds, and adding at least five UI tests.

Handling data synchronization conflicts using clear rules (e.g., keep the latest version or prompt user selection).

Writing deployment documentation, including project structure, process flow diagrams, data models, and usage scenarios.

Displaying analysis results using scores or charts and storing them for historical comparison.

🔹 Expert Level(Khó) – Advanced Authorization, Real-Time Features, and Integration Testing

The Expert level aims to deliver a fully featured, scalable system with robust testing and enhanced user experience.

This level includes:

Extending role-based authorization to multiple contextual roles (e.g., creator, approver, viewer), with distinct UI and behavior policies.

Implementing real-time features where appropriate, such as status updates, notifications, or chat functionality.

Designing and implementing a complete report export workflow, allowing users to select time ranges and criteria, generate PDF/CSV files, and store export history.

Writing integration tests for at least three critical user flows, along with failure recovery plans for cloud or API disruptions.

Enhancing user experience by supporting both mobile phones and tablets, providing light/dark modes, and ensuring basic accessibility compliance.

Providing automated feedback based on analysis results and allowing users to download concise summary reports.

Only implement what I explicitly request.

========================
CODING RULES
========================
- Dart only
- No experimental patterns
- Avoid over-engineering
- Add short comments only where necessary
- Prefer clarity over cleverness

========================
WORKFLOW SAFETY
========================
Before writing code:
1. List the files you will create or modify
2. Confirm no restricted files are touched
3. Wait for my approval

After writing code:
- Provide brief explanation of logic
- No extra refactoring unless requested

If anything is ambiguous, ASK before proceeding.
Từ đây về sau mỗi khi code , t muốn m áp dụng toàn bộ các rules này
Từ đây về sau mỗi khi code , t muốn m áp dụng toàn bộ các rules này