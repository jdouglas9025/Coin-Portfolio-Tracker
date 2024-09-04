package com.jdouglas9025.coinportfoliotracker.entity.globaldata;

// Represents the processed global data entity after parsing a CoinGecko response for global data API call
public class GlobalDataEntity {
    public Integer activeCryptocurrencies;
    public Double totalMarketCap;
    public Double totalVolume;
    public Double btcMarketCapPercentage;
    public Double ethMarketCapPercentage;
    public Double marketCapChangePercentage24H;

    public GlobalDataEntity(Integer activeCryptocurrencies, Double totalMarketCap, Double totalVolume, Double btcMarketCapPercentage, Double ethMarketCapPercentage, Double marketCapChangePercentage24H) {
        this.activeCryptocurrencies = activeCryptocurrencies;
        this.totalMarketCap = totalMarketCap;
        this.totalVolume = totalVolume;
        this.btcMarketCapPercentage = btcMarketCapPercentage;
        this.ethMarketCapPercentage = ethMarketCapPercentage;
        this.marketCapChangePercentage24H = marketCapChangePercentage24H;
    }
}
