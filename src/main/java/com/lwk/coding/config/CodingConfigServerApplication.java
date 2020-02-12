package com.lwk.coding.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@EnableConfigServer
@SpringBootApplication
public class CodingConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(CodingConfigServerApplication.class, args);
    }

}
