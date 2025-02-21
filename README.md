# MatchProfilesApp

## Overview
MatchProfilesApp is an iOS application that fetches user profiles from an API and allows users to accept or decline matches. The app supports offline mode using Core Data for data persistence, ensuring a seamless experience even when the internet connection is unavailable.

## Features
- **API Integration:** Retrieves user data from [randomuser.me](https://randomuser.me/api/?results=10).
- **User Interface:** Displays match cards with user images, details, and action buttons.
- **Accept/Decline Functionality:** Lets users accept or decline matches, updating both the UI and local database accordingly.
- **Local Database:** Uses Core Data to store user profiles and their acceptance/decline status.
- **Offline Mode:** Caches data and queues actions for later synchronization when online.
- **Reactive Data Flow:** Utilizes Combine to update the UI in real time.
- **Clean UI Design:** Built with SwiftUI for an intuitive and visually appealing experience.

## Technologies Used
- **Swift:** Primary programming language.
- **SwiftUI:** For designing the user interface.
- **URLSession:** For API calls (alternative to Alamofire).
- **SDWebImage:** For efficient image loading and caching.
- **Core Data:** For local data storage.
- **Combine:** For reactive programming and data binding.
- **Network Framework:** For monitoring network connectivity.

## Installation
1. **Clone the Repository:**
   ```sh
   git clone https://github.com/your-username/MatchProfilesApp.git
