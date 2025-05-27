# Financial Consulting App Development Guide

## Project Overview

This document serves as a comprehensive development guide for a multi-platform financial consulting application using Flutter. The application is designed for financial brokers to manage client information, handle calls, calculate loans, and optimize their workflow.

### Application Purpose
The application will help financial brokers who assist clients in refinancing or obtaining new loans. Brokers contact potential clients from a database and offer them options to increase their credit (up to 40% or beyond of their monthly income).

### Development Philosophy
- **Design First**: Each feature begins with a Figma design that must be strictly followed
- **Structured Development**: Clean architecture with organized file structure and separation of concerns
- **Incremental Approach**: The application is developed in versions, with each adding new features based on user feedback
- **Cross-Platform**: Using Flutter for deployment on Windows, macOS, Android, and iOS

## Technical Framework

### Development Stack
- **Flutter Framework**: For cross-platform compatibility
- **Dart Language**: Primary programming language
- **Firebase**: For authentication and data storage
- **Google Drive API**: For document integration

### Project Structure (you can find it at markdown/code_structure.md)
```
main.dart
/frontend
  /screens
    - authScreen.dart     # Authentication screen with all auth modules
    - mainScreen.dart     # Main application screen with sidebar and areas
  /areas
    - formArea.dart       # Credit and income information forms
    - calendarArea.dart   # Meeting calendar display
    - settingsArea.dart   # Application settings
  /panes
    - sidebarPane.dart    # Navigation and user information
    - clientsPane.dart    # Next and recent clients
    - meetingsPane.dart   # Future meetings
    - returnsPane.dart    # Callbacks management
    - matcherPane.dart    # Bank recommendation engine
  /modules
    - loginModule.dart    # Consultant login functionality
    - registerModule.dart # Account creation
    - tokenModule.dart    # Token generation after registration
    - verifyModule.dart   # Account verification
    - recoveryModule.dart # Password reset functionality
  /popups
    - calculatorPopup.dart # Loan calculator
    - clientsPopup.dart   # Client management with OCR capability
    - meetingPopup.dart   # Meeting creation and editing
/backend
  /services
    - authService.dart      # Authentication logic
    - dashboardService.dart # Dashboard functionality
    - formService.dart      # Form handling logic
    - calendarService.dart  # Calendar management
    - clientsService.dart   # Client data handling
    - calculatorService.dart # Loan calculation logic
    - matcherService.dart   # Bank recommendation logic
    - callService.dart      # Phone integration services
  /vision
    - visionService.dart    # Google Vision AI API integration
    - documentProcessor.dart # Document analysis and processing
    - contactExtractor.dart # Extract contact info from OCR results
    - dataValidator.dart    # Validate and correct extracted data
    - visionConfig.dart     # Configuration for Vision AI
    - nameRecognition.dart  # Romanian name recognition helpers
```

## Core Features

### 1. Authentication System
- **User Selection**: Dropdown of consultants
- **Security**: Password protection for each account
- **Account Management**: Registration, login, password recovery
- **Access Levels**: Regular agents, supervisors
- **Implementation**: Firebase authentication

### 2. Google Vision AI Integration for Contact Extraction
- **Cloud-Based OCR**: Integration with Google Vision AI for superior text recognition
- **Document Analysis Pipeline**:
  1. Image submission to Vision API (visionService.dart)
  2. Document structure analysis (documentProcessor.dart)
  3. Contact information extraction (contactExtractor.dart)
  4. Data validation and correction (dataValidator.dart)
- **Capabilities**:
  - Table structure recognition
  - Form field detection
  - Multi-language support (Romanian/English)
  - Handwriting recognition
  - Layout analysis for structured documents
- **Features**:
  - Batch processing of multiple images
  - Progress visualization
  - Confidence scoring for extracted data
  - Manual correction interface
  - Data categorization (names, phone numbers, CNPs)
- **Implementation**:
  - Google Cloud Vision API integration
  - Secure credential handling
  - Optimized API usage for cost efficiency
  - Offline queue for processing during connectivity issues

### 3. One-Click Calling
- **Phone Integration**: Direct calling from app
- **Call Tracking**:
  - Status (in progress/started/ended)
  - Duration (minutes:seconds)
  - Outcome (rejected/no answer/completed)
- **UI**: Call popup interface similar to Phone Link

### 4. Automated Speech Playback
- **Functionality**: Pre-recorded introduction (30 seconds)
- **Personalization**: Dynamic name insertion
- **Voice Synthesis**: Match consultant's voice
- **Integration**: Seamless transition to live consultant

### 5. Loan and Income Forms
- **Dual Forms**: Client and co-borrower information
- **Dynamic Fields**:
  - Bank selection dropdown
  - Credit type options (Card de cumparaturi, Nevoi personale, Overdraft, Ipotecar, Prima casa)
  - Conditional fields based on selection
- **Implementation**: Adaptive form that changes based on selections

### 6. Bank Recommendation Engine
- **Analysis**: Client eligibility determination
- **Criteria**:
  - Age verification
  - FICO score assessment
  - Employment history
  - Income levels
