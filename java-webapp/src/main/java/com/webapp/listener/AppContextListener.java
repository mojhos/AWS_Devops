package com.webapp.listener;

import com.webapp.config.DatabaseConfig;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class AppContextListener implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=== Initializing Web Application ===");
        
        // Initialize database schema
        DatabaseConfig.initializeDatabase();
        
        System.out.println("=== Web Application Started Successfully ===");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("=== Web Application Shutting Down ===");
    }
}
