<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.List, java.util.ArrayList, com.gms.model.CartItem, com.gms.model.User, java.math.BigDecimal"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Your Shopping Cart - FoodMart</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
	rel="stylesheet">
<%-- Fonts from index.jsp --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Roboto:wght@300;400;500;700&display=swap"
	rel="stylesheet">

<style>
/* Color and Font Variables from index.jsp */
:root {
	--primary-color: #4CAF50; /* index.jsp's green */
	--primary-dark: #388E3C;
	--primary-light: #C8E6C9;
	--secondary-color: #FF9800; /* index.jsp's orange */
	--secondary-dark: #F57C00;
	--accent-color: #03A9F4; /* index.jsp's blue */
	--text-dark: #212121;
	--text-light: #757575;
	--text-on-primary: #FFFFFF;
	--text-on-secondary: #FFFFFF;
	--bg-light: #F5F5F5;
	--bg-white: #FFFFFF;
	--border-color: #E0E0E0;
	--shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
	--shadow-md: 0 4px 8px rgba(0, 0, 0, 0.1);
	--shadow-lg: 0 10px 20px rgba(0, 0, 0, 0.1);
	--radius-sm: 4px;
	--radius-md: 8px;
	--radius-lg: 16px;
	--font-primary: 'Poppins', sans-serif;
	--font-secondary: 'Roboto', sans-serif;
	--transition-smooth: 0.3s ease-in-out;
	--transition-fast: 0.2s ease-in-out;

	/* Specific for cart page, if needed, maintaining existing success/danger */
	--success-color: #28a745;
	--danger-color: #dc3545;
	--info-color: #17a2b8;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: var(--font-secondary);
	background-color: var(--bg-light); /* Matches index.jsp body */
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

/* Header Styles - Matched to index.jsp */
.header {
	background-color: var(--bg-white); /* Matched to index.jsp */
	padding: 1rem 0; /* Matched to index.jsp */
	box-shadow: var(--shadow-md); /* Matched to index.jsp */
	position: sticky;
	top: 0;
	z-index: 1000;
	transition: background-color var(--transition-smooth),
		box-shadow var(--transition-smooth);
}

.header .container {
	display: flex;
	justify-content: space-between;
	align-items: center;
	max-width: 1200px;
	margin: 0 auto;
	padding: 0 15px; /* Matched to index.jsp */
}

/* Logo Styles - Matched to index.jsp */
.logo-container {
	display: block; /* Ensures the whole container is clickable */
}

.logo-container img {
	height: 45px; /* Matched to index.jsp */
	width: auto;
	transition: transform var(--transition-smooth);
}

.logo-container img:hover {
	transform: scale(1.05);
}

.user-greeting {
	display: flex;
	align-items: center;
	color: var(--text-dark); /* Matched to index.jsp's text colors */
	font-weight: 500;
	font-family: var(--font-primary); /* Matched to index.jsp's primary font */
	font-size: 1.1rem;
}

.user-greeting i {
	margin-right: 0.5rem;
	color: var(--primary-color); /* Kept primary color for icon */
}

/* Main Container */
.cart-container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 3rem 15px; /* Consistent padding with index.jsp sections */
	flex-grow: 1;
}

.cart-header {
	text-align: center;
	margin-bottom: 3.5rem; /* Consistent spacing */
}

.cart-title {
	font-family: var(--font-primary); /* Matched to index.jsp titles */
	font-size: 3.5rem;
	font-weight: 700; /* 800 was a bit too bold, 700 matches index.jsp titles */
	color: var(--text-dark); /* Matched to index.jsp titles */
	margin-bottom: 0.75rem;
	text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.05); /* Softer shadow */
}

.cart-title i {
	margin-right: 0.8rem;
	color: var(--primary-color); /* Kept primary color */
}

.cart-subtitle {
	font-family: var(--font-secondary); /* Matched to index.jsp subtitles */
	font-size: 1.3rem;
	color: var(--text-light); /* Matched to index.jsp subtitles */
	font-weight: 400;
}

