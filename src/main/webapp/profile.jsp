<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.gms.model.User"%>
<%@ page import="com.gms.model.Order"%>
<%@ page import="com.gms.model.Product"%>
<%@ page import="java.util.List"%>
<%@ page import="com.gms.model.OrderItem"%>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>My Profile - FoodMart</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* --- Root Variables --- */
:root {
	--font-family-sans: 'Inter', -apple-system, BlinkMacSystemFont,
		"Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
	--primary-color: #2563EB; /* Blue-600 */
	--primary-hover: #1D4ED8; /* Blue-700 */
	--primary-light: #EFF6FF; /* Blue-50 */
	--secondary-color: #6B7280; /* Gray-500 */
	--success-color: #059669; /* Green-600 */
	--danger-color: #DC2626; /* Red-600 */
    --danger-hover: #B91C1C; /* Darker Red */
	--warning-color: #D97706; /* Amber-600 */
	--info-color: #3B82F6; /* Blue-500, for info states */
	--light-bg: #F9FAFB; /* Gray-50 */
	--card-bg: #FFFFFF;
	--text-primary: #1F2937; /* Gray-800 */
	--text-secondary: #4B5563; /* Gray-600 */
	--text-muted: #9CA3AF; /* Gray-400 */
	--border-color: #E5E7EB; /* Gray-200 */
	--border-strong: #D1D5DB; /* Gray-300 */
	--link-color: var(--primary-color);
	--shadow-xs: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
	--shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.07), 0 1px 2px 0
		rgba(0, 0, 0, 0.04);
	--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -1px
		rgba(0, 0, 0, 0.04);
	--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -2px
		rgba(0, 0, 0, 0.03);
	--radius-sm: 0.25rem; /* 4px */
	--radius-md: 0.5rem; /* 8px */
	--radius-lg: 0.75rem; /* 12px */
	--radius-xl: 1rem; /* 16px */
	--radius-full: 9999px;
	--spacing-1: 0.25rem;
	--spacing-2: 0.5rem;
	--spacing-3: 0.75rem;
	--spacing-4: 1rem;
	--spacing-5: 1.25rem;
	--spacing-6: 1.5rem;
	--spacing-8: 2rem;
	--spacing-10: 2.5rem;
	--spacing-12: 3rem;
}

/* --- Base Styles --- */
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: var(--font-family-sans);
	background-color: var(--light-bg);
	color: var(--text-primary);
	margin: 0;
	padding: 0;
	line-height: 1.6;
}

/* --- Site Header --- */
.site-header {
	background-color: var(--card-bg);
	padding: var(--spacing-4) var(--spacing-6);
	text-align: center;
	border-bottom: 1px solid var(--border-color);
	box-shadow: var(--shadow-sm);
	margin-bottom: var(--spacing-8);
}

.site-header .site-name {
	font-size: 1.75rem;
	font-weight: 700;
	color: var(--primary-color);
	text-decoration: none;
}

.site-header .site-name:hover {
	color: var(--primary-hover);
}

/* --- Main Content Container --- */
.profile-container {
	max-width: 900px;
	margin: 0 auto var(--spacing-12) auto;
	padding: var(--spacing-8);
	border-radius: var(--radius-xl);
	box-shadow: var(--shadow-lg);
	background-color: var(--card-bg);
}

/* Message Styling */
.message {
    padding: var(--spacing-3) var(--spacing-4);
    margin-bottom: var(--spacing-6);
    border-radius: var(--radius-md);
    text-align: center;
    font-size: 0.95rem;
}
.message i { margin-right: var(--spacing-2); }

.success-message {
	background-color: #D1FAE5; /* Green-100 */
	color: #065F46; /* Green-700 */
	border: 1px solid #6EE7B7; /* Green-300 */
}
.error-message-box { /* Renamed from general .error-message to avoid conflict */
    background-color: #FEE2E2; /* Red-100 */
    color: #991B1B; /* Red-700 */
    border: 1px solid #FCA5A5; /* Red-300 */
}


/* --- Profile Header --- */
.profile-header-main {
	display: flex;
	align-items: center;
	padding-bottom: 2px;
	margin-bottom: 2px;
	border-bottom: 1px solid var(--border-color);
}

.profile-pic {
	width: 100px;
	height: 100px;
	border-radius: var(--radius-full);
	object-fit: cover;
	margin-right: var(--spacing-6);
	box-shadow: var(--shadow-md);
	flex-shrink: 0;
}

