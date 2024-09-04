package com.jdouglas9025.coinportfoliotracker.entity.market;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

// Represents a coin object received in CoinGecko market data API response
public class CoinEntity {
    public String id;
    public String symbol;
    public String name;
    public String image;
    @SerializedName("current_price")
    public Double currentPrice;
    @SerializedName("market_cap")
    public Double marketCap;
    @SerializedName("market_cap_rank")
    public Integer marketCapRank;
    @SerializedName("fully_diluted_valuation")
    public Double fullyDilutedValuation;
    @SerializedName("total_volume")
    public Double totalVolume;
    @SerializedName("high_24h")
    public Double high24H;
    @SerializedName("low_24h")
    public Double low24H;
    @SerializedName("price_change_24h")
    public Double priceChange24H;
    @SerializedName("price_change_percentage_24h")
    public Double priceChangePercentage24H;
    @SerializedName("market_cap_change_24h")
    public Double marketCapChange24H;
    @SerializedName("market_cap_change_percentage_24h")
    public Double marketCapChangePercentage24H;
    @SerializedName("circulating_supply")
    public Double circulatingSupply;
    @SerializedName("total_supply")
    public Double totalSupply;
    @SerializedName("max_supply")
    public Double maxSupply;
    @SerializedName("ath")
    public Double ath;
    @SerializedName("ath_change_percentage")
    public Double athChangePercentage;
    @SerializedName("ath_date")
    public String athDate;
    @SerializedName("atl")
    public Double atl;
    @SerializedName("atl_change_percentage")
    public Double atlChangePercentage;
    @SerializedName("atl_date")
    public String atlDate;
    @SerializedName("sparkline_in_7d")
    public SparklineIn7D sparklineIn7D;
    @SerializedName("price_change_percentage_7d_in_currency")
    public Double priceChangePercentage7D;
    @SerializedName("price_change_percentage_14d_in_currency")
    public Double priceChangePercentage14D;
    @SerializedName("price_change_percentage_30d_in_currency")
    public Double priceChangePercentage30D;
    @SerializedName("price_change_percentage_1y_in_currency")
    public Double priceChangePercentage1Y;

    // Estimated last refresh time for sparkline data based on observed CoinGecko refreshes
    @Expose(deserialize = false)
    public String sparklineLastUpdated;

    // Data added to entity from metadata API call
    // Ignore these fields when constructing an entity with GSON
    @Expose(deserialize = false)
    public Long blockTime;
    @Expose(deserialize = false)
    public String hashingAlgorithm;
    @Expose(deserialize = false)
    public String description;
    @Expose(deserialize = false)
    public String homepageUrl;
    @Expose(deserialize = false)
    public String subredditUrl;
    @Expose(deserialize = false)
    public String genesisDate;
    @Expose(deserialize = false)
    public Double positiveSentimentPercentage;

    // Recommended coin ids added from Python script execution
    @Expose(deserialize = false)
    public String[] recommendedCoins;
}
