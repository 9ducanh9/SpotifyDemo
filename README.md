# SpotifyDemo

SpotifyDemo is a Dart backend prototype for a music application. It exposes a
small HTTP API with user authentication, password hashing, JWT-based sessions,
and PostgreSQL access.

## What it builds

- Dart server entrypoint in `bin/server.dart`
- Route handling with `shelf` and `shelf_router`
- PostgreSQL access through the `postgres` package
- Password hashing with `bcrypt`
- JWT token creation with `dart_jsonwebtoken`
- Basic test structure under `test/`

## Tech Stack

- Dart
- Shelf
- PostgreSQL
- bcrypt
- JSON Web Tokens

## Run Locally

Install dependencies:

```bash
dart pub get
```

Run the server:

```bash
dart run bin/server.dart
```

## Status

This is an early backend prototype. It is useful as a learning project for Dart
server-side development, but it needs API documentation, database setup notes,
and integration testing before it should be presented as a polished product.
