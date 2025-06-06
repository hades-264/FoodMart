package com.gms.servlet;

import com.gms.model.CartItem; // Changed from OrderItem to CartItem
import com.gms.model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/orderReview")
public class OrderReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Helper class for displaying cart items in order review
    public static class OrderReviewItemDisplay {
        private CartItem cartItem; // Changed from OrderItem to CartItem
        private BigDecimal calculatedItemTotal;
        private String imageFileName;

        public OrderReviewItemDisplay(CartItem cartItem, BigDecimal calculatedItemTotal, String imageFileName) {
            this.cartItem = cartItem;
            this.calculatedItemTotal = calculatedItemTotal;
            this.imageFileName = imageFileName;
        }

        public CartItem getCartItem() { // Changed getter name
            return cartItem;
        }

        public BigDecimal getCalculatedItemTotal() {
            return calculatedItemTotal;
        }

        public String getImageFileName() {
            return imageFileName;
        }
    }

    private String formatCurrency(BigDecimal amount) {
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        currencyFormat.setCurrency(java.util.Currency.getInstance("INR"));
        return currencyFormat.format(amount);
    }

    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Your+session+has+expired.+Please+login+again.");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        // FIXED: Use correct session attribute name and type
        List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cart");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please+login+to+review+your+order.");
            return;
        }

        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp?message=Your+cart+is+empty.+Please+add+items+to+review.");
            return;
        }

        // Prepare items for display
        List<OrderReviewItemDisplay> displayOrderItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : cartItems) {
            // FIXED: Use CartItem methods instead of OrderItem methods
            BigDecimal itemTotal = item.getUnitPrice().multiply(new BigDecimal(item.getQuantity()));
            subtotal = subtotal.add(itemTotal);

            String imageFileName = "placeholder.jpg"; // Default placeholder
            String productId = item.getProductId();


            displayOrderItems.add(new OrderReviewItemDisplay(item, itemTotal, imageFileName));
        }

        // Calculate totals
        BigDecimal packagingFee = new BigDecimal("10.00");
        BigDecimal deliveryCharges = new BigDecimal("40.00");
        String freeShippingInfo = null;
        BigDecimal freeShippingThreshold = new BigDecimal("2000.00");

        if (subtotal.compareTo(freeShippingThreshold) >= 0) {
            deliveryCharges = BigDecimal.ZERO;
            freeShippingInfo = "Free Shipping Applied (Order over " + formatCurrency(freeShippingThreshold) + ")";
        }

        BigDecimal totalAmount = subtotal.add(packagingFee).add(deliveryCharges);

        // Set attributes for JSP
        request.setAttribute("shippingUser", loggedInUser);
        request.setAttribute("displayOrderItems", displayOrderItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("packagingFee", packagingFee);
        request.setAttribute("deliveryCharges", deliveryCharges);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("totalItemCount", cartItems.size());
        if (freeShippingInfo != null) {
            request.setAttribute("freeShippingMessage", freeShippingInfo);
        }

        // FIXED: Store correct session attributes for PaymentServlet
        session.setAttribute("finalOrderSubtotal", subtotal);
        session.setAttribute("finalOrderPackagingFee", packagingFee);
        session.setAttribute("finalOrderShipping", deliveryCharges);
        session.setAttribute("finalOrderTotalAmount", totalAmount);
        
        // CRITICAL FIX: Set the attribute name that PaymentServlet expects
        session.setAttribute("finalOrderTotalForPayment", totalAmount);
        session.setAttribute("cartTotal", totalAmount); // Keep for backward compatibility

        request.getRequestDispatcher("orderReview.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("loggedInUser") == null ||
            session.getAttribute("cart") == null || // FIXED: Check correct session attribute
            session.getAttribute("finalOrderTotalForPayment") == null) { // FIXED: Check correct attribute
            
            String redirectUrl = request.getContextPath() + "/cart.jsp?error=Order+details+missing+or+session+expired.+Please+review+cart.";
            if (session == null || session.getAttribute("loggedInUser") == null) {
                redirectUrl = request.getContextPath() + "/login.jsp?message=Session+expired.+Please+login.";
            }
            response.sendRedirect(redirectUrl);
            return;
        }
        
        // FIXED: Redirect to PaymentServlet, not directly to payment.jsp
        response.sendRedirect(request.getContextPath() + "/PaymentServlet");
    }
}