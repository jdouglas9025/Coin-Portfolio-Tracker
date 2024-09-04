package com.jdouglas9025.coinportfoliotracker.entity.trending;

public class TrendingEntity {
    public String id;
    public String name;
    public String symbol;
    public Integer marketCapRank;
    public String largeImage;
    public Integer trendingScore;
    public Double price;
    public Double priceChangePercentage24H;
    public Double marketCap;
    public Double volume;
    public String description;

    public TrendingEntity(String id, String name, String symbol, Integer marketCapRank, String largeImage, Integer trendingScore, Double price, Double priceChangePercentage24H, Double marketCap, Double volume, String description) {
        this.id = id;
        this.name = name;
        this.symbol = symbol;
        this.marketCapRank = marketCapRank;
        this.largeImage = largeImage;
        this.trendingScore = trendingScore;
        this.price = price;
        this.priceChangePercentage24H = priceChangePercentage24H;
        this.marketCap = marketCap;
        this.volume = volume;
        this.description = description;
    }
}
