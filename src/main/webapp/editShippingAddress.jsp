<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.gms.model.User"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Edit Profile - FoodMart</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
    rel="stylesheet">
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* --- Root Variables (Same as profile.jsp) --- */
:root {
    --font-family-sans: 'Inter', -apple-system, BlinkMacSystemFont,
        "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    --primary-color: #2563EB; /* Blue-600 */
    --primary-hover: #1D4ED8; /* Blue-700 */
    --primary-light: #EFF6FF; /* Blue-50 */
    --secondary-color: #6B7280; /* Gray-500 */
    --success-color: #059669; /* Green-600 */
    --danger-color: #DC2626; /* Red-600 */
    --warning-color: #D97706; /* Amber-600 */
    --info-color: #3B82F6; /* Blue-500 */
    --light-bg: #F9FAFB; /* Gray-50 */
    --card-bg: #FFFFFF;
    --text-primary: #1F2937; /* Gray-800 */
    --text-secondary: #4B5563; /* Gray-600 */
    --text-muted: #9CA3AF; /* Gray-400 */
    --border-color: #E5E7EB; /* Gray-200 */
    --border-strong: #D1D5DB; /* Gray-300 */
    --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.07), 0 1px 2px 0
        rgba(0, 0, 0, 0.04);
    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -1px
        rgba(0, 0, 0, 0.04);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -2px
        rgba(0, 0, 0, 0.03);
    --radius-md: 0.5rem; /* 8px */
    --radius-lg: 0.75rem; /* 12px */
    --radius-xl: 1rem; /* 16px */
    --spacing-1: 0.25rem; /* 4px */
    --spacing-2: 0.5rem; /* 8px */
    --spacing-3: 0.75rem; /* 12px */
    --spacing-4: 1rem; /* 16px */
    --spacing-5: 1.25rem; /* 20px */
    --spacing-6: 1.5rem; /* 24px */
    --spacing-8: 2rem; /* 32px */
    --spacing-10: 2.5rem; /* 40px */
    --spacing-12: 3rem; /* 48px */
}

/* --- Base Styles --- */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: var(--font-family-sans);
    background-color: var(--light-bg);
    color: var(--text-primary);
    margin: 0;
    padding: 0;
    line-height: 1.6;
}

/* --- Site Header --- */
.site-header {
    background-color: var(--card-bg);
    padding: var(--spacing-4) var(--spacing-6);
    text-align: center;
    border-bottom: 1px solid var(--border-color);
    box-shadow: var(--shadow-sm);
    margin-bottom: var(--spacing-8);
}

.site-header .site-name {
    font-size: 1.75rem;
    font-weight: 700;
    color: var(--primary-color);
    text-decoration: none;
}

.site-header .site-name:hover {
    color: var(--primary-hover);
}

/* --- Main Content Container --- */
.form-container {
    max-width: 700px;
    margin: 0 auto var(--spacing-12) auto;
    background: var(--card-bg);
    padding: var(--spacing-8);
    border-radius: var(--radius-xl);
    box-shadow: var(--shadow-lg);
}

.page-title {
    font-size: 1.875rem;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 var(--spacing-6) 0;
    padding-bottom: var(--spacing-4);
    border-bottom: 1px solid var(--border-color);
    text-align: center;
}

.page-title i {
    margin-right: var(--spacing-2);
    color: var(--primary-color);
}

/* --- Form Styling --- */
.form-section {
    margin-bottom: var(--spacing-8);
    padding-bottom: var(--spacing-6);
    border-bottom: 1px solid var(--border-color);
}
.form-section:last-of-type { /* Remove bottom border for the last section */
    border-bottom: none;
    margin-bottom: 0; /* Adjust margin if needed */
    padding-bottom: 0;
}


.form-section-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--primary-color);
    margin-bottom: var(--spacing-5);
}
.form-section-title i {
    margin-right: var(--spacing-2);
}


.edit-profile-form .form-group {
    margin-bottom: var(--spacing-5);
}

.edit-profile-form label {
    display: block;
    font-weight: 600;
    color: var(--text-secondary);
    margin-bottom: var(--spacing-2);
    font-size: 0.9rem;
}

