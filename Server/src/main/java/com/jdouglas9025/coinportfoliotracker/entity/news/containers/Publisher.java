package com.jdouglas9025.coinportfoliotracker.entity.news.containers;

import com.google.gson.annotations.SerializedName;

public class Publisher {
    @SerializedName("href")
    public String publisherUrl;

    @SerializedName("title")
    public String publisherName;
}
