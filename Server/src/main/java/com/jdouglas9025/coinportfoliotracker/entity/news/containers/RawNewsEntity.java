package com.jdouglas9025.coinportfoliotracker.entity.news.containers;

import com.google.gson.annotations.SerializedName;

// Represents a news entity returned from python script execution
public class RawNewsEntity {
    public String title;
    // High-level overview
    public String description;
    @SerializedName("published date")
    public String publishedDate;
    public String url;
    public Publisher publisher;
    // Header image
    public String imageUrl;
}
