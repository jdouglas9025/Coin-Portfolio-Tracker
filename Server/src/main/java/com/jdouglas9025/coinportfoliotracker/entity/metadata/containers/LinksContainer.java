package com.jdouglas9025.coinportfoliotracker.entity.metadata.containers;

import com.google.gson.annotations.SerializedName;

public class LinksContainer {
    @SerializedName("homepage")
    public String[] homepageUrlContainer;

    @SerializedName("subreddit_url")
    public String subredditUrl;
}