.profile-info h1 {
	font-size: 2rem;
	font-weight: 700;
	color: var(--text-primary);
	margin: 0 0 0 0;
}

.profile-info .page-title-icon {
	margin-right: var(--spacing-2);
	color: var(--primary-color);
	font-size: 1.8rem;
	vertical-align: middle;
}

.profile-info p {
	font-size: 0.95rem;
	color: var(--text-secondary);
	margin: 1px 0;
	line-height: 1.0;
}

.profile-info p strong {
	color: var(--text-primary);
	font-weight: 600;
	min-width: 80px;
	display: inline-block;
}

.profile-info p span {
	color: var(--text-secondary);
}

/* --- General Section Styling --- */
.profile-section {
	margin-bottom: var(--spacing-10);
}

.profile-section:last-child {
	margin-bottom: 0;
}

.section-title {
	font-size: 1.5rem;
	font-weight: 600;
	color: var(--text-primary);
}

.section-title i {
	margin-right: var(--spacing-3);
	color: var(--secondary-color);
}

/* --- Order History & Accordion --- */
.accordion-toggle-btn {
    background-color: transparent;
    border: none;
    border-bottom: 1px solid var(--border-color);
    padding: var(--spacing-4) 0;
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    margin-bottom: var(--spacing-6);
}
.accordion-toggle-btn:focus {
    outline: 2px solid var(--primary-light);
}
.accordion-toggle-btn .section-title { /* Ensure title within button has no extra margins */
    margin: 0;
    padding: 0;
    border: none;
}
.accordion-icon {
    font-size: 1.2rem;
    color: var(--secondary-color);
    transition: transform 0.3s ease-in-out;
}
/* .accordion-icon.open {
    transform: rotate(180deg); Removed as direct class manipulation is better via JS for up/down states
} */

.accordion-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.4s ease-out;
}
.accordion-content.open {
    max-height: 5000px; /* Large enough to show all content */
    transition: max-height 0.5s ease-in;
}


.order-history-container {
	display: flex;
	flex-direction: column;
	gap: var(--spacing-6);
}

.order-card {
	background-color: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: var(--radius-lg);
	padding: var(--spacing-6);
	box-shadow: var(--shadow-sm);
	transition: box-shadow 0.2s ease-in-out, transform 0.2s ease-in-out;
}

.order-card:hover {
	box-shadow: var(--shadow-md);
	transform: translateY(-4px);
}

.order-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: var(--spacing-3);
	flex-wrap: wrap;
	gap: var(--spacing-2);
}

.order-id {
	font-size: 1.25rem;
	font-weight: 600;
	color: var(--text-primary);
}

.order-id i {
	margin-right: var(--spacing-2);
	color: var(--secondary-color);
}

.order-status {
	font-size: 0.8rem;
	font-weight: 600;
	padding: var(--spacing-1) var(--spacing-3);
	border-radius: var(--radius-full);
	color: var(--card-bg);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	align-self: center;
}

.status-delivered { background-color: var(--success-color); }
.status-shipped { background-color: var(--info-color); }
.status-processing, .status-pending { background-color: var(--warning-color); color: var(--text-primary); }
.status-cancelled { background-color: var(--danger-color); }


.order-meta {
	font-size: 0.9rem;
	color: var(--text-secondary);
	margin-bottom: var(--spacing-4);
	display: flex;
	justify-content: space-between;
	flex-wrap: wrap;
	border-bottom: 1px dashed var(--border-color);
	padding-bottom: var(--spacing-3);
}

.order-meta strong { color: var(--text-primary); }
.order-meta span { margin-right: var(--spacing-4); }

.order-items-title {
	font-size: 1rem;
	font-weight: 600;
	color: var(--text-primary);
	margin: var(--spacing-4) 0 var(--spacing-3) 0;
}

.order-items-list { list-style-type: none; padding-left: 0; }
.order-items-list li {
	font-size: 0.9rem;
	color: var(--text-secondary);
	padding: var(--spacing-2) 0;
	border-bottom: 1px solid var(--primary-light);
	display: flex;
	justify-content: space-between;
	flex-wrap: wrap;
}
.order-items-list li:last-child { border-bottom: none; }
.item-name-qty { flex-basis: 70%; }
.item-price { font-weight: 500; color: var(--text-primary); flex-basis: 30%; text-align: right; }

