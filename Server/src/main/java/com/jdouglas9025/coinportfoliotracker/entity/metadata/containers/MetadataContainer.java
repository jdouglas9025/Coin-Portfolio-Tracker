package com.jdouglas9025.coinportfoliotracker.entity.metadata.containers;

import com.google.gson.annotations.SerializedName;

public class MetadataContainer {
    @SerializedName("block_time_in_minutes")
    public Long blockTime;

    @SerializedName("hashing_algorithm")
    public String hashingAlgorithm;

    @SerializedName("description")
    public DescriptionContainer descriptionContainer;

    @SerializedName("links")
    public LinksContainer linksContainer;

    @SerializedName("genesis_date")
    public String genesisDate;

    @SerializedName("sentiment_votes_up_percentage")
    public Double positiveSentimentPercentage;

    @Override
    public String toString() {
        return "MetadataContainer{" +
                "blockTime=" + blockTime +
                ", hashingAlgorithm='" + hashingAlgorithm + '\'' +
                ", descriptionContainer=" + descriptionContainer +
                ", linksContainer=" + linksContainer +
                ", genesisDate='" + genesisDate + '\'' +
                ", positiveSentimentPercentage=" + positiveSentimentPercentage +
                '}';
    }
}
