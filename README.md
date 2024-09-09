# CyMe
CyMe is an open-source menstrual health tracking app developed as part of the research project **Seen by CyMe [si:][mi:]: Towards an open-source, customizable menstrual health app**. The app is built around the principles of customization and personalization, enabling the user to tailor the app to their needs and to receive personalized insights into their menstrual health. It further leverages different non-intrusive reporting options, including the integration of data collected automatically by wearables.

This repository contains the source code of the CyMe app. The project was developed using Swift and currently supports iOS and watchOS. The app refrains from using a client-server architecture, instead opting to store all user data on their personal device, ensuring a high level of data privacy and control. The project can be fully customized for those interested in contributing to or building on this code.

## Built with
- iOS and watchOS App: [Swift](https://www.swift.org/)
- Database: [SQLite](https://www.sqlite.org/)
- Other Tools: [Apple Health Kit](https://developer.apple.com/documentation/healthkit/)

## Getting Started
### Prerequisites
The CyMe app is developed with the following minimal OS Versions in mind:
- iOS: at least 16.2
- watchOS: at least 9.1

### Installation
1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) the Repository
2. Locate the `.xcodeproj` or `.xcworkspace` file in the project directory, and double-click it to open the project in Xcode.
3. Make sure you are [logged in](https://forums.developer.apple.com/forums/thread/744296) with your [Apple developer account](https://developer.apple.com/) to use the Apple HealthKit functionalities. 

### Run
#### With the project installed:
With the project installed, you can run your project either in the Simulator or on a real device utilizing Xcode. Find more information [here](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).

#### Without the installation of the project:
You can **test the app without installing the code** by using the public TestFlight link. It is possible to run the app directly on on your device by accessing this [link](https://testflight.apple.com/join/tbgXeJFm).

The link is active until the 4th of November. Please reach out to the development team for an active link after this date.

## License

Distributed under the MIT License. See `LICENSE` for more information.