# ExampleApp

Demo application for ARCMaps.

## Requirements

- Xcode 16.0+
- iOS 17.0+
- Swift 6.0+

## Running the Example

1. Open `ExampleApp.xcodeproj` in Xcode
2. The ARCMaps package is referenced locally (no additional setup needed)
3. Select an iOS simulator and press Run (Cmd+R)

## Features Demonstrated

### Map Demo Tab

- **Interactive Map**: Displays sample places on an Apple Maps view
- **Custom Markers**: Wishlist places show red heart markers, visited places show green checkmark markers
- **Place Details**: Tap any marker to see place information in a sheet
- **Map Controls**: Use built-in controls to fit all places, change map style, and show user location
- **iOS 18+ POI Selection**: Toggle to enable tapping native Apple Maps points of interest

### Filter Demo Tab

- **Status Filter**: Show only wishlist or visited places
- **Category Filter**: Filter by restaurant, cafe, or market
- **Rating Filter**: Set minimum rating threshold (0-5 stars)
- **Real-time Updates**: Map updates immediately as filters change

### About Tab

- Package information and version
- Feature list with descriptions
- Links to documentation

## Sample Data

The app uses fictional places in Madrid, Spain to demonstrate ARCMaps features. In a real application, you would:

1. Configure `ARCMapsConfiguration` with your Google Places API key
2. Use `GooglePlacesService` or `AppleMapsSearchService` to search for real places
3. Use `PlaceEnrichmentViewModel` to manage search state

## Project Structure

```
ExampleApp/
├── ExampleApp.xcodeproj    # Xcode project (references ARCMaps locally)
├── ExampleApp/
│   ├── ExampleAppApp.swift # App entry point with configuration
│   ├── ContentView.swift   # Tab navigation
│   ├── MapDemoView.swift   # Basic map demonstration
│   ├── FilterDemoView.swift# Filter functionality demo
│   ├── AboutView.swift     # App information
│   ├── SampleData.swift    # Example places
│   ├── Info.plist          # App configuration
│   └── Assets.xcassets     # App assets
└── README.md               # This file
```

## Customization

### Using Google Places API

To enable Google Places search, update `ExampleAppApp.swift`:

```swift
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
    defaultProvider: .google
)
```

### Adding Location Permission

The app already includes the required `NSLocationWhenInUseUsageDescription` in Info.plist. Location permission is requested automatically when the map view appears.

## See Also

- [ARCMaps Documentation](../../Sources/ARCMaps.docc/)
- [Getting Started Guide](../../Sources/ARCMaps.docc/GettingStarted.md)
