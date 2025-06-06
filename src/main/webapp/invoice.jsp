<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale, java.sql.Timestamp, java.text.SimpleDateFormat" %>
<%@ page import="com.gms.model.Order" %> <%-- Import your Order model --%>
<%@ page import="com.gms.model.OrderItem" %> <%-- Import your OrderItem model --%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Order Invoice - FoodMart</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
            background: #e6f2ff;
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }
        .invoice-container {
            background: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 700px;
            box-sizing: border-box;
            margin: 20px auto;
        }
        .invoice-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 25px;
            color: #007bff;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .message {
            padding: 12px;
            margin-bottom: 25px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
            font-size: 1.1em;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .message.error { /* Added for potential error display */
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .invoice-section {
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .invoice-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        .invoice-header div p, .invoice-details p {
            margin: 5px 0;
            color: #555;
            font-size: 0.95em;
            line-height: 1.6;
        }
        .invoice-header h3 { 
            margin: 0 0 10px 0; 
            color: #333; 
            font-size: 1.5em; 
        }
        .invoice-details h3, .invoice-items h3, .invoice-summary h3 {
            font-size: 1.2em;
            color: #333;
            margin-bottom: 10px;
            margin-top: 0;
        }
       .invoice-items table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        .invoice-items th, .invoice-items td {
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            text-align: left;
            font-size: 0.9em;
        }
        .invoice-items th {
            background-color: #f8f9fa;
            color: #333;
            font-weight: 600;
        }
        .invoice-items td.text-right, .invoice-items th.text-right {
            text-align: right;
        }
        .invoice-summary {
            text-align: right;
        }
        .invoice-summary p {
            margin: 6px 0;
            font-size: 1em;
            color: #444;
        }
        .invoice-summary .total {
            font-size: 1.3em;
            font-weight: bold;
            color: #28a745;
            margin-top: 10px;
        }
        .invoice-footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px dashed #ccc;
        }
        .action-buttons {
            text-align: center;
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 15px;
        }
        .action-buttons button, .action-buttons a {
            font-weight: bold; 
            font-size: 1em; 
            border-radius: 5px;
            padding: 10px 20px; 
            border: none; 
            cursor: pointer;
            transition: background-color 0.2s; 
            text-decoration: none;
            display: inline-block; 
            line-height: 1.5;
        }
        .action-buttons .print-btn { 
            background-color: #6c757d; 
            color: white; 
        }
        .action-buttons .print-btn:hover { 
            background-color: #5a6268; 
        }
        .action-buttons .continue-shopping-btn { 
            background-color: #007bff; 
            color: white; 
        }
        .action-buttons .continue-shopping-btn:hover { 
            background-color: #0056b3; 
        }
       @media print {
            body { 
                background: none; 
                padding: 0; 
                margin: 0; 
            }
            .invoice-container { 
                box-shadow: none; 
                border: 1px solid #ccc; 
                padding: 15px; 
                max-width: 100%; 
                margin: 0; 
                border-radius: 0;
            }
            .action-buttons { 
                display: none; 
            }
            .invoice-header, .invoice-details, .invoice-items, .invoice-summary, .invoice-footer {
                page-break-inside: avoid;
            }
        }
        .payment-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #28a745;
        }
        .payment-info h4 {
            margin: 0 0 10px 0;
            color: #28a745;
            font-size: 1.1em;
        }
        .payment-info p {
            margin: 5px 0;
            font-size: 0.95em;
            color: #555;
        }
    </style>
