package com.jdouglas9025.coinportfoliotracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@EnableCaching
public class Driver {
    public static void main(String[] args) {
        SpringApplication.run(Driver.class, args);
    }
}
