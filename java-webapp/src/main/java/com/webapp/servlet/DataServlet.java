package com.webapp.servlet;

import com.webapp.dao.MessageDAO;
import com.webapp.model.Message;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/data")
public class DataServlet extends HttpServlet {
    
    private MessageDAO messageDAO;
    
    @Override
    public void init() throws ServletException {
        messageDAO = new MessageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Message> messages = messageDAO.getAllMessages();
        request.setAttribute("messages", messages);
        
        request.getRequestDispatcher("/WEB-INF/views/data.jsp").forward(request, response);
    }
}
