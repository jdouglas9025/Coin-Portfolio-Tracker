# Coin Portfolio Tracker

Coin Portfolio Tracker is a full stack iOS app for advanced cryptocurrency portfolio tracking and analysis. It allows users to perform comprehensive tracking of their cryptocurrency portfolio as well as useful analysis such as future value estimation. It also features a powerful recommendation system (based on coins already in the user's portfolio) and provides a real-time collection of trending news articles (retrieved from Google News). The backend server leverages features such as caching and rate limiting to improve service quality and reliability. 

This project is built using Java, Python, Spring Boot (including frameworks for caching), and Swift/SwiftUI (including frameworks such as Combine). The app is compatible with devices running iOS 17+.

## Key Highlights

• Built a full stack iOS app for advanced cryptocurrency portfolio tracking and analysis

• Leveraged Java, Python, and Spring Boot for backend services deployed on AWS EC2

• Utilized Swift/SwiftUI and frameworks such as Combine and Swift Charts for frontend interface

## Languages

Java, Python, Spring Boot, Swift/SwiftUI (including Combine and Swift Charts)

## Systems

AWS EC2

## Example Screenshots
Note: Additional screenshots to be added within the next few days.

### Portfolio Management

#### Home Portfolio View

Summary: Shows an overview of the currently selected portfolio. Includes one day value changes (in dollars and percentages), current prices, and holding values. Also offers the ability to filter coins based on a search term, sort coins using predefined criteria (e.g., sort by holding value), and view holding profits/losses.

<img src="https://github.com/user-attachments/assets/d6814d5c-ec42-4e4d-8911-f49f13d1b0d2" width="240">

#### Top Coins View

Summary: Shows an overview of the top 1000 coins by marketcap. Utilizes a lazy loading approach to improve response time. Includes one day value changes (in percentages) as well as current prices. Also offers the ability to filter coins based on a search term, sort coins using predefined criteria (e.g., sort by market cap), and view market statistics such as total market cap.

<img src="https://github.com/user-attachments/assets/c4cd8a56-4eca-4b59-986f-2a92eefde537" width="240">

#### Detail Coin View

Summary: Shows an in-depth overview of a selected coin. Includes current price, one day value change (in dollars and percentage) as well as other information such as description and rank. Also provides an interactive chart showing price performance over a specified interval (default seven days).

<img src="https://github.com/user-attachments/assets/60e66f92-b949-49b6-b57a-236d57e47264" width="240">
