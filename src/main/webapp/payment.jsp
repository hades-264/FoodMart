<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.Map, java.util.HashMap" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Secure Payment - FoodMart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Expires" content="0"/>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #f0f4f8 0%, #d9e2ec 100%);
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }
        .form-container {
            background: white;
            padding: 30px 35px;
            border-radius: 12px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            width: 100%;
            max-width: 450px;
            box-sizing: border-box;
            border: 1px solid rgba(220, 220, 220, 0.5);
            animation: fadeIn 0.5s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .form-container h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 28px;
            color: #2c3e50;
            font-weight: 600;
            letter-spacing: 0.5px;
            font-size: 1.8em;
        }
        .form-group {
            margin-bottom: 22px;
            position: relative;
        }
        .form-group label {
            display: block;
            font-weight: 500;
            margin-bottom: 8px;
            color: #34495e;
            font-size: 0.95em;
        }
        .form-group input[type="text"],
        .form-group input[type="tel"],
        .form-group input[type="password"] {
            width: 100%;
            padding: 12px 15px;
            border-radius: 8px;
            border: 1px solid #cdd4da;
            box-sizing: border-box;
            font-size: 1em;
            transition: border-color 0.3s, box-shadow 0.3s;
            background-color: #fcfdff;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }
        .form-group input:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.2);
            outline: none;
        }
        .form-group input[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
            color: #495057;
        }
        .btn-submit {
            font-weight: 600;
            font-size: 17px;
            border-radius: 8px;
            background-color: #007bff;
            color: white;
            padding: 14px 15px;
            border: none;
            width: 100%;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.1s ease, box-shadow 0.3s;
            box-shadow: 0 6px 15px rgba(0, 123, 255, 0.3);
        }
        .btn-submit:hover {
            background-color: #0056b3;
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 123, 255, 0.4);
        }
        .btn-submit:active {
            transform: translateY(0);
            box-shadow: 0 4px 10px rgba(0, 123, 255, 0.3);
        }
        .message {
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 8px;
            text-align: center;
            font-size: 0.95em;
            border: 1px solid transparent;
        }
        .message.success {
            background-color: #d1e7dd;
            color: #0f5132;
            border-color: #badbcc;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .error-message { /* This is the style for individual field errors */
            color: #dc3545;
            font-size: 0.85em;
            margin-top: 6px;
            display: block;
            font-weight: 500;
        }
        .expiry-cvv-group {
            display: flex;
            justify-content: space-between;
            gap: 20px;
        }
        .expiry-cvv-group .form-group {
            flex: 1;
            margin-bottom: 0; /* Adjusted from 22px to 0 for items in this group */
        }
        .cvv-input-container {
            position: relative;
            width: 100%;
            display: flex;
            align-items: center;
        }
        .cvv-input-container input {
            padding-right: 40px; /* Space for the toggle icon */
        }
        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #888;
            font-size: 1.1em;
            transition: color 0.2s ease;
            z-index: 2; /* Ensure it's above the input field */
        }
        .toggle-password:hover {
            color: #333;
        }
        
        /* Hide number input spinners */
        input::-webkit-outer-spin-button,
        input::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }
        input[type=number] { -moz-appearance: textfield; }

        /* Hide Edge password reveal button and other browser-specific autofill/clear buttons */
        input::-ms-reveal, input::-ms-clear { display: none !important; }
        input::-webkit-password-toggle-button { display: none !important; -webkit-appearance: none !important; }
        input::-webkit-contacts-auto-fill-button { display: none !important; -webkit-appearance: none !important; }
        input::-webkit-calendar-picker-indicator { display: none !important; }

        /* Style for Webkit autofill */
        input:-webkit-autofill,
        input:-webkit-autofill:hover,
        input:-webkit-autofill:focus,
        input:-webkit-autofill:active {
            -webkit-box-shadow: 0 0 0px 1000px #fcfdff inset !important; /* Use form input background color */
            -webkit-text-fill-color: #333 !important; /* Adjust text color if needed */
            transition: background-color 5000s ease-in-out 0s;
        }
    </style>
    <script>
        // Function to format Expiry Date as MM/YY
        function formatExpiryDate(input) {
            let value = input.value.replace(/\D/g, ''); // Remove all non-digit characters
            if (value.length > 2) {
                // Insert slash after the first two digits (month)
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            input.value = value; // Update the input field with formatted value
        }

        // Function to toggle CVV visibility
        function toggleCvvVisibility() {
            const cvvInput = document.getElementById("cvv");
            const toggleIcon = document.getElementById("toggleCvvIcon"); // Get the <i> element
            if (cvvInput.type === "password") {
                cvvInput.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            } else {
                cvvInput.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            }
        }
    </script>
</head>
<body>

<%
    // --- MODIFIED SCRIPTLET SECTION ---

    // Retrieve general messages and errors from request
    String generalMessage = (String) request.getAttribute("message");
    String generalMessageType = (String) request.getAttribute("messageType");
    String paymentError = (String) request.getAttribute("paymentError"); // Specific error from payment processing
    String generalError = (String) request.getAttribute("generalError"); // Error from doGet (e.g., total missing, session expired)
    @SuppressWarnings("unchecked") // Suppress warning for this cast
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) {
        errors = new HashMap<>(); // Initialize if not present, VERY IMPORTANT
    }
    // Retrieve individual field validation errors
    String cardNumberError = (String) request.getAttribute("cardNumberError");
    String cardHolderNameError = (String) request.getAttribute("cardHolderNameError");
    String expiryDateError = (String) request.getAttribute("expiryDateError");
    String cvvError = (String) request.getAttribute("cvvError");

    // Determine if there are any specific field validation errors
    boolean hasFieldValidationErrors = (cardNumberError != null && !cardNumberError.isEmpty()) ||
                                     (cardHolderNameError != null && !cardHolderNameError.isEmpty()) ||
                                     (expiryDateError != null && !expiryDateError.isEmpty()) ||
                                     (cvvError != null && !cvvError.isEmpty());

    // Initialize variables for old input values
    String oldCardNumber;
    String oldCardHolderName;
    String oldExpiryDate; // This will be used for the input field's value attribute
    String oldCvv;

    // Retrieve values that might have been sent back by the servlet for repopulation
    // These are the names used in servlet: request.setAttribute("cardNumber", ...);
    String servletProvidedCardNumber = (String) request.getAttribute("cardNumber");
    String servletProvidedCardHolderName = (String) request.getAttribute("cardHolderName");
    // For expiry date, the servlet sets "expiryDate" as the attribute name for the value.
    // The input field itself is named "expiryDateValue".
    String servletProvidedExpiryDate = (String) request.getAttribute("expiryDate");
    String servletProvidedCvv = (String) request.getAttribute("cvv");

    if (hasFieldValidationErrors) {
        // If there are specific field validation errors, clear all payment input fields as requested.
        oldCardNumber = "";
        oldCardHolderName = "";
        oldExpiryDate = "";
        oldCvv = "";
    } else {
        // No specific field validation errors.
        // This means it's an initial load, or a postback without field validation issues
        // (e.g., a general message is shown, or after a successful operation).

        // If the servlet provided values (e.g., for repopulation after a non-validation error,
        // or if the servlet wants to clear fields by sending empty strings), use them.
        // Otherwise (e.g., initial GET request where servlet attributes are null), use dummy values.

        oldCardNumber = (servletProvidedCardNumber != null) ? servletProvidedCardNumber : "";
        oldCardHolderName = (servletProvidedCardHolderName != null) ? servletProvidedCardHolderName : "";
        oldExpiryDate = (servletProvidedExpiryDate != null) ? servletProvidedExpiryDate : "";
        oldCvv = (servletProvidedCvv != null) ? servletProvidedCvv : "";
    }

    // Total amount logic (remains the same)
    String totalAmountForDisplay = (String) request.getAttribute("totalAmountForDisplay");
    if (totalAmountForDisplay == null || totalAmountForDisplay.trim().isEmpty()) {
        totalAmountForDisplay = "0.00"; // Fallback, though servlet should ideally always set this.
    }
    // --- END OF MODIFIED SCRIPTLET SECTION ---
