package com.gms.servlet;

import com.gms.dao.UserDAO;
import com.gms.dao.OrderDAO;
import com.gms.model.User;
import com.gms.model.Order;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private OrderDAO orderDAO;

    public void init() {
        userDAO = new UserDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please log in to view your profile.");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        String userId = loggedInUser.getUserId();

        // Re-fetch user to ensure IS_ACTIVE status is current, especially if another session deactivates them.
        User userProfile = userDAO.findUserById(userId);

        if (userProfile == null || !userProfile.isActive()) {
            // If user is not found or marked inactive in DB, invalidate session and redirect.
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=account_inactive_login_attempt");
            return;
        }
        
        // Update session user if it was different from DB (e.g. isActive status changed)
        session.setAttribute("loggedInUser", userProfile);


        try {
            List<Order> orderList = orderDAO.getOrdersByUserId(userId); // Assuming OrderDAO is correct

            request.setAttribute("userProfile", userProfile);
            request.setAttribute("orderList", orderList);

            String successMsg = (String) session.getAttribute("successMsg");
            if (successMsg != null) {
                request.setAttribute("successMsg", successMsg);
                session.removeAttribute("successMsg");
            }
             String errorMsg = (String) session.getAttribute("errorMsg");
            if (errorMsg != null) {
                request.setAttribute("errorMsg", errorMsg); // For displaying errors on profile page
                session.removeAttribute("errorMsg");
            }


            RequestDispatcher dispatcher = request.getRequestDispatcher("/profile.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            System.err.println("An unexpected error occurred in ProfileServlet (GET): " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred while loading your profile.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session expired. Please log in again.");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");

        if ("deactivateAccount".equals(action)) {
            try {
                boolean success = userDAO.updateUserActiveStatus(loggedInUser.getUserId(), false);
               
                if (success) {
                	 loggedInUser.setActive(false);
                    session.invalidate(); // Log out the user
                    // Redirect to login page with a success message for deactivation
                    response.sendRedirect(request.getContextPath() + "/login.jsp?message=account_deactivated");
                } else {
                    // Failed to update status in DB
                    session.setAttribute("errorMsg", "Could not deactivate account. Please try again or contact support.");
                    response.sendRedirect(request.getContextPath() + "/profile"); // Redirect back to profile
                }
            } catch (Exception e) {
                System.err.println("Error during account deactivation for user: " + loggedInUser.getUserId() + " - " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMsg", "An error occurred while deactivating your account.");
                response.sendRedirect(request.getContextPath() + "/profile");
            }
        } else {
            // Handle other POST actions if any, or redirect to doGet
            doGet(request, response);
        }
    }
}
