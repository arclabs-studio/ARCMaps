# 🗺️ ARCMaps

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A comprehensive Swift Package for place enrichment and map visualization in iOS and macOS apps.

## ✨ Features

### 🔍 Place Enrichment
- **Multi-Provider Search**: Support for Google Places API and Apple MapKit
- **Rich Data**: Photos, reviews, ratings, hours, contact info
- **Smart Caching**: Automatic result caching for better performance
- **Automatic Fallback**: Seamlessly switches between providers

### 🗺️ Map Visualization
- **Interactive Maps**: Native MapKit integration
- **Custom Markers**: Distinct markers for wishlist vs. visited places
- **Advanced Filtering**: Filter by status, category, rating, date
- **Location Services**: User location with permission handling
- **External Navigation**: Launch Apple Maps, Google Maps, or Waze

### 🏗️ Architecture
- **Clean Architecture**: Separation of concerns with Domain/Data/Presentation layers
- **Protocol-Based**: Easy to test and extend
- **Swift 6 Ready**: Full async/await and strict concurrency support
- **SwiftUI First**: Modern declarative UI components

## 📦 Installation

### Swift Package Manager

#### Xcode
1. File > Add Package Dependencies
2. Enter: `https://github.com/carlosrasensio/ARCMaps.git`
3. Select version and add to target

#### Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/carlosrasensio/ARCMaps.git", from: "1.0.0")
]
```

## 🚀 Quick Start

See [CLAUDE.md](CLAUDE.md) for detailed development documentation and the DocC documentation for complete API reference.

### Basic Configuration

```swift
import ARCMaps

ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_API_KEY",
    defaultProvider: .google
)
```

### Display a Map

```swift
import SwiftUI
import ARCMaps

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    
    var body: some View {
        ARCMapView(viewModel: viewModel)
            .onAppear {
                viewModel.setPlaces(yourPlaces)
            }
    }
}
```

## 📖 Documentation

- **CLAUDE.md**: Development guide and architecture overview
- **DocC**: Full API documentation (build in Xcode)
- **Examples**: See test files for usage examples

## 🧪 Testing

Comprehensive test helpers included:
- Mock services and fixtures
- 95%+ code coverage
- Swift 6 concurrency safe

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Made with ❤️ by ARC Labs Studio**