%>

<div class="form-container">
    <h2>Secure Payment</h2>

    <%-- Display general messages or errors at the top --%>
    <% if (generalMessage != null && !generalMessage.isEmpty()) { %>
        <div class="message <%= generalMessageType != null ? generalMessageType : "success" %>">
            <%= generalMessage %>
        </div>
    <% } %>
    <%-- Display paymentError if it exists and isn't covered by field errors already causing fields to clear --%>
    <%-- This message is more for overall transaction issues rather than input validation --%>
    <% if (paymentError != null && !paymentError.isEmpty()) { %>
        <div class="message error"><%= paymentError %></div>
    <% } %>
    <% if (generalError != null && !generalError.isEmpty()) { %>
        <div class="message error"><%= generalError %></div>
    <% } %>

   <form action="PaymentServlet" method="post" id="paymentForm">
    <div class="form-group">
        <label for="cardNumber">Card Number</label>
        <input type="tel" id="cardNumber" name="cardNumber" placeholder="XXXX XXXX XXXX XXXX"
               value="<%= oldCardNumber %>"
               title="Card number must be digits only"
               inputmode="numeric" maxlength="19"> <%-- Removed HTML pattern/required for JS full control --%>
        <span id="cardNumberErrorClient" class="error-message"></span> <%-- For JS empty/format errors --%>
        <% if (errors.containsKey("cardNumberError")) { %>
            <span class="error-message" style="display: block;"><%= errors.get("cardNumberError") %></span>
        <% } %>
    </div>

    <div class="form-group">
        <label for="cardHolderName">Card Holder Name</label>
        <input type="text" id="cardHolderName" name="cardHolderName" placeholder="e.g., John Doe"
               value="<%= oldCardHolderName %>"
               title="Card holder name must be letters and spaces only"
               maxlength="100"> <%-- Removed HTML required/minlength for JS full control --%>
        <span id="cardHolderNameErrorClient" class="error-message"></span> <%-- For JS empty/format errors --%>
        <% if (errors.containsKey("cardHolderNameError")) { %>
            <span class="error-message" style="display: block;"><%= errors.get("cardHolderNameError") %></span>
        <% } %>
    </div>

    <div class="expiry-cvv-group">
        <div class="form-group">
            <label for="expiryDate">Expiry Date (MM/YY)</label>
            <input type="text" id="expiryDate" name="expiryDateValue" placeholder="MM/YY"
                   value="<%= oldExpiryDate %>"
                   title="Enter expiry date in MM/YY format (e.g., 12/25)"
                   maxlength="5"
                   oninput="formatExpiryDate(this)"> <%-- Removed HTML required/pattern for JS full control --%>
            <span id="expiryDateErrorClient" class="error-message"></span> <%-- For JS empty/format errors --%>
            <% if (errors.containsKey("expiryDateError")) { %>
                <span class="error-message" style="display: block;"><%= errors.get("expiryDateError") %></span>
            <% } %>
        </div>
        <div class="form-group">
            <label for="cvv">CVV</label>
            <div class="cvv-input-container">
                <input type="password" id="cvv" name="cvv" placeholder="XXX"
                       value="<%= oldCvv %>"
                       title="CVV must be 3 digits"
                       maxlength="3" inputmode="numeric"> <%-- Updated maxlength to 3, removed HTML pattern/required for JS full control --%>
                <span class="toggle-password" id="toggleCvv" onclick="toggleCvvVisibility()">
                    <i id="toggleCvvIcon" class="fas fa-eye"></i>
                </span>
            </div>
            <span id="cvvErrorClient" class="error-message"></span> <%-- For JS empty/format errors --%>
            <% if (errors.containsKey("cvvError")) { %>
                <span class="error-message" style="display: block;"><%= errors.get("cvvError") %></span>
            <% } %>
        </div>
    </div>

    <div class="form-group">
        <label for="amountDisplay">Amount Payable</label>
        <input type="text" id="amountDisplay" name="amountDisplay" value="₹<%= totalAmountForDisplay %>" readonly>
        <input type="hidden" name="amount" value="<%= totalAmountForDisplay %>">
        <% if (errors.containsKey("amountError")) { %>
            <span class="error-message" style="display: block;"><%= errors.get("amountError") %></span>
        <% } else if (errors.containsKey("amountErrorGlobal")) { %>
             <span class="error-message" style="display: block;"><%= errors.get("amountErrorGlobal") %></span>
        <% } %>
    </div>

    <div id="error-popup" class="message error" style="display: none; margin-top: 10px; margin-bottom: 20px;">
        <%-- Content will be set by JS, or you can keep your p tag --%>
        Invalid Card Details
    </div>

    <button onclick="check_cred()" id="payNow" type="button" class="btn-submit">Pay Now</button>
