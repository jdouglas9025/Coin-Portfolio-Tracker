package com.jdouglas9025.coinportfoliotracker.entity.news;

public class NewsEntity {
    public String title;
    public String publishedDate;
    public String url;
    public String publisherName;
    public String imageUrl;

    public NewsEntity(String title, String publishedDate, String url, String publisherName, String imageUrl) {
        this.title = title;
        this.publishedDate = publishedDate;
        this.url = url;
        this.publisherName = publisherName;
        this.imageUrl = imageUrl;
    }

    @Override
    public String toString() {
        return "NewsEntity{" +
                "title='" + title + '\'' +
                ", publishedDate='" + publishedDate + '\'' +
                ", url='" + url + '\'' +
                ", publisherName='" + publisherName + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                '}';
    }
}
