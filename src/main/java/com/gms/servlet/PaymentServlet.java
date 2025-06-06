package com.gms.servlet;

// Core Servlet Imports
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

// Java Standard Library Imports
import java.math.BigDecimal;
import java.math.RoundingMode; // For precise tax calculation
import java.sql.Timestamp; // Corrected import
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// import java.util.UUID; // Not used directly
// import java.util.concurrent.ThreadLocalRandom; // Kept for structure, but OTP is static

// Your GMS Project Imports
import com.gms.model.User;
import com.gms.model.CartItem; // To retrieve from session
import com.gms.model.Order;     // To create an order
import com.gms.model.OrderItem; // To create order items
import com.gms.dao.OrderDAO;    // To save the order
import com.gms.dbutil.*; // Assuming IdGenerator is in here

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO; // Declare OrderDAO

    // Define tax rate (e.g., 5% = 0.05)
    // private static final BigDecimal TAX_RATE = new BigDecimal("0.05"); // Tax calculation was commented out

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO(); // Initialize OrderDAO
    }

    private void clearPaymentFormErrorAttributes(HttpServletRequest request) {
        // Clear individual field errors
        request.removeAttribute("cardNumberError");
        request.removeAttribute("cardHolderNameError");
        request.removeAttribute("expiryDateError");
        request.removeAttribute("cvvError");

        // Clear general payment error message that might be set from a POST
        request.removeAttribute("paymentError"); 
        // Note: generalError is typically set by doGet for issues like missing total, so it's handled separately.

        // Clear previously submitted input values (except totalAmountForDisplay which is set by doGet)
        request.removeAttribute("cardNumber");
        request.removeAttribute("cardHolderName");
        request.removeAttribute("expiryDate"); // This is the attribute name used in JSP for oldExpiryDate
        request.removeAttribute("cvv");

        // Clear general message and type if they are meant to be transient after a POST
        // request.removeAttribute("message");
        // request.removeAttribute("messageType");
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Clear previous form-specific errors and input values at the beginning of a GET request
        clearPaymentFormErrorAttributes(request);

        String action = request.getParameter("action");
        
        if ("resendOTP".equals(action)) {
            // Note: resendOTP might also need to preserve some context or clear specific OTP errors
            // For now, clearPaymentFormErrorAttributes will run, which is generally fine.
            handleResendOTP(request, response);
            return;
        }
        
        HttpSession session = request.getSession(false);
        String totalAmountForDisplay = "0.00"; // Default
        String generalError = null; // This is for errors identified during GET (e.g., session issues)

        if (session != null && session.getAttribute("finalOrderTotalForPayment") != null) {
            Object orderTotalObj = session.getAttribute("finalOrderTotalForPayment");
            if (orderTotalObj instanceof BigDecimal) {
                totalAmountForDisplay = ((BigDecimal) orderTotalObj).setScale(2, BigDecimal.ROUND_HALF_UP).toString();
            } else {
                System.err.println("PaymentServlet (doGet): finalOrderTotalForPayment in session is not a BigDecimal. Type: " + orderTotalObj.getClass().getName());
                generalError = "Error retrieving order total. Please try again from cart.";
                if (orderTotalObj instanceof String) {
                    try {
                        BigDecimal tempDecimal = new BigDecimal((String)orderTotalObj);
                        totalAmountForDisplay = tempDecimal.setScale(2, BigDecimal.ROUND_HALF_UP).toString();
                        generalError = null; // Parsed successfully
                    } catch (NumberFormatException e) {
                        System.err.println("PaymentServlet (doGet): Could not parse finalOrderTotalForPayment string: " + orderTotalObj);
                        // generalError remains as set above
                    }
                }
            }
        } else {
            System.err.println("PaymentServlet (doGet): finalOrderTotalForPayment not found in session. User might have direct navigated or session expired.");
            generalError = "Your session may have expired or the order total is missing. Please return to your cart and try checking out again.";
        }

        if (generalError != null) {
            // This generalError is specific to issues found during the GET request (e.g. missing total)
            request.setAttribute("generalError", generalError);
        }
        request.setAttribute("totalAmountForDisplay", totalAmountForDisplay); 
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        
        if ("verifyOTP".equals(action)) {
            handleOTPVerification(request, response);
            return;
        }
        
        // Default action is to handle payment submission
        handlePaymentSubmission(request, response);
    }
    
    private void handlePaymentSubmission(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false); 
        clearPaymentFormErrorAttributes(request);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            // Set a general error to be displayed on the payment page or redirect to login
            request.setAttribute("generalError", "Session expired or you are not logged in. Please log in and try again.");
            // It's better to redirect to login if session is invalid for payment
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session_expired_please_login_again_to_pay");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        String userEmailForInvoice = loggedInUser.getEmail() != null ? loggedInUser.getEmail() : "N/A";
        String deliveryAddressForInvoice = loggedInUser.getAddress() != null ? loggedInUser.getAddress() : "N/A";
        String userPhoneForRecord = loggedInUser.getContactNumber() != null ? loggedInUser.getContactNumber() : "0000000000"; 


        // Use a map to collect errors during validation
        Map<String, String> fieldErrors = new HashMap<>();
        String cardNumber = request.getParameter("cardNumber") != null ? request.getParameter("cardNumber").trim() : "";
        String cardHolderName = request.getParameter("cardHolderName") != null ? request.getParameter("cardHolderName").trim() : "";
        String expiryDate = request.getParameter("expiryDateValue") != null ? request.getParameter("expiryDateValue").trim() : ""; 
        String cvv = request.getParameter("cvv") != null ? request.getParameter("cvv").trim() : "";
        String amountParamFromForm = request.getParameter("amount") != null ? request.getParameter("amount").trim() : "";

        // --- Server-Side Validation ---
        if (cardNumber.isEmpty()) {
            fieldErrors.put("cardNumberError", "Card number is required.");
        } else {
            String cardNumberCleaned = cardNumber.replaceAll("\\s+", "");
            if (!cardNumberCleaned.matches("^[0-9]{13,19}$")) {
                fieldErrors.put("cardNumberError", "Invalid card number (must be 13-19 digits).");
            }
        }
        if (cardHolderName.isEmpty()) {
            fieldErrors.put("cardHolderNameError", "Card holder name is required.");
        } else if (cardHolderName.length() < 2 || cardHolderName.length() > 100) {
             fieldErrors.put("cardHolderNameError", "Name must be between 2 and 100 characters.");
        } else if (!cardHolderName.matches("^[a-zA-Z\\s'.\\-]+$")) {
            fieldErrors.put("cardHolderNameError", "Name can only contain letters, spaces, periods, hyphens, and apostrophes.");
        }

        if (expiryDate.isEmpty()) {
            fieldErrors.put("expiryDateError", "Expiry date is required.");
        } else {
            if (!expiryDate.matches("^(0[1-9]|1[0-2])\\/([0-9]{2})$")) { // MM/YY
                fieldErrors.put("expiryDateError", "Format must be MM/YY (e.g., 12/25).");
            } else {
                try {
                    String[] parts = expiryDate.split("/");
                    int month = Integer.parseInt(parts[0]);
                    int year = 2000 + Integer.parseInt(parts[1]); 
                    if (month < 1 || month > 12) { 
                        fieldErrors.put("expiryDateError", "Month must be between 01 and 12.");
                    } else {
                        Calendar cal = Calendar.getInstance();
                        int currentYear = cal.get(Calendar.YEAR);
                        int currentMonth = cal.get(Calendar.MONTH) + 1; 
                        if (year < currentYear || (year == currentYear && month < currentMonth)) {
                            fieldErrors.put("expiryDateError", "Card has expired. Please use a valid card.");
                        }
                        if (year > currentYear + 20) { 
                            fieldErrors.put("expiryDateError", "Expiry date seems too far in the future.");
                        }
                    }
                } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                    fieldErrors.put("expiryDateError", "Invalid expiry date format or parsing error.");
                }
            }
        }
        if (cvv.isEmpty()) {
            fieldErrors.put("cvvError", "CVV is required.");
        } else if (!cvv.matches("^[0-9]{3,4}$")) { 
            fieldErrors.put("cvvError", "CVV must be 3 or 4 digits.");
        }

        String topLevelPaymentError = null; // For errors like amount mismatch, to be shown at the top
        BigDecimal paymentAmountFromSession = BigDecimal.ZERO;

        if (session.getAttribute("finalOrderTotalForPayment") != null && session.getAttribute("finalOrderTotalForPayment") instanceof BigDecimal) {
            paymentAmountFromSession = ((BigDecimal) session.getAttribute("finalOrderTotalForPayment")).setScale(2, BigDecimal.ROUND_HALF_UP);
        } else {
            topLevelPaymentError = "Order total is missing from session. Please restart the checkout process from your cart.";
            System.err.println("PaymentServlet (handlePaymentSubmission): finalOrderTotalForPayment not found/valid in session.");
        }

        if (topLevelPaymentError == null) { // Only proceed if session amount was okay
            BigDecimal paymentAmountFromFormValidated = BigDecimal.ZERO;
            if (amountParamFromForm.isEmpty()) {
                topLevelPaymentError = "Amount is missing from form submission. This is an unexpected error.";
            } else {
                try {
                    paymentAmountFromFormValidated = new BigDecimal(amountParamFromForm); 
                    if (paymentAmountFromFormValidated.compareTo(BigDecimal.ZERO) <= 0 && paymentAmountFromSession.compareTo(BigDecimal.ZERO) > 0) {
                        topLevelPaymentError = "Amount from form is invalid, but session amount seems okay. Discrepancy detected.";
                         System.err.println("PaymentServlet: Form amount invalid ("+paymentAmountFromFormValidated+"), session amount ("+paymentAmountFromSession+").");
                    } else if (paymentAmountFromFormValidated.compareTo(BigDecimal.ZERO) <= 0) {
                         topLevelPaymentError = "Amount must be positive.";
                    }
                    if (paymentAmountFromSession.compareTo(paymentAmountFromFormValidated.setScale(2, BigDecimal.ROUND_HALF_UP)) != 0) {
                        topLevelPaymentError = "Payment amount does not match the order total. Please try checking out again from your cart to ensure correct pricing.";
                        System.err.println("PaymentServlet: Amount Mismatch! Form: " + paymentAmountFromFormValidated + ", Session: " + paymentAmountFromSession);
                    }
                } catch (NumberFormatException e) {
                    topLevelPaymentError = "Invalid amount format in form submission. This is an unexpected error.";
                }
            }
        }
        
        String totalAmountForRedisplayOnError = paymentAmountFromSession.compareTo(BigDecimal.ZERO) > 0 ? paymentAmountFromSession.toString() : "0.00";
         // If form amount was present but caused an error, it might be better to show the session amount for consistency.
        if (amountParamFromForm != null && !amountParamFromForm.isEmpty() && topLevelPaymentError != null) {
             // totalAmountForRedisplayOnError = amountParamFromForm; // Or stick to session amount
        }


        if (!fieldErrors.isEmpty() || topLevelPaymentError != null) {
            // Set individual field error attributes for the JSP
            for(Map.Entry<String, String> entry : fieldErrors.entrySet()){
                request.setAttribute(entry.getKey(), entry.getValue());
            }
            
            if (topLevelPaymentError != null) {
                request.setAttribute("paymentError", topLevelPaymentError); // Use paymentError for top-level form errors from POST
            }
            
            // Set back the input values for repopulation
            request.setAttribute("cardNumber", cardNumber); 
            request.setAttribute("cardHolderName", cardHolderName);
            request.setAttribute("expiryDate", expiryDate); 
            request.setAttribute("cvv", cvv); 
            
            request.setAttribute("totalAmountForDisplay", totalAmountForRedisplayOnError); 
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            return;
        }

        // If all validations pass, proceed to OTP
        String otp = "123456"; // Static OTP for now
        
        session.setAttribute("pendingPayment", true);
        session.setAttribute("paymentOTP", otp);
        session.setAttribute("otpGeneratedTime", System.currentTimeMillis());
        
        session.setAttribute("paymentCardHolderName", cardHolderName); 
        session.setAttribute("paymentFinalAmount", paymentAmountFromSession); 
        session.setAttribute("userEmailForInvoice", userEmailForInvoice); 
        session.setAttribute("deliveryAddressForInvoice", deliveryAddressForInvoice); 
        session.setAttribute("userContactForOrder", userPhoneForRecord); 

        System.out.println("PaymentServlet: OTP for payment verification: " + otp + " for user: " + userEmailForInvoice + " (Phone for record: " + userPhoneForRecord + ")");
        
        request.setAttribute("userEmail", userEmailForInvoice); 
        String maskedPhoneDisplay = "N/A";
        if (userPhoneForRecord != null && userPhoneForRecord.length() > 4) {
            maskedPhoneDisplay = "****" + userPhoneForRecord.substring(userPhoneForRecord.length() - 4);
        } else if (userPhoneForRecord != null && !userPhoneForRecord.equals("0000000000")) { 
            maskedPhoneDisplay = "****" + userPhoneForRecord; 
        }
        request.setAttribute("maskedPhone", maskedPhoneDisplay);
        request.getRequestDispatcher("/otpVerification.jsp").forward(request, response);
    }
    
    private void handleOTPVerification(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("pendingPayment") == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session_invalid_or_expired_for_OTP_verification");
            return;
        }
        
        String enteredOTP = request.getParameter("otp");
        String sessionOTP = (String) session.getAttribute("paymentOTP");
        Long otpGeneratedTime = (Long) session.getAttribute("otpGeneratedTime");
        
        long currentTime = System.currentTimeMillis();
        long otpValidityPeriod = 5 * 60 * 1000; // 5 minutes
        
        String userEmailForDisplay = (String) session.getAttribute("userEmailForInvoice");
        String userPhoneForDisplay = (String) session.getAttribute("userContactForOrder"); 
        String maskedPhoneDisplay = "N/A";
         if (userPhoneForDisplay != null && userPhoneForDisplay.length() > 4) {
            maskedPhoneDisplay = "****" + userPhoneForDisplay.substring(userPhoneForDisplay.length() - 4);
        } else if (userPhoneForDisplay != null && !userPhoneForDisplay.equals("0000000000")) {
            maskedPhoneDisplay = "****" + userPhoneForDisplay;
        }

        request.setAttribute("userEmail", userEmailForDisplay);
        request.setAttribute("maskedPhone", maskedPhoneDisplay);


        if (otpGeneratedTime == null || (currentTime - otpGeneratedTime) > otpValidityPeriod) {
            clearPendingPaymentSessionAttributes(session); 
            request.setAttribute("otpError", "OTP has expired. Please initiate payment again by returning to your cart.");
            request.getRequestDispatcher("/otpVerification.jsp").forward(request, response);
            return;
        }
        
        if (enteredOTP == null || !enteredOTP.trim().equals(sessionOTP)) {
            request.setAttribute("otpError", "Invalid OTP. Please try again.");
            request.getRequestDispatcher("/otpVerification.jsp").forward(request, response);
            return;
        }
        
        processPaymentAndCreateOrder(request, response, session); 
    }
    
    private void handleResendOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingPayment") == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session_invalid_for_resending_OTP");
            return;
        }
        
        String newOTP = "123456"; 
        session.setAttribute("paymentOTP", newOTP);
        session.setAttribute("otpGeneratedTime", System.currentTimeMillis()); 
        
        System.out.println("PaymentServlet: Resent OTP: " + newOTP + " for user: " + session.getAttribute("userEmailForInvoice"));
        
        request.setAttribute("userEmail", session.getAttribute("userEmailForInvoice"));
        String userPhoneForDisplay = (String) session.getAttribute("userContactForOrder");
        String maskedPhoneDisplay = "N/A";
         if (userPhoneForDisplay != null && userPhoneForDisplay.length() > 4) {
            maskedPhoneDisplay = "****" + userPhoneForDisplay.substring(userPhoneForDisplay.length() - 4);
        } else if (userPhoneForDisplay != null && !userPhoneForDisplay.equals("0000000000")) {
            maskedPhoneDisplay = "****" + userPhoneForDisplay;
        }
        request.setAttribute("maskedPhone", maskedPhoneDisplay);
        request.setAttribute("otpMessage", "A new OTP has been sent (it's " + newOTP + ")."); 
        request.getRequestDispatcher("/otpVerification.jsp").forward(request, response);
    }
    
    private void processPaymentAndCreateOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        @SuppressWarnings("unchecked")
        List<CartItem> sessionCartItems = (List<CartItem>) session.getAttribute("cart"); 
        BigDecimal paymentFinalAmount = (BigDecimal) session.getAttribute("paymentFinalAmount");
        
        Object packagingFeeObj = session.getAttribute("packagingFee");
        Object deliveryChargesObj = session.getAttribute("deliveryCharges");

        BigDecimal packagingFeeDecimal = BigDecimal.ZERO;
        BigDecimal deliveryChargesDecimal = BigDecimal.ZERO;
        BigDecimal freeBigDecimal = new BigDecimal(10);
        packagingFeeDecimal.add(freeBigDecimal);

        if (packagingFeeObj instanceof BigDecimal) {
            packagingFeeDecimal = (BigDecimal) packagingFeeObj;
        } else if (packagingFeeObj instanceof Double) {
            packagingFeeDecimal = BigDecimal.valueOf((Double)packagingFeeObj).setScale(2, RoundingMode.HALF_UP);
        } else if (packagingFeeObj instanceof String) {
            try {
                packagingFeeDecimal = new BigDecimal((String)packagingFeeObj).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) { /* default to zero */ }
        }
        
        if (deliveryChargesObj instanceof BigDecimal) {
            deliveryChargesDecimal = (BigDecimal) deliveryChargesObj;
        } else if (deliveryChargesObj instanceof Double) {
            deliveryChargesDecimal = BigDecimal.valueOf((Double)deliveryChargesObj).setScale(2, RoundingMode.HALF_UP);
        } else if (deliveryChargesObj instanceof String) {
             try {
                deliveryChargesDecimal = new BigDecimal((String)deliveryChargesObj).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) { /* default to zero */ }
        }


        if (loggedInUser == null || sessionCartItems == null || sessionCartItems.isEmpty() || paymentFinalAmount == null) {
            clearPendingPaymentSessionAttributes(session);
            System.err.println("PaymentServlet (processPayment): Critical data missing from session (User, Cart, or FinalAmount).");
            session.setAttribute("cartMessage", "Order processing failed due to missing critical data. Please review your cart and try again.");
            session.setAttribute("cartMessageType", "error");
            response.sendRedirect(request.getContextPath() + "/CartServlet"); 
            return;
        }

        Order order = new Order();
        String newOrderId = null;
        try {
            newOrderId = IdGenerator.generateUniqueOrderId(orderDAO); 
        } catch (Exception e) {
             System.err.println("PaymentServlet: CRITICAL - Exception during Order ID generation: " + e.getMessage());
             e.printStackTrace();
        }

        if (newOrderId == null) {
            System.err.println("PaymentServlet: CRITICAL - Failed to generate unique Order ID (returned null).");
            clearPendingPaymentSessionAttributes(session);
            request.setAttribute("paymentError", "Failed to process your order due to an internal error (Order ID Generation). Please contact support.");
            String totalAmountForRetry = paymentFinalAmount != null ? paymentFinalAmount.toString() : "0.00";
            request.setAttribute("totalAmountForDisplay", totalAmountForRetry);
            request.setAttribute("cardHolderName", (String) session.getAttribute("paymentCardHolderName")); // Repopulate if available
            // Potentially repopulate other fields if you decide to store them temporarily in session for such failures
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            return;
        }
        order.setOrderId(newOrderId);
        order.setUserId(loggedInUser.getUserId());
        order.setOrderDate(new Timestamp(System.currentTimeMillis()));
        order.setShippingAddress((String) session.getAttribute("deliveryAddressForInvoice"));
        order.setContactOnOrder((String) session.getAttribute("userContactForOrder"));
        order.setStatus("Pending"); 

        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal calculatedSubtotalFromCartItems = BigDecimal.ZERO; 

        for (CartItem cartItem : sessionCartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(newOrderId); 
            orderItem.setProductId(cartItem.getProductId());
            orderItem.setProductName(cartItem.getProductName());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setPriceAtPurchase(cartItem.getUnitPrice()); 
            orderItems.add(orderItem);
            if (cartItem.getSubtotal() != null) { 
                calculatedSubtotalFromCartItems = calculatedSubtotalFromCartItems.add(cartItem.getSubtotal());
            }
        }
        order.setOrderItems(orderItems);
        
        calculatedSubtotalFromCartItems = calculatedSubtotalFromCartItems.setScale(2, BigDecimal.ROUND_HALF_UP);
        
        BigDecimal finalAmountExpected = calculatedSubtotalFromCartItems;
        BigDecimal totalBigDecimal = paymentFinalAmount;
                                
        finalAmountExpected = finalAmountExpected.setScale(2, BigDecimal.ROUND_HALF_UP);
        
        if (paymentFinalAmount.compareTo(totalBigDecimal) != 0) {
            System.err.println("PaymentServlet (processPayment): MISMATCH between session final amount (" + paymentFinalAmount  + 
                               ") and calculated expected amount (" + finalAmountExpected + "). Order " + newOrderId + " NOT created.");
            clearPendingPaymentSessionAttributes(session);
            request.setAttribute("paymentError", "Order total mismatch during final processing. Please try again or contact support. Session: " + paymentFinalAmount + ", Calculated: " + finalAmountExpected);
            String totalAmountForRetry = paymentFinalAmount.toString();
            request.setAttribute("totalAmountForDisplay", totalAmountForRetry);
            request.setAttribute("cardHolderName", (String) session.getAttribute("paymentCardHolderName"));
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            return;
        }
        order.setTotalAmount(paymentFinalAmount); 


        String createdOrderIdFromDAO = null;
        try {
            createdOrderIdFromDAO = orderDAO.createOrder(order); 
        } catch (Exception e) {
            System.err.println("PaymentServlet: Exception during DAO createOrder for Order ID: " + newOrderId + " - " + e.getMessage());
            e.printStackTrace();
            clearPendingPaymentSessionAttributes(session);
            request.setAttribute("paymentError", "Failed to place your order due to a database error. Please contact support. (DAO Exception)");
            String totalAmountForRetry = paymentFinalAmount.toString();
            request.setAttribute("totalAmountForDisplay", totalAmountForRetry);
            request.setAttribute("cardHolderName", (String) session.getAttribute("paymentCardHolderName"));
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
            return; 
        }

        if (createdOrderIdFromDAO != null && createdOrderIdFromDAO.equals(newOrderId)) {
            System.out.println("PaymentServlet: Order " + createdOrderIdFromDAO + " successfully created in database.");

            String cardHolderNameForInvoice = (String) session.getAttribute("paymentCardHolderName"); // Get before clearing

            // Clear cart and payment related session attributes AFTER successful order
            session.removeAttribute("cart");
            session.removeAttribute("cartTotal"); 
            session.removeAttribute("cartItemCount"); 
            session.removeAttribute("finalOrderTotalForPayment"); 
            session.removeAttribute("packagingFee");
            session.removeAttribute("deliveryCharges");
            
            clearPendingPaymentSessionAttributes(session); 

            String transactionIdForInvoice = "FOODMART-TXN-" + System.currentTimeMillis() + "-" + newOrderId.substring(Math.max(0, newOrderId.length() - 4));

            request.setAttribute("message", "Payment Successful & Order Placed!");
            request.setAttribute("messageType", "success"); 
            request.setAttribute("invoiceOrder", order); 

            request.setAttribute("transactionId", transactionIdForInvoice);
            request.setAttribute("cardHolderName", cardHolderNameForInvoice != null ? cardHolderNameForInvoice : "N/A");
            request.setAttribute("userEmailForInvoice", loggedInUser.getEmail() != null ? loggedInUser.getEmail() : "N/A");
            request.setAttribute("subtotal", calculatedSubtotalFromCartItems.toString());
            request.setAttribute("shipping", packagingFeeDecimal.add(deliveryChargesDecimal).toString());

            request.getRequestDispatcher("/invoice.jsp").forward(request, response);

        } else {
            System.err.println("PaymentServlet: Order creation failed in DAO for attempted Order ID: " + newOrderId + 
                               (createdOrderIdFromDAO == null ? ". DAO returned null." : ". DAO returned different ID: " + createdOrderIdFromDAO));
            clearPendingPaymentSessionAttributes(session); 
            request.setAttribute("paymentError", "Failed to place your order due to a database error. Please try again or contact support. (DAO Error)");
            
            String totalAmountForRetry = paymentFinalAmount.toString();
            request.setAttribute("totalAmountForDisplay", totalAmountForRetry);
            request.setAttribute("cardHolderName", (String) session.getAttribute("paymentCardHolderName"));
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
        }
    }

    private void clearPendingPaymentSessionAttributes(HttpSession session) {
        if (session == null) return;
        session.removeAttribute("pendingPayment");
        session.removeAttribute("paymentOTP");
        session.removeAttribute("otpGeneratedTime");
        session.removeAttribute("paymentCardHolderName"); 
        session.removeAttribute("paymentFinalAmount");
        session.removeAttribute("userEmailForInvoice");
        session.removeAttribute("deliveryAddressForInvoice");
        session.removeAttribute("userContactForOrder");
    }
}
