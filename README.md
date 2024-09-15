# Coin Portfolio Tracker

Coin Portfolio Tracker is a full stack iOS app for advanced cryptocurrency portfolio tracking and analysis. It allows users to perform comprehensive tracking of their cryptocurrency portfolio as well as useful analysis such as future value estimation. It also features a powerful recommendation system (based on coins already in the user's portfolio) and provides a real-time collection of trending news articles (retrieved from Google News). The backend server leverages features such as caching and rate limiting to improve service quality and reliability. 

This app is compatible with devices running iOS 17+.

## Key Highlights

• Built a full stack iOS app for advanced cryptocurrency portfolio tracking and analysis

• Leveraged Java, Python, and Spring Boot for backend services deployed on AWS EC2

• Utilized Swift/SwiftUI and frameworks such as Combine and Swift Charts for frontend interface

## Languages and Frameworks

This project is built using Java, Python, Spring Boot, and Swift/SwiftUI. In addition to these primary languages, the project also leverages a variety of supplementary frameworks such as GSON, Caffeine (caching), Bucket4J (rate limiting), Swift Combine, and Swift Charts. 

## Systems

The backend server is deployed on an AWS EC2 instance.

## Example Screenshots

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

#### Total Value View

Summary: Shows an in-depth overview of the performance for the currently active portfolio. Includes various metrics related to total value change over a specified interval (default seven days) and provides an interactive chart for visualizing value change on an hour-to-hour basis.

<img src="https://github.com/user-attachments/assets/28720e96-31a1-4781-8fdb-35023e7baec1" width="240">

### Calculators

#### Future View

Summary: Provides a user with an overview of their custom goals as well as progress towards these goals. Also allows the user to access four different calculators related to investing (future value, historical CAGR, breakeven point, and capital gains).

<img src="https://github.com/user-attachments/assets/4521fbbd-ce1a-455b-9ce4-c19a5af52e6f" width="240">

#### Future Value (Reverse CAGR) Calculator

Summary: Allows a user to estimate what their portfolio might be worth given a certain annual growth rate and timeframe. Computes future value and provides an interactive chart showing total value over the specified interval.

<img src="https://github.com/user-attachments/assets/746a4bc7-ad42-47f3-8a11-22e6b0c0bc1c" width="240">

### Other

#### Market View

Summary: Shows a list of trending coins and news articles. News articles are retrieved from Google News and loaded from the publisher's website via an in-app browser. For news articles, users have the ability to filter results by keyword and/or published date.

<img src="https://github.com/user-attachments/assets/f82b6b56-21a8-40ff-b8b2-809c27bb5cf9" width="240">

#### Settings View

Summary: Allows the user to customize various UI-related settings, such as dark mode, font color, and font size. Any changes are reflected nearly instantly throughout the entire app (no manual reload required).

<img src="https://github.com/user-attachments/assets/9b5fc64c-ec28-4d65-9e21-37a20e8bf743" width="240">

