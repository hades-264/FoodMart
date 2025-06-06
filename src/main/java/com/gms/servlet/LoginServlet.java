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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = request.getParameter("identifier"); // This can be email or userId
        String password = request.getParameter("password");

        if (identifier == null || identifier.trim().isEmpty()) {
            request.setAttribute("identifierError", "User ID or Email cannot be empty.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        if (password == null || password.isEmpty()) {
            request.setAttribute("passwordError", "Password cannot be empty.");
            request.setAttribute("identifier", identifier); // Keep identifier in form
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = null;
        // Try to find user by email first (common case)
        if (identifier.contains("@")) { // Simple check if it looks like an email
            user = userDAO.findUserByEmail(identifier.trim());
        }

        // If not found by email (or if it didn't look like an email), try finding by User ID
        if (user == null) {
            user = userDAO.findUserById(identifier.trim());
        }

        if (user != null) {
            // Plain text password comparison (NOT FOR PRODUCTION)
            if (user.getPassword().equals(password)) {
                HttpSession session = request.getSession();
                session.setAttribute("loggedInUser", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userName", user.getUserName());
                session.setAttribute("userRole", user.getRole());

                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                } else {
                	// Check if there was a redirect URL passed (e.g., from trying to access a protected page or clicking a product as guest)
                    String redirectUrl = request.getParameter("redirect");
                    if (redirectUrl != null && !redirectUrl.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/" + redirectUrl);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home"); // Default redirect for customers
                    }                }
            } else {
                request.setAttribute("loginError", "Invalid credentials. Please try again.");
                request.setAttribute("identifier", identifier);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("loginError", "Invalid credentials. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}