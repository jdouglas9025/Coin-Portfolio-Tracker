package com.jdouglas9025.coinportfoliotracker.entity.trending.containers;

// Represents the data object inside trending response from CoinGecko
public class RawData {
    public String price;
    public RawPriceChangePercentage24H price_change_percentage_24h;
    public String market_cap;
    public String total_volume;
    // Content may be null
    public RawContent content;
}
