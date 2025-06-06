package com.gms.servlet;

import com.gms.dao.OrderDAO; 
import com.gms.model.User;   // For checking admin role

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminOrderUpdateServlet")
public class AdminOrderUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Security Check: Ensure an admin is logged in
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session_expired_please_login_again");
            return;
        }
        User loggedInAdmin = (User) session.getAttribute("loggedInUser");
        if (loggedInAdmin == null || !"ADMIN".equals(loggedInAdmin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Admin_access_required");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");
        String currentSection = request.getParameter("currentSection"); // To redirect back to the correct tab

        // Default redirect path
        String redirectURL = request.getContextPath() + "/adminDashboard";
        if (currentSection != null && !currentSection.trim().isEmpty()) {
            redirectURL += "?section=" + currentSection;
        } else {
            redirectURL += "?section=orders"; // Default to orders section
        }


        if (orderIdStr == null || orderIdStr.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            session.setAttribute("formSubmissionMessage", "Error: Missing order ID or new status for update.");
            response.sendRedirect(redirectURL + "&statusUpdate=error_missing_params");
            return;
        }

        try {
            String orderId = orderIdStr;
            OrderDAO orderDAO = new OrderDAO(); // Instantiate your OrderDAO

            boolean updateSuccess = orderDAO.updateOrderStatus(orderId, newStatus);

            if (updateSuccess) {
                session.setAttribute("formSubmissionMessage", "Success: Order ID " + orderId + " status updated to " + newStatus + ".");
                // Append a success query parameter for potential client-side handling (e.g., toast notification)
                response.sendRedirect(redirectURL + "&statusUpdate=success&orderId=" + orderId);
            } else {
                session.setAttribute("formSubmissionMessage", "Error: Failed to update status for Order ID " + orderId + ".");
                response.sendRedirect(redirectURL + "&statusUpdate=failure&orderId=" + orderId);
            }

        } catch (NumberFormatException e) {
            session.setAttribute("formSubmissionMessage", "Error: Invalid Order ID format.");
            response.sendRedirect(redirectURL + "&statusUpdate=error_invalid_id");
            e.printStackTrace(); // Log the error
        } catch (Exception e) {
            session.setAttribute("formSubmissionMessage", "Error: An unexpected error occurred while updating order status.");
            response.sendRedirect(redirectURL + "&statusUpdate=error_exception");
            e.printStackTrace(); // Log the error
        }
    }

    /**
     * Helper method to validate the order status.
     * @param status The status string to validate.
     * @return true if the status is valid, false otherwise.
     */


    // doGet is not typically used for updates, but you can redirect if accessed directly
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to dashboard or show an error, as updates should be via POST
        response.sendRedirect(request.getContextPath() + "/adminDashboard?section=orders&message=Direct_access_not_allowed_for_update");
    }
}
