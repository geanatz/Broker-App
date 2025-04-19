# Financial Consulting Application Reference Guide

## Project Overview

This document serves as a comprehensive reference for developing a multi-platform financial consulting application using Flutter. The application will facilitate financial brokers in managing client information, handling calls, calculating loans, and optimizing their workflow.

### Application Purpose
The application is designed for financial brokers who help clients refinance or obtain new loans. Brokers contact potential clients from a database and offer them options to increase their credit (up to 40% or beyond of their monthly income). The application will automate and streamline this process.

### Development Approach
- **Incremental Development**: The application will be developed in versions, with each version adding new features and improvements.
- **Feedback-Driven**: Initial versions will be used by a single broker to gather feedback for improvements.
- **Scalable Architecture**: Although initially used by one broker, the application will be designed to accommodate multiple brokers and teams.
- **Flutter Framework**: Using Flutter for cross-platform compatibility (Windows, macOS, Android, iOS).
- **Dart Language**: Will be learning Dart throughout the development process.

## Technical Requirements

### Development Background
- Previous experience with Python, JavaScript, HTML/CSS, C++, and React Native
- Learning Dart during the development process
- UI/UX design created in Figma that must be strictly followed

### Code Quality Requirements
- Well-structured, optimized, and stable code
- Organized into logical file structures
- Clean architecture with separation of concerns
- Properly documented for future maintenance

## Core Features

### 1. Authentication System
- User selection from a list of agents
- Password protection for each account
- Secure login process
- Different access levels (regular agents, supervisors)

### 2. Image to Contacts (OCR System)
- **Functionality**: Extract client information from images of tables/documents
- **Data to Extract**: Names, phone numbers, CNPs (Romanian personal identification numbers)
- **Process Requirements**:
  - Image preprocessing to enhance character recognition
  - Text extraction from images
  - Text post-processing to correct extraction errors
  - Contact creation from extracted data
- **Visual Feedback**: Display all extraction steps and results to the agent
- **Accuracy Requirements**: High precision even with poor-quality images (low resolution, glare, etc.)
- **Privacy**: Consider local AI implementation to avoid sending sensitive data externally

### 3. One-Click Calling
- Integration with the agent's phone for direct calling
- Call status tracking (in progress, started, ended)
- Call duration monitoring (minutes and seconds)
- Call outcome recording (rejected, no answer, completed)

### 4. One-Click Speech
- Automated introduction speech (approximately 30 seconds)
- Integration with calling system
- Custom name insertion using AI voice synthesis
- Voice recording by the agent with dynamic name replacement

### 5. Loan and Income Forms
- Separate forms for client and co-borrower information
- Switch functionality between client and co-borrower data
- Dynamic form fields based on selections:
  - Bank selection dropdown
  - Credit type dropdown (Card de cumparaturi, Nevoi personale, Overdraft, Ipotecar, Prima casa)
  - Conditional input fields based on credit type

### 6. Automatic Bank Recommendation
- Analysis of client data to determine eligible banks
- Verification criteria including:
  - Client/co-borrower age
  - FICO scores
  - Employment history
  - Income levels
- Configurable bank parameters in application settings

### 7. Loan Calculator
- Inputs: loan amount, annual interest rate, loan period (years/months)
- Outputs: monthly payment, total interest, total payment
- Amortization table with show/hide functionality

### 8. Follow-up Call Management
- Scheduling system for callbacks
- Categories for:
  - Clients who requested a later call (with specific time)
  - Clients who didn't answer (to be called at agent's discretion)
- Reminder notifications for scheduled callbacks

### 9. Meeting Calendar for Teams
- Shared calendar visible to all agents across 3 teams
- Office availability tracking (3 meeting rooms)
- Appointment scheduling to avoid conflicts
- Permission control (agents can only modify their own appointments)

### 10. Duty Agent Rotation
- Tracking system for cleaning duty rotation
- Display of current duty agent
- Fair distribution of responsibilities across all agents

### 11. Statistics and Information Dashboard
- Performance metrics tracking:
  - Calls per day/week/month
  - Approved/rejected clients per week/month
  - Revenue generated per month/year
- Visual representation of statistics
- Time period filtering options

### 12. Home Screen/Dashboard
- Overview of important information
- Quick access to key features
- Display of upcoming calls
- Current duty agent information
- Key performance indicators

### 13. Client Status Tracking
- End-of-call status recording (accepted/rejected/postponed)
- Notes on conversation outcomes
- Follow-up action items

### 14. Client Recommendation System
- Tracking of client referrals
- Association between referrer and referred clients
- Commission calculation for successful referrals

### 15. Google Drive & Sheets Integration
- Automatic data transfer to Google Sheets
- Information to sync:
  - Client/co-borrower personal details
  - Credit information
  - Income information
  - Status updates
  - Recommendations

### 16. Supervisor Oversight
- Comprehensive view of all agent activities
- Agent performance statistics
  - Calls per day/week/month
  - Meetings per day/week/month
- Duty agent tracking
- Performance rankings for agents by different time periods

## Development Guidelines

### UI/UX Implementation
- Strictly follow the Figma designs provided
- Consult before making any design changes
- CSS code and Figma images will be provided as needed

### Improvement Suggestions
- Although designs should be followed, better implementation solutions are welcome
- Consider multiple approaches for each feature, prioritizing:
  - Performance
  - Stability
  - User experience
  - Maintainability
  - Compatibility with project requirements

### Version Management
- Develop the application incrementally
- Release usable versions for testing by a single broker
- Incorporate feedback into subsequent versions
- Plan for eventual deployment to the entire company

### Scaling Considerations
- Single user during development
- Multi-user, multi-team design from the start
- Future-proof architecture to accommodate company-wide adoption

## Implementation Priorities

The development should follow these priorities:

1. Core infrastructure and authentication
2. Basic client data management
3. Call handling and speech features
4. Loan calculation and bank recommendations
5. Meeting and duty management
6. Statistics and reporting
7. Google integration
8. Supervisor features

## Technical Integration Points

### Mobile Device Integration
- Communication protocol between app and phone
- Call status API integration
- Voice synthesis for speech feature

### Google Services
- Authentication and authorization
- Document creation and editing
- Data synchronization

### OCR Implementation
- Image processing libraries
- Text extraction algorithms
- Potential local AI models for improved accuracy

### Data Storage
- Local database structure
- Cloud synchronization
- Security and privacy considerations

## Testing Requirements

- Unit tests for core functionality
- Integration tests for feature combinations
- User acceptance testing with actual broker
- Performance testing across different platforms
- Security testing for sensitive financial data

## Conclusion

This financial consulting application aims to streamline the workflow of financial brokers by automating repetitive tasks, organizing client information, and providing valuable insights through statistics. The development approach focuses on iterative improvement based on real-world feedback, with a scalable architecture that can grow from a single-user tool to a company-wide system.