/* Message Styles */
.message-container {
	margin-bottom: 2.5rem;
}

.message {
	padding: 1.25rem 2rem;
	border-radius: var(--radius-md); /* Consistent radius */
	display: flex;
	align-items: center;
	font-weight: 500;
	animation: fadeIn 0.5s ease-out;
	box-shadow: var(--shadow-sm); /* Lighter shadow */
}

.message i {
	margin-right: 1rem;
	font-size: 1.5rem;
}

.message.success {
	background-color: #d4edda; /* Default Bootstrap success */
	color: #155724;
	border: 1px solid #c3e6cb;
}

.message.error {
	background-color: #f8d7da; /* Default Bootstrap error */
	color: #721c24;
	border: 1px solid #f5c6cb;
}

/* Cart Content */
.cart-content {
	display: grid;
	grid-template-columns: 2.5fr 1.5fr;
	gap: 2.5rem;
	align-items: flex-start;
}

@media ( max-width : 992px) {
	.cart-content {
		grid-template-columns: 1fr;
		gap: 2rem;
	}
}

/* Cart Items */
.cart-items {
	background: var(--bg-white); /* Matched to index.jsp cards */
	border-radius: var(--radius-lg); /* Consistent radius */
	padding: 2.5rem;
	box-shadow: var(--shadow-md); /* Consistent shadow */
}

.cart-item {
	display: flex;
	align-items: center;
	padding: 1.5rem;
	margin-bottom: 1.25rem;
	background: var(--bg-light); /* Lighter background for items */
	border-radius: var(--radius-md); /* Consistent radius */
	transition: all var(--transition-smooth);
	border: 1px solid var(--border-color); /* Consistent border */
}

.cart-item:hover {
	transform: translateY(-5px);
	box-shadow: var(--shadow-md); /* Consistent shadow */
	border-color: var(--primary-color); /* Primary color highlight on hover */
}

.cart-item:last-child {
	margin-bottom: 0;
}

.item-image {
	width: 120px;
	height: 120px;
	border-radius: var(--radius-md); /* Consistent radius */
	overflow: hidden;
	margin-right: 2rem;
	flex-shrink: 0;
	box-shadow: var(--shadow-sm); /* Lighter shadow */
	border: 1px solid var(--border-color); /* Consistent border */
}

.item-image img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	transition: transform var(--transition-smooth);
}

.cart-item:hover .item-image img {
	transform: scale(1.05);
}

.item-details {
	flex-grow: 1;
	margin-right: 1.5rem;
}

.item-name {
	font-family: var(--font-primary); /* Consistent font */
	font-size: 1.4rem;
	font-weight: 600;
	color: var(--text-dark);
	margin-bottom: 0.6rem;
}

.item-price {
	font-size: 1.1rem;
	color: var(--text-light); /* Consistent text color */
	margin-bottom: 0.4rem;
}

.item-subtotal {
	font-family: var(--font-primary); /* Consistent font */
	font-size: 1.3rem;
	font-weight: 700;
	color: var(--primary-color); /* Primary color for emphasis */
}

.item-actions {
	display: flex;
	align-items: center;
	gap: 0.75rem;
	flex-shrink: 0;
}

/* Quantity Controls - NEW STYLES */
.quantity-control-group {
	display: flex;
	align-items: center;
	border: 1px solid var(--border-color);
	border-radius: var(--radius-sm);
	overflow: hidden;
	height: 48px; /* Match height of other buttons */
}

.quantity-btn {
	background-color: var(--bg-light); /* Lighter background for buttons */
	color: var(--text-dark);
	border: none;
	padding: 0 1rem;
	font-size: 1.5rem;
	font-weight: 700;
	cursor: pointer;
	transition: background-color var(--transition-fast),
		color var(--transition-fast);
	height: 100%; /* Fill parent height */
	display: flex;
	align-items: center;
	justify-content: center;
}

.quantity-btn:hover:not(:disabled) {
	background-color: var(--primary-color);
	color: var(--text-on-primary);
}

