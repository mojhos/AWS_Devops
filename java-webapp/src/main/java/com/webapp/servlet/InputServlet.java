package com.webapp.servlet;

import com.webapp.dao.MessageDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/input")
public class InputServlet extends HttpServlet {
    
    private MessageDAO messageDAO;
    
    @Override
    public void init() throws ServletException {
        messageDAO = new MessageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/input.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String message = request.getParameter("message");
        
        if (message != null && !message.trim().isEmpty()) {
            boolean success = messageDAO.insertMessage(message);
            
            if (success) {
                request.setAttribute("successMessage", "Message submitted successfully!");
            } else {
                request.setAttribute("errorMessage", "Failed to submit message. Please try again.");
            }
        } else {
            request.setAttribute("errorMessage", "Please enter a message.");
        }
        
        request.getRequestDispatcher("/WEB-INF/views/input.jsp").forward(request, response);
    }
}