.edit-profile-form .form-control,
.edit-profile-form .read-only-field {
    display: block;
    width: 100%;
    padding: var(--spacing-3) var(--spacing-4);
    font-size: 1rem;
    font-family: var(--font-family-sans);
    color: var(--text-primary);
    background-color: var(--card-bg);
    background-clip: padding-box;
    border: 1px solid var(--border-strong);
    appearance: none;
    border-radius: var(--radius-md);
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.edit-profile-form .form-control:focus {
    border-color: var(--primary-color);
    outline: 0;
    box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.25);
}

.edit-profile-form textarea.form-control {
    min-height: 100px;
    resize: vertical;
}

.edit-profile-form .read-only-field {
    background-color: var(--light-bg);
    color: var(--text-secondary);
    border: 1px solid var(--border-color);
    line-height: 1.5;
}

.password-input-container {
    position: relative;
    display: flex;
    align-items: center;
}
.password-input-container .form-control {
    flex-grow: 1;
    /* If there's a right padding on form-control, adjust it or the icon position */
    padding-right: 40px; /* Make space for the icon */
}
.toggle-password {
    cursor: pointer;
    position: absolute;
    right: 12px; /* Adjust as needed */
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-muted);
    font-size: 1.1rem;
}


.form-text {
    font-size: 0.8rem;
    color: var(--text-muted);
    margin-top: var(--spacing-1);
}

.message-area {
    margin-bottom: var(--spacing-6);
    text-align: center;
}
.success-message {
    background-color: #D1FAE5;
    color: #047857;
    padding: var(--spacing-3) var(--spacing-4);
    border: 1px solid #6EE7B7;
    border-radius: var(--radius-md);
}
.error-message, .validation-error { /* Combined for general errors and field validation */
    background-color: #FEE2E2;
    color: #991B1B;
    padding: var(--spacing-3) var(--spacing-4);
    border: 1px solid #FCA5A5;
    border-radius: var(--radius-md);
    margin-bottom: var(--spacing-4); /* Add margin for individual field errors */
}
.error-message-field { /* Specific for field-level errors, smaller text */
    color: #D8000C;
    font-size: 0.85em;
    display: block;
    margin-top: var(--spacing-1);
}

.message-area i, .error-message i, .success-message i {
    margin-right: var(--spacing-2);
}


/* --- Form Actions (Buttons) --- */
.form-actions {
    margin-top: var(--spacing-8);
    display: flex;
    justify-content: flex-end;
    gap: var(--spacing-3);
    border-top: 1px solid var(--border-color);
    padding-top: var(--spacing-6);
}

.btn {
    display: inline-block;
    padding: var(--spacing-3) var(--spacing-6);
    font-size: 1rem;
    font-weight: 600;
    text-align: center;
    text-decoration: none;
    border-radius: var(--radius-md);
    transition: all 0.2s ease;
    cursor: pointer;
    border: 1px solid transparent;
}

.btn i { margin-right: var(--spacing-2); }

.btn-primary {
    background-color: var(--primary-color);
    color: var(--card-bg);
    border-color: var(--primary-color);
}
.btn-primary:hover {
    background-color: var(--primary-hover);
    border-color: var(--primary-hover);
    box-shadow: var(--shadow-md);
}