.quantity-btn:disabled {
	opacity: 0.5;
	cursor: not-allowed;
	background-color: var(--border-color); /* Muted for disabled state */
}

.quantity-input {
	width: 60px; /* Smaller width as buttons handle +/- */
	text-align: center;
	border: none; /* No individual border */
	font-weight: 600;
	font-size: 1.1rem;
	padding: 0 0.25rem;
	/* Hide default number input arrows */
	-moz-appearance: textfield;
}

.quantity-input::-webkit-outer-spin-button,
.quantity-input::-webkit-inner-spin-button {
	-webkit-appearance: none;
	margin: 0;
}

.btn-action {
	height: 48px;
	padding: 0 1.25rem;
	border: none;
	border-radius: var(--radius-sm); /* Consistent radius */
	font-weight: 600;
	font-size: 1rem;
	cursor: pointer;
	transition: all var(--transition-fast);
	display: flex;
	align-items: center;
	gap: 0.6rem;
	font-family: var(--font-primary);
}

/* Specific style for the update icon button */
.btn-update-icon {
    background: var(--primary-color);
    color: var(--text-on-primary);
    width: 48px; /* Make it square */
    height: 48px;
    padding: 0; /* Remove padding */
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 1.2rem; /* Size of the icon */
    border-radius: var(--radius-sm);
    transition: background var(--transition-fast), transform var(--transition-fast), box-shadow var(--transition-fast);
}

.btn-update-icon:hover:not(:disabled) {
    background: var(--primary-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.btn-update-icon:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    background-color: var(--text-light);
    box-shadow: none;
}


.btn-remove {
	background: var(--danger-color);
	color: var(--text-on-primary);
}

.btn-remove:hover {
	background: #c82333;
	transform: translateY(-2px);
	box-shadow: var(--shadow-md);
}

/* Cart Summary - NEW STYLES */
.cart-summary {
    background: var(--bg-white); /* Matched to index.jsp cards */
    border-radius: var(--radius-lg); /* Consistent radius */
    padding: 2.5rem;
    box-shadow: var(--shadow-md); /* Consistent shadow */
    position: sticky;
    top: 100px; /* Adjust based on header height */
    height: fit-content;
    border: 1px solid var(--border-color); /* Consistent border */
    display: flex; /* Use flexbox for internal layout */
    flex-direction: column; /* Stack items vertically */
    gap: 1.5rem; /* Spacing between summary sections */
}

.summary-header {
    text-align: center;
    padding-bottom: 1.5rem;
    border-bottom: 2px dashed var(--border-color); /* Dashed border for distinct look */
}

.summary-title {
    font-family: var(--font-primary); /* Consistent font */
    font-size: 1.8rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0; /* No bottom margin, handled by gap */
}

.summary-details {
    display: flex;
    flex-direction: column;
    gap: 0.8rem; /* Spacing between detail lines */
    padding-bottom: 1.5rem;
    border-bottom: 1px solid var(--border-color);
}

.summary-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-family: var(--font-secondary);
    font-size: 1.1rem;
    color: var(--text-dark);
}

.summary-item span:first-child {
    font-weight: 500;
    color: var(--text-light); /* Lighter for labels */
}

.summary-item span:last-child {
    font-weight: 600;
    color: var(--text-dark); /* Darker for values */
}

.summary-item.total {
    font-family: var(--font-primary);
    font-size: 1.5rem; /* Larger for total */
    font-weight: 700;
    color: var(--primary-dark);
    padding-top: 0.8rem; /* Space from above items */
    border-top: 1px solid rgba(0,0,0,0.05); /* Subtle top border for total */
}

.summary-item.total span:last-child {
    font-size: 1.8rem; /* Even larger for the final price */
    color: var(--primary-color);
}


