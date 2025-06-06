package com.gms.servlet;

import com.gms.dao.UserDAO;
import com.gms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    // Password validation regex: At least 6 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char
    private static final String PASSWORD_REGEX = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*]).{6,}$";
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(PASSWORD_REGEX);

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session expired. Please log in again.");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        String userIdFromSession = loggedInUser.getUserId();
        String userIdFromRequest = request.getParameter("userId");

        // Security check: Ensure the user is trying to update their own profile
        if (userIdFromRequest == null || !userIdFromRequest.equals(userIdFromSession)) {
            session.setAttribute("errorMsg", "Unauthorized profile update attempt.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        String formAction = request.getParameter("formAction"); // "updateProfileDetails" or "updatePassword"
        String returnUrl = request.getParameter("returnUrl"); // e.g., "orderReview" or null
        String sectionFocus = request.getParameter("sectionFocus"); // e.g., "address", "password", or null


        boolean detailsUpdated = false;
        boolean passwordChanged = false;
        boolean hasError = false;

        User userToUpdate = userDAO.findUserById(userIdFromRequest); // Get the latest user data from DB

        if (userToUpdate == null) {
            session.setAttribute("errorMsg", "User not found. Cannot update profile.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        // --- Handle Profile Details Update ---
        // This part runs if formAction is 'updateProfileDetails' OR if it's 'updatePassword' but also details fields are present (e.g. user filled both sections)
        // However, if sectionFocus is "password", we might only want to process password.
        // The `setFormAction()` JS function tries to set formAction correctly.

        if ("updateProfileDetails".equals(formAction) || (!"password".equals(sectionFocus) && !"updatePassword".equals(formAction)) ) {
            // Only update details if not specifically a password-only update focus
            String userName = request.getParameter("userName");
            String email = request.getParameter("email");
            String contactNumber = request.getParameter("contactNumber");
            String address = request.getParameter("address");

            // Basic validation (can be more extensive)
            if (userName == null || userName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                request.setAttribute("errorMsg", "Full Name, Email, and Address cannot be empty.");
                hasError = true;
            } else {
                userToUpdate.setUserName(userName.trim());
                userToUpdate.setEmail(email.trim());
                userToUpdate.setContactNumber(contactNumber != null ? contactNumber.trim() : "");
                userToUpdate.setAddress(address.trim());

                if (userDAO.updateUser(userToUpdate)) {
                    detailsUpdated = true;
                } else {
                    request.setAttribute("errorMsg", "Failed to update profile details. Please try again.");
                    hasError = true;
                }
            }
        }


        // --- Handle Password Change ---
        // This part runs if formAction is 'updatePassword' OR if password fields are filled
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        boolean tryingToChangePassword = (currentPassword != null && !currentPassword.isEmpty()) ||
                                         (newPassword != null && !newPassword.isEmpty()) ||
                                         (confirmPassword != null && !confirmPassword.isEmpty());
        
        if ("updatePassword".equals(formAction) || (tryingToChangePassword && !"address".equals(sectionFocus))) {
             // If any password field is filled, proceed with password validation
            if (currentPassword == null || currentPassword.isEmpty()) {
                request.setAttribute("currentPasswordError", "Current password is required to change password.");
                hasError = true;
            } else if (!userToUpdate.getPassword().equals(currentPassword)) { // PLAIN TEXT COMPARISON - NOT SECURE
                request.setAttribute("currentPasswordError", "Incorrect current password.");
                hasError = true;
            }

            if (newPassword == null || newPassword.isEmpty()) {
                request.setAttribute("newPasswordError", "New password cannot be empty if changing password.");
                hasError = true;
            } else if (!isValidPassword(newPassword)) {
                 request.setAttribute("newPasswordError", "Password does not meet complexity requirements.");
                 hasError = true;
            }


            if (confirmPassword == null || confirmPassword.isEmpty()) {
                request.setAttribute("confirmPasswordError", "Please confirm your new password.");
                hasError = true;
            } else if (newPassword != null && !newPassword.equals(confirmPassword)) {
                request.setAttribute("confirmPasswordError", "New passwords do not match.");
                hasError = true;
            }

            if (!hasError && tryingToChangePassword) { // Ensure no prior errors and user actually intended to change
                // IMPORTANT: In a real application, HASH the newPassword before saving
                if (userDAO.updateUserPassword(userIdFromRequest, newPassword)) {
                    passwordChanged = true;
                } else {
                    request.setAttribute("passwordErrorMsg", "Failed to update password. Please try again.");
                    hasError = true;
                }
            }
             // If there was an error in password fields, ensure sectionFocus reflects this for JSP
            if (request.getAttribute("currentPasswordError") != null ||
                request.getAttribute("newPasswordError") != null ||
                request.getAttribute("confirmPasswordError") != null ||
                request.getAttribute("passwordErrorMsg") != null) {
                 sectionFocus = "password"; // Force focus to password section on error
            }
        }


        // --- Post-Update Processing ---
        if (hasError) {
            request.setAttribute("currentUserToEdit", userToUpdate); // Send back the (potentially partially modified) user
            request.setAttribute("returnUrl", returnUrl);
            request.setAttribute("sectionFocus", sectionFocus); // Pass back section focus
            request.getRequestDispatcher("/editProfile.jsp").forward(request, response);
        } else {
            // Update session with the latest user details if anything changed
            User updatedUserFromDB = userDAO.findUserById(userIdFromRequest); // Fetch the fully updated user
            session.setAttribute("loggedInUser", updatedUserFromDB);

            String successMessage = "";
            if (detailsUpdated && passwordChanged) {
                successMessage = "Profile details and password updated successfully!";
            } else if (detailsUpdated) {
                successMessage = "Profile details updated successfully!";
            } else if (passwordChanged) {
                successMessage = "Password changed successfully!";
            } else if (tryingToChangePassword && !passwordChanged && !hasError) {
                 // This case might happen if only password fields were filled but no actual change occurred
                 // (e.g., user cleared fields after typing).
                 // No specific success message needed unless you want to indicate "No changes made".
            }


            if (!successMessage.isEmpty()) {
                 session.setAttribute("successMsg", successMessage);
            }

            // Determine redirect location
            if ("orderReview".equals(returnUrl) && "address".equals(sectionFocus) && detailsUpdated) {
                response.sendRedirect(request.getContextPath() + "/orderReview");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }
        }
    }
    
    private boolean isValidPassword(String password) {
        if (password == null) return false;
        Matcher matcher = PASSWORD_PATTERN.matcher(password);
        return matcher.matches();
    }
}
