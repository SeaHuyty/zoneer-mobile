# Zoneer Mobile - Folder Structure Documentation

This document explains the project folder structure following Clean Architecture + MVVM pattern.

## Root Structure

```
lib/
├── core/                   # Shared infrastructure and components
├── features/               # Feature modules (feature-first organization)
└── main.dart              # Application entry point
```

---

## Core Directory

**Purpose**: Contains shared services, utilities, models, and widgets used across multiple features.

```
core/
├── services/              # External integrations and business services
├── utils/                 # Helper functions and utilities
```

### core/services/

**What goes here**: Service classes for external integrations

- API services (HTTP client, REST API calls)
- Authentication services (login, logout, token management)
- Storage services (local database, SharedPreferences)
- Third-party integrations (Firebase, analytics, etc.)

**Examples**:

- `api_service.dart` - Handles all HTTP requests
- `auth_service.dart` - Manages authentication state

### core/utils/

**What goes here**: Utility classes and helper functions

- Constants (API endpoints, app configuration)
- Validators (email, password, phone validation)
- Formatters (date, currency, text)
- Extensions (String, DateTime extensions)
- Helper functions

**Examples**:

- `constants.dart` - App-wide constant values
- `validators.dart` - Input validation functions

---

## Shared Directory

**Purpose**: Contains shared models, and widgets used across multiple features.

```
core/
├── models/    
├── widgets/          
```

### shared/models/

**What goes here**: Shared data models used across multiple features

- Base response models
- Common DTOs (Data Transfer Objects)
- Shared entity classes

**Examples**:

- `base_response.dart` - Standard API response wrapper

### shared/widgets/

**What goes here**: Reusable UI components used in 2+ features

- Custom buttons
- Loading indicators
- Error dialogs
- Common form fields

**Examples**:

- `custom_button.dart` - Consistent button styling

---

## Features Directory

**Purpose**: Contains feature modules organized by business domain. Each feature is self-contained with its own models, views, viewmodels, and repositories.

```
features/
├── auth/                  # Authentication feature
├── home/                  # Home/Dashboard feature
└── profile/               # User profile feature
```

### Feature Structure (MVVM Pattern)

Each feature follows this structure:

```
feature_name/
├── models/                # Feature-specific data models
├── views/                 # UI screens and pages
├── viewmodels/            # Business logic and state management
├── repositories/          # Data access layer
└── widgets/               # Feature-specific UI components (optional)
```

### Example: Auth Feature

```
auth/
├── models/
│   └── user_model.dart              # User data structure
├── views/
│   ├── login_view.dart              # Login screen UI
│   └── register_view.dart           # Registration screen UI
├── viewmodels/
│   ├── login_viewmodel.dart         # Login business logic
│   └── register_viewmodel.dart      # Registration business logic
├── repositories/
│   └── auth_repository.dart         # Auth API calls
└── widgets/                          # Auth-specific widgets (optional)
    ├── login_form.dart
    └── password_field.dart
```

### models/

**What goes here**: Data models specific to this feature

- Entity classes
- Request/Response DTOs
- JSON serialization/deserialization

### views/

**What goes here**: UI screens and pages (StatelessWidget/StatefulWidget)

- Screen layouts
- Navigation logic
- UI event handling

### viewmodels/

**What goes here**: Business logic and state management

- Data fetching and processing
- Form validation
- State management (ChangeNotifier, Provider, etc.)
- Communication between View and Repository

### repositories/

**What goes here**: Data access layer for this feature

- API calls specific to this feature
- Data caching
- Local storage operations

### widgets/ (optional)

**What goes here**: UI components used ONLY within this feature

- Feature-specific custom widgets
- Reusable components within the feature

---

## MVVM Pattern Explained

### Model

- Represents data and business entities
- Located in `models/` directories
- Plain Dart classes with JSON serialization

### View

- UI layer (widgets, screens)
- Located in `views/` directories
- Observes ViewModel state
- Handles user interactions

### ViewModel

- Business logic and state management
- Located in `viewmodels/` directories
- Fetches data from Repository
- Exposes state to View
- Uses ChangeNotifier, Provider, Riverpod, etc.

### Repository (Data Layer)

- Abstracts data sources
- Located in `repositories/` directories
- Handles API calls, caching, local storage
- Provides clean API for ViewModels

---

## Adding a New Feature

Follow these steps to add a new feature:

1. **Create feature directory**:

   ```
   lib/features/new_feature/
   ```

2. **Create MVVM subdirectories**:

   ```
   new_feature/
   ├── models/
   ├── views/
   ├── viewmodels/
   └── repositories/
   ```

---

## File Naming Conventions

- **Views**: `feature_name_view.dart` (e.g., `login_view.dart`)
- **ViewModels**: `feature_name_viewmodel.dart` (e.g., `login_viewmodel.dart`)
- **Models**: `entity_name_model.dart` (e.g., `user_model.dart`)
- **Repositories**: `feature_name_repository.dart` (e.g., `auth_repository.dart`)
- **Services**: `service_name_service.dart` (e.g., `api_service.dart`)
- **Widgets**: `widget_name.dart` (e.g., `custom_button.dart`)
