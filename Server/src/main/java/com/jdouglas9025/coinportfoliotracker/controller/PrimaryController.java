package com.jdouglas9025.coinportfoliotracker.controller;

import com.jdouglas9025.coinportfoliotracker.api.ApiService;
import com.jdouglas9025.coinportfoliotracker.entity.globaldata.GlobalDataEntity;
import com.jdouglas9025.coinportfoliotracker.entity.market.CoinEntity;
import com.jdouglas9025.coinportfoliotracker.entity.news.NewsEntity;
import com.jdouglas9025.coinportfoliotracker.entity.trending.TrendingEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/crypto")
public class PrimaryController {
    private final ApiService apiService;

    @Autowired
    public PrimaryController(ApiService apiService) {
        this.apiService = apiService;
    }

    // Returns market data on all supported coins
    @GetMapping("/marketData")
    public ResponseEntity<Response<List<CoinEntity>>> getMarketData() {
        String lastUpdated = apiService.getAllCoinsLastUpdated();
        List<CoinEntity> data = apiService.getAllCoins();

        Response<List<CoinEntity>> response = new Response<>(lastUpdated, data);

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // Returns global data (e.g., market cap)
    @GetMapping("/globalData")
    public ResponseEntity<Response<GlobalDataEntity>> getGlobalData() {
        String lastUpdated = apiService.getGlobalDataLastUpdated();
        GlobalDataEntity data = apiService.getGlobalData();

        Response<GlobalDataEntity> response = new Response<>(lastUpdated, data);

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // Returns trending coins
    @GetMapping("/trendingData")
    public ResponseEntity<Response<List<TrendingEntity>>> getTrending() {
        String lastUpdated = apiService.getTrendingCoinsLastUpdated();
        List<TrendingEntity> data = apiService.getTrendingCoins();

        Response<List<TrendingEntity>> response = new Response<>(lastUpdated, data);

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // Returns recent news article headlines from Google News
    @GetMapping("/newsData")
    public ResponseEntity<Response<List<NewsEntity>>> getNews() {
        String lastUpdated = apiService.getNewsLastUpdated();
        List<NewsEntity> data = apiService.getNews();

        Response<List<NewsEntity>> response = new Response<>(lastUpdated, data);

        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
