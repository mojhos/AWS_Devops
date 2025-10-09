package com.webapp.dao;

import com.webapp.config.DatabaseConfig;
import com.webapp.model.Message;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {
    
    /**
     * Insert a new message into the database
     */
    public boolean insertMessage(String messageText) {
        String sql = "INSERT INTO messages (message) VALUES (?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, messageText);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error inserting message: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Retrieve all messages from the database
     */
    public List<Message> getAllMessages() {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT id, message, timestamp FROM messages ORDER BY timestamp DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Message msg = new Message(
                    rs.getInt("id"),
                    rs.getString("message"),
                    rs.getTimestamp("timestamp")
                );
                messages.add(msg);
            }
            
        } catch (SQLException e) {
            System.err.println("Error retrieving messages: " + e.getMessage());
        }
        
        return messages;
    }
    
    /**
     * Get message count
     */
    public int getMessageCount() {
        String sql = "SELECT COUNT(*) as count FROM messages";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt("count");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting message count: " + e.getMessage());
        }
        
        return 0;
    }
    
    /**
     * Delete a message by ID
     */
    public boolean deleteMessage(int id) {
        String sql = "DELETE FROM messages WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting message: " + e.getMessage());
            return false;
        }
    }
}