/* Transaction details specific styling */
.transaction-details-list {
    margin-top: var(--spacing-2);
}
.transaction-details-list .item-name-qty,
.transaction-details-list .item-price {
    font-size: 0.85rem;
}
.transaction-details-list .item-price.success {
    color: var(--success-color);
    font-weight: 600;
}
.transaction-details-list .item-price.refund {
    color: var(--warning-color);
    font-weight: 600;
}


.no-orders {
	text-align: center;
	color: var(--text-secondary);
	padding: var(--spacing-8);
	background-color: var(--light-bg);
	border-radius: var(--radius-lg);
	border: 1px dashed var(--border-color);
}
.no-orders i { font-size: 3rem; margin-bottom: var(--spacing-4); color: var(--text-muted); }
.no-orders p { margin-bottom: var(--spacing-4); font-size: 1.1rem; }


/* --- Account Settings & Actions --- */
.account-actions {
	display: flex;
    flex-direction: column; /* Stack buttons vertically */
	gap: var(--spacing-4);
    align-items: stretch; /* Align buttons to the start */
}
.account-actions .action-group {
    display: flex;
    gap: var(--spacing-4);
    flex-wrap: wrap; /* Allow wrapping for edit/logout */
    width: 100%; /* Take full width for alignment */
}


.btn-action {
	display: inline-flex;
	align-items: center;
	padding: var(--spacing-3) var(--spacing-6);
	font-size: 1rem;
	font-weight: 600;
	text-align: center;
	text-decoration: none;
	border-radius: var(--radius-md);
	transition: all 0.2s ease;
	cursor: pointer;
	border: 1px solid transparent;
    min-width: 180px; /* Ensure buttons have a decent minimum width */
    justify-content: center;
}

.btn-action i { margin-right: var(--spacing-2); }

.btn-primary {
	background-color: var(--primary-color);
	color: var(--card-bg) !important;
	border-color: var(--primary-color);
}
.btn-primary:hover {
	background-color: var(--primary-hover);
	border-color: var(--primary-hover);
	box-shadow: var(--shadow-md);
	transform: translateY(-2px);
}

.btn-danger {
	background-color: var(--danger-color);
	color: var(--card-bg) !important;
	border-color: var(--danger-color);
}
.btn-danger:hover {
	background-color: var(--danger-hover);
	border-color: var(--danger-hover);
	box-shadow: var(--shadow-md);
	transform: translateY(-2px);
}

/* Deactivation section */
.deactivate-section {
    margin-top: var(--spacing-8); /* Add some space above the deactivation button */
    padding-top: var(--spacing-6);
    border-top: 1px solid var(--border-color);
}
.deactivate-section .btn-danger {
    width: auto; /* Allow button to size based on content */
    display: inline-flex; /* Keep it inline-flex for icon alignment */
}


/* --- Responsive Adjustments --- */
@media (max-width : 768px) {
	.profile-container { padding: var(--spacing-5); margin-top: var(--spacing-4); margin-bottom: var(--spacing-8); }
	.profile-header-main { flex-direction: column; text-align: center; }
	.profile-pic { margin-right: 0; margin-bottom: var(--spacing-5); width: 120px; height: 120px; }
	.profile-info h1 { font-size: 1.75rem; }
	.section-title { font-size: 1.375rem; }
	.order-meta, .order-items-list li { flex-direction: column; align-items: flex-start; gap: var(--spacing-1); }
	.order-meta span { width: 100%; }
	.item-price { text-align: left; }
	
    .account-actions .action-group, 
    .deactivate-section .btn-danger {
        width: 100%; /* Make buttons full width on smaller screens */
    }
     .btn-action {
        width: 100%; 
        justify-content: center; 
    }
}

@media (max-width : 480px) {
	.profile-info h1 { font-size: 1.5rem; }
	.section-title { font-size: 1.25rem; }
	.order-id { font-size: 1.1rem; }
	.btn-action { font-size: 0.9rem; padding: var(--spacing-2) var(--spacing-4); }
}

/* Modal Styles (Basic - enhance as needed) */
.modal {
    display: none; /* Hidden by default */
    position: fixed; /* Stay in place */
    z-index: 1000; /* Sit on top */
    left: 0;
    top: 0;
    width: 100%; /* Full width */
    height: 100%; /* Full height */
    overflow: auto; /* Enable scroll if needed */
    background-color: rgba(0,0,0,0.6); /* Black w/ opacity */
}

