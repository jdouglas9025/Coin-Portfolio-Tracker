package com.jdouglas9025.coinportfoliotracker.api;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.jdouglas9025.coinportfoliotracker.entity.globaldata.GlobalDataEntity;
import com.jdouglas9025.coinportfoliotracker.entity.globaldata.containers.GlobalDataContainer;
import com.jdouglas9025.coinportfoliotracker.entity.globaldata.containers.RawGlobalData;
import com.jdouglas9025.coinportfoliotracker.entity.market.CoinEntity;
import com.jdouglas9025.coinportfoliotracker.entity.metadata.MetadataEntity;
import com.jdouglas9025.coinportfoliotracker.entity.metadata.containers.MetadataContainer;
import com.jdouglas9025.coinportfoliotracker.entity.news.NewsEntity;
import com.jdouglas9025.coinportfoliotracker.entity.news.containers.RawNewsEntity;
import com.jdouglas9025.coinportfoliotracker.entity.trending.TrendingEntity;
import com.jdouglas9025.coinportfoliotracker.entity.trending.containers.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.annotation.Schedules;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ApiService {
    // Used for executing on schedule based on EST time
    private final String timezone = "America/New_York";

    // Output all dates as a consistent format
    private final DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");

    // Intervals for scheduled price and global data updates:
    // Active - Every 23 minutes between 8AM and 9:59PM EST
    private final String every23MinutesFor14Hours = "0 */23 8-21 * * *";
    // Inactive - Every 30 minutes between 10PM and 7:59AM EST
    private final String every30MinutesFor10Hours = "0 */30 22-23,0-7 * * *";

    // Interval for scheduled trending coins updates:
    // Every 6 hours (4 times a day)
    private final String every6Hours = "21600000";

    // Interval for refreshing coin metadata:
    // On the first of each month at 3AM EST
    private final String atFirstOfMonth = "0 0 3 1 * *";

    // Interval for refreshing news article headlines
    // Every 60 minutes (24 times a day)
    private final String every60Minutes = "3600000";

    private final HttpClient client = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_2)
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    private final Gson gson = new Gson();
    private final String baseUrl = "https://api.coingecko.com/api/v3";
    private final String authHeader = "x-cg-demo-api-key";

    private final String baseFilePath = ""; // Update to base path on current machine
    private final String googleNewsScriptFilePath = baseFilePath + "/googleNewsScraper.py";
    private final String recommendationScriptFilePath = baseFilePath + "/recommendationSystem.py";
    private final String metadataEntitiesFilePath = baseFilePath + "/metadata/metaDataEntities.txt";
    private final String descriptionsFilePath = baseFilePath + "/metadata/descriptions.csv";
    private final String recommendationsFilePath = baseFilePath + "/metadata/recommendations.txt";
    private final String newsFeedFilePath = baseFilePath + "/news/newsFeed.txt";

    @Value("${custom.coinGecko.apiKey}")
    private String apiKey;

    // All coins from market data API call
    private List<CoinEntity> allCoins;
    private String allCoinsLastUpdated;

    // Global data (e.g., total market cap)
    private GlobalDataEntity globalData;
    private String globalDataLastUpdated;

    // Trending coins
    private List<TrendingEntity> trendingCoins;
    private String trendingCoinsLastUpdated;

    // Map of metadata (key: coinId) for with metadata for each coin
    private Map<String, MetadataEntity> metadata;

    // Collection of news headlines from Google News
    private List<NewsEntity> news;
    private String newsLastUpdated;

    // Map of coin to recommended coins (key: coinId to get recommendations for, value: array of coin ids)
    private Map<String, String[]> recommendedCoins;

    // Executes initial methods upon boot to load data in memory from disk
    public ApiService() {
        // Load metadata map into memory
        getMetadataMapFromDisk();

        // Load recommended coins into memory
        getRecommendedCoins();
    }

    // Updates price data for the top 1000 cryptos by making 4x API calls to the CoinGecko API
    // Also pulls in latest metadata/recommendations if available
    // Busy period calls: 4,532 | Off period calls: 2,480
    @Schedules({@Scheduled(cron = every23MinutesFor14Hours, zone = timezone), @Scheduled(cron = every30MinutesFor10Hours, zone = timezone)})
    public void updateAllCoins() {
        Runnable task = () -> {
            // New list to hold results and times before execution
            List<CoinEntity> result = new ArrayList<>();
            LocalDateTime currentTime = LocalDateTime.now(ZoneId.of(timezone));
            String sparklineLastUpdated = getLastUpdateTimeForSparkline();

            // Get top 1000 coins (page 1,2,3,4)
            for (int i = 1; i <= 4; i++) {
                String endpoint = "/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page="
                        + i + "&sparkline=true&price_change_percentage=7d%2C14d%2C30d%2C1y&locale=en&precision=full";

                try {
                    HttpRequest request = HttpRequest.newBuilder()
                            .GET()
                            .uri(URI.create(baseUrl + endpoint))
                            .setHeader(authHeader, apiKey)
                            .build();

                    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                    if (response == null || response.statusCode() != 200) {
                        return;
                    }

                    String body = response.body();
                    CoinEntity[] parsedData = gson.fromJson(body, CoinEntity[].class);

                    for (CoinEntity coin : parsedData) {
                        // Skip outdated coins that contain '[OLD]' or '(OLD)' in their name (should only be a few at most)
                        if (coin.name.contains("[OLD]") || coin.name.contains("(OLD)")) {
                            continue;
                        }

                        coin.sparklineLastUpdated = sparklineLastUpdated;

                        result.add(coin);
                    }
                } catch (Exception ignored) {
                }
            }

            // Only update stored map if able to get new results
            if (!result.isEmpty()) {
                allCoins = result;
                allCoinsLastUpdated = currentTime.format(dateTimeFormatter);
            }

            // Get metadata for each coin (if available)
            if (metadata != null && !metadata.isEmpty()) {
                for (CoinEntity coin : allCoins) {
                    String coinId = coin.id;
                    MetadataEntity data = metadata.get(coinId);

                    // Update coin with metadata
                    if (data != null) {
                        coin.blockTime = data.blockTime;
                        coin.hashingAlgorithm = data.hashingAlgorithm;
                        coin.description = data.description;
                        coin.homepageUrl = data.homepageUrl;
                        coin.subredditUrl = data.subredditUrl;
                        coin.genesisDate = data.genesisDate;
                        coin.positiveSentimentPercentage = data.positiveSentimentPercentage;
                    }
                }
            }

            // Get recommendations for each coin (if available)
            if (recommendedCoins != null && !recommendedCoins.isEmpty()) {
                for (CoinEntity coin : allCoins) {
                    String coinId = coin.id;

                    coin.recommendedCoins = recommendedCoins.get(coinId);
                }
            }
        };

        executeBackgroundTask(task);
    }

    // Updates global data (e.g., total market cap) by making 1x API call to the CoinGecko Global API endpoint
    // Busy period calls: 1,133 | Off period calls: 620
    @Schedules({@Scheduled(cron = every23MinutesFor14Hours, zone = timezone), @Scheduled(cron = every30MinutesFor10Hours, zone = timezone)})
    public void updateGlobalData() {
        Runnable task = () -> {
            String endpoint = "/global";

            try {
                HttpRequest request = HttpRequest.newBuilder()
                        .GET()
                        .uri(URI.create(baseUrl + endpoint))
                        .setHeader(authHeader, apiKey)
                        .build();

                HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                if (response == null || response.statusCode() != 200) {
                    return;
                }

                // Parse into container object
                String body = response.body();
                GlobalDataContainer container = gson.fromJson(body, GlobalDataContainer.class);

                // Perform processing on container to update global data object
                processGlobalDataContainer(container);
            } catch (Exception ignored) {
            }
        };

        executeBackgroundTask(task);
    }

    // Updates trending coin data by making 1x API call to the CoinGecko Trending API endpoint
    // Total calls: 124 calls
    @Scheduled(fixedRateString = every6Hours)
    public void updateTrendingCoins() {
        Runnable task = () -> {
            String endpoint = "/search/trending";

            try {
                HttpRequest request = HttpRequest.newBuilder()
                        .GET()
                        .uri(URI.create(baseUrl + endpoint))
                        .setHeader(authHeader, apiKey)
                        .build();

                HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                if (response == null || response.statusCode() != 200) {
                    return;
                }

                // Parse into container object
                String body = response.body();
                TrendingContainer container = gson.fromJson(body, TrendingContainer.class);

                // Perform processing on container to update global data object
                processTrendingContainer(container);
            } catch (Exception ignored) {
            }
        };

        executeBackgroundTask(task);
    }

    // Updates metadata (e.g., descriptions) for the top 1K coins by making 1x API call to the CoinGecko coins API endpoint
    // Performed over 100 minutes (10 calls per minute)
    // Total calls: 1000 calls
    @Scheduled(cron = atFirstOfMonth, zone = timezone)
    public void updateMetadata() {
        Runnable task = () -> {
            String endpoint = "/coins/";
            String queryParams = "?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false";

            // Verify data exists in coins (possible initial boot during execution)
            if (allCoins == null || allCoins.isEmpty()) {
                try {
                    // Wait 30.5 minutes (30 minute max interval for getting coins + .5 minute for processing), then try again
                    Thread.sleep(1830000);

                    if (allCoins == null || allCoins.isEmpty()) {
                        return;
                    }
                } catch (Exception ignored) {
                }
            }

            // Use new map rather than resetting stored map
            Map<String, MetadataEntity> result = new HashMap<>();

            // Process 10 coins per minute
            int numOfIterations = allCoins.size() / 10;

            for (int i = 0; i < numOfIterations; i++) {
                // Process next 10 coins (or however many left)
                for (int j = i * 10; j < allCoins.size() && j < (i * 10) + 10; j++) {
                    CoinEntity coin = allCoins.get(j);
                    String coinId = coin.id;

                    try {
                        HttpRequest request = HttpRequest.newBuilder()
                                .GET()
                                .uri(URI.create(baseUrl + endpoint + coinId + queryParams))
                                .setHeader(authHeader, apiKey)
                                .build();

                        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                        if (response == null || response.statusCode() != 200) {
                            // Skip to next coin
                            continue;
                        }

                        // Parse into container object
                        String body = response.body();
                        MetadataContainer container = gson.fromJson(body, MetadataContainer.class);

                        // Perform processing on container and add entity to map
                        processMetadataContainer(result, container, coinId);
                    } catch (Exception ignored) {
                    }
                }

                // Wait 1 minute before processing next iteration to avoid rate throttle
                try {
                    Thread.sleep(60000);
                } catch (Exception ignored) {
                }
            }

            if (!result.isEmpty()) {
                metadata = result;

                // Write metadata entity map to disk
                try (BufferedWriter writer = new BufferedWriter(new FileWriter(metadataEntitiesFilePath))) {
                    String json = gson.toJson(metadata);
                    writer.write(json);
                } catch (Exception ignored) {
                }

                // Write coin descriptions to disk for recommendations script
                try (BufferedWriter writer = new BufferedWriter(new FileWriter(descriptionsFilePath))) {
                    // Header row (columns)
                    writer.write("coinId,description\n");

                    // Write data for each entity and append new line to separate
                    for (String coinId : metadata.keySet()) {
                        String description = metadata.get(coinId).description;

                        // Skip coin if description is null/empty
                        if (description == null || description.isEmpty()) {
                            continue;
                        }

                        // Remove escape/quote characters from description and enclose in quotes to prevent CSV issues
                        description = "\"" + description
                                .replaceAll("[\\r\\n]+", " ")
                                .replaceAll("\"", "'")
                                + "\"";

                        writer.append(coinId).append(",");
                        writer.append(description).append("\n");
                    }
                } catch (Exception ignored) {
                }

                // Update recommended coins now that descriptions are saved to disk
                getRecommendedCoins();
            }
        };

        executeBackgroundTask(task);
    }

    // Updates news article headlines every 60 minutes with max 150 articles from Google News
    @Scheduled(fixedRateString = every60Minutes)
    public void updateNewsFeed() {
        Runnable task = () -> {
            try {
                // CLI commands to execute
                String[] command = {"python3", googleNewsScriptFilePath};

                ProcessBuilder builder = new ProcessBuilder(command);
                Process process = builder.start();

                // Wait for script to finish
                process.waitFor();

                // Read from file that script saved on disk
                try (BufferedReader reader = new BufferedReader(new FileReader(newsFeedFilePath))) {
                    StringBuilder buffer = new StringBuilder();

                    // Parse response
                    String nextLine;
                    while ((nextLine = reader.readLine()) != null) {
                        buffer.append(nextLine);
                    }

                    RawNewsEntity[] container = gson.fromJson(buffer.toString(), RawNewsEntity[].class);

                    // Only update if not null and > 0 items -- else, keep old data in memory
                    if (container != null && container.length > 0) {
                        news = processNewsEntitiesContainer(container);
                        newsLastUpdated = LocalDateTime.now(ZoneId.of(timezone)).format(dateTimeFormatter);
                    }
                } catch (Exception ignored) {
                }

                process.destroy();
            } catch (Exception ignored) {
            }
        };

        executeBackgroundTask(task);
    }

    private void processGlobalDataContainer(GlobalDataContainer container) {
        if (container == null || container.data == null) {
            return;
        }

        RawGlobalData rawData = container.data;

        // Update reference with new object constructed from response data
        globalData = new GlobalDataEntity(
                rawData.active_cryptocurrencies, rawData.total_market_cap.usd, rawData.total_volume.usd,
                rawData.market_cap_percentage.btc, rawData.market_cap_percentage.eth, rawData.market_cap_change_percentage_24h_usd
        );

        globalDataLastUpdated = LocalDateTime.now(ZoneId.of(timezone)).format(dateTimeFormatter);
    }

    private void processTrendingContainer(TrendingContainer container) {
        if (container == null || container.coins == null) {
            return;
        }

        // Temporary list to hold results
        List<TrendingEntity> results = new ArrayList<>();

        // Process each coin in container
        for (CoinContainer coin : container.coins) {
            RawItem item = coin.item;

            if (item == null) {
                continue;
            }

            String id = item.id;
            String name = item.name;
            String symbol = item.symbol.toUpperCase();
            Integer marketCapRank = item.market_cap_rank;
            String largeImage = item.large;
            // Add 1 since 0-indexed
            Integer trendingScore = item.score + 1;

            // Check if data is null; if so, skip to next coin without adding current
            RawData data = item.data;
            if (data == null) {
                continue;
            }

            Double price;
            Double marketCap;
            Double volume;
            Double priceChangePercentage24H;

            try {
                // Price, market cap, volume comes back with '$' in front and ',' between numbers
                price = Double.parseDouble(data.price.replaceAll("[$,]", ""));
                marketCap = Double.parseDouble(data.market_cap.replaceAll("[$,]", ""));
                volume = Double.parseDouble(data.total_volume.replaceAll("[$,]", ""));

                priceChangePercentage24H = data.price_change_percentage_24h.usd;
            } catch (NumberFormatException | NullPointerException ignored) {
                // Skip this coin since unable to get key price data
                continue;
            }

            // Check if content is null -- if so, save coin and skip to next coin (description optional)
            RawContent content = data.content;
            if (content == null) {
                results.add(new TrendingEntity(id, name, symbol, marketCapRank, largeImage, trendingScore, price,
                        priceChangePercentage24H, marketCap, volume, null)
                );
                continue;
            }

            String description = content.description;

            // All fields processed
            results.add(new TrendingEntity(id, name, symbol, marketCapRank, largeImage, trendingScore, price,
                    priceChangePercentage24H, marketCap, volume, description));
        }

        // Update reference to processed results
        if (!results.isEmpty()) {
            trendingCoins = results;
            trendingCoinsLastUpdated = LocalDateTime.now(ZoneId.of(timezone)).format(dateTimeFormatter);
        }
    }

    private void processMetadataContainer(Map<String, MetadataEntity> map, MetadataContainer container, String coinId) {
        if (container == null) {
            return;
        }

        MetadataEntity entity = new MetadataEntity();

        // Update data with non-exception throwing results
        entity.blockTime = container.blockTime;
        entity.hashingAlgorithm = container.hashingAlgorithm;
        entity.genesisDate = container.genesisDate;
        entity.positiveSentimentPercentage = container.positiveSentimentPercentage;

        if (container.descriptionContainer != null && container.descriptionContainer.description != null) {
            // Format description using regex
            entity.description = container.descriptionContainer.description.replaceAll("<[^>]*>", "");
        }

        if (container.linksContainer != null) {
            // Get homepage URL
            if (container.linksContainer.homepageUrlContainer != null && container.linksContainer.homepageUrlContainer.length > 0) {
                entity.homepageUrl = container.linksContainer.homepageUrlContainer[0];
            }

            // Get subreddit URL
            entity.subredditUrl = container.linksContainer.subredditUrl;
        }

        map.put(coinId, entity);
    }

    private List<NewsEntity> processNewsEntitiesContainer(RawNewsEntity[] container) {
        List<NewsEntity> result = new ArrayList<>();

        for (RawNewsEntity rawData : container) {
            if (rawData.publisher != null) {
                String publisherName = rawData.publisher.publisherName;

                // Process title
                int titleEndIndex = rawData.title.lastIndexOf(" - " + publisherName);
                String title = rawData.title.substring(0, titleEndIndex);

                NewsEntity newsEntity = new NewsEntity(title, rawData.publishedDate, rawData.url, publisherName, rawData.imageUrl);
                result.add(newsEntity);
            } else {
                NewsEntity newsEntity = new NewsEntity(rawData.title, rawData.publishedDate, rawData.url, null, rawData.imageUrl);
                result.add(newsEntity);
            }
        }

        return result;
    }

    // Generates recommended coins using script
    // Executed on calling thread rather than separate thread
    private void getRecommendedCoins() {
        try {
            String[] command = {"python3", recommendationScriptFilePath};

            ProcessBuilder builder = new ProcessBuilder(command);
            Process process = builder.start();

            // Wait for process to finish
            process.waitFor();

            process.destroy();

            // Read newly created file
            try (BufferedReader reader = new BufferedReader(new FileReader(recommendationsFilePath))) {
                StringBuilder buffer = new StringBuilder();

                // Parse response
                String nextLine;
                while ((nextLine = reader.readLine()) != null) {
                    buffer.append(nextLine);
                }

                // Parse JSON into map where key is coin id and value is array of strings of recommended coin ids
                Map<String, String[]> processed = gson.fromJson(buffer.toString(), new TypeToken<Map<String, String[]>>() {
                }.getType());

                // Only update if not null and > 0 items -- else, keep old data in memory
                if (processed != null && !processed.isEmpty()) {
                    recommendedCoins = processed;
                }
            } catch (Exception ignored) {
            }
        } catch (Exception ignored) {
        }
    }

    // Executed on calling thread rather than separate thread
    private void getMetadataMapFromDisk() {
        try (BufferedReader reader = new BufferedReader(new FileReader(metadataEntitiesFilePath))) {
            StringBuilder buffer = new StringBuilder();

            // Parse response
            String nextLine;
            while ((nextLine = reader.readLine()) != null) {
                buffer.append(nextLine);
            }

            // Parse JSON into map and update reference
            Map<String, MetadataEntity> processed = gson.fromJson(buffer.toString(), new TypeToken<Map<String, MetadataEntity>>() {
            }.getType());

            // Only update if not null and > 0 items -- else, keep old data in memory
            if (processed != null && !processed.isEmpty()) {
                metadata = processed;
            }
        } catch (Exception ignored) {
        }
    }

    private String getLastUpdateTimeForSparkline() {
        // Find most recent update interval for sparkline data to use for period overview and chart
        // Data is updated at approximately 00:00, 06:00, 12:00, 18:00 in UTC
        // Updated with data through previous hour (e.g., 06:00's last data point is for 05:00), so subtract an hour
        // Get dates as UTC, then convert to eastern before returning
        final ZoneId utcTimezone = ZoneId.of("UTC");
        final ZoneId easternTimezone = ZoneId.of(timezone);

        // Update times in UTC
        LocalTime midnight = LocalTime.of(0, 0);
        LocalTime sixAM = LocalTime.of(6, 0);
        LocalTime midday = LocalTime.of(12, 0);
        LocalTime sixPM = LocalTime.of(18, 0);

        // Current time in UTC (find closet time before)
        LocalTime current = LocalTime.now(utcTimezone);

        // Check from latest to earliest time
        if (current.isAfter(sixPM)) {
            // Current time between 6:00PM - 12:00AM
            return sixPM
                    .minusHours(1L)
                    .atDate(LocalDate.now(utcTimezone))
                    // Build into a UTC represented object
                    .atZone(utcTimezone)
                    // Convert into EST
                    .withZoneSameInstant(easternTimezone)
                    .format(dateTimeFormatter);
        } else if (current.isAfter(midday)) {
            // Current time between 12:00PM - 6:00PM
            return midday
                    .minusHours(1L)
                    .atDate(LocalDate.now(utcTimezone))
                    .atZone(utcTimezone)
                    .withZoneSameInstant(easternTimezone)
                    .format(dateTimeFormatter);
        } else if (current.isAfter(sixAM)) {
            // Current time between 6:00AM - 12:00PM
            return sixAM
                    .minusHours(1L)
                    .atDate(LocalDate.now(utcTimezone))
                    .atZone(utcTimezone)
                    .withZoneSameInstant(easternTimezone)
                    .format(dateTimeFormatter);
        } else {
            // Current time between 12:00AM - 6:00AM
            return midnight
                    .minusHours(1L)
                    .atDate(LocalDate.now(utcTimezone))
                    .minusDays(1L)
                    .atZone(utcTimezone)
                    .withZoneSameInstant(easternTimezone)
                    .format(dateTimeFormatter);
        }
    }

    private void executeBackgroundTask(Runnable task) {
        Thread background = new Thread(task);

        background.setDaemon(true);
        background.start();
    }

    public List<CoinEntity> getAllCoins() {
        return allCoins;
    }

    public String getAllCoinsLastUpdated() {
        return allCoinsLastUpdated;
    }

    public GlobalDataEntity getGlobalData() {
        return globalData;
    }

    public String getGlobalDataLastUpdated() {
        return globalDataLastUpdated;
    }

    public List<TrendingEntity> getTrendingCoins() {
        return trendingCoins;
    }

    public String getTrendingCoinsLastUpdated() {
        return trendingCoinsLastUpdated;
    }

    public List<NewsEntity> getNews() {
        return news;
    }

    public String getNewsLastUpdated() {
        return newsLastUpdated;
    }
}
