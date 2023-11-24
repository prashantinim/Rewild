# Rewild - README

## Overview

Rewild is a SwiftUI-based iOS application designed to assist users in finding the perfect plants for their needs. It utilizes OpenAI's powerful language models to provide personalized plant recommendations based on the user's location and preferences. The app also features user profile management, allowing users to track their plant cultivation progress and maintain a wishlist of desired plants.

## Features

- **User Authentication**: Users can log in to the app using their credentials.
- **Profile Management**: Users can set and view their preferred plant characteristics, track the number of plants they have cultivated, and maintain a wishlist.
- **Plant Recommendations**: Users can receive personalized plant recommendations based on their location and specified preferences, like plant size, flowering color, type, and height.
- **Interactive UI**: The app uses SwiftUI for a seamless and interactive user interface.
- **WebView Integration**: Incorporates WebKit to display external content within the app.
- **OpenAI Integration**: Utilizes OpenAI to fetch tailored plant care information and recommendations.

## How to Use

1. **Login**: Start by logging in with your username and password.
2. **Set Preferences**: Navigate to your profile to set your preferred plant characteristics.
3. **Get Recommendations**: Go to the 'Search' tab, enter your location details, select your preferences, and hit the "Find Plants" button.
4. **View Plant Details**: Access detailed information about the recommended plants, including care instructions.

## Technical Details

- **SwiftUI & Combine**: For building the user interface and handling asynchronous programming.
- **CoreLocation**: To access the user's location data.
- **OpenAISwift**: For integrating with OpenAI's APIs.
- **Custom Components**: Includes `PlantImageView`, `WebView`, and `PlantCareView` for various functionalities.

## Installation

Clone the repository and open the project in Xcode. Ensure you have the latest version of Xcode installed to handle SwiftUI effectively.

```bash
git clone [URL to the PlantRecommenderApp repository]
```

## Configuration

Replace the placeholder OpenAI API key in the `APICaller` class with your actual API key.

```swift
self.client = createClient(withKey: "YOUR_ACTUAL_API_KEY")
```

## Dependencies

- SwiftUI
- Combine
- WebKit
- CoreLocation
- OpenAISwift

## Contributing

Contributions are welcome. Please fork the repository and submit pull requests with any enhancements.

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

