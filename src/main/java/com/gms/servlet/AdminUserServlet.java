package com.gms.servlet;

import com.gms.dao.UserDAO;
import com.gms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/AdminUserServlet")
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String userIdParam = request.getParameter("userId");
        String sourceSection = request.getParameter("sourceSection"); // To redirect back to the correct section

        if (userIdParam == null || userIdParam.isEmpty()) {
            request.getSession().setAttribute("formSubmissionMessage", "Error: User ID is missing.");
            response.sendRedirect(request.getContextPath() + "/adminDashboard?section=" + (sourceSection != null ? sourceSection : "users"));
            return;
        }

        String userId;
        try {
            userId = userIdParam;
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("formSubmissionMessage", "Error: Invalid User ID format.");
            response.sendRedirect(request.getContextPath() + "/adminDashboard?section=" + (sourceSection != null ? sourceSection : "users"));
            return;
        }

        boolean success = false;
        String message = "";

        try {

            User user = userDAO.findUserById(userId);
            if (user == null) {
                message = "Error: User not found.";
            } else {
                if ("ACTIVATE_USER".equals(action)) {
                    user.setActive(true);
                    success = userDAO.updateUser(user); // Assuming updateUser handles active status
                    message = success ? "User '" + user.getUserName() + "' activated successfully!" : "Failed to activate user.";
                } else if ("DEACTIVATE_USER".equals(action)) {
                    user.setActive(false);
                    success = userDAO.updateUser(user); // Assuming updateUser handles active status
                    message = success ? "User '" + user.getUserName() + "' deactivated successfully!" : "Failed to deactivate user.";
                } else {
                    message = "Error: Unknown action.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "An unexpected error occurred: " + e.getMessage();
        }

        // Set message and redirect back to the admin dashboard, specifically the users section
        request.getSession().setAttribute("formSubmissionMessage", (success ? "success" : "error") + ": " + message);
        response.sendRedirect(request.getContextPath() + "/adminDashboard?section=" + (sourceSection != null ? sourceSection : "users"));
    }
}