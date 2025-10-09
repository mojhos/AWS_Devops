<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scalable Web Application on AWS</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            max-width: 1000px;
            width: 100%;
            padding: 60px;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
        }

        h1 {
            font-size: 48px;
            color: #1a2332;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 700;
        }

        .description {
            font-size: 18px;
            color: #4a5568;
            line-height: 1.8;
            margin-bottom: 50px;
            text-align: center;
        }

        .section {
            margin-bottom: 40px;
        }

        .section h2 {
            font-size: 24px;
            color: #2d3748;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .section p {
            font-size: 16px;
            color: #4a5568;
            line-height: 1.7;
        }

        .button-container {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 50px;
        }

        .btn {
            padding: 16px 48px;
            font-size: 18px;
            font-weight: 600;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
            cursor: pointer;
            border: none;
            display: inline-block;
        }

        .btn-primary {
            background: #4299e1;
            color: white;
        }

        .btn-primary:hover {
            background: #3182ce;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(66, 153, 225, 0.3);
        }

        .btn-secondary {
            background: #48bb78;
            color: white;
        }

        .btn-secondary:hover {
            background: #38a169;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(72, 187, 120, 0.3);
        }

        @media (max-width: 768px) {
            .container {
                padding: 30px;
            }

            h1 {
                font-size: 32px;
            }

            .button-container {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Scalable Web Application Architecture on AWS</h1>
        
        <p class="description">
            This page describes a fully automated, production-grade web application environment 
            deployed on AWS, designed with high availability, scalability, and security in mind.
        </p>

        <div class="section">
            <h2>User Interaction and Entry Point</h2>
            <p>
                End-users access the application through the AWS WAF (Web Application Firewall) 
                and an Application Load Balancer (ALB), which distributes traffic to EC2 instances 
                across multiple Availability Zones.
            </p>
        </div>

        <div class="section">
            <h2>Backend Application Layer</h2>
            <p>
                A monolithic web application runs on EC2 instances. The application allows users 
                to submit a message, and the backend handles logic and integrates with database.
            </p>
        </div>

        <div class="section">
            <h2>Database Layer</h2>
            <p>
                User-submitted data is stored in Amazon RDS (Relational Database Service), with 
                a master node for writes and read replicas for load balancing and performance.
            </p>
        </div>

        <div class="button-container">
            <a href="${pageContext.request.contextPath}/input" class="btn btn-primary">Submit Message</a>
            <a href="${pageContext.request.contextPath}/data" class="btn btn-secondary">View Data</a>
        </div>
    </div>
</body>
</html>