.modal-content {
    background-color: #fff;
    margin: 15% auto; /* 15% from the top and centered */
    padding: var(--spacing-8);
    border: 1px solid var(--border-strong);
    border-radius: var(--radius-lg);
    width: 80%; /* Could be more or less, depending on screen size */
    max-width: 500px; /* Maximum width */
    box-shadow: var(--shadow-lg);
    text-align: center;
}

.modal-content h3 {
    margin-top: 0;
    margin-bottom: var(--spacing-4);
    color: var(--text-primary);
}
.modal-content p {
    margin-bottom: var(--spacing-6);
    color: var(--text-secondary);
    font-size: 0.95rem;
}

.modal-buttons {
    display: flex;
    justify-content: center;
    gap: var(--spacing-4);
}
.modal-buttons .btn-action {
    min-width: 120px;
}
.btn-secondary { /* For cancel button in modal */
    background-color: var(--secondary-color);
    color: var(--card-bg) !important;
    border-color: var(--secondary-color);
}
.btn-secondary:hover {
    background-color: #5A6268; /* Darker gray */
    border-color: #5A6268;
}



</style>
</head>
<body>

<%
String contextPath = request.getContextPath();
User user = (User) request.getAttribute("userProfile");
List<Order> orderList = (List<Order>) request.getAttribute("orderList");
String successMsg = (String) request.getAttribute("successMsg");
String errorMsg = (String) request.getAttribute("errorMsg");

String userName = (user != null && user.getUserName() != null) ? user.getUserName() : "User";
String userId = (user != null && user.getUserId() != null) ? user.getUserId() : "N/A";
String email = (user != null && user.getEmail() != null) ? user.getEmail() : "N/A";
String phone = (user != null && user.getContactNumber() != null && !user.getContactNumber().isEmpty()) ? user.getContactNumber() : "Not Provided";
String address = (user != null && user.getAddress() != null && !user.getAddress().isEmpty()) ? user.getAddress() : "Not Provided";

SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, yyyy hh:mm a");
%>

<header class="site-header">
    <a href="<%= contextPath %>/welcome" class="site-name">FoodMart</a>
</header>