</form>
</div>
<script type="text/javascript">
    // Function to format Expiry Date as MM/YY (existing - keep as is)
    function formatExpiryDate(input) {
        let value = input.value.replace(/\D/g, '');
        if (value.length > 2) {
            value = value.substring(0, 2) + '/' + value.substring(2, 4);
        }
        input.value = value;
    }

    // Function to toggle CVV visibility (existing - keep as is)
    function toggleCvvVisibility() {
        const cvvInput = document.getElementById("cvv");
        const toggleIcon = document.getElementById("toggleCvvIcon");
        if (cvvInput.type === "password") {
            cvvInput.type = "text";
            toggleIcon.classList.remove("fa-eye");
            toggleIcon.classList.add("fa-eye-slash");
        } else {
            cvvInput.type = "password";
            toggleIcon.classList.remove("fa-eye-slash");
            toggleIcon.classList.add("fa-eye");
        }
    }

    // Helper to display individual field error (only for empty checks)
    function displayIndividualError(fieldId, message) {
        const errorElement = document.getElementById(fieldId + "ErrorClient");
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.style.display = "block"; // Make visible
        }
    }

    // Helper to clear all client-side errors
    function clearAllClientValidationMessages() {
        const fieldIds = ["cardNumber", "cardHolderName", "expiryDate", "cvv"];
        fieldIds.forEach(id => {
            const errorElement = document.getElementById(id + "ErrorClient");
            if (errorElement) {
                errorElement.textContent = "";
                errorElement.style.display = "none"; // Hide
            }
        });
        // Hide the general error popup as well
        const errorPopup = document.getElementById("error-popup");
        if (errorPopup) {
            errorPopup.style.display = "none";
        }
    }

    function check_cred() {
        clearAllClientValidationMessages();

        const cardNumberInput = document.getElementById("cardNumber");
        const cardHolderNameInput = document.getElementById("cardHolderName");
        const expiryDateInput = document.getElementById("expiryDate");
        const cvvInput = document.getElementById("cvv");
        const generalErrorPopup = document.getElementById("error-popup");

        const cardNumberValue = cardNumberInput.value.trim();
        const cardHolderNameValue = cardHolderNameInput.value.trim();
        const expiryDateValue = expiryDateInput.value.trim();
        const cvvValue = cvvInput.value.trim();

        let hasEmptyFields = false;

        // --- 1. Empty Field Checks ---
        // If a field is empty, show its specific "Please enter..." message.
        if (!cardNumberValue) {
            displayIndividualError("cardNumber", "Please enter Card Number.");
            hasEmptyFields = true;
        }
        if (!cardHolderNameValue) {
            displayIndividualError("cardHolderName", "Please enter Card Holder Name.");
            hasEmptyFields = true;
        }
        if (!expiryDateValue) {
            displayIndividualError("expiryDate", "Please enter Expiry Date.");
            hasEmptyFields = true;
        }
        if (!cvvValue) {
            displayIndividualError("cvv", "Please enter CVV.");
            hasEmptyFields = true;
        }

        if (hasEmptyFields) {
            return; // Stop if any field is empty, showing only the "Please enter..." messages.
        }

        // --- 2. All Fields are Filled: Perform Format and Hardcoded Value Checks ---
        // If any of these checks fail, only the single "Invalid Card Details" message will be shown.

        // Define hardcoded values
        const HC_CARD_NUMBER = "1234123412341234";
        const HC_CARD_NAME = "Rohit Sharma";
        const HC_EXPIRY_DATE = "04/30";
        const HC_CVV = "264";

        // Define format patterns
        const cardNumberPattern = /^[0-9]+$/; // Allows only digits
        const cardHolderNamePattern = /^[a-zA-Z\s]+$/; // Allows letters and spaces
        const expiryDatePattern = /^(0[1-9]|1[0-2])\/([0-9]{2})$/; // MM/YY
        const cvvPattern = /^[0-9]{3}$/; // Exactly 3 digits

        let isFormatCorrect = true;
        if (!cardNumberPattern.test(cardNumberValue)) isFormatCorrect = false;
        if (!cardHolderNamePattern.test(cardHolderNameValue)) isFormatCorrect = false;
        if (!expiryDatePattern.test(expiryDateValue)) isFormatCorrect = false;
        if (!cvvPattern.test(cvvValue)) isFormatCorrect = false;
        
        let matchesHardcoded = true;
        if (cardNumberValue !== HC_CARD_NUMBER) matchesHardcoded = false;
        if (cardHolderNameValue !== HC_CARD_NAME) matchesHardcoded = false;
        if (expiryDateValue !== HC_EXPIRY_DATE) matchesHardcoded = false;
        if (cvvValue !== HC_CVV) matchesHardcoded = false;

        if (isFormatCorrect && matchesHardcoded) {
            console.log("All validations passed. Submitting form...");
            document.getElementById("paymentForm").submit();
        } else {
            // All fields were filled, but there was a format error OR a hardcoded value mismatch.
            // Show only the single "Invalid Card Details" message.
            console.log("Validation failed (format or hardcoded mismatch after all fields filled).");
            if (generalErrorPopup) {
                generalErrorPopup.textContent = "Invalid Card Details"; // Ensure correct message
                generalErrorPopup.style.display = "block";
            }
        }
    }
</script>
</body>
</html>