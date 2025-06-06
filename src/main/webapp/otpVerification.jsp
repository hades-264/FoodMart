<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OTP Verification - FoodMart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #e6f2ff 0%, #d9e2ec 100%); /* Softer gradient */
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }
        .otp-container {
            background: white;
            padding: 35px 30px; /* More padding */
            border-radius: 12px; /* Consistent border radius */
            box-shadow: 0 8px 25px rgba(0,0,0,0.1); /* Consistent shadow */
            width: 100%;
            max-width: 400px;
            text-align: center;
            animation: fadeInOtp 0.5s ease-out;
        }
        @keyframes fadeInOtp {
            from { opacity: 0; transform: scale(0.95) translateY(10px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        .otp-container h2 {
            margin-top: 0;
            margin-bottom: 25px;
            color: #2c3e50; /* Darker heading */
            font-weight: 600;
            font-size: 1.7em;
        }
        .otp-info {
            background-color: #f0f8ff; /* Lighter blue */
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
            border-left: 5px solid #007bff; /* Prominent accent */
            text-align: left; /* Align text to left for readability */
        }
        .otp-info p {
            margin: 8px 0; /* More spacing */
            color: #0056b3; /* Darker blue text */
            font-size: 0.95em;
        }
        .otp-info p strong {
            color: #004085; /* Even darker for emphasis */
        }
        .form-group {
            margin-bottom: 25px;
            text-align: left;
        }
        .form-group label {
            display: block;
            font-weight: 500; /* Medium weight */
            margin-bottom: 10px;
            color: #34495e; /* Consistent label color */
            font-size: 0.95em;
        }
        .form-group input[type="text"] {
            width: 100%;
            padding: 14px 18px; /* Larger padding */
            border-radius: 8px; /* Consistent radius */
            border: 1px solid #cdd4da; /* Consistent border */
            box-sizing: border-box;
            font-size: 1.3em; /* Larger OTP digits */
            text-align: center;
            letter-spacing: 3px; /* More spacing for OTP */
            font-weight: 600; /* Bolder OTP */
            transition: border-color 0.3s, box-shadow 0.3s;
        }
        .form-group input:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.2); /* Consistent focus */
            outline: none;
        }
        .btn-verify {
            font-weight: 600;
            font-size: 1.1em; /* Slightly larger button text */
            border-radius: 8px;
            background-color: #28a745; /* Green for verify */
            color: white;
            padding: 14px 30px; /* More padding */
            border: none;
            width: 100%;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.1s ease;
            box-shadow: 0 6px 15px rgba(40, 167, 69, 0.3);
        }
        .btn-verify:hover {
            background-color: #218838; /* Darker green */
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(40, 167, 69, 0.4);
        }
        .btn-verify:active {
            transform: translateY(0);
        }
        .message {
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 8px;
            text-align: center;
            font-size: 0.95em;
            border: 1px solid transparent;
        }
        .message.error { /* For OTP errors */
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
         .message.success { /* For OTP resend confirmation */
            background-color: #d1e7dd;
            color: #0f5132;
            border-color: #badbcc;
        }
        .resend-otp-section { /* Container for timer and link */
            margin-top: 25px;
            text-align: center;
        }
        .resend-otp-section .timer-message { /* "Didn't receive OTP?" or "Resend OTP in..." */
            color: #555;
            font-size: 0.9em;
            margin-bottom: 8px;
        }
        .resend-otp-section a {
            color: #007bff;
            text-decoration: none;
            font-size: 0.95em;
            font-weight: 500;
        }
        .resend-otp-section a:hover {
            text-decoration: underline;
            color: #0056b3;
        }
    </style>
</head>
<body>
    <%
        String contextPath = request.getContextPath();
        String otpError = (String) request.getAttribute("otpError");
        String otpMessage = (String) request.getAttribute("otpMessage"); // For success messages like "OTP Resent"
        String userEmail = (String) request.getAttribute("userEmail");
        String maskedPhone = (String) request.getAttribute("maskedPhone");
        
        // Provide defaults if attributes are missing, though servlet should always set them
        if (userEmail == null || userEmail.trim().isEmpty()) userEmail = "your registered email";
        if (maskedPhone == null || maskedPhone.trim().isEmpty()) maskedPhone = "your mobile number";
    %>

    <div class="otp-container">
        <h2>Verify Your Identity</h2>
        
        <div class="otp-info">
            <p>An OTP has been sent to:</p>
            <p><strong>Email:</strong> <%= userEmail %></p>
            <p><strong>Mobile:</strong> <%= maskedPhone %></p>
            <p style="font-size:0.85em; color: #007bff;">(The OTP for testing is 123456)</p>
        </div>

        <%-- Display OTP error if any --%>
        <% if (otpError != null && !otpError.isEmpty()) { %>
            <div class="message error">
                <%= otpError %>
            </div>
        <% } %>
        <%-- Display general OTP message (e.g., OTP resent) --%>
        <% if (otpMessage != null && !otpMessage.isEmpty()) { %>
            <div class="message success">
                <%= otpMessage %>
            </div>
        <% } %>

        <form action="<%= contextPath %>/PaymentServlet" method="post">
            <input type="hidden" name="action" value="verifyOTP">
            
            <div class="form-group">
                <label for="otp">Enter 6-digit OTP</label>
                <input type="text" id="otp" name="otp" placeholder="X X X X X X" 
                       maxlength="6" pattern="[0-9]{6}" inputmode="numeric" required
                       autocomplete="one-time-code">
            </div>

            <button type="submit" class="btn-verify">Verify & Complete Payment</button>
        </form>

        <div class="resend-otp-section">
            <p class="timer-message">Didn't receive the OTP or it expired?</p>
            <a href="<%= contextPath %>/PaymentServlet?action=resendOTP">Resend OTP</a>
            <p style="font-size:0.8em; color: #6c757d; margin-top: 10px;">(OTP is valid for 5 minutes)</p>
        </div>
    </div>

</body>
</html>