<div class="profile-container">
    <div class="profile-header-main">
        <img src="<%= contextPath %>/images/user.png" alt="Profile Picture" class="profile-pic"
             onerror="this.src='<%= contextPath %>/images/placeholder.jpg';" />
        <div class="profile-info">
            <h1><%= userName %></h1>
            <p><strong>ID:</strong> <span><%= userId %></span></p>
            <p><strong>Email:</strong> <span><%= email %></span></p>
            <p><strong>Phone:</strong> <span><%= phone %></span></p>
            <p><strong>Address:</strong> <span><%= address %></span></p>
        </div>
    </div>

    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="message success-message">
            <i class="fas fa-check-circle"></i> <%= successMsg %>
        </div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="message error-message-box">
            <i class="fas fa-exclamation-triangle"></i> <%= errorMsg %>
        </div>
    <% } %>

	<div class="profile-section">
		<button type="button" id="orderHistoryToggle" class="accordion-toggle-btn" aria-expanded="true">
			<h2 class="section-title"><i class="fas fa-history"></i> My Order History</h2>
			<i id="orderHistoryIcon" class="fas fa-chevron-up accordion-icon"></i> <%-- Starts open, so icon is UP --%>
		</button>

		<div id="orderHistoryContent" class="order-history-container accordion-content open"> <%-- Starts open --%>
			<% if (orderList != null && !orderList.isEmpty()) {
				for (Order order : orderList) {
					String statusValue = order.getStatus() != null ? order.getStatus().toLowerCase().replaceAll("\\s+", "-") : "pending";
					String displayStatus = order.getStatus() != null ? order.getStatus() : "Pending";
					String transactionId = "TXN" + (order.getOrderId() != null && order.getOrderId().length() > 4 ? order.getOrderId().substring(4) : "N/A");
			%>
			<div class="order-card">
				<div class="order-header">
					<span class="order-id"><i class="fas fa-receipt"></i> Order #<%= order.getOrderId() %></span>
					<span class="order-status status-<%= statusValue %>"><%= displayStatus %></span>
				</div>
				<div class="order-meta">
					<span><strong>Date:</strong> <%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "N/A" %></span>
					<span><strong>Total:</strong> ₹<%= order.getTotalAmount() != null ? order.getTotalAmount().setScale(2, java.math.BigDecimal.ROUND_HALF_UP) : "0.00" %></span>
				</div>
				<h4 class="order-items-title">Items:</h4>
				<ul class="order-items-list">
					<% List<OrderItem> items = order.getOrderItems();
						if (items != null && !items.isEmpty()) {
							for (OrderItem item : items) { %>
					<li>
						<span class="item-name-qty"><%= item.getProductName() != null ? item.getProductName() : "Product ID: " + item.getProductId() %> (Qty: <%= item.getQuantity()%>)</span>
						<span class="item-price">₹<%= item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().setScale(2, java.math.BigDecimal.ROUND_HALF_UP) : "N/A" %></span>
					</li>
					<%	   }
						} else { %>
					<li>No items listed for this order.</li>
					<%	} %>
				</ul>
				
				<h4 class="order-items-title">Transaction Details:</h4>
				<ul class="order-items-list transaction-details-list">
					<li>
						<span class="item-name-qty">Transaction ID:</span>
						<span class="item-price"><%= transactionId %></span>
					</li>
					<li>
						<span class="item-name-qty">Mode of Payment:</span>
						<span class="item-price">Debit Card</span>
					</li>
					<li>
						<span class="item-name-qty">Card Holder Name:</span>
						<span class="item-price"><%= userName %></span>
					</li>
					<li>
						<span class="item-name-qty">Card Number:</span>
						<span class="item-price">XXXX XXXX XXXX 4444</span>
					</li>
					<% if (displayStatus.equalsIgnoreCase("Cancelled")) { %>
						<li>
							<span class="item-name-qty">Payment Status:</span>
							<span class="item-price refund">Refund Initiated <i class="fas fa-check-circle" style="color: var(--warning-color);"></i></span>
						</li>
					<% } else { %>
						<li>
							<span class="item-name-qty">Payment Status:</span>
							<span class="item-price success">Transaction Successful <i class="fas fa-check-circle" style="color: var(--success-color);"></i></span>
						</li>
					<% } %>
				</ul>
			</div>
			<%  }
			  } else { %>
			<div class="no-orders">
				<i class="fas fa-box-open"></i>
				<p>You have no past orders.</p>
				<a href="<%= contextPath %>/products" class="btn-action btn-primary">Start Shopping</a>
			</div>
			<% } %>
		</div>
	</div>


   


    <div class="profile-section">
        <h2 class="section-title" style="margin-bottom: 20px;"><i class="fas fa-cog"></i> Account Settings</h2>
        <div class="account-actions">
            <div class="action-group">
                 <a href="<%= contextPath %>/editProfile" class="btn-action btn-primary">
                    <i class="fas fa-user-edit"></i> Edit Profile
                </a>
                <a href="<%= contextPath %>/logout?logout=true" class="btn-action btn-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>

<% if(user.getRole().equalsIgnoreCase("CUSTOMER")) {%>
            <div class="deactivate-section">
                 <button type="button" id="deactivateAccountBtn" class="btn-action btn-danger">
                    <i class="fas fa-user-slash"></i> Deactivate My Account
                </button>
            </div>
        </div>
    </div>
</div>
<% } %>
<div id="deactivateModal" class="modal">
  <div class="modal-content">
    <h3>Confirm Account Deactivation</h3>
    <p>Are you sure you want to deactivate your account? This action will prevent you from logging in and accessing your profile.</p>
    <div class="modal-buttons">
        <form id="deactivateForm" action="<%= request.getContextPath() %>/profile" method="post" style="display: inline;">
            <input type="hidden" name="action" value="deactivateAccount">
            <button type="submit" class="btn-action btn-danger"><i class="fas fa-user-slash"></i> Yes, Deactivate</button>
        </form>
        <button type="button" id="cancelDeactivateBtn" class="btn-action btn-secondary"><i class="fas fa-times"></i> Cancel</button>
    </div>
  </div>
</div>

<script>
    // Modal script
    const modal = document.getElementById('deactivateModal');
    const deactivateBtn = document.getElementById('deactivateAccountBtn');
    const cancelBtn = document.getElementById('cancelDeactivateBtn');

    if(deactivateBtn) {
        deactivateBtn.onclick = function() {
            modal.style.display = "block";
        }
    }

    if(cancelBtn) {
        cancelBtn.onclick = function() {
            modal.style.display = "none";
        }
    }

    // Close modal if user clicks outside of it
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
</script>
</body>
</html>
