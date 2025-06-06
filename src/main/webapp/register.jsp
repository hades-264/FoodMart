<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.gms.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Register - FoodMart</title>
    <link rel="preconnect" href="[https://fonts.googleapis.com](https://fonts.googleapis.com)">
    <link rel="preconnect" href="[https://fonts.gstatic.com](https://fonts.gstatic.com)" crossorigin>
    <link href="[https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap](https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap)" rel="stylesheet">
    <link rel="stylesheet" href="[https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css](https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css)">
    <%-- Link to your external CSS file --%>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/register.css">
</head>
<body>
    <%
    boolean registrationSuccess = request.getAttribute("registrationSuccess") != null && (Boolean) request.getAttribute("registrationSuccess");
    User registeredUser = null;
    if (registrationSuccess) {
        registeredUser = (User) request.getAttribute("registeredUser");
    }

    String contextPath = request.getContextPath();

    // Retrieve general form error (for DB failure, etc.)
    String formError = (String) request.getAttribute("formError");

    // Retrieve individual field errors
    String nameError = (String) request.getAttribute("nameError");
    String emailError = (String) request.getAttribute("emailError");
    String phoneError = (String) request.getAttribute("phoneError");
    String addressError = (String) request.getAttribute("addressError");
    String passwordError = (String) request.getAttribute("passwordError");
    String confirmPasswordError = (String) request.getAttribute("confirmPasswordError");

    // Retrieve previously submitted values to re-populate the form
    // These are set by the servlet if validation fails or if it's an initial GET request after an error.
    String nameValue = request.getAttribute("nameValue") != null ? (String)request.getAttribute("nameValue") : "";
    String emailValue = request.getAttribute("emailValue") != null ? (String)request.getAttribute("emailValue") : "";
    String phoneValue = request.getAttribute("phoneValue") != null ? (String)request.getAttribute("phoneValue") : "";
    String addressValue = request.getAttribute("addressValue") != null ? (String)request.getAttribute("addressValue") : "";
    // Passwords are not re-populated for security
    %>

    <div class="page-wrapper <%= registrationSuccess ? "blurred" : "" %>">
        <div class="form-container" style="<%= registrationSuccess ? "display:none;" : "" %>">
            <h2>Create Your FoodMart Account</h2>

            <% if (formError != null && !registrationSuccess) { %>
                <div class="message form-error"><%= formError %></div>
            <% } %>

            <form id="registrationForm" action="<%= contextPath %>/register" method="post" novalidate> <%-- Added novalidate to rely on server-side --%>
                <div class="form-columns">
                    <div class="column-left">
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="name">Full Name</label>
                            <input type="text" id="name" name="name" placeholder="Enter your full name" value="<%= nameValue %>" />
                            <% if (nameError != null) { %><span class="error-message"><%= nameError %></span><% } %>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="email">Email Address</label>
                            <input type="text" id="email" name="email" placeholder="e.g., user@example.com" value="<%= emailValue %>" /> <%-- Changed type to text to allow server to validate format --%>
                            <% if (emailError != null) { %><span class="error-message"><%= emailError %></span><% } %>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="phone">Phone Number</label>
                            <input type="tel" id="phone" name="phone" placeholder="e.g., 9876543210" value="<%= phoneValue %>" maxlength="10" />
                            <% if (phoneError != null) { %><span class="error-message"><%= phoneError %></span><% } %>
                        </div>
                    </div>

                    <div class="column-right">
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="address">Address</label>
                            <input type="text" id="address" name="address" placeholder="Enter your full address" value="<%= addressValue %>" />
                            <% if (addressError != null) { %><span class="error-message"><%= addressError %></span><% } %>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="password">Password</label>
                            <div class="password-input-container">
                                <input type="password" id="password" name="password" placeholder="Create a password" title="6-15 chars, 1 upper, 1 lower, 1 digit, 1 special."/>
                                <i class="fas fa-eye toggle-password" id="togglePassword"></i>
                            </div>
                            <% if (passwordError != null) { %><span class="error-message"><%= passwordError %></span><% } %>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label for="confirmPassword">Confirm Password</label>
                            <div class="password-input-container">
                                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" />
                                <i class="fas fa-eye toggle-password" id="toggleConfirmPassword"></i>
                            </div>
                            <% if (confirmPasswordError != null) { %><span class="error-message"><%= confirmPasswordError %></span><% } %>
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn-submit">Register</button>
            </form>
            <div class="login-link">
                <p>Already have an account? <a href="<%= contextPath %>/login.jsp">Login here</a></p>
            </div>
            <div class="copyright">
                &copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> FoodMart. All Rights Reserved.
            </div>
        </div>
    </div>

    <% if (registrationSuccess && registeredUser != null) { %>
        <div class="popup-overlay visible">
            <div class="confirmation-popup">
                <h2>Registration Successful!</h2>
                <p>Thank you for creating your FoodMart account.</p>
                <p>Your User ID is: <span class="user-id-highlight"><%= registeredUser.getUserId() %></span></p>
                <p>You can use this User ID or your email address to log in.</p>

                <div class="user-details">
                    <p><strong>Full Name:</strong> <%= registeredUser.getUserName() %></p>
                    <p><strong>Email:</strong> <%= registeredUser.getEmail() %></p>
                    <p><strong>Contact:</strong> <%= registeredUser.getContactNumber() %></p>
                    <p><strong>Address:</strong> <%= registeredUser.getAddress() %></p>
                </div>
                <form action="<%= contextPath %>/login.jsp" method="get">
                    <button type="submit" class="btn-ok">OK, Proceed to Login</button>
                </form>
            </div>
        </div>
    <% } %>

    <script>
        function setupPasswordToggle(passwordInputId, toggleIconId) {
            const passwordInput = document.getElementById(passwordInputId);
            const toggleIcon = document.getElementById(toggleIconId);
            if (passwordInput && toggleIcon) {
                toggleIcon.addEventListener('click', function () {
                    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                    passwordInput.setAttribute('type', type);
                    this.classList.toggle('fa-eye');
                    this.classList.toggle('fa-eye-slash');
                });
            }
        }
        setupPasswordToggle('password', 'togglePassword');
        setupPasswordToggle('confirmPassword', 'toggleConfirmPassword');
    </script>
</body>
</html>