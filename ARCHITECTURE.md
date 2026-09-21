# Architecture

Flutter desktop app (Windows + macOS), FVM-pinned Flutter 3.47.0.
Stack: Drift/SQLite, Riverpod (codegen), go_router, AppFlowyEditor, pdfrx.

## Folder layout

```
lib/
  main.dart                  bootstrap: backup, ProviderContainer, runApp
  app/                       MaterialApp.router + route table
  core/                      cross-cutting helpers (IDs, DB backup)
  data/
    tables/                  Drift table definitions + enums
    database/                AppDatabase, migrations, db provider
    repositories/            the only code that touches Drift
  features/
    library/                 folder/document tree (placeholder home screen)
    editor/                  note editor (AppFlowyEditor placeholder)
    pdf/                     PDF viewer (pdfrx placeholder)
test/
  data/repositories/         repository tests on an in-memory database
drift_schemas/               exported schema snapshots (drift_schema_v1.json)
```

A feature folder owns its widgets, screens and feature-local providers.
Anything shared by two features moves down into `core/` or `data/`.

## Layer rules

- **UI reads only via providers.** Widgets never construct a repository or a
  database; they `ref.watch(...)` a provider.
- **Only repositories touch Drift.** No `select`, `update` or companion type
  outside `lib/data/repositories/`. Widgets and providers deal in row classes
  (`Folder`, `Document`) and repository methods.
- **Providers are generated**, not hand-written: `@riverpod` + `build_runner`.
  `appDatabaseProvider` is the single DB handle and is overridden in tests.
  Exception: a provider whose declared return type mentions a drift-generated
  data class (`Folder`/`Document`), even nested in a `Stream`/`List`, crashes
  `riverpod_generator` (`InvalidTypeException`) as of riverpod_generator
  4.0.9 + drift_dev 2.35.0. Those few providers (`allFoldersProvider`,
  `allDocumentsProvider`, `selectedNoteDocumentProvider` in
  `features/library/library_providers.dart`) are hand-written `Provider`/
  `StreamProvider` values instead; everything downstream still consumes them
  the normal way via `ref.watch`.
- Tests exercise repositories directly against `NativeDatabase.memory()`.

Regenerate after touching tables or providers:

```
fvm dart run build_runner build
fvm dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
```

## Data conventions

- **IDs**: client-generated UUID v4 text primary keys (`core/ids.dart`), so
  rows can be created offline and synced later without renumbering.
- **Timestamps**: `createdAt` / `updatedAt` / `deletedAt` are always UTC.
  Drift stores them as ISO-8601 text (`storeDateTimeAsText: true`); convert to
  local time only for display.
- **Soft delete**: nothing is hard-deleted. Deleting sets `deletedAt` and
  cascades to descendants (child folders and their documents) in one
  transaction. Every repository query filters `deletedAt IS NULL`, so watch
  streams never emit deleted rows.
- **Ordering**: `sortIndex` is per sibling list (per `parentId` / `folderId`).
  New rows are appended; `reorder(orderedIds)` rewrites the list.
- **Tree roots**: `folders.parentId == null` and `documents.folderId == null`
  mean "at the library root".
- **Schema**: `schemaVersion = 1` with an explicit `MigrationStrategy`.
  Bumping the version requires a new step in `onUpgrade` plus a fresh schema
  dump in `drift_schemas/`.

## Files on disk

Everything lives in the platform application support directory
(`getApplicationSupportDirectory()`):

```
<app support>/
  lernapp.sqlite             the database
  backups/
    lernapp-YYYY-MM-DD.sqlite   one per day, 7 newest kept
```

On Windows that is `%APPDATA%\<company>\lernapp`, on macOS
`~/Library/Application Support/<bundle id>`.

The backup runs once on app start (`core/db_backup.dart`) via SQLite
`VACUUM INTO`, which produces a consistent snapshot of the already-open
database. A failing backup is swallowed so it can never block startup.
