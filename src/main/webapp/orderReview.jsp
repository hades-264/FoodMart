<%@page import="com.gms.model.CartItem"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="com.gms.model.User" %>
<%@ page import="com.gms.model.OrderItem" %>
<%@ page import="com.gms.model.Product" %> <%-- Import Product if you ever need to cast --%>
<%@ page import="com.gms.servlet.OrderReviewServlet.OrderReviewItemDisplay" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Order Review - FoodMart</title>
    <%-- Your existing CSS styles --%>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            color: #1c1e21;
        }
        .review-container {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
            width: 100%;
            max-width: 700px; 
            display: flex;
            flex-direction: column;
        }
        .page-title {
            font-size: 1.5em;
            font-weight: 600;
            padding: 20px;
            border-bottom: 1px solid #dddce1;
            text-align: center; 
            color: #007bff; /* Example: Theme color for title */
        }
        .section {
            padding: 20px;
            border-bottom: 1px solid #dddce1;
        }
        .section:last-child { border-bottom: none; }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .section-header h2 {
            font-size: 1.125em;
            font-weight: 600;
            margin: 0;
            color: #333; /* Darker color for section headers */
        }
        .edit-btn {
            font-size: 0.875em;
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
        }
        .edit-btn:hover { text-decoration: underline; }
        
        .address-info {
            background-color: #f9f9f9; /* Light background for address */
            padding: 15px;
            border-radius: 6px;
            border: 1px solid #eee;
        }
        .address-info p {
            margin: 4px 0;
            font-size: 0.9375em;
            line-height: 1.5;
        }
        .address-info p strong { font-weight: 600; color: #0056b3; }
        .address-info .address-line {
            white-space: normal; 
        }

        .order-item-card {
            display: flex;
            align-items: flex-start; 
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        .order-item-card:last-child { margin-bottom: 0; border-bottom: none; padding-bottom: 0; }
        .order-item-card img {
            width: 70px; 
            height: 70px;
            border-radius: 6px;
            object-fit: cover;
            margin-right: 15px;
            border: 1px solid #dddce1;
        }
        .item-details { flex-grow: 1; }
        .item-details .item-name {
            font-weight: 600; 
            font-size: 1em;
            margin: 0 0 5px 0;
            color: #007bff; /* Make product name a link-like color */
        }
        .item-details .item-meta {
            font-size: 0.875em; 
            color: #606770;
            margin: 2px 0;
        }
        .item-price-total {
            font-size: 1em;
            font-weight: 600;
            text-align: right;
            min-width: 80px;
            margin-left: 10px; 
            color: #333;
        }
        .summary-title {
            font-size: 1.125em; 
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        .summary-line {
            display: flex;
            justify-content: space-between;
            font-size: 0.9375em; 
            padding: 8px 0;
        }
        .summary-line span:first-child { color: #606770; }
        .summary-line.total {
            font-size: 1.1em; 
            font-weight: 700;
            border-top: 2px solid #dddce1;
            margin-top: 10px;
            padding-top: 12px;
        }
        .summary-line.total span:first-child { color: #1c1e21; }
        .free-shipping-banner { 
            background-color: #e7f3fe; /* Light blue for info */
            color: #004085; /* Darker blue text */
            padding: 10px 20px;
            text-align: center;
            font-size: 0.9em;
            font-weight: 500;
            border-bottom: 1px solid #dddce1; 
            border-top: 1px solid #dddce1; /* Add top border too */
            margin: -1px 0 0 0; /* Overlap border slightly if needed */
        }
        .applied-free-shipping-msg {
            color: #28a745; /* Green for success/applied */
            font-size: 0.9em;
            text-align: center;
            margin-bottom: 10px;
            font-weight: 500;
            background-color: #d4edda; /* Light green background */
            padding: 8px;
            border-radius: 4px;
        }
        .action-footer {
            padding: 20px;
            background-color: #f7f7f7;
            border-top: 1px solid #dddce1;
            text-align: center; 
        }
        .make-payment-btn {
            background-color: #28a745; /* Green for primary action */
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 6px;
            font-size: 1em; 
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            width: 100%; 
            box-sizing: border-box;
            transition: background-color 0.2s ease;
        }
        .make-payment-btn:hover { background-color: #218838; } /* Darker green */
        .info-text {
             font-size: 0.875em;
             color: #606770;
             margin-bottom: 15px; 
             text-align: center;
        }
        .empty-cart-message {
            text-align: center;
            padding: 30px 20px;
            font-size: 1.1em;
            color: #606770;
        }
        .empty-cart-message a {
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
        }
        .empty-cart-message a:hover {
            text-decoration: underline;
        }

        /* Responsive adjustments if necessary */
        @media (max-width: 600px) {
            .review-container {
                margin: 10px;
                padding: 0;
            }
            .page-title, .section, .action-footer {
                padding: 15px;
            }
            .order-item-card img {
                width: 60px;
                height: 60px;
                margin-right: 10px;
            }
            .item-details .item-name { font-size: 0.95em; }
            .item-details .item-meta { font-size: 0.8em; }
            .item-price-total { font-size: 0.95em; }
        }
    </style>
</head>
<body>
    <%
        String contextPath = request.getContextPath();

        User shippingUser = (User) request.getAttribute("shippingUser");
        List<OrderReviewItemDisplay> displayOrderItems = (List<OrderReviewItemDisplay>) request.getAttribute("displayOrderItems");

        BigDecimal subtotal = (BigDecimal) request.getAttribute("subtotal");
        BigDecimal packagingFee = (BigDecimal) request.getAttribute("packagingFee");
        BigDecimal deliveryCharges = (BigDecimal) request.getAttribute("deliveryCharges");
        BigDecimal totalAmount = (BigDecimal) request.getAttribute("totalAmount");
        
        String freeShippingAppliedMessage = (String) request.getAttribute("freeShippingMessage"); 
        String generalFreeShippingOffer = "Free Shipping over ₹2000"; 

        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        currencyFormat.setCurrency(java.util.Currency.getInstance("INR"));

        if (shippingUser == null) shippingUser = new User(); 
        if (displayOrderItems == null) displayOrderItems = new ArrayList<OrderReviewItemDisplay>();
        int displayedItemCount = displayOrderItems.size(); 

        if (subtotal == null) subtotal = BigDecimal.ZERO;
        if (packagingFee == null) packagingFee = BigDecimal.ZERO;
        if (deliveryCharges == null) deliveryCharges = BigDecimal.ZERO;
        if (totalAmount == null) totalAmount = BigDecimal.ZERO;
    %>

    <div class="review-container">
        <div class="page-title">Order Review</div>

        <div class="section">
            <div class="section-header">
                <h2>Shipping Address</h2>
                <a href="<%= contextPath %>/editShippingAddress.jsp" class="edit-btn">Edit</a>
            </div>
            <% if (shippingUser != null && shippingUser.getUserName() != null && !shippingUser.getUserName().isEmpty()) { %>
                <div class="address-info">
                    <p><strong><%= shippingUser.getUserName() %></strong></p>
                    <p class="address-line"><%= shippingUser.getAddress() != null ? shippingUser.getAddress() : "Address not provided" %></p>
                    <p><strong>Phone:</strong> <%= shippingUser.getContactNumber() != null ? shippingUser.getContactNumber() : "N/A" %></p>
                </div>
            <% } else { %>
                <p>Shipping user details not available. Please <a href="<%= contextPath %>/editShippingAddress.jsp">update your profile</a>.</p>
            <% } %>
        </div>

        <% if (freeShippingAppliedMessage == null || freeShippingAppliedMessage.isEmpty()) { %>
            <% if (generalFreeShippingOffer != null && !displayOrderItems.isEmpty()) {  %>
                <div class="free-shipping-banner"><%= generalFreeShippingOffer %></div>
            <% } %>
        <% } %>
        
        <div class="section">
            <div class="section-header">
                 <h2>Order Items (<%= displayedItemCount %>)</h2>
                 <% if (!displayOrderItems.isEmpty()) { %>
                    <a href="<%= contextPath %>/CartServlet" class="edit-btn">Edit Cart</a>
                 <% } %>
            </div>
            <% if (!displayOrderItems.isEmpty()) { %>
                <% for (OrderReviewItemDisplay displayItem : displayOrderItems) { %>
                    <% CartItem item = displayItem.getCartItem(); %>
                    <div class="order-item-card">
                        <img src="<%
                                    String itemImageFileName = displayItem.getImageFileName();
                                    String imagePathToDisplay;
                                 
                                    if (itemImageFileName != null && !itemImageFileName.isEmpty() && !itemImageFileName.equals("placeholder.jpg")) {
                                        imagePathToDisplay = contextPath + "/images/" + itemImageFileName;
                                    } else {
                                        imagePathToDisplay = contextPath + "/images/placeholder_product_foodmart.jpg";
                                    }
                                    out.print(imagePathToDisplay);
                                 %>"
                             alt="<%= item.getProductName() != null ? item.getProductName() : "Product Image" %>">
                      
                        <div class="item-details">
                            <p class="item-name"><%= item.getProductName() %></p>
                            <p class="item-meta">Price: <%= currencyFormat.format(item.getUnitPrice()) %></p>
                            <p class="item-meta">Qty: <%= item.getQuantity() %></p>
                        </div>
                        <div class="item-price-total">
                            <%= currencyFormat.format(displayItem.getCalculatedItemTotal()) %>
                        </div>
                    </div>
                <% } %>
            <% } else { %>
                <div class="empty-cart-message">
                    <p>Your cart is currently empty. Please <a href="<%= contextPath %>/products">continue shopping</a>.</p>
                </div>
            <% } %>
        </div>

        <% if (!displayOrderItems.isEmpty()) { // Only show summary if there are items %>
        <div class="section">
            <h2 class="summary-title">Order Summary</h2>
             <% if (freeShippingAppliedMessage != null && !freeShippingAppliedMessage.isEmpty()) { %>
                <p class="applied-free-shipping-msg"><%= freeShippingAppliedMessage %></p>
            <% } %>
            <div class="summary-line">
                <span>Subtotal</span>
                <span><%= currencyFormat.format(subtotal) %></span>
            </div>
            <div class="summary-line">
                <span>Packaging Fee</span>
                <span><%= currencyFormat.format(packagingFee) %></span>
            </div>
            <div class="summary-line">
                <span>Delivery Charges</span>
                <span><%= currencyFormat.format(deliveryCharges) %></span>
            </div>
            <div class="summary-line total">
                <span>Total Amount</span>
                <span><%= currencyFormat.format(totalAmount) %></span>
            </div>
        </div>
        
        <div class="action-footer">
             <p class="info-text">Review your order. If you have any query or are facing any problem, please contact us.</p>
            <form action="<%= contextPath %>/PaymentServlet" method="post" style="margin:0;">
                 <button type="submit" class="make-payment-btn">Make Payment</button>
            </form>
        </div>
        <% } %>
    </div>
</body>
</html>