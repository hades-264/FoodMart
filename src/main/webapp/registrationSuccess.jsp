<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.gms.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Registration Successful - FoodMart</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: #e6f2ff; /* Light blue background */
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }
        .confirmation-container {
            background: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            width: 100%;
            max-width: 500px;
            text-align: center;
        }
        .confirmation-container h2 {
            color: #28a745; /* Green for success */
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 1.8em;
        }
        .confirmation-container p {
            color: #333;
            font-size: 1.1em;
            line-height: 1.6;
            margin-bottom: 10px;
        }
        .user-details {
            margin-top: 20px;
            margin-bottom: 25px;
            text-align: left;
            padding: 15px;
            background-color: #f9f9f9;
            border: 1px solid #eee;
            border-radius: 8px;
        }
        .user-details p {
            font-size: 1em;
            margin-bottom: 8px;
        }
        .user-details strong {
            color: #0056b3; /* Darker blue for labels */
        }
        .user-id-highlight {
            font-weight: bold;
            color: #dc3545; /* Red to make User ID stand out */
            font-size: 1.2em;
        }
        .btn-ok {
            font-weight: bold;
            font-size: 1.1em;
            border-radius: 8px;
            background-color: #007bff;
            color: white;
            padding: 10px 25px;
            border: none;
            cursor: pointer;
            text-decoration: none; /* If used as a link styled as button */
            display: inline-block;
            transition: background-color 0.2s;
        }
        .btn-ok:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <%
        User registeredUser = (User) request.getAttribute("registeredUser");
        String contextPath = request.getContextPath();

        if (registeredUser == null) {
            // Should not happen if servlet forwards correctly, but handle gracefully
            response.sendRedirect(contextPath + "/register?message=Registration_details_not_found");
            return;
        }
    %>
    <div class="confirmation-container">
        <h2>Registration Successful!</h2>
        <p>Thank you for creating your account on FoodMart.</p>
        <p>Your User ID is: <span class="user-id-highlight"><%= registeredUser.getUserId() %></span></p>
        <p>You can use your User ID or your email address to log in.</p>

        <div class="user-details">
            <p><strong>Full Name:</strong> <%= registeredUser.getUserName() %></p>
            <p><strong>Email:</strong> <%= registeredUser.getEmail() %></p>
            <p><strong>Contact:</strong> <%= registeredUser.getContactNumber() %></p>
            <p><strong>Address:</strong> <%= registeredUser.getAddress() %></p>
        </div>

        <form action="<%= contextPath %>/login" method="get"> <%-- Simple GET redirect to login page --%>
            <button type="submit" class="btn-ok">OK, Proceed to Login</button>
        </form>
    </div>
</body>
</html>