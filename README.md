# TMDB Movie App

A SwiftUI-based iOS application that showcases movies using The Movie Database (TMDB) API. 

## Features

### Upcoming Movies
- Browse through a list of upcoming movie releases
- Infinite scrolling pagination
- Pull-to-refresh functionality
- Search movies with debounced input
- Accessible UI with VoiceOver support

### Movie Details
- View detailed information about each movie
- High-quality movie poster images with caching
- Movie overview, rating, and genre information
- Responsive layout supporting Dynamic Type

## Technical Implementation

### Architecture
- MVVM-C architecture
- Protocol-oriented design
- Dependency injection for better testability
- Combine for reactive programming

### Networking
- Async/await for network calls
- Generic network layer
- Error handling and retry logic
- Image caching system

### UI/UX
- SwiftUI-based interface
- Responsive layouts
- Loading states and error handling
- Smooth animations and transitions

### Accessibility
- VoiceOver support
- Clear accessibility labels and hints

## Implementation Notes

### Search Functionality
Currently, the search implementation:
- Debounces user input
- Shows immediate results
- Handles empty states

 Next steps: Adding a pagination for search