.checkout-btn {
	width: 100%;
	height: 65px;
	background: linear-gradient(135deg, var(--primary-color), var(--primary-dark)); /* Primary theme gradient */
	color: var(--text-on-primary);
	border: none;
	border-radius: var(--radius-md); /* Consistent radius */
	font-size: 1.3rem;
	font-weight: 700;
	cursor: pointer;
	transition: all var(--transition-smooth);
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 0.8rem;
	margin-bottom: 1.25rem;
	text-decoration: none;
	box-shadow: var(--shadow-md); /* Consistent shadow */
	font-family: var(--font-primary);
}

.checkout-btn:hover:not(:disabled) {
	transform: translateY(-3px);
	box-shadow: var(--shadow-lg); /* Larger shadow on hover */
	color: var(--text-on-primary);
}

.checkout-btn:disabled {
	opacity: 0.6;
	cursor: not-allowed;
	background: var(--text-light);
	box-shadow: none;
}

.checkout-btn i {
	font-size: 1.5rem;
}

.continue-shopping {
	width: 100%;
	height: 55px;
	background: transparent;
	color: var(--primary-color);
	border: 2px solid var(--primary-color);
	border-radius: var(--radius-md); /* Consistent radius */
	font-size: 1.1rem;
	font-weight: 600;
	cursor: pointer;
	transition: all var(--transition-smooth);
	text-decoration: none;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 0.6rem;
	font-family: var(--font-primary);
}

.continue-shopping:hover {
	background: var(--primary-color);
	color: var(--text-on-primary);
	transform: translateY(-2px);
	box-shadow: var(--shadow-sm); /* Consistent shadow */
}

/* Empty Cart */
.empty-cart {
	text-align: center;
	padding: 5rem 2rem;
	background: var(--bg-white); /* Consistent with other cards */
	border-radius: var(--radius-lg); /* Consistent radius */
	box-shadow: var(--shadow-md); /* Consistent shadow */
	border: 1px solid var(--border-color); /* Consistent border */
}

.empty-cart-icon {
	font-size: 5rem;
	color: var(--border-color); /* Subtle icon color */
	margin-bottom: 1.5rem;
	animation: bounceIn 0.8s ease-out;
}

.empty-cart h2 {
	font-family: var(--font-primary);
	font-size: 2.5rem;
	font-weight: 700;
	color: var(--text-dark);
	margin-bottom: 1rem;
}

.empty-cart p {
	font-family: var(--font-secondary);
	font-size: 1.2rem;
	color: var(--text-light);
	margin-bottom: 2.5rem;
	max-width: 600px;
	margin-left: auto;
	margin-right: auto;
}

.shop-now-btn {
	display: inline-flex;
	align-items: center;
	gap: 0.75rem;
	padding: 1.2rem 2.5rem;
	background: linear-gradient(135deg, var(--primary-color), var(--primary-dark)); /* Primary theme gradient */
	color: var(--text-on-primary);
	text-decoration: none;
	border-radius: var(--radius-md); /* Consistent radius */
	font-weight: 600;
	font-size: 1.2rem;
	transition: all var(--transition-smooth);
	box-shadow: var(--shadow-md); /* Consistent shadow */
	font-family: var(--font-primary);
}

.shop-now-btn:hover {
	transform: translateY(-3px);
	box-shadow: var(--shadow-lg); /* Larger shadow on hover */
	color: var(--text-on-primary);
}

/* Footer - Matched to index.jsp */
.footer {
	background-color: var(--text-dark); /* Matched to index.jsp */
	color: var(--bg-light); /* Matched to index.jsp */
	padding: 1.5rem 0;
	text-align: center;
	margin-top: 4rem; /* Consistent margin from content */
	font-size: 0.9rem;
	font-family: var(--font-secondary);
}

.footer a {
	color: var(--primary-light); /* Matched to index.jsp */
	text-decoration: none;
	transition: color var(--transition-smooth);
}

.footer a:hover {
	color: var(--secondary-color); /* Matched to index.jsp */
	text-decoration: underline;
}

/* Animations (kept from previous version as they are good) */
@
keyframes fadeIn {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
@
keyframes bounceIn {from, 20%, 40%, 60%, 80%, to {
	-webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);
	animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);
}

