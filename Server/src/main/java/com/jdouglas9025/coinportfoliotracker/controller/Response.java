package com.jdouglas9025.coinportfoliotracker.controller;

// Response object to return to API requests -- includes time updated and data
public class Response<T> {
    public String lastUpdated;
    public T data;

    public Response(String lastUpdated, T data) {
        this.lastUpdated = lastUpdated;
        this.data = data;
    }

    @Override
    public String toString() {
        return "Response{" +
                "lastUpdated=" + lastUpdated +
                ", data=" + data +
                '}';
    }
}