.btn-outline-secondary {
    color: var(--text-secondary);
    border-color: var(--border-strong);
}
.btn-outline-secondary:hover {
    background-color: var(--light-bg);
    color: var(--text-primary);
}
</style>
</head>
<body>
    <%
        String contextPath = request.getContextPath();
        User currentUser = (User) request.getAttribute("currentUserToEdit");

        // Parameters from EditProfileServlet or UpdateProfileServlet (on error)
        String sectionFocus = (String) request.getAttribute("sectionFocus");
        String returnUrl = (String) request.getAttribute("returnUrl");

        // Messages from UpdateProfileServlet
        String errorMsg = (String) request.getAttribute("errorMsg");
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) {
            session.removeAttribute("successMsg");
        }
        String passwordErrorMsg = (String) request.getAttribute("passwordErrorMsg");
        String currentPasswordError = (String) request.getAttribute("currentPasswordError");
        String newPasswordError = (String) request.getAttribute("newPasswordError");
        String confirmPasswordError = (String) request.getAttribute("confirmPasswordError");


        // Initialize with empty strings if currentUser is null
        String currentUserId = (currentUser != null && currentUser.getUserId() != null) ? currentUser.getUserId() : "";
        String currentUserName = (currentUser != null && currentUser.getUserName() != null) ? currentUser.getUserName() : "";
        String currentEmail = (currentUser != null && currentUser.getEmail() != null) ? currentUser.getEmail() : "";
        String currentContactNumber = (currentUser != null && currentUser.getContactNumber() != null)
                ? currentUser.getContactNumber()
                : "";
        String currentAddress = (currentUser != null && currentUser.getAddress() != null) ? currentUser.getAddress() : "";

        boolean focusAddressOnly = "address".equals(sectionFocus);
        String pageTitleText = focusAddressOnly ? "Edit Your Delivery Address" : "Edit Your Profile";
        String submitButtonText = focusAddressOnly ? "Update Address" : "Save All Changes";
        if ("password".equals(sectionFocus)) {
             pageTitleText = "Change Your Password"; // If focusing on password section
             submitButtonText = "Update Password";
        }
    %>

    <header class="site-header">
        <a href="<%=contextPath%>/welcome" class="site-name">FoodMart</a>
    </header>

    <div class="form-container">
        <h1 class="page-title">
            <i class="fas fa-user-cog"></i> <%= pageTitleText %>
        </h1>

        <div class="message-area">
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-triangle"></i> <%=errorMsg%>
                </div>
            <% } %>
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                 <div class="success-message">
                    <i class="fas fa-check-circle"></i> <%=successMsg%>
                </div>
            <% } %>
            <% if (passwordErrorMsg != null && !passwordErrorMsg.isEmpty()) { %>
                <div class="error-message">
                    <i class="fas fa-key"></i> <%=passwordErrorMsg%>
                </div>
            <% } %>
        </div>

        <% if (currentUser != null) { %>
            <form action="<%=contextPath%>/updateProfile" method="POST" class="edit-profile-form">
                <input type="hidden" name="userId" value="<%=currentUserId%>">
                <input type="hidden" name="formAction" value="updateProfileDetails"> <%-- Default action --%>


                <% if (returnUrl != null && !returnUrl.isEmpty()) { %>
                    <input type="hidden" name="returnUrl" value="<%= returnUrl %>">
                <% } %>
                <% if (sectionFocus != null && !sectionFocus.isEmpty()) { %>
                    <input type="hidden" name="sectionFocus" value="<%= sectionFocus %>">
                <% } %>

                <%-- PROFILE DETAILS SECTION --%>
                <% if (!"password".equals(sectionFocus)) { %>
                <div class="form-section">
                    <h2 class="form-section-title"><i class="fas fa-id-card"></i> Personal Information</h2>
                    <div class="form-group">
                        <label for="userName"><i class="fas fa-user"></i> Full Name</label>
                        <% if (!focusAddressOnly) { %>
                            <input type="text" class="form-control" id="userName" name="userName" value="<%=currentUserName%>" required>
                        <% } else { %>
                            <div class="read-only-field"><%=currentUserName%></div>
                            <input type="hidden" name="userName" value="<%=currentUserName%>">
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label for="email"><i class="fas fa-envelope"></i> Email Address</label>
                        <% if (!focusAddressOnly) { %>
                            <input type="email" class="form-control" id="email" name="email" value="<%=currentEmail%>" required>
                        <% } else { %>
                            <div class="read-only-field"><%=currentEmail%></div>
                            <input type="hidden" name="email" value="<%=currentEmail%>">
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label for="contactNumber"><i class="fas fa-phone"></i> Phone Number</label>
                        <% if (focusAddressOnly) { %>
                            <input type="tel" class="form-control" id="contactNumber" name="contactNumber" value="<%=currentContactNumber%>" pattern="[+]?[0-9\\s\\-()]{10,15}" title="Enter a valid phone number (e.g., +91 9876543210 or 9876543210)">
                        <% } else { %>
                            <div class="read-only-field"><%=currentContactNumber%></div>
                            <input type="hidden" name="contactNumber" value="<%=currentContactNumber%>">
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label for="address"><i class="fas fa-map-marker-alt"></i> Delivery Address</label>
                        <textarea class="form-control" id="address" name="address" rows="4" required><%=currentAddress%></textarea>
                        <% if (focusAddressOnly) { %>
                            <p class="form-text">You are currently editing only your delivery address.</p>
                        <% } %>
                    </div>
                </div>
                <% } %>


                <%-- CHANGE PASSWORD SECTION --%>
                <% if (!focusAddressOnly) { %>
                <div class="form-section">
                    <h2 class="form-section-title"><i class="fas fa-key"></i> Change Password</h2>
                     <p class="form-text" style="margin-bottom: var(--spacing-4);">Leave these fields blank if you do not want to change your password.</p>

                    <div class="form-group">
                        <label for="currentPassword"><i class="fas fa-lock"></i> Current Password</label>
                        <div class="password-input-container">
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword">
                            <i class="fas fa-eye toggle-password" data-target="currentPassword"></i>
                        </div>
                        <% if (currentPasswordError != null) { %><span class="error-message-field"><%= currentPasswordError %></span><% } %>
                    </div>

                    <div class="form-group">
                        <label for="newPassword"><i class="fas fa-lock-open"></i> New Password</label>
                         <div class="password-input-container">
                            <input type="password" class="form-control" id="newPassword" name="newPassword" pattern="^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*]).{6,}$" title="Password must be at least 6 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.">
                            <i class="fas fa-eye toggle-password" data-target="newPassword"></i>
                        </div>
                        <p class="form-text">Min. 6 characters, with uppercase, lowercase, number, and special character.</p>
                        <% if (newPasswordError != null) { %><span class="error-message-field"><%= newPasswordError %></span><% } %>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword"><i class="fas fa-check-circle"></i> Confirm New Password</label>
                        <div class="password-input-container">
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword">
                             <i class="fas fa-eye toggle-password" data-target="confirmPassword"></i>
                        </div>
                        <% if (confirmPasswordError != null) { %><span class="error-message-field"><%= confirmPasswordError %></span><% } %>
                    </div>
                </div>
                <% } %>


                <div class="form-actions">
                    <%
                        String cancelUrl = contextPath + "/profile";
                        if ("orderReview".equals(returnUrl) && focusAddressOnly) { // Only redirect to orderReview if only address was focused
                            cancelUrl = contextPath + "/orderReview";
                        }
                    %>
                    <a href="<%=cancelUrl%>" class="btn btn-outline-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <button type="submit" class="btn btn-primary" onclick="setFormAction()">
                        <i class="fas fa-save"></i> <%= submitButtonText %>
                    </button>
                </div>
            </form>
        <% } else { %>
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i> Could not load user details for editing. Please try again or contact support.
            </div>
        <% } %>
    </div>
<script>
    // Script for toggling password visibility
    document.querySelectorAll('.toggle-password').forEach(item => {
        item.addEventListener('click', function (e) {
            const targetInputId = e.target.getAttribute('data-target');
            const passwordInput = document.getElementById(targetInputId);
            if (passwordInput) {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                // Toggle eye icon
                e.target.classList.toggle('fa-eye');
                e.target.classList.toggle('fa-eye-slash');
            }
        });
    });

    // Function to set the correct formAction before submitting
    // This helps the servlet distinguish if it's a full profile update or just password
    function setFormAction() {
        const currentPassword = document.getElementById('currentPassword');
        const newPassword = document.getElementById('newPassword');
        const confirmPassword = document.getElementById('confirmPassword');
        const form = document.querySelector('.edit-profile-form');
        const formActionInput = form.querySelector('input[name="formAction"]');

        // If password fields are being used, set action to updatePassword
        // Otherwise, it's an updateProfileDetails action
        if (currentPassword && newPassword && confirmPassword &&
            (currentPassword.value.trim() !== '' || newPassword.value.trim() !== '' || confirmPassword.value.trim() !== '')) {
            if (formActionInput) formActionInput.value = 'updatePassword';
        } else {
             if (formActionInput) formActionInput.value = 'updateProfileDetails';
        }
         // If sectionFocus is 'password', always treat as password update attempt
        <% if ("password".equals(sectionFocus)) { %>
            if (formActionInput) formActionInput.value = 'updatePassword';
        <% } %>
    }

    // If the page loaded with a password focus, ensure the submit button reflects that
    <% if ("password".equals(sectionFocus)) { %>
        const submitButton = document.querySelector('.form-actions .btn-primary');
        if (submitButton) {
            // The button text is already set by JSP, this is more for the hidden input
            const form = document.querySelector('.edit-profile-form');
            const formActionInput = form.querySelector('input[name="formAction"]');
            if (formActionInput) formActionInput.value = 'updatePassword';
        }
    <% } %>
</script>
</body>
</html>