</head>
<body>
    <%
        String contextPath = request.getContextPath();
        String message = (String) request.getAttribute("message");
        String messageType = (String) request.getAttribute("messageType"); // "success" or "error"

        // --- Retrieve the Order object ---
        Order invoiceOrder = (Order) request.getAttribute("invoiceOrder");

        // --- Initialize variables for display, with fallbacks ---
        String displayInvoiceNumber = "N/A";
        String displayOrderDateTime = "N/A";
        String displayTransactionId = (String) request.getAttribute("transactionId"); // Assumed to be passed separately
        if (displayTransactionId == null) displayTransactionId = "N/A";

        String displayCardHolderName = (String) request.getAttribute("cardHolderName"); // Assumed to be passed separately
        if (displayCardHolderName == null) displayCardHolderName = "N/A";
        
        String displayUserEmail = (String) request.getAttribute("userEmailForInvoice"); // Assumed to be passed separately
        if (displayUserEmail == null) displayUserEmail = "N/A";

        String displayDeliveryAddress = "N/A";
        
        List<OrderItem> itemsToDisplay = new ArrayList<>();
        BigDecimal orderSubtotal = BigDecimal.ZERO;
        BigDecimal orderTotalPaid = BigDecimal.ZERO;

        // Date and Currency Formatters
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        currencyFormat.setCurrency(java.util.Currency.getInstance("INR"));

        if (invoiceOrder != null) {
            displayInvoiceNumber = invoiceOrder.getOrderId() != null ? invoiceOrder.getOrderId() : "N/A";
            if (invoiceOrder.getOrderDate() != null) {
                displayOrderDateTime = dateFormat.format(invoiceOrder.getOrderDate());
            }
            // If User object is part of Order, or if name/email are directly on Order:
            // displayCardHolderName = invoiceOrder.getCustomerName(); // Example
            // displayUserEmail = invoiceOrder.getCustomerEmail(); // Example
            displayDeliveryAddress = invoiceOrder.getShippingAddress() != null ? invoiceOrder.getShippingAddress() : "N/A";
            
            if (invoiceOrder.getOrderItems() != null) {
                itemsToDisplay = invoiceOrder.getOrderItems();
                for (OrderItem item : itemsToDisplay) {
                    // Calculate subtotal from items if not directly on Order model
                     if (item.getPriceAtPurchase() != null) { // Ensure price is not null
                        orderSubtotal = orderSubtotal.add(
                            item.getPriceAtPurchase().multiply(BigDecimal.valueOf(item.getQuantity()))
                        );
                    }
                }
            }
            if (invoiceOrder.getTotalAmount() != null) {
                orderTotalPaid = invoiceOrder.getTotalAmount();
            }
        }

        // These might still be passed separately if not part of your Order model's calculation logic
        String subtotalStr = (String) request.getAttribute("subtotal");
      //  String taxStr = (String) request.getAttribute("tax");
        String shippingStr = (String) request.getAttribute("shipping");

        BigDecimal displaySubtotal = (subtotalStr != null) ? new BigDecimal(subtotalStr) : orderSubtotal;
     //   BigDecimal displayTax = (taxStr != null) ? new BigDecimal(taxStr) : BigDecimal.ZERO; // Default to 0 if not passed
        BigDecimal displayShipping = (shippingStr != null) ? new BigDecimal(shippingStr) : BigDecimal.ZERO; // Default to 0

        // If total wasn't on order, calculate it (though it should be on order)
     //   if (invoiceOrder == null || invoiceOrder.getTotalAmount() == null) {
      //       orderTotalPaid = displaySubtotal.add(displayTax).add(displayShipping);
    //    }

    %>

    <div class="invoice-container">
        <h2>Order Invoice</h2>

        <%-- Display success or error message --%>
        <% if (message != null && messageType != null) { %>
            <div class="message <%= "success".equals(messageType) ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <% if (invoiceOrder != null) { %>
            <%-- Invoice Header Section --%>
            <div class="invoice-section">
                <div class="invoice-header">
                    <div>
                        <h3>FoodMart</h3>
                        <p><strong>Address:</strong> 123 Food Street, Gourmet City, IN</p>
                        <p><strong>Phone:</strong> +91-9876543210</p>
                        <p><strong>Email:</strong> support@foodmart.com</p>
                        <p><strong>GST No:</strong> 29ABCDE1234F2Z5</p>
                    </div>
                    <div style="text-align: right;">
                        <p><strong>Invoice No:</strong> <%= displayInvoiceNumber %></p>
                        <p><strong>Date & Time:</strong> <%= displayOrderDateTime %></p>
                        <p><strong>Transaction ID:</strong> <%= displayTransactionId %></p>
                    </div>
                </div>
            </div>

            <%-- Customer Details Section --%>
            <div class="invoice-section invoice-details">
                <h3>Bill To:</h3>
                <p><strong>Customer:</strong> <%= displayCardHolderName %></p>
                <p><strong>Email:</strong> <%= displayUserEmail %></p>
                <p><strong>Delivery Address:</strong> <%= displayDeliveryAddress %></p>
            </div>

            <%-- Payment Information Section --%>
            <div class="payment-info">
                <h4>Payment Information</h4>
                <p><strong>Payment Method:</strong> Credit/Debit Card (Online)</p>
                <p><strong>Cardholder Name:</strong> <%= displayCardHolderName %></p>
                <p><strong>Transaction ID:</strong> <%= displayTransactionId %></p>
                <p><strong>Payment Status:</strong> <span style="color: #28a745; font-weight: bold;">SUCCESSFUL</span></p>
            </div>

            <%-- Order Items Section --%>
            <div class="invoice-section invoice-items">
                <h3>Order Details</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Item Name</th>
                            <th class="text-right">Unit Price</th>
                            <th class="text-right">Quantity</th>
                            <th class="text-right">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (!itemsToDisplay.isEmpty()) {
                            for (OrderItem item : itemsToDisplay) {
                                BigDecimal itemUnitPrice = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase() : BigDecimal.ZERO;
                                BigDecimal itemSubtotal = itemUnitPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                        %>
                            <tr>
                                <td><%= item.getProductName() != null ? item.getProductName() : "N/A" %></td>
                                <td class="text-right"><%= currencyFormat.format(itemUnitPrice) %></td>
                                <td class="text-right"><%= item.getQuantity() %></td>
                                <td class="text-right"><%= currencyFormat.format(itemSubtotal) %></td>
                            </tr>
                        <% 
                            }
                        } else {
                        %>
                            <tr>
                                <td colspan="4" style="text-align: center; color: #666;">No items in this order.</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <%-- Invoice Summary Section --%>
            <div class="invoice-section invoice-summary">
                <h3>Payment Summary</h3>
                <p><strong>Subtotal:</strong> <%= currencyFormat.format(displaySubtotal) %></p>
                <p><strong>Shipping & Packaging:</strong> <%= currencyFormat.format(displayShipping) %></p>
                <hr style="border: 1px solid #ddd; margin: 10px 0;">
                <p class="total"><strong>Total Paid:</strong> <%= currencyFormat.format(orderTotalPaid) %></p>
            </div>

        <% } else if (messageType == null || !"success".equals(messageType)) { // Show error if order object is null and no success message
        %>
             <div class="message error">
                Could not retrieve order details. Please check your order history or contact support.
            </div>
        <% } %>


        <%-- Invoice Footer --%>
        <div class="invoice-footer">
            <p style="margin: 5px 0; color: #666; font-size: 0.9em;">
                Thank you for your order! Your food will be delivered within 30-45 minutes.
            </p>
            <p style="margin: 5px 0; color: #666; font-size: 0.85em;">
                For any queries, contact us at support@foodmart.com or call +91-9876543210
            </p>
            <p style="margin: 10px 0 0 0; color: #888; font-size: 0.8em; font-style: italic;">
                This is a computer-generated invoice and does not require a signature.
            </p>
        </div>

        <%-- Action Buttons --%>
        <div class="action-buttons">
            <button class="print-btn" onclick="window.print()">Print Invoice</button>
            <a href="<%= contextPath %>/home" class="continue-shopping-btn">Continue Shopping</a>
        </div>
    </div>

</body>
</html>