0% {
	opacity: 0;
	-webkit-transform: scale3d(0.3, 0.3, 0.3);
	transform: scale3d(0.3, 0.3, 0.3);
}

20% {
	-webkit-transform: scale3d(1.1, 1.1, 1.1);
	transform: scale3d(1.1, 1.1, 1.1);
}

40% {
	-webkit-transform: scale3d(0.9, 0.9, 0.9);
	transform: scale3d(0.9, 0.9, 0.9);
}

60% {
	opacity: 1;
	-webkit-transform: scale3d(1.03, 1.03, 1.03);
	transform: scale3d(1.03, 1.03, 1.03);
}

80% {
	-webkit-transform: scale3d(0.97, 0.97, 0.97);
	transform: scale3d(0.97, 0.97, 0.97);
}

to {
	opacity: 1;
	-webkit-transform: scale3d(1, 1, 1);
	transform: scale3d(1, 1, 1);
}

}
.cart-item {
	animation: fadeIn 0.6s ease-out forwards;
}



</style>
</head>
<body>
	<%
	String contextPath = request.getContextPath();
	HttpSession currentSession = request.getSession(false);
	User loggedInUser = null;
	String userNameForGreeting = "Guest";
	if (currentSession != null && currentSession.getAttribute("loggedInUser") != null) {
		loggedInUser = (User) currentSession.getAttribute("loggedInUser");
		userNameForGreeting = loggedInUser.getUserName();
	}
	List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
	if (cartItems == null) {
		if (currentSession != null) {
			cartItems = (List<CartItem>) currentSession.getAttribute("cart");
		}
		if (cartItems == null) {
			cartItems = new ArrayList<>();
		}
	}
	BigDecimal cartTotal = (BigDecimal) (currentSession != null ? currentSession.getAttribute("cartTotal")
			: BigDecimal.ZERO);
	if (cartTotal == null)
		cartTotal = BigDecimal.ZERO;
	cartTotal = cartTotal.setScale(2, BigDecimal.ROUND_HALF_UP);

	// Placeholder for shipping and tax for demonstration.
	// In a real application, these would be calculated dynamically.
	BigDecimal shippingCost = new BigDecimal("5.00");
	BigDecimal taxRate = new BigDecimal("0.08"); // 8% tax
	BigDecimal subtotal = BigDecimal.ZERO;
	for(CartItem item : cartItems) {
	    subtotal = subtotal.add(item.getSubtotal());
	}
	BigDecimal taxAmount = subtotal.multiply(taxRate).setScale(2, BigDecimal.ROUND_HALF_UP);
	BigDecimal grandTotal = subtotal.add(shippingCost);


	String cartMessage = (String) (currentSession != null ? currentSession.getAttribute("cartMessage") : null);
	if (currentSession != null)
		currentSession.removeAttribute("cartMessage");
	%>

	<header class="header">
		<div class="container">
			<a href="<%=contextPath%>/welcome" class="logo-container"> <img
				src="<%=contextPath%>/images/logo.png" alt="FoodMart Logo">
			</a>
			<div class="user-greeting">
			<a href="<%= contextPath %>/profile" style="text-decoration:none;">
				<i class="fas fa-user-circle"></i> Hello,
				<%=userNameForGreeting%>!</a>
			</div>

		</div>
		    
	</header>
	
						<a href="home" style="text-decoration: none;">
    <div style="
        display: inline-flex;
        align-items: center;
        background-color: #e4eefc;
        border-radius: 25px;
        padding: 10px 20px;
        margin-top: 20px;
        margin-left:10px;
        color: #155724;
        font-weight: bold;
        font-family: Arial, sans-serif;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        transition: background-color 0.3s;
    " onmouseover="this.style.backgroundColor='#c3e6cb'" onmouseout="this.style.backgroundColor='#e4eefc'">
        <img src="images/back.png" alt="Back" style="width:24px; height:24px; margin-right:10px;" />
        Back
    </div>
