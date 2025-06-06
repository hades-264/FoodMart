package com.gms.servlet;

// Assuming IdGenerator is in com.gms.util or similar if you created it
// For now, let's use UUID if IdGenerator is not defined yet.
// import com.gms.util.IdGenerator; 

import com.gms.dao.UserDAO;
import com.gms.dbutil.IdGenerator;
import com.gms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID; // Using standard UUID for simplicity

@WebServlet("/register")
public class RegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO(); // Ensure UserDAO is initialized
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Clear any previous submission messages if arriving via GET
        request.removeAttribute("registrationSuccess");
        request.removeAttribute("registeredUser");
        request.removeAttribute("formError");
        // Clear individual field errors as well
        clearErrorAttributes(request);
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Trim all incoming string parameters to handle leading/trailing spaces
        String name = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
        String address = request.getParameter("address") != null ? request.getParameter("address").trim() : "";
        String password = request.getParameter("password"); // Passwords are not usually trimmed for leading/trailing spaces by default
        String confirmPassword = request.getParameter("confirmPassword");

        Map<String, String> errors = new HashMap<>();

        // --- Server-Side Validation (Field by Field with specific messages) ---

        // Name Validation
        if (name.isEmpty()) {
            errors.put("nameError", "Please enter your full name.");
        } else if (!name.matches("^[a-zA-Z\\s'.\\-]+$")) { // Allows alphabets, spaces, apostrophe, dot, hyphen
            errors.put("nameError", "Name can only contain letters, spaces.");
        } else if (name.length() > 100) {
            errors.put("nameError", "Name is too long (max 100 characters).");
        }

        // Email Validation
        if (email.isEmpty()) {
            errors.put("emailError", "Please enter your email address.");
        } else if (!isValidEmail(email)) {
            errors.put("emailError", "Please enter a valid email format (e.g., user@example.com).");
        } else if (userDAO.emailExists(email)) { // Ensure userDAO is initialized
            errors.put("emailError", "This email is already registered. Please try another or login.");
        }

        // Phone Number Validation
        if (phone.isEmpty()) {
            errors.put("phoneError", "Please enter your phone number.");
        } else if (!phone.matches("^[6-9]\\d{9}$")) { // Starts with 6-9, exactly 10 digits
            errors.put("phoneError", "Please enter a valid 10-digit phone number (e.g., starting with 6, 7, 8, or 9).");
        }

        // Address Validation
        if (address.isEmpty()) {
            errors.put("addressError", "Please enter your address.");
        } else if (address.length() > 255) {
            errors.put("addressError", "Address is too long (max 255 characters).");
        }

        // Password Validation
        if (password == null || password.isEmpty()) {
            errors.put("passwordError", "Please create a password.");
        } else if (!isValidPasswordPolicy(password)) {
            errors.put("passwordError", "Password must be 6-15 characters, with 1 uppercase, 1 lowercase, 1 digit, & 1 special char (@#$%^&+=!).");
        }

        // Confirm Password Validation
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPasswordError", "Please confirm your password.");
        } else if (password != null && !password.isEmpty() && !password.equals(confirmPassword)) {
            // Only check for match if password itself is not empty and has passed its own validation (or at least isn't null)
            errors.put("confirmPasswordError", "Passwords do not match.");
        }


        if (!errors.isEmpty()) {
            for (Map.Entry<String, String> entry : errors.entrySet()) {
                request.setAttribute(entry.getKey(), entry.getValue());
            }
            // Set back the originally submitted values (trimmed where appropriate) for repopulation
            request.setAttribute("nameValue", name);
            request.setAttribute("emailValue", email);
            request.setAttribute("phoneValue", phone);
            request.setAttribute("addressValue", address);
            // Do NOT send back password values for security

            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // If validation passes, proceed with registration
        User newUser = new User();
        String userId = IdGenerator.generateUniqueUserId(userDAO);
     
      

        newUser.setUserId(userId);
        newUser.setUserName(name); // Use the trimmed name
        newUser.setEmail(email);   // Use the trimmed email
        newUser.setPassword(password); // Store plain text for now. HASH in a real app!
        newUser.setAddress(address); // Use the trimmed address
        newUser.setContactNumber(phone); // Use the trimmed phone
        newUser.setRole("CUSTOMER");
        newUser.setActive(true); // Set new users as active by default (from your User model)

        boolean success = false;
        try {
             success = userDAO.registerUser(newUser);
        } catch (Exception e) {
            // Catch any unexpected DAO exceptions too
            e.printStackTrace();
            request.setAttribute("formError", "An unexpected database error occurred during registration.");
            setFormValuesOnError(request, name, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }


        if (success) {
            request.setAttribute("registrationSuccess", true);
            request.setAttribute("registeredUser", newUser);
            request.getRequestDispatcher("/register.jsp").forward(request, response); // Forward back to register.jsp to show "pop-up"
        } else {
            // Check if it was an email existence issue that somehow wasn't caught before (race condition, though unlikely)
            if (userDAO.emailExists(email)) {
                 errors.put("emailError", "This email was just registered. Please try logging in or use a different email.");
                 for (Map.Entry<String, String> entry : errors.entrySet()) {
                    request.setAttribute(entry.getKey(), entry.getValue());
                 }
            } else {
                request.setAttribute("formError", "Registration failed due to a server error. Please try again later.");
            }
            setFormValuesOnError(request, name, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    private void setFormValuesOnError(HttpServletRequest request, String name, String email, String phone, String address) {
        request.setAttribute("nameValue", name);
        request.setAttribute("emailValue", email);
        request.setAttribute("phoneValue", phone);
        request.setAttribute("addressValue", address);
    }
    
    private void clearErrorAttributes(HttpServletRequest request) {
        request.removeAttribute("formError");
        request.removeAttribute("nameError");
        request.removeAttribute("emailError");
        request.removeAttribute("phoneError");
        request.removeAttribute("addressError");
        request.removeAttribute("passwordError");
        request.removeAttribute("confirmPasswordError");
        request.removeAttribute("nameValue");
        request.removeAttribute("emailValue");
        request.removeAttribute("phoneValue");
        request.removeAttribute("addressValue");
    }


    // --- Validation Helper Methods ---
    private boolean isValidEmail(String email) {
        if (email == null) return false;
        // Standard RFC 5322 email regex (simplified for common use cases)
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@[a-zA-Z0-9-]+\\.[a-zA-Z]{2,7}$";

        return email.matches(emailRegex);
    }

    private boolean isValidPhoneNumber(String phone) {
        if (phone == null) return false;
        // Validates 10 digits, starting with 6, 7, 8, or 9
        return phone.matches("^[6-9]\\d{9}$");
    }

    private boolean isValidPasswordPolicy(String password) {
        if (password == null) return false;
        // Password policy: 6-15 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special char.
        if (password.length() < 6 || password.length() > 15) return false; // Updated length
        if (!password.matches(".*[A-Z].*")) return false; // At least one uppercase
        if (!password.matches(".*[a-z].*")) return false; // At least one lowercase
        if (!password.matches(".*\\d.*")) return false;   // At least one digit
        if (!password.matches(".*[@#$%^&+=!].*")) return false; // At least one special character from this set
        return true;
    }
}