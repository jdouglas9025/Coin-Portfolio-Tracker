package com.jdouglas9025.coinportfoliotracker.entity.trending.containers;

// Represents the item object inside trending response from CoinGecko
public class RawItem {
    public String id;
    public String name;
    public String symbol;
    public Integer market_cap_rank;
    // Image in large format
    public String large;
    // Score is popularity rank in trending list
    public Integer score;
    public RawData data;
}
