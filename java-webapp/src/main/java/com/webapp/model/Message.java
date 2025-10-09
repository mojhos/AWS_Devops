package com.webapp.model;

import java.sql.Timestamp;

public class Message {
    private int id;
    private String message;
    private Timestamp timestamp;
    
    public Message() {
    }
    
    public Message(String message) {
        this.message = message;
    }
    
    public Message(int id, String message, Timestamp timestamp) {
        this.id = id;
        this.message = message;
        this.timestamp = timestamp;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public Timestamp getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }
    
    @Override
    public String toString() {
        return "Message{" +
                "id=" + id +
                ", message='" + message + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
