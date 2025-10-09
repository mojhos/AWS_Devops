<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Input Data</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            background: white;
            max-width: 1000px;
            width: 100%;
            margin: 0 auto;
            padding: 50px;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }

        h1 {
            font-size: 40px;
            color: #1a2332;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 700;
        }

        .subtitle {
            font-size: 16px;
            color: #4a5568;
            text-align: center;
            margin-bottom: 40px;
        }

        .table-container {
            overflow-x: auto;
            margin-bottom: 30px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        thead {
            background: #2d3748;
            color: white;
        }

        th {
            padding: 16px;
            text-align: left;
            font-size: 18px;
            font-weight: 600;
        }

        tbody tr {
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s ease;
        }

        tbody tr:hover {
            background-color: #f7fafc;
        }

        td {
            padding: 16px;
            font-size: 16px;
            color: #2d3748;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #718096;
        }

        .empty-state svg {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .btn {
            display: inline-block;
            padding: 14px 32px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            background: #2d3748;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
            text-align: center;
        }

        .btn:hover {
            background: #1a202c;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(45, 55, 72, 0.3);
        }

        .button-container {
            text-align: center;
        }

        @media (max-width: 768px) {
            .container {
                padding: 30px 20px;
            }

            h1 {
                font-size: 32px;
            }

            th, td {
                padding: 12px 8px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>User Input Data</h1>
        <p class="subtitle">
            Here are the messages that have been submitted to the web application.
        </p>

        <div class="table-container">
            <c:choose>
                <c:when test="${not empty messages}">
                    <table>
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Message</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="msg" items="${messages}">
                                <tr>
                                    <td>
                                        <fmt:formatDate value="${msg.timestamp}" 
                                                        pattern="yyyy-MM-dd HH:mm:ss" />
                                    </td>
                                    <td>${msg.message}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <p style="font-size: 18px; margin-bottom: 10px;">No messages yet</p>
                        <p>Be the first to submit a message!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="button-container">
            <a href="${pageContext.request.contextPath}/" class="btn">Back to Home</a>
        </div>
    </div>
</body>
</html>
