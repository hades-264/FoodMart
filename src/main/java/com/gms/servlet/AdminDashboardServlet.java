package com.gms.servlet; // Or your actual package

import com.gms.dao.OrderDAO;
import com.gms.dao.ProductDAO;
import com.gms.dao.UserDAO;
import com.gms.model.Order;
import com.gms.model.Product;
import com.gms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@WebServlet("/adminDashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private final SimpleDateFormat DATE_FORMAT_PARAM = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    public void init() {
        userDAO = new UserDAO();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Authentication & Authorization Check
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please login as admin.");
            return;
        }
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        if (!"ADMIN".equals(loggedInUser.getRole())) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Access denied. Admin login required.");
            return;
        }
        // This attribute is already set in the JSP from session, but explicit set from servlet is fine.
        request.setAttribute("adminNameForGreeting", loggedInUser.getUserName());

        // --- Fetch data for Dashboard Cards (always all-time totals for cards) ---
        List<User> allUsersForCards = userDAO.getAllUsers(); // Contains isActive status
        List<Order> allOrdersForCards = orderDAO.getAllOrders();
        List<Product> allProductsForCards = productDAO.getAllProducts();

        long dashboardTotalUsers = 0;
        if (allUsersForCards != null) {
            // Counts only CUSTOMER roles for the card.
            // If you want to count ALL users (including admins) for the card, remove/adjust the filter.
            dashboardTotalUsers = allUsersForCards.stream()
                                          .filter(user -> "CUSTOMER".equalsIgnoreCase(user.getRole()))
                                          .count();
        }
        request.setAttribute("dashboardTotalUsers", dashboardTotalUsers);
        request.setAttribute("dashboardTotalOrders", (allOrdersForCards != null) ? allOrdersForCards.size() : 0L);
        request.setAttribute("dashboardTotalProducts", (allProductsForCards != null) ? allProductsForCards.size() : 0L);
        
        BigDecimal dashboardTotalEarnings = BigDecimal.ZERO;
        if (allOrdersForCards != null) {
            for (Order order : allOrdersForCards) {
                if (order.getTotalAmount() != null) {
                    dashboardTotalEarnings = dashboardTotalEarnings.add(order.getTotalAmount());
                }
            }
        }
        request.setAttribute("dashboardTotalEarnings", dashboardTotalEarnings.setScale(2, BigDecimal.ROUND_HALF_UP));

        // --- Date Filter Logic for Orders Table ---
        String dateRangeParam = request.getParameter("dateRange");
        String customStartDateParam = request.getParameter("customStartDate");
        String customEndDateParam = request.getParameter("customEndDate");

        Timestamp filterStartDate = null;
        Timestamp filterEndDate = null;
        String selectedDateRange = (dateRangeParam != null && !dateRangeParam.isEmpty()) ? dateRangeParam : "all_time";

        Calendar cal = Calendar.getInstance();
        Date today = cal.getTime();

        switch (selectedDateRange) {
            case "last_7_days":
                cal.add(Calendar.DAY_OF_MONTH, -6); 
                filterStartDate = new Timestamp(getStartOfDay(cal.getTime()).getTime());
                filterEndDate = new Timestamp(getEndOfDay(today).getTime());
                break;
            case "last_30_days":
                cal.add(Calendar.DAY_OF_MONTH, -29); 
                filterStartDate = new Timestamp(getStartOfDay(cal.getTime()).getTime());
                filterEndDate = new Timestamp(getEndOfDay(today).getTime());
                break;
            case "custom":
                if (customStartDateParam != null && !customStartDateParam.isEmpty()) {
                    try {
                        filterStartDate = new Timestamp(getStartOfDay(DATE_FORMAT_PARAM.parse(customStartDateParam)).getTime());
                    } catch (ParseException e) { /* ignore, use null */ }
                }
                if (customEndDateParam != null && !customEndDateParam.isEmpty()) {
                    try {
                        filterEndDate = new Timestamp(getEndOfDay(DATE_FORMAT_PARAM.parse(customEndDateParam)).getTime());
                    } catch (ParseException e) { /* ignore, use null */ }
                }
                break;
            case "all_time":
            default:
                // filterStartDate and filterEndDate remain null for all time
                break;
        }
        request.setAttribute("selectedDateRange", selectedDateRange);
        request.setAttribute("customStartDateVal", customStartDateParam); 
        request.setAttribute("customEndDateVal", customEndDateParam);   

        // Fetch orders based on the determined date range for the table
        // Assumes OrderDAO has getOrdersByDateRange that handles null start/end dates as "all time"
        List<Order> orderListForTable = orderDAO.getOrdersByDateRange(filterStartDate, filterEndDate);
        request.setAttribute("orderList", orderListForTable != null ? orderListForTable : new ArrayList<>());

        // Set other lists for different sections (these are not date filtered here)
        request.setAttribute("userList", allUsersForCards != null ? allUsersForCards : new ArrayList<>());
        request.setAttribute("productList", allProductsForCards != null ? allProductsForCards : new ArrayList<>());

        // Determine active section
        String activeSection = request.getParameter("section");
        if (activeSection == null || activeSection.isEmpty()) {
            activeSection = "dashboard";
        }
        request.setAttribute("activeSection", activeSection);

        // Handle specific section data loading
        switch (activeSection) {
            case "editItem":
                String productIdToEdit = request.getParameter("productId");
                if (productIdToEdit != null && !productIdToEdit.isEmpty()) {
                    Product productToEdit = productDAO.findProductById(productIdToEdit);
                    request.setAttribute("productToEdit", productToEdit);
                }
                activeSection = "addItem"; // Re-use the addItem form for editing
                request.setAttribute("activeSection", activeSection); // Override for JSP
                break;
            case "orderDetails":
                 String orderIdParam = request.getParameter("orderId");
                 if (orderIdParam != null && !orderIdParam.isEmpty()) {
                     Order detailedOrder = orderDAO.getOrderById(orderIdParam); 
                     // Ensure order items are loaded if getOrderById doesn't do it by default
                     // Example: if (detailedOrder != null && (detailedOrder.getOrderItems() == null || detailedOrder.getOrderItems().isEmpty())) {
                     // detailedOrder.setOrderItems(orderDAO.getOrderItemsByOrderId(detailedOrder.getOrderId()));
                     // }
                     request.setAttribute("detailedOrder", detailedOrder);
                 }
                break;
            // Other cases (dashboard, users, orders, inventory, addItem) are covered by data set above
            default:
                break;
        }

        // Handle messages from other servlets (e.g., AdminProductServlet, AdminOrderUpdateServlet)
        String formSubmissionMsg = (String) session.getAttribute("formSubmissionMessage");
        if (formSubmissionMsg != null) {
            request.setAttribute("formSubmissionMessage", formSubmissionMsg);
            session.removeAttribute("formSubmissionMessage"); 
        }

        request.getRequestDispatcher("/adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle POST the same as GET, primarily for filter submissions that might use POST
        doGet(request, response); 
    }

    private Date getStartOfDay(Date date) {
        if (date == null) return null;
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }

    private Date getEndOfDay(Date date) {
        if (date == null) return null;
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.set(Calendar.HOUR_OF_DAY, 23);
        calendar.set(Calendar.MINUTE, 59);
        calendar.set(Calendar.SECOND, 59);
        calendar.set(Calendar.MILLISECOND, 999);
        return calendar.getTime();
    }
}
