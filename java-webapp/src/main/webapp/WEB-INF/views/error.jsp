<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
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
            text-align: center;
        }

        h1 {
            font-size: 72px;
            color: #e53e3e;
            margin-bottom: 20px;
        }

        h2 {
            font-size: 28px;
            color: #2d3748;
            margin-bottom: 15px;
        }

        p {
            font-size: 16px;
            color: #718096;
            margin-bottom: 30px;
        }

        .btn {
            display: inline-block;
            padding: 14px 32px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            background: #4299e1;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .btn:hover {
            background: #3182ce;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚠️</h1>
        <h2>Oops! Something went wrong</h2>
        <p>We encountered an error while processing your request.</p>
        <a href="${pageContext.request.contextPath}/" class="btn">Go to Home</a>
    </div>
</body>
</html>