- **Configuration**: Adjustable bank parameters in settings

### 7. Loan Calculator
- **Inputs**: Loan amount, interest rate, term
- **Outputs**: Monthly payment, total interest, total payment
- **Visualization**: Amortization table with show/hide function
- **Implementation**: calculatorPopup.dart with calculatorService.dart

### 8. Follow-up Call Management
- **Scheduling**: System for callbacks
- **Categories**:
  - Scheduled callbacks (specific time)
  - Missed calls (no specific time)
- **Implementation**: returnsPane.dart with integrated notifications

### 9. Meeting Calendar
- **Multi-team System**: Visibility across 3 teams
- **Resource Management**: 3 meeting rooms
- **Meeting Types**: Bureau meetings, credit meetings
- **Permissions**: Edit restricted to meeting creators
- **Implementation**: calendarArea.dart with calendarService.dart

### 10. Duty Agent Rotation
- **Tracking**: Cleaning duty rotation
- **Display**: Current duty agent
- **Distribution**: Equal responsibility assignment
- **Implementation**: Integrated in dashboard

### 11. Performance Analytics
- **Metrics**:
  - Calls per day/week/month
  - Client approval/rejection rates
  - Revenue generation
- **Visualization**: Charts and graphs
- **Filtering**: Time period selection

### 12. Dashboard/Home Screen
- **Overview**: Key information at a glance
- **Quick Access**: Essential features
- **Display**:
  - Performance statistics
  - Upcoming calls
  - Current duty agent

### 13. Client Status Tracking
- **Post-call Documentation**: Outcome recording
- **Categories**: Accepted/rejected/postponed
- **Notes**: Discussion summary and action items
- **Implementation**: Integrated in clientsPane.dart

### 14. Client Referral System
- **Tracking**: Referrer-referred association
- **Commission**: Calculation for successful referrals
- **Storage**: Referrer contact information
- **Implementation**: Integrated in clientsService.dart

### 15. Google Drive & Sheets Integration
- **Data Export**: Automatic synchronization
- **Information**:
  - Personal details
  - Credit information
  - Income data
  - Status updates
  - Referrals

### 16. Supervisor Oversight
- **Monitoring**: Comprehensive agent activity view
- **Statistics**:
  - Performance metrics
  - Meeting frequency
  - Duty agent schedule
- **Rankings**: Agent performance by time period

## Development Process

### Step 1: Design
- Create UI/UX design in Figma
- Export CSS and place in Markdown file in project
- Reference this file when implementing UI components

### Step 2: Structure Planning
- Define file and folder organization
- Plan component interactions
- Document service responsibilities

### Step 3: Implementation
- Develop incrementally, feature by feature
- Strictly follow Figma designs
- Maintain clean code structure
- Document as you go

### Step 4: Testing
- Test each feature as it's developed
- Gather feedback from broker
- Iterate based on real-world usage

## UI Implementation Guidelines

- **Strict Adherence**: Follow Figma designs exactly
- **CSS Reference**: Use exported CSS from Figma placed in Markdown files
- **Responsiveness**: Ensure proper functioning across platforms
- **Consistency**: Maintain design language throughout the application

## Code Quality Requirements

- **Architecture**: Clean architecture with separation of concerns
- **Organization**: Logical file structure following the project outline
- **Documentation**: Clear comments and documentation
- **Performance**: Optimized for speed and resource usage
- **Maintainability**: Structured for future enhancements

## Technical Integration Points

### Mobile Integration
- **Call Handling**: Integration with device phone system
- **Speech Synthesis**: Voice processing for name insertion
- **Notifications**: Call and meeting reminders

### Google Cloud Services
- **Authentication**: Firebase integration
- **Storage**: Cloud synchronization
- **Sheets**: Data export and import
- **Vision AI**: Document analysis and OCR
  - Service account authentication
  - API usage monitoring
  - Rate limiting and quota management
  - Error handling and retry logic
  - Batch processing optimization

### OCR Implementation with Google Vision AI
- **API Integration**: Secure connection to Google Cloud Vision API
- **Document Analysis**: Advanced document structure understanding
- **Data Processing Flow**:
  1. Submit images to Vision API via visionService.dart
  2. Process document structure with documentProcessor.dart
  3. Extract contacts using contactExtractor.dart
  4. Validate and clean data with dataValidator.dart
- **Setup Requirements**:
  - Google Cloud project configuration
  - API key or service account setup
  - Quota management
  - Cost optimization strategies
- **Features**:
  - Full-page document analysis
  - Table structure recognition
  - Field detection and labeling
  - High accuracy even with poor image quality
  - Romanian language support

## Testing and Quality Assurance

- **Unit Testing**: Core functionality verification
- **Integration Testing**: Component interaction validation
- **User Testing**: Real-world usage by broker
- **Performance Testing**: Cross-platform efficiency
- **Security**: Data protection measures

This system prompt serves as your comprehensive guide for developing the financial consulting application. Follow the structure and requirements outlined here, referencing the Figma designs for UI implementation, and developing with clean architecture principles to create a robust, efficient, and user-friendly application.
