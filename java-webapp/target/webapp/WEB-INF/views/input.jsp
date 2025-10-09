<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Input Form</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            max-width: 600px;
            width: 100%;
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
            line-height: 1.6;
        }

        .form-group {
            margin-bottom: 30px;
        }

        label {
            display: block;
            font-size: 18px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 10px;
        }

        textarea {
            width: 100%;
            padding: 16px;
            font-size: 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-family: inherit;
            resize: vertical;
            min-height: 120px;
            transition: border-color 0.3s ease;
        }

        textarea:focus {
            outline: none;
            border-color: #4299e1;
        }

        textarea::placeholder {
            color: #a0aec0;
        }

        .btn {
            width: 100%;
            padding: 18px;
            font-size: 20px;
            font-weight: 600;
            color: white;
            background: #4299e1;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn:hover {
            background: #3182ce;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(66, 153, 225, 0.3);
        }

        .btn:active {
            transform: translateY(0);
        }

        .message {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }

        .success {
            background: #c6f6d5;
            color: #22543d;
            border: 1px solid #9ae6b4;
        }

        .error {
            background: #fed7d7;
            color: #742a2a;
            border: 1px solid #fc8181;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 25px;
            color: #4299e1;
            text-decoration: none;
            font-size: 16px;
            font-weight: 500;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            .container {
                padding: 30px;
            }

            h1 {
                font-size: 32px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>User Input Form</h1>
        <p class="subtitle">
            Submit a message to the web application.<br>
            Click 'Submit' to store it in the database.
        </p>

        <% if (request.getAttribute("successMessage") != null) { %>
            <div class="message success">
                <%= request.getAttribute("successMessage") %>
            </div>
        <% } %>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="message error">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/input" method="post">
            <div class="form-group">
                <label for="message">Message</label>
                <textarea 
                    id="message" 
                    name="message" 
                    placeholder="Enter your message"
                    required></textarea>
            </div>
            
            <button type="submit" class="btn">Submit</button>
        </form>

        <a href="${pageContext.request.contextPath}/" class="back-link">← Back to Home</a>
    </div>
</body>
</html>
