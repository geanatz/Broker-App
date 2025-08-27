# MAT Finance - Application Architecture Documentation

## Overview
MAT Finance is a comprehensive financial management application for consultants to manage client relationships, credit processes, and team coordination.

## Architecture

### Core Components
- **Authentication System**: Firebase-based authentication with support for mobile and desktop platforms
- **Client Management**: Comprehensive client database with advanced filtering and sorting capabilities
- **Calendar Integration**: Meeting scheduling and management system
- **Color System**: Consultant-specific color themes for team identification
- **Settings Management**: Centralized configuration for application preferences

### Key Features

#### Color Management System
- **10 predefined color palettes** for consultant identification
- **Real-time color availability tracking** across team members
- **Color trading system** for team coordination
- **Simplified color names only** (descriptions removed for cleaner UI)

#### Client Management
- Advanced client database with multi-criteria filtering
- Sortable columns: Number, Name, Age, FICO Score, Status
- Status hierarchy: Neapelat → Nu răspunde → Amanat → Programat → Finalizat
- Real-time synchronization with Firebase

#### Settings Area
- Consultant color selection and management
- Color trading requests and approvals
- Clean, streamlined interface with color names only

### Technical Implementation

#### Frontend Architecture
- **Flutter-based UI** with responsive design
- **Custom theme system** (AppTheme class)
- **Component-based architecture** with reusable widgets
- **Real-time state management** for dynamic updates

#### Backend Services
- **Firebase Firestore** for data persistence
- **Custom service layer** for business logic
- **Optimized data synchronization** with caching mechanisms

#### Platform Support
- **Windows Desktop**: Full-featured desktop application
- **Android/iOS Mobile**: Optimized mobile interface
- **Web**: Cross-platform web deployment

## Recent Changes

### Color System Optimization (16/01/2025)
- **Removed color descriptions** from entire application
- **Simplified colorNames map** in AppTheme class
- **Cleaned up settings interface** to show only color names
- **Eliminated deprecated methods** for color descriptions
- **Verified no breaking changes** across the application
- **Adjusted individual color container bottom padding** for proportional spacing (bottom padding = 8 + internal header height)
- **Removed visual hover effects** from color selection buttons while keeping click cursor

### Client Management Enhancements
- **Advanced sorting system** for all client table columns
- **Status-based prioritization** with custom ordering logic
- **Streamlined action buttons** with consistent theming
- **Optimized performance** for large client databases

## Data Flow

### Color Management Flow
1. Consultant selects color in settings area
2. System checks color availability in real-time
3. If taken, offers color trading functionality
4. Updates propagate to all team members via Firebase
5. UI reflects changes instantly across all components

### Client Management Flow
1. Clients loaded from Firebase with caching
2. Filtering and sorting applied client-side
3. Real-time updates via Firestore streams
4. Optimistic UI updates for better user experience

## Dependencies
- Flutter SDK
- Firebase Core, Auth, Firestore
- Google Fonts (Outfit font family)
- Flutter SVG for icon management
- Window Manager for desktop window controls
- Package Info Plus for version management

## Development Guidelines

### Color System
- Use AppTheme.getPrimaryColor(index) for main colors
- Use AppTheme.getSecondaryColor(index) for stroke/border colors
- Color names available via AppTheme.getColorName(index)
- Colors indexed 1-10 for consultant identification

### State Management
- Use ValueNotifier for simple reactive state
- Implement proper dispose patterns for controllers
- Prefer StreamBuilder for Firebase data streams
- Use addPostFrameCallback for UI updates after build

### Performance Optimization
- Implement proper caching for frequently accessed data
- Use const constructors where possible
- Optimize rebuild patterns with proper keys
- Minimize unnecessary widget rebuilds

## Setup and Deployment

### Development Environment
1. Install Flutter SDK (latest stable version)
2. Configure Firebase project with proper security rules
3. Set up platform-specific configurations
4. Run `flutter pub get` to install dependencies

### Build Process
- Use `flutter build windows` for desktop builds
- Use `flutter build apk` for Android builds
- Use `flutter build ios` for iOS builds
- Configure signing certificates for production builds

### Testing
- Run `flutter test` for unit tests
- Use `flutter analyze` for static analysis
- Test on multiple platforms for consistency
- Verify Firebase integration in staging environment
