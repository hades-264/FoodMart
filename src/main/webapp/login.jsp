<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - FoodMart</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style>
        :root {
            --primary-green: #4CAF50; /* A vibrant food-mart green */
            --dark-green: #388E3C;
            --primary-blue: #2196F3; /* For links/accents if needed */
            --text-dark: #333;
            --text-light: #f8f8f8;
            --bg-light-blue: #e0f7fa; /* Lighter background accent */
            --shadow-color: rgba(0,0,0,0.2);
            --form-bg: #ffffff;
            --error-red: #e74c3c;
            --success-green-light: #d4edda;
            --success-green-dark: #155724;
        }

        body {
            font-family: 'Poppins', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
            color: var(--text-dark);
            /* Corrected background path assuming 'img/bg.jpeg' based on previous successful implementation */
            background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
                        url('img/bg.jpeg') center center / cover no-repeat fixed;
        }

        .form-container {
            background: var(--form-bg);
            padding: 40px 35px; /* Increased padding */
            border-radius: 15px; /* More rounded corners */
            box-shadow: 0 15px 30px var(--shadow-color), 0 5px 10px rgba(0,0,0,0.1); /* Deeper, softer shadow */
            width: 100%;
            max-width: 400px; /* Slightly wider than original */
            border: 1px solid rgba(255,255,255,0.7); /* Subtle white border */
            backdrop-filter: blur(8px); /* Frosted glass effect */
            animation: fadeInScale 0.6s ease-out; /* Smooth animation on load */
        }
        
        @keyframes fadeInScale {
            from { opacity: 0; transform: scale(0.95) translateY(20px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }

        .form-container h2 {
            font-family: 'Playfair Display', serif; /* Elegant font for title */
            text-align: center;
            margin-top: 0;
            margin-bottom: 30px; /* More space */
            color: var(--primary-green); /* FoodMart brand color */
            font-size: 2.2em; /* Larger title */
            font-weight: 700;
            position: relative;
            padding-bottom: 10px;
        }
        .form-container h2::after {
            content: '';
            position: absolute;
            left: 50%;
            bottom: 0;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background-color: var(--primary-green);
            border-radius: 2px;
        }

        .form-group {
            margin-bottom: 20px; /* More spacing between groups */
        }
        .form-group label {
            display: block;
            font-weight: 500; /* Softer bold */
            margin-bottom: 8px; /* More space below label */
            color: var(--text-dark);
            font-size: 0.95em;
        }
        /* Style for the container wrapping input and eye icon */
        .password-input-container {
            position: relative;
            width: 100%;
        }

        .form-group input[type="email"],
        .form-group input[type="password"],
        .form-group input[type="text"] {
            width: 100%;
            padding: 12px 15px; /* More padding */
            border-radius: 8px; /* More rounded */
            border: 1px solid #dcdcdc; /* Softer border */
            box-sizing: border-box;
            font-size: 1em;
            color: var(--text-dark);
            transition: all 0.3s ease; /* Smooth transitions */
            background-color: #fcfcfc; /* Slightly off-white background */
        }
        .form-group input:focus {
            border-color: var(--primary-blue);
            outline: none;
            box-shadow: 0 0 0 4px rgba(33, 150, 243, 0.2); /* Soft blue glow on focus */
        }

        /* Style for the eye icon */
        .toggle-password {
            position: absolute;
            right: 15px; /* Position from the right */
            top: 50%; /* Center vertically */
            transform: translateY(-50%); /* Adjust for vertical centering */
            cursor: pointer;
            color: #999; /* Grey color for the icon */
            font-size: 1.1em; /* Slightly larger icon */
            transition: color 0.2s ease;
        }
        .toggle-password:hover {
            color: #555;
        }

        /* --- CSS TO HIDE BROWSER'S DEFAULT EYE ICON --- */
        /* For Webkit browsers (Chrome, Safari, etc.) */
        input::-ms-reveal,
        input::-webkit-reveal {
            display: none !important;
        }

        /* Optional: Also hide the clear button often seen in Edge/IE */
        input::-ms-clear {
            display: none;
        }
        /* --- END CSS TO HIDE BROWSER'S DEFAULT EYE ICON --- */

        .btn-submit {
            font-weight: 600; /* More prominent */
            font-size: 1.1em; /* Larger text */
            border-radius: 10px; /* More rounded */
            background-color: var(--primary-green); /* FoodMart green */
            color: white;
            padding: 12px 20px; /* More padding */
            border: none;
            width: 100%;
            cursor: pointer;
            transition: all 0.3s ease; /* Smooth transition */
            box-shadow: 0 5px 15px rgba(76, 175, 80, 0.3); /* Green shadow */
        }
        .btn-submit:hover {
            background-color: var(--dark-green); /* Darker green on hover */
            transform: translateY(-3px); /* Subtle lift effect */
            box-shadow: 0 8px 20px rgba(76, 175, 80, 0.4);
        }
        .btn-submit:active {
            transform: translateY(0); /* Press effect */
            box-shadow: 0 3px 8px rgba(76, 175, 80, 0.2);
        }

        .register-link, .message-area {
            text-align: center;
            margin-top: 25px; /* Increased margin */
        }
        .register-link p {
            color: #666;
            font-size: 0.95em;
        }
        .register-link a {
            color: var(--primary-blue); /* Consistent blue link */
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s ease;
        }
        .register-link a:hover {
            text-decoration: underline;
            color: #0056b3;
        }
        
        /* Message styles */
        .message {
            padding: 12px 15px;
            margin-bottom: 20px; /* More space below message */
            border-radius: 8px;
            text-align: center;
            font-weight: 500;
            line-height: 1.4;
            animation: fadeIn 0.5s ease-out; /* Smooth fade-in for messages */
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #a8e6b1;
        }
        .message.error {
            background-color: #ffe6e6; /* Lighter red background */
            color: var(--error-red);
            border: 1px solid #ffb3b3;
        }
        .user-id-info { 
            font-weight: 600; /* More prominent */
            color: var(--success-green-dark); 
        }
        
        /* Field-specific errors (red text below input) */
        .form-group .error-message { 
            color: var(--error-red); 
            font-size: 0.88em;
            margin-top: 8px; /* More space */
            display: block; 
            font-weight: 400;
        }

        /* Copyright Notice */
        .copyright {
            text-align: center; 
            margin-top: 40px; /* More separation */
            font-size: 0.85em; 
            color: #999; /* Softer color */
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    </style>
</head>
<body>
    <%
        String regSuccessMsg = null;
        String registeredUserId = null;
        if ("success".equals(request.getParameter("registration"))) {
            registeredUserId = request.getParameter("userId");
            if (registeredUserId != null && !registeredUserId.isEmpty()) {
                regSuccessMsg = "Registration successful! Your User ID is: ";
                regSuccessMsg += "<span class='user-id-info'>" + registeredUserId + "</span>. ";
                regSuccessMsg += "Please login with your User ID or Email.";
            } else {
                regSuccessMsg = "Registration successful! Please login.";
            }
        }

        String logoutMsg = null;
        if ("true".equals(request.getParameter("logout"))) {
            logoutMsg = "You have been logged out successfully.";
        }

        String loginError = (String) request.getAttribute("loginError");
        String identifierError = (String) request.getAttribute("identifierError"); // For specific error on identifier field
        String passwordError = (String) request.getAttribute("passwordError");

        // Re-populate identifier field if there was an error
        String identifierValue = request.getParameter("identifier") != null && loginError != null ? request.getParameter("identifier") : "";
    %>

    <div class="form-container">
        <h2>Welcome Back to FoodMart!</h2>

        <div class="message-area">
            <% if (regSuccessMsg != null) { %>
                <div class="message success"><%= regSuccessMsg %></div>
            <% } %>
            <% if (logoutMsg != null) { %>
                <div class="message success"><%= logoutMsg %></div>
            <% } %>
            <% if (loginError != null) { %>
                <div class="message error"><%= loginError %></div>
            <% } %>
        </div>

        <form id="loginForm" action="login" method="post">
            <div class="form-group">
                <label for="identifier">User ID or Email</label>
                <input type="text" id="identifier" name="identifier" placeholder="Enter your User ID or Email" value="<%= identifierValue %>" required />
                 <% if (identifierError != null) { %><span class="error-message"><%= identifierError %></span><% } %>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-input-container"> <%-- New container for input and icon --%>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required />
                    <i class="fas fa-eye toggle-password" id="togglePassword"></i> <%-- Eye Icon --%>
                </div>
                 <% if (passwordError != null) { %><span class="error-message"><%= passwordError %></span><% } %>
            </div>
            <button type="submit" class="btn-submit">Login</button>
        </form>
        <div class="register-link">
            <p>Don't have an account? <a href="register.jsp">Register here</a></p>
        </div>
        
        <div class="copyright">
	    	&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> 
	    	FoodMart. All Rights Reserved.
		</div>
    </div>

    <script>
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');

        togglePassword.addEventListener('click', function (e) {
            // toggle the type attribute
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            // toggle the eye icon
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });
    </script>
</body>
</html>