</a>

	<div class="container cart-container">
		<div class="cart-header">
			<h1 class="cart-title">
				<i class="fas fa-shopping-cart"></i> Your Shopping Cart
			</h1>
			<p class="cart-subtitle">Review your delicious selections and
				proceed to checkout</p>
		</div>

		<%
		if (cartMessage != null && !cartMessage.isEmpty()) {
		%>
		<div class="message-container">
			<div
				class="message <%=cartMessage.toLowerCase().contains("error") ? "error" : "success"%>">
				<i
					class="fas <%=cartMessage.toLowerCase().contains("error") ? "fa-exclamation-circle" : "fa-check-circle"%>"></i>
				<%=cartMessage%>
			</div>
		</div>
		<%
		}
		%>

		<%
		if (cartItems.isEmpty()) {
		%>
		<div class="empty-cart">
			<div class="empty-cart-icon">
				<i class="fas fa-shopping-basket"></i>
			</div>
			<h2>Your cart is currently empty!</h2>
			<p>
				It seems you haven't added any fresh produce or gourmet delights
				yet. Let's fill it up with some yummy items!
			</p>
			<a href="<%=contextPath%>/products" class="shop-now-btn"> <i
				class="fas fa-store"></i> Discover Products
			</a>
		</div>
		<%
		} else {
		%>
		<div class="cart-content">
		

			<div class="cart-items">
				<%
				for (CartItem item : cartItems) {
				%>
				<div class="cart-item">
					<div class="item-image">
						<%
						String imageUrl = (item.getImageFileName() != null && !item.getImageFileName().isEmpty()
								&& !"placeholder.jpg".equals(item.getImageFileName())) ? contextPath + "/images/" + item.getImageFileName()
										: contextPath + "/images/placeholder_product_foodmart.png"; // Fallback to index.jsp's specific placeholder
						%>
						<img src="<%=imageUrl%>" alt="<%=item.getProductName()%>"
							onerror="this.onerror=null; this.src='<%=contextPath%>/images/placeholder_product_foodmart.png';">
					</div>

					<div class="item-details">
						<h3 class="item-name"><%=item.getProductName()%></h3>
						<div class="item-price">
							<span style="font-weight: 500;">Price:</span> ₹<%=item.getUnitPrice().setScale(2, BigDecimal.ROUND_HALF_UP)%>
							per unit
						</div>
						<div class="item-subtotal">
							<span style="font-weight: 500;">Subtotal:</span> ₹<%=item.getSubtotal().setScale(2, BigDecimal.ROUND_HALF_UP)%></div>
					</div>

					<div class="item-actions">
						<form action="<%=contextPath%>/CartServlet" method="post"
							class="d-flex align-items-center gap-2 item-update-form">
							<input type="hidden" name="action" value="UPDATE"> <input
								type="hidden" name="productId" value="<%=item.getProductId()%>">

							<div class="quantity-control-group">
								<button type="button" class="quantity-btn minus-btn"
									data-product-id="<%=item.getProductId()%>">-</button>
								<input type="number" name="quantity" class="quantity-input"
									value="<%=item.getQuantity()%>" min="1" max="999" required
									aria-label="Quantity for <%=item.getProductName()%>"
									data-initial-quantity="<%=item.getQuantity()%>">
								<button type="button" class="quantity-btn plus-btn"
									data-product-id="<%=item.getProductId()%>">+</button>
							</div>

							<button type="submit" class="btn-update-icon"
								title="Update quantity" disabled>
								<i class="fas fa-redo-alt"></i>
							</button>
						</form>

						<form action="<%=contextPath%>/CartServlet" method="post"
							class="d-inline">
							<input type="hidden" name="action" value="REMOVE"> <input
								type="hidden" name="productId" value="<%=item.getProductId()%>">
							<button type="submit" class="btn-action btn-remove"
								onclick="return confirm('Are you sure you want to remove <%=item.getProductName()%> from your cart?')"
								title="Remove item">
								<i class="fas fa-trash-alt"></i> Remove
							</button>
						</form>

					</div>
				</div>
				<%
				}
				%>
			</div>

			<div class="cart-summary">
				<div class="summary-header">
					<h3 class="summary-title">Order Summary</h3>
				</div>
				<div class="summary-details">
					
					
					<div class="summary-item total">
						<span>Total Amount:</span> <span>₹<%=subtotal%></span>
					</div>
				</div>

				<form action="<%=contextPath%>/CartServlet" method="post">
					<input type="hidden" name="action" value="PROCEED_TO_CHECKOUT">
					<button type="submit" class="checkout-btn"
						<%=cartItems.isEmpty() ? "disabled" : ""%>>
						<i class="fas fa-credit-card"></i> Proceed to Checkout
					</button>
				</form>

				<a href="<%=contextPath%>/products" class="continue-shopping"> <i
					class="fas fa-arrow-left"></i> Continue Shopping
				</a>
			</div>
		</div>
		<%
		}
		%>
	</div>

	<footer class="footer">
		<div class="container">
			<div class="footer-content">
				<p>
					&copy;
					<%=new java.text.SimpleDateFormat("yyyy").format(new java.util.Date())%>
					FoodMart Online Services. All Rights Reserved.
				</p>
				
				<p>Crafted for your convenience.</p>
			</div>
		</div>
	</footer>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
		// Optional: Header shrink on scroll (consistent with index.jsp)
		const header = document.querySelector('.header');
		if (header) {
			window.addEventListener('scroll', () => {
				if (window.scrollY > 50) {
					header.style.padding = '0.75rem 0';
					header.style.boxShadow = 'var(--shadow-sm)';
				} else {
					header.style.padding = '1rem 0';
					header.style.boxShadow = 'var(--shadow-md)';
				}
			});
		}

		// Quantity Plus/Minus Logic
		document.addEventListener('DOMContentLoaded', function() {
			document.querySelectorAll('.item-update-form').forEach(form => {
				const quantityInput = form.querySelector('.quantity-input');
				const minusBtn = form.querySelector('.minus-btn');
				const plusBtn = form.querySelector('.plus-btn');
				const updateBtn = form.querySelector('.btn-update-icon'); // Changed to the new class

				const initialQuantity = parseInt(quantityInput.dataset.initialQuantity); // Get initial quantity from data attribute

				function updateQuantityDisplay(newValue) {
					// Ensure newValue is a number and at least 1
					newValue = isNaN(newValue) || newValue < 1 ? 1 : newValue;
					// Enforce client-side max (e.g., 999) if user manually types
					newValue = newValue > 999 ? 999 : newValue; 
					
					quantityInput.value = newValue;

					// Enable/disable the "Update" button based on change from initial value
					if (newValue !== initialQuantity) { // Only enable if quantity has truly changed
						updateBtn.removeAttribute('disabled');
					} else {
						updateBtn.setAttribute('disabled', 'true');
					}

					// Disable minus button if quantity is 1
					if (newValue <= 1) {
						minusBtn.setAttribute('disabled', 'true');
					} else {
						minusBtn.removeAttribute('disabled');
					}
				}

				// Initial state setup
				updateQuantityDisplay(initialQuantity);

				minusBtn.addEventListener('click', () => {
					let currentValue = parseInt(quantityInput.value);
					if (currentValue > 1) {
						updateQuantityDisplay(currentValue - 1);
					}
				});

				plusBtn.addEventListener('click', () => {
					let currentValue = parseInt(quantityInput.value);
					// Client-side max cap (server-side will enforce actual stock)
					if (currentValue < 999) { // Example max, adjust if you have a different client-side max
						updateQuantityDisplay(currentValue + 1);
					} else {
						alert('Maximum quantity per item is 999.'); // Provide feedback
					}
				});

				// Listen for manual input changes (though buttons are primary)
				quantityInput.addEventListener('input', () => {
					let currentValue = parseInt(quantityInput.value);
					// This will call the same validation and update logic
					updateQuantityDisplay(currentValue);
				});
			});
		});
	</script>
</body>
</html>
