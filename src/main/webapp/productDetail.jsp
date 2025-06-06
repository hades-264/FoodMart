<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="com.gms.model.Product, com.gms.model.User, com.gms.model.CartItem, java.math.BigDecimal, java.util.List, java.util.ArrayList, java.net.URLEncoder"%>
<%
// --- Product and Related Products Data ---
Product currentProduct = (Product) request.getAttribute("product");
String pageTitle = "Product Details - FoodMart";
if (currentProduct != null) {
	pageTitle = currentProduct.getProductName() + " - FoodMart";
}
String errorMessage = (String) request.getAttribute("errorMessage"); // For page-level errors
List<Product> relatedProducts = (List<Product>) request.getAttribute("relatedProducts");
if (relatedProducts == null) {
	relatedProducts = new ArrayList<>();
}

String contextPath = request.getContextPath();

// --- User Session Data (for header and cart) ---
HttpSession currentSession = request.getSession(false);
User loggedInUser = null;
String userNameForGreeting = "Guest";
String userRoleForPage = "GUEST";
List<CartItem> cartItems = new ArrayList<>();
BigDecimal cartTotal = BigDecimal.ZERO;
int cartItemCount = 0;

if (currentSession != null) {
	if (currentSession.getAttribute("loggedInUser") != null) {
		loggedInUser = (User) currentSession.getAttribute("loggedInUser");
		if (loggedInUser.getUserName() != null && !loggedInUser.getUserName().trim().isEmpty()) {
	userNameForGreeting = loggedInUser.getUserName();
		}
		userRoleForPage = loggedInUser.getRole();
	}

	List<CartItem> sessionCart = (List<CartItem>) currentSession.getAttribute("cart");
	if (sessionCart != null) {
		cartItems.addAll(sessionCart);
		cartItemCount = cartItems.size();
	}

	BigDecimal sessionCartTotal = (BigDecimal) currentSession.getAttribute("cartTotal");
	if (sessionCartTotal != null) {
		cartTotal = sessionCartTotal;
	}
}

cartTotal = cartTotal.setScale(2, BigDecimal.ROUND_HALF_UP);

// Cart action message for toast/offcanvas alert
String cartActionMessage = null;
if (currentSession != null) {
    cartActionMessage = (String) currentSession.getAttribute("cartActionMessage");
    if (cartActionMessage != null) {
        currentSession.removeAttribute("cartActionMessage"); // Clear after retrieving
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%=pageTitle%></title>

<%-- Fonts --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=Open+Sans:wght@300;400;600;700&display=swap"
	rel="stylesheet">

<%-- Libraries CSS --%>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css"
	rel="stylesheet">


<style>
:root {
	--font-primary: 'Montserrat', sans-serif;
	--font-secondary: 'Open Sans', sans-serif;
	--color-brand-primary: #5cb85c; /* Original green */
	--color-brand-primary-dark: #4cae4c;
    --color-brand-primary-light: #dff0d8; /* For product card hover border */
	--color-brand-accent: #4CAF50; /* Accent green */
	--color-brand-accent-dark: #45a049; /* Darker accent for hover */
	--color-text-dark: #333740;
	--color-text-medium: #555b68;
	--color-text-light: #888f99;
	--color-text-on-dark: #ffffff;
    --color-text-on-primary: #ffffff; /* Added for consistency */
	--color-background-body: #f9fafb;
	--color-background-card: #ffffff;
    --color-background-section-alt: #f0f2f5; /* For offcanvas header */
	--color-border: #e1e4e8;
	--color-border-light: #ebeef0;
    --color-border-medium: #d1d5db; /* Added for consistency */
	--color-error: #d9534f;
    --color-success: #5cb85c; /* Added for stock status & toasts */
    --color-info: #5bc0de; /* Added for toasts */
	--shadow-soft: 0 2px 8px rgba(0, 0, 0, 0.07);
	--shadow-medium: 0 5px 15px rgba(0, 0, 0, 0.1);
    --shadow-strong: 0 8px 25px rgba(0,0,0,0.12); /* For pop-up */
	--radius-default: 8px;
	--radius-large: 12px;
    --radius-small: 4px; /* Added for consistency */
	--container-max-width: 1240px;
	--header-height-rd: 75px;
	--transition-fast: 0.2s ease-in-out;
	--transition-smooth: 0.3s ease-in-out;
}

*, *::before, *::after {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

html {
	scroll-behavior: smooth;
	font-size: 16px;
}

body {
	font-family: var(--font-secondary);
	line-height: 1.7;
	color: var(--color-text-medium);
	background-color: var(--color-background-body);
	display: flex;
	flex-direction: column;
	min-height: 100vh;
}

.container-rd {
	width: 90%;
	max-width: var(--container-max-width);
	margin-left: auto;
	margin-right: auto;
	padding-left: 15px;
	padding-right: 15px;
}

h1, h2, h3, h4, h5, h6 {
	font-family: var(--font-primary);
	color: var(--color-text-dark);
	font-weight: 600;
	line-height: 1.3;
	margin-bottom: 0.75em;
}

a {
	color: var(--color-brand-primary);
	text-decoration: none;
	transition: color var(--transition-fast);
}

a:hover {
	color: var(--color-brand-primary-dark);
}

img {
	max-width: 100%;
	height: auto;
	display: block;
}

.btn-rd {
	display: inline-block;
	padding: 0.65rem 1.5rem;
	font-family: var(--font-primary);
	font-weight: 500;
	font-size: 0.95rem;
	text-align: center;
	border-radius: var(--radius-default);
	cursor: pointer;
	transition: all var(--transition-smooth);
	border: 1px solid transparent;
	text-decoration: none;
	line-height: 1.5;
}

.btn-primary-rd {
	background-color: var(--color-brand-primary);
	color: var(--color-text-on-dark);
	border-color: var(--color-brand-primary);
}

.btn-primary-rd:hover {
	background-color: var(--color-brand-primary-dark);
	border-color: var(--color-brand-primary-dark);
	color: var(--color-text-on-dark);
	transform: translateY(-2px);
	box-shadow: var(--shadow-soft);
}

.btn-secondary-rd { /* For View Full Cart in offcanvas */
    background-color: var(--color-background-section-alt);
    color: var(--color-text-medium);
    border-color: var(--color-border);
}
.btn-secondary-rd:hover {
    background-color: var(--color-border-light);
    color: var(--color-text-dark);
    border-color: var(--color-border-medium);
}


/* --- Reusable Site Header (from home_redesign.css, slightly adapted from productDetail's original) --- */
.site-header-rd {
	background-color: var(--color-background-card);
	box-shadow: var(--shadow-soft);
	position: sticky;
	top: 0;
	z-index: 1000;
	height: var(--header-height-rd);
	display: flex;
	align-items: center;
	padding: 0; /* Let container handle padding */
}

.header-main-rd {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 1rem;
	width: 100%;
	/* max-width: var(--container-max-width); Removed, as .container-rd handles this */
	/* margin: 0 auto; Removed */
}

.header-logo-rd {
	display: flex;
	align-items: center;
	text-decoration: none;
}

.header-logo-rd .logo-img-rd {
	height: 40px;
	margin-right: 0.6rem;
}

.header-logo-rd .logo-text-rd { /* Hidden in this version but kept for potential future use */
	font-family: var(--font-primary);
	font-size: 1.6rem;
	font-weight: 700;
	color: var(--color-brand-primary);
	display: none;
}

.header-search-rd {
	flex-grow: 1;
	max-width: 450px;
}

.header-search-rd .search-form-rd {
	display: flex;
	align-items: center;
	background-color: var(--color-background-body);
	border-radius: var(--radius-large);
	padding: 0.3rem 0.4rem 0.3rem 1rem;
	border: 1px solid var(--color-border-light);
}

.header-search-rd .search-input-rd {
	flex-grow: 1;
	border: none;
	background-color: transparent;
	padding: 0.4rem;
	font-size: 0.9rem;
	color: var(--color-text-medium);
}

.header-search-rd .search-input-rd:focus {
	outline: none;
}

.header-search-rd .search-button-rd {
	background: none;
	border: none;
	color: var(--color-text-light);
	padding: 0.4rem;
	cursor: pointer;
	display: flex;
	align-items: center;
}
.header-search-rd .search-button-rd svg { /* Targeting SVG directly for color change */
    transition: color var(--transition-fast); /* Smooth transition for icon color */
}
.header-search-rd .search-button-rd:hover svg {
	color: var(--color-brand-primary);
}

.header-actions-rd {
	display: flex;
	align-items: center;
	gap: 0.75rem; /* Consistent gap */
}

.header-actions-rd .user-greeting-rd {
	font-size: 0.9rem;
	color: var(--color-text-medium);
	white-space: nowrap;
	margin-right: 0.5rem;
	/* display: none; /* Control via media queries if needed */
}

.header-actions-rd .action-link-rd {
	color: var(--color-text-medium);
	padding: 0.5rem;
	position: relative;
	display: flex;
	align-items: center;
	border-radius: 50%;
	transition: background-color var(--transition-fast), color var(--transition-fast);
}

.header-actions-rd .action-link-rd:hover {
	background-color: var(--color-background-body);
	color: var(--color-brand-primary);
}

.header-actions-rd .cart-badge-rd {
	position: absolute;
	top: -2px;
	right: -4px;
	background-color: var(--color-brand-accent);
	color: white;
	font-size: 0.65rem;
	border-radius: 50%;
	width: 16px;
	height: 16px;
	display: flex; /* For centering text in badge */
	justify-content: center;
	align-items: center;
	font-weight: 600;
	border: 1px solid white;
}

/* Consistent Login/Register/Logout Button Styles */
.header-actions-rd .btn-rd { /* Base for header action buttons */
    font-size: 0.85rem;
    padding: 0.4rem 0.9rem;
    white-space: nowrap;
    text-decoration: none;
    border-radius: var(--radius-small); /* Consistent radius */
    display: inline-block;
    text-align: center;
    transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
    line-height: 1.5;
}
.header-actions-rd .pdp-style-login-btn { /* Login button */
    background-color: transparent;
    color: var(--color-brand-primary); /* Using main brand color */
    border: 2px solid var(--color-brand-primary);
}
.header-actions-rd .pdp-style-login-btn:hover {
    background-color: var(--color-brand-primary);
    color: var(--color-text-on-primary);
    border-color: var(--color-brand-primary);
}
.header-actions-rd .pdp-style-register-btn { /* Register button */
    background-color: var(--color-brand-primary);
    color: var(--color-text-on-primary);
    border: 2px solid var(--color-brand-primary);
}
.header-actions-rd .pdp-style-register-btn:hover {
    background-color: var(--color-brand-primary-dark);
    border-color: var(--color-brand-primary-dark);
    color: var(--color-text-on-primary);
}
.header-actions-rd .btn-logout-rd { /* Logout button */
    background-color: transparent;
    color: var(--color-brand-accent-dark); /* Using accent color */
    border: 1px solid var(--color-brand-accent-dark);
}
.header-actions-rd .btn-logout-rd:hover {
    background-color: var(--color-brand-accent-dark);
    color: white;
}


/* --- Main Content Area --- */
.main-content-pd { /* Changed from main-content-rd to avoid conflict if home_redesign.css is also linked */
	flex-grow: 1;
	padding-top: 2rem;
	padding-bottom: 3rem;
}

/* --- Product Detail Section --- */
.product-detail-card-rd {
	background-color: var(--color-background-card);
	padding: 2.5rem;
	border-radius: var(--radius-large);
	box-shadow: var(--shadow-medium);
	margin-top: 1.5rem;
}

.product-image-main-rd {
	width: 100%;
	max-height: 450px;
	object-fit: contain;
	border-radius: var(--radius-default);
	border: 1px solid var(--color-border-light);
	margin-bottom: 1rem; /* Spacing below image on small screens */
}

.product-info-pd h1 { /* Changed from product-info-rd to avoid conflict with card's .product-info-rd */
	font-size: 2.2rem;
	font-weight: 700;
	margin-bottom: 0.75rem;
	color: var(--color-text-dark);
}

.product-info-pd .category-tag-rd {
	font-size: 0.85rem;
	color: var(--color-text-light);
	margin-bottom: 0.75rem;
	display: inline-block;
	padding: 0.25rem 0.75rem;
	background-color: var(--color-background-body);
	border-radius: var(--radius-small);
	text-transform: capitalize;
}

.product-info-pd .price-tag-rd {
	font-size: 2rem;
	font-weight: 700;
	color: var(--color-brand-primary); /* Main brand color for price */
	margin-bottom: 1.25rem;
}

.product-info-pd .description-rd {
	color: var(--color-text-medium);
	line-height: 1.8;
	margin-bottom: 1.5rem;
	font-size: 0.95rem;
}

.product-info-pd .stock-status-rd {
	font-weight: 600;
	margin-bottom: 1.5rem;
	font-size: 1rem;
}

.stock-status-rd.in-stock-rd {
	color: var(--color-success); /* Use success color variable */
}

.stock-status-rd.out-of-stock-rd {
	color: var(--color-error); /* Use error color variable */
}

.add-to-cart-form-pd label {
	font-weight: 500;
	margin-right: 0.75rem;
	font-size: 0.9rem;
}

.add-to-cart-form-pd input[type="number"] {
	width: 65px;
	text-align: center;
	padding: 0.5rem;
	border: 1px solid var(--color-border);
	border-radius: var(--radius-small);
	margin-right: 0.75rem;
}

.add-to-cart-form-pd .btn-add-cart-pd {
	font-size: 1rem;
	padding: 0.6rem 1.5rem;
	background-color: var(--color-brand-accent); /* Accent color for Add to Cart */
	color: var(--color-text-on-dark);
	border-color: var(--color-brand-accent);
}

.add-to-cart-form-pd .btn-add-cart-pd:hover {
	background-color: var(--color-brand-accent-dark);
	border-color: var(--color-brand-accent-dark);
}

.add-to-cart-form-pd .btn-add-cart-pd:disabled {
	background-color: var(--color-text-light);
	border-color: var(--color-text-light);
	cursor: not-allowed;
}

.page-error-message-rd {
	color: var(--color-error);
	background-color: #fddede;
	border: 1px solid #f7c5c5;
	padding: 1.5rem;
	border-radius: var(--radius-default);
	text-align: center;
	margin-top: 2rem;
}

.page-error-message-rd .btn-back-rd {
	margin-top: 1rem;
}

/* --- Related Products Section --- */
.related-products-container-rd {
	margin-top: 3.5rem;
	padding-top: 2.5rem;
	border-top: 1px solid var(--color-border);
}

.related-products-container-rd h3.section-title-related-rd {
	text-align: center;
	font-size: 1.8rem;
	margin-bottom: 2.5rem;
	color: var(--color-text-dark);
}

.related-products-container-rd .product-grid-rd { /* Reusing product-grid-rd from home for consistency */
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); /* Adjusted minmax for related */
	gap: 1.5rem; /* Consistent gap */
	justify-content: center; /* Center items if they don't fill the row */
	padding-top: 1rem;
	padding-bottom: 1rem;
}

.product-card-rd { /* Reusing product-card-rd from home for consistency */
	background-color: var(--color-background-card);
	border-radius: var(--radius-default);
	box-shadow: var(--shadow-soft);
	overflow: hidden;
	transition: transform var(--transition-smooth), box-shadow var(--transition-smooth);
	display: flex;
	flex-direction: column;
	border: 1px solid transparent;
	height: 100%; /* Ensure cards in a row are same height if content varies */
}

.product-card-rd:hover {
	transform: translateY(-5px);
	box-shadow: var(--shadow-medium);
	border-color: var(--color-brand-primary-light); /* Use light primary for hover border */
}

.product-link-rd { /* Reusing from home */
	text-decoration: none;
	color: inherit;
	display: flex;
	flex-direction: column;
	flex-grow: 1;
}

.product-image-wrapper-rd { /* Reusing from home, slight adjustment for related products */
	background-color: var(--color-background-card);
	padding: 0.5rem;
	text-align: center;
	aspect-ratio: 1 / 1; /* Square for related product images */
	display: flex;
	align-items: center;
	justify-content: center;
	overflow: hidden;
}

.product-img-rd { /* Reusing from home */
	max-width: 100%;
	max-height: 150px; /* Max height for related product images */
	object-fit: contain;
	transition: transform var(--transition-smooth);
}

.product-card-rd:hover .product-img-rd {
	transform: scale(1.08);
}

.product-info-rd { /* This class is for the card's info section. productDetail page uses .product-info-pd */
	padding: 0.8rem 1rem; /* Padding for related product info */
	flex-grow: 1;
	text-align: left;
}

.product-name-rd { /* For related product cards */
	font-size: 0.95rem;
	font-weight: 600;
	color: var(--color-text-dark);
	margin-bottom: 0.3rem;
	line-height: 1.3;
	display: -webkit-box;
	-webkit-line-clamp: 2; /* Limit to 2 lines */
	-webkit-box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
	min-height: 2.6em; /* Approx 2 lines height */
}

.product-price-rd { /* For related product cards */
	font-size: 1.1rem;
	font-weight: 700;
	color: var(--color-brand-primary); /* Main brand color */
	margin-bottom: 0.5rem;
}

.product-actions-rd-related { /* Specific to related product card actions area */
	padding: 0 1rem 1rem 1rem;
	margin-top: auto; /* Pushes button to bottom */
}

.btn-view-details-related {
	width: 100%;
	background-color: transparent;
	color: var(--color-brand-primary);
	border: 1px solid var(--color-brand-primary);
	font-size: 0.85rem;
	padding: 0.5rem 0.8rem;
}

.btn-view-details-related:hover {
	background-color: var(--color-brand-primary);
	color: white;
}

/* --- Footer (Consistent with home.jsp) --- */
.site-footer-rd {
	background-color: #2c3e50;
	color: #bdc3c7;
	
	font-size: 0.9rem;
	margin-top: auto; /* Pushes footer to bottom */
}
.footer-content-rd {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 2.5rem;
	
}
.footer-column-rd h4 {
	font-size: 1.15rem;
	color: var(--color-text-on-dark);
	margin-bottom: 1.25rem;
	font-weight: 500;
	position: relative;
	padding-bottom: 0.5rem;
}
.footer-column-rd h4::after {
	content: '';
	position: absolute;
	left: 0;
	bottom: 0;
	width: 40px;
	height: 2px;
	background-color: var(--color-brand-accent);
}
.footer-logo-rd {
	height: 35px;
	margin-bottom: 1rem;
	filter: brightness(0) invert(0.8);
}
.footer-column-rd p {
	line-height: 1.8;
	margin-bottom: 0;
}
.footer-column-rd ul {
	list-style: none;
	padding-left: 0;
}
.footer-column-rd ul li a {
	color: #bdc3c7;
	padding: 0.25rem 0;
	display: block;
	transition: color var(--transition-fast), padding-left var(--transition-fast);
}
.footer-column-rd ul li a:hover {
	color: var(--color-brand-accent);
	padding-left: 8px;
}
.footer-bottom-rd {
	text-align: center;
	padding-top: 2rem;
	border-top: 1px solid #34495e;
	font-size: 0.85rem;
	color: #95a5a6;
}
/* Social links for footer if needed */
.social-links-rd a {
    color: #bdc3c7;
    font-size: 1.4rem;
    margin-right: 1.2rem;
    display: inline-block;
    transition: color var(--transition-fast), transform var(--transition-fast);
}
.social-links-rd a:hover {
    color: var(--color-brand-accent);
    transform: scale(1.15);
}
.mt-rd-2 { margin-top: 0.5rem; } /* Utility class */


/* --- Offcanvas Cart Styles (already defined, ensure consistency) --- */
.offcanvas {
	z-index: 1048; /* Default is 1045, modals are 1050/1055. Toasts are higher. */
}
.offcanvas-header {
	background-color: var(--color-background-section-alt); /* Consistent light grey */
	border-bottom: 1px solid var(--color-border);
}
.offcanvas-title {
	font-family: var(--font-primary);
	font-weight: 600;
	color: var(--color-text-dark);
}
.offcanvas-body {
	padding: 1.5rem;
	display: flex;
	flex-direction: column;
}
.empty-cart-display-rd {
	text-align: center;
	padding: 2rem 0;
	flex-grow: 1;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
}
.empty-cart-icon-rd {
	font-size: 4.5rem;
	color: var(--color-border); /* Softer color */
	margin-bottom: 1.5rem;
}
.empty-cart-display-rd p {
    color: var(--color-text-medium);
    margin-bottom: 1.5rem;
    font-size: 1.1rem;
}
.cart-items-list-rd {
	flex-grow: 1;
	overflow-y: auto;
	margin-bottom: 1.5rem;
    padding-right: 0.5rem; /* For scrollbar */
}
.cart-item-entry-rd {
	display: flex;
	align-items: center;
	gap: 1rem;
	padding: 1rem 0;
	border-bottom: 1px solid var(--color-border-light);
}
.cart-item-image-rd {
	width: 60px; /* Slightly larger */
	height: 60px;
	object-fit: cover;
	border-radius: var(--radius-small);
}
.cart-item-details-rd {
	flex-grow: 1;
}
.cart-item-name-rd {
	font-weight: 500;
	font-size: 0.9rem;
    color: var(--color-text-dark);
    margin-bottom: 0.2rem;
}
.cart-item-price-rd { /* For Qty x Price line */
	font-size: 0.8rem;
    color: var(--color-text-light);
}
.cart-item-subtotal-rd {
	font-weight: 600;
    font-size: 0.95rem; /* Consistent subtotal size */
    color: var(--color-text-dark);
}
.btn-remove-item-rd { /* For remove 'x' button */
	background: none;
	border: none;
	color: var(--color-error);
	cursor: pointer;
    padding: 0.3rem; /* Make it easier to click */
    font-size: 1rem; /* Icon size */
    transition: color var(--transition-fast);
}
.btn-remove-item-rd:hover {
    color: #a94442; /* Darker red */
}
.cart-total-section-rd {
	padding: 1.25rem 0;
	border-top: 2px solid var(--color-brand-primary); /* Primary color border */
	margin-top: 1rem; /* Ensure space from items list */
	text-align: right;
	font-size: 1.3rem; /* Larger total */
	font-weight: 700;
    color: var(--color-text-dark);
}
.cart-actions-buttons-rd {
	display: flex;
	flex-direction: column;
	gap: 0.75rem;
	margin-top: 1rem;
}
/* .btn-view-cart-rd and .btn-checkout-rd are covered by .btn-secondary-rd and .btn-primary-rd */

/* --- Toast Notifications CSS (from home.jsp for consistency) --- */
.toast-container-rd {
    position: fixed;
    bottom: 25px;
    right: 25px;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 12px;
}
.toast-notification-rd {
    background-color: var(--color-text-dark);
    color: var(--color-text-on-dark);
    padding: 14px 22px;
    border-radius: var(--radius-default);
    box-shadow: var(--shadow-medium);
    font-size: 0.95rem;
    display: flex;
    align-items: center;
    gap: 10px;
    opacity: 0;
    transform: translateX(110%);
    animation: slideInToastRd 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
.toast-notification-rd.success { background-color: var(--color-success); }
.toast-notification-rd.error { background-color: var(--color-error); }
.toast-notification-rd.info { background-color: var(--color-info); }
.toast-notification-rd i { font-size: 1.3em; }

@keyframes slideInToastRd { to { opacity: 1; transform: translateX(0); } }
@keyframes fadeOutToastRd {
    from { opacity: 1; transform: translateX(0); }
    to { opacity: 0; transform: translateX(110%); }
}

/* --- Custom Confirmation Popup Styles (from home.jsp) --- */
.popup-overlay-rd {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.6);
    display: none; /* JS will change to flex */
    justify-content: center;
    align-items: center;
    z-index: 20000; /* Very high z-index */
    opacity: 0;
    visibility: hidden;
    transition: opacity var(--transition-smooth), visibility 0s linear var(--transition-smooth);
}
.popup-overlay-rd.active {
    display: flex; /* Added by JS */
    opacity: 1;
    visibility: visible;
    transition: opacity var(--transition-smooth);
}
.popup-content-rd {
    background-color: var(--color-background-card);
    padding: 25px 30px;
    border-radius: var(--radius-large);
    box-shadow: var(--shadow-strong);
    width: 90%;
    max-width: 450px;
    text-align: center;
    transform: scale(0.9);
    transition: transform var(--transition-smooth);
}
.popup-overlay-rd.active .popup-content-rd {
    transform: scale(1);
}
.popup-title-rd {
    font-size: 1.4em;
    color: var(--color-text-dark);
    margin-bottom: 15px;
    font-weight: 600;
}
.popup-message-rd {
    margin-bottom: 25px;
    font-size: 1.05em;
    color: var(--color-text-medium);
    line-height: 1.6;
}
.popup-actions-rd {
    display: flex;
    justify-content: center;
    gap: 1rem;
}
.popup-actions-rd .btn-rd {
    padding: 0.6rem 1.5rem;
    min-width: 100px;
}
.btn-danger-rd { /* For confirm button in pop-up */
    background-color: var(--color-error);
    color: var(--color-text-on-dark);
    border-color: var(--color-error);
}
.btn-danger-rd:hover {
    background-color: #c9302c;
    border-color: #ac2925;
    color: var(--color-text-on-dark);
}

</style>
</head>
<body>

	<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
        <defs>
            <symbol id="icon-user" viewBox="0 0 24 24"><path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></symbol>
            <symbol id="icon-cart" viewBox="0 0 24 24"><path fill="currentColor" d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59L3.62 17H19v-2H7l1.1-2h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0 0 20 4H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></symbol>
            <symbol id="icon-search" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5A6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></symbol>
        </defs>
    </svg>

	<header class="site-header-rd">
		<div class="container-rd">
			<div class="header-main-rd">
				<div class="header-logo-rd">
					<a href="<%=contextPath%>/home"> <img
						src="<%=contextPath%>/images/logo.png" alt="FoodMart Logo"
						class="logo-img-rd"> <%-- <span class="logo-text-rd">FoodMart</span> --%>
					</a>
				</div>
				<div class="header-search-rd">
					<form id="search-form-header-pd" class="search-form-rd"
						action="<%=contextPath%>/SearchServlet" method="get">
						<input type="text" name="searchQuery" class="search-input-rd"
							placeholder="Search products..." />
						<button type="submit" class="search-button-rd" aria-label="Search">
							<svg width="20" height="20" viewBox="0 0 24 24">
								<use xlink:href="#icon-search"></use></svg>
						</button>
					</form>
				</div>
				<div class="header-actions-rd">
					<% if (loggedInUser != null) { %>
					    <span class="user-greeting-rd">Hello, <%=userNameForGreeting%>!</span>
                        <a href="<%=contextPath%>/profile" class="action-link-rd" aria-label="My Profile" title="My Profile">
                            <svg width="22" height="22" viewBox="0 0 24 24"><use xlink:href="#icon-user"></use></svg>
                        </a>
                        <a href="#" class="action-link-rd cart-trigger-rd" aria-label="My Cart" title="My Cart"
                           data-bs-toggle="offcanvas" data-bs-target="#offcanvasCart" aria-controls="offcanvasCart">
                            <svg width="22" height="22" viewBox="0 0 24 24"><use xlink:href="#icon-cart"></use></svg>
                            <% if (cartItemCount > 0) { %>
                                <span class="cart-badge-rd"><%=cartItemCount%></span>
                            <% } %>
                        </a>
                        <a href="<%=contextPath%>/logout" class="btn-rd btn-logout-rd">Logout</a>
					<% } else { %>
						<a href="<%=contextPath%>/login" class="btn-rd pdp-style-login-btn">Login</a>
                        <a href="<%=contextPath%>/register.jsp" class="btn-rd pdp-style-register-btn">Register</a>

					<% } %>
				</div>
			</div>
		</div>
	</header>

	<main class="container-rd main-content-pd">
		<%
		if (errorMessage != null && currentProduct == null) { // Only show page error if product is not found or major issue
		%>
		<div class="page-error-message-rd" role="alert">
			<i class="fas fa-exclamation-triangle"
				style="margin-right: 8px; font-size: 1.2em;"></i>
			<%=errorMessage%>
			<p style="margin-top: 1rem;">
				<a href="<%=contextPath%>/products"
					class="btn-rd btn-primary-rd btn-back-rd">Browse Products</a>
			</p>
		</div>
		<%
		} else if (currentProduct != null) {
		%>
		<div class="product-detail-card-rd">
			<div class="row">
				<div class="col-md-5 text-center">
					<%
					String imagePath = (currentProduct.getImageFileName() != null && !currentProduct.getImageFileName().isEmpty()
							&& !"placeholder.png".equals(currentProduct.getImageFileName())
							&& !"placeholder.jpg".equals(currentProduct.getImageFileName()))
							? contextPath + "/images/" + currentProduct.getImageFileName()
							: contextPath + "/images/placeholder.jpg";
					%>
					<img src="<%=imagePath%>"
						alt="<%=currentProduct.getProductName()%>"
						class="product-image-main-rd"
						onerror="this.src='<%=contextPath%>/images/placeholder.jpg';">
				</div>
				<div class="col-md-7 product-info-pd"> <%-- Changed to product-info-pd --%>
					<h1><%=currentProduct.getProductName()%></h1>
					<%
					if (currentProduct.getCategory() != null && !currentProduct.getCategory().isEmpty()) {
					%>
					<p class="category-tag-rd"><%=currentProduct.getCategory()%></p>
					<%
					}
					%>
					<p class="price-tag-rd">
						₹<%=currentProduct.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP)%></p>
					<p class="description-rd"><%=currentProduct.getProductDescription()%></p>

					<%
					if (!currentProduct.isAvailable() && (loggedInUser == null || !"ADMIN".equals(userRoleForPage))) {
					%>
					<p class="stock-status-rd out-of-stock-rd">This product is
						currently unavailable.</p>
                    <% if (errorMessage != null && currentProduct.isAvailable() == false) { // Show specific error if product is unavailable %>
                        <p class="text-danger small mt-1"><%= errorMessage %></p>
                    <% } %>
					<%
					} else if (currentProduct.getAvailableQuantity() > 0) {
					%>
					
					<form class="add-to-cart-form-pd mt-3"
						action="<%=contextPath%>/cart.jsp" method="post">
						<input type="hidden" name="action" value="ADD"> <input
							type="hidden" name="productId"
							value="<%=currentProduct.getProductId()%>">
						<input type="hidden" name="returnUrl"
							value="<%=request.getRequestURI() + "?id=" + currentProduct.getProductId()%>">
						<div class="d-flex align-items-center">
							<label for="quantity_detail_<%=currentProduct.getProductId()%>">Quantity:</label>
							<input type="number" name="quantity"
								id="quantity_detail_<%=currentProduct.getProductId()%>"
								value="1" min="1"
								max="<%=currentProduct.getAvailableQuantity()%>" required
                                <% if (!currentProduct.isAvailable()) out.print("disabled"); %> >
							<button type="submit" class="btn-rd btn-add-cart-pd ms-2"
                                <% if (!currentProduct.isAvailable()) out.print("disabled"); %> >
								<i class="fas fa-cart-plus me-2"></i>Add to Cart
							</button>
						</div>
					</form>
					<%
					} else { // Available quantity is 0
					%>
					<p class="stock-status-rd out-of-stock-rd">Out of Stock</p>
					<%
					}
					%>
					<%
					if (loggedInUser != null && "ADMIN".equals(userRoleForPage) && !currentProduct.isAvailable()) {
					%>
					<p class="stock-status-rd out-of-stock-rd"
						style="font-weight: normal; color: #777; font-size: 0.9em; margin-top: 0.5rem;">(Admin
						view: Product is marked as unavailable)</p>
					<%
					}
					%>
				</div>
			</div>
		</div>

		<%-- Related Products Section --%>
		<%
		if (!relatedProducts.isEmpty()) {
		%>
		<section class="related-products-container-rd">
			<h3 class="section-title-related-rd">You Might Also Like</h3>
			<div class="product-grid-rd"> 
				<%
				for (Product relatedProd : relatedProducts) {
				%>
				<div class="product-card-rd"> 
					<a
						href="<%=contextPath%>/productDetail?id=<%=relatedProd.getProductId()%>"
						class="product-link-rd"> 
						<div class="product-image-wrapper-rd"> 
							<%
							String relatedImagePath = (relatedProd.getImageFileName() != null && !relatedProd.getImageFileName().isEmpty()
									&& !"placeholder.png".equals(relatedProd.getImageFileName())
									&& !"placeholder.jpg".equals(relatedProd.getImageFileName()))
									? contextPath + "/images/" + relatedProd.getImageFileName()
									: contextPath + "/images/placeholder.jpg";
							%>
							<img src="<%=relatedImagePath%>"
								alt="<%=relatedProd.getProductName()%>" class="product-img-rd" /* Using .product-img-rd */
								onerror="this.src='<%=contextPath%>/images/placeholder.jpg';">
						</div>
						<div class="product-info-rd"> 
							<h5 class="product-name-rd"><%=relatedProd.getProductName()%></h5>
							<p class="product-price-rd">
								₹<%=relatedProd.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP)%></p>
						</div>
					</a>
					<div class="product-actions-rd-related">
						<a
							href="<%=contextPath%>/productDetail?id=<%=relatedProd.getProductId()%>"
							class="btn-rd btn-view-details-related"> View Details </a>
					</div>
				</div>
				<%
				}
				%>
			</div>
		</section>
		<%
		}
		%>

		<%
		} else if (errorMessage == null && currentProduct == null) { // Fallback if no product and no specific error
		%>
		<div class="page-error-message-rd" role="alert">
			<i class="fas fa-exclamation-triangle"
				style="margin-right: 8px; font-size: 1.2em;"></i> Sorry, we couldn't
			find the product you're looking for.
			<p style="margin-top: 1rem;">
				<a href="<%=contextPath%>/products"
					class="btn-rd btn-primary-rd btn-back-rd">Browse Other Products</a>
			</p>
		</div>
		<%
		}
		%>
	</main>

	<footer class="site-footer-rd">
		
			<div class="footer-content-rd">
				
				
			<div class="footer-bottom-rd">
			<div class="footer-column-rd">
                    
					
				</div>
				<p>Your favorite online grocery store, committed to bringing you the best.</p>
				<p>
					&copy; <%=new java.text.SimpleDateFormat("yyyy").format(new java.util.Date())%>
					FoodMart. All Rights Reserved.
				</p>
			</div>
		</div>
	</footer>


	<div class="offcanvas offcanvas-end" data-bs-scroll="true"
		tabindex="-1" id="offcanvasCart" aria-labelledby="offcanvasCartLabel">
		<div class="offcanvas-header">
			<h5 class="offcanvas-title" id="offcanvasCartLabel">Your Shopping Cart</h5>
			<button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
		</div>
		<div class="offcanvas-body">
			<%-- Use cartActionMessage for in-panel alerts --%>
			<%
			if (cartActionMessage != null && !cartActionMessage.isEmpty() && !cartActionMessage.toLowerCase().contains("added to cart") && !cartActionMessage.toLowerCase().contains("updated in cart") && !cartActionMessage.toLowerCase().contains("removed from cart")) {
			%>
			<div class="alert <%=cartActionMessage.toLowerCase().contains("error") ? "alert-danger" : "alert-success"%> alert-dismissible fade show" role="alert">
				<%=cartActionMessage%>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			</div>
			<%
			}
			%>

			<% if (cartItems.isEmpty()) { %>
			<div class="empty-cart-display-rd">
				<i class="fas fa-shopping-basket empty-cart-icon-rd"></i>
				<p>Your cart is currently empty.</p>
				<button type="button" class="btn-rd btn-primary-rd" data-bs-dismiss="offcanvas">Continue Shopping</button>
			</div>
			<% } else { %>
			<ul class="list-unstyled cart-items-list-rd">
				<% for (CartItem item : cartItems) { %>
				<li class="cart-item-entry-rd">
                    <img src="<%=contextPath%>/images/<%=(item.getImageFileName() != null && !item.getImageFileName().isEmpty() ? item.getImageFileName() : "placeholder_product_foodmart.jpg")%>"
						 alt="<%=item.getProductName()%>" class="cart-item-image-rd"
						 onerror="this.src='<%=contextPath%>/images/placeholder_product_foodmart.jpg';">
					<div class="cart-item-details-rd">
						<div class="cart-item-name-rd"><%=item.getProductName()%></div>
						<div class="cart-item-price-rd">
							Qty: <%=item.getQuantity()%> &times; ₹<%=item.getUnitPrice().setScale(2)%>
                        </div>
					</div>
					<div class="cart-item-subtotal-rd">
						₹<%=item.getSubtotal().setScale(2)%>
                    </div>
					<form action="<%=contextPath%>/CartServlet" method="post" class="remove-item-form-rd d-inline">
						<input type="hidden" name="action" value="REMOVE">
                        <input type="hidden" name="productId" value="<%=item.getProductId()%>">
						<input type="hidden" name="returnUrl" value="<%=request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "")%>">
						<%-- Updated button for confirmation pop-up --%>
                        <button type="button" class="btn-remove-item-rd js-confirm-cart-action"
                                data-action-message="Remove <%= item.getProductName().replace("\"", "&quot;").replace("'", "\\'") %> from your cart"
                                aria-label="Remove item">
							<i class="fas fa-times"></i>
						</button>
					</form>
                </li>
				<% } %>
			</ul>
			<div class="cart-total-section-rd">
				<strong>Total: ₹<%=cartTotal.setScale(2)%></strong>
			</div>
			<div class="cart-actions-buttons-rd">
				<a href="<%=contextPath%>/cart.jsp" class="btn-rd btn-secondary-rd btn-view-cart-rd">View Full Cart</a>
				<form action="<%=contextPath%>/cart.jsp" method="get" style="display: contents;">
					<input type="hidden" name="amount" value="<%=cartTotal.setScale(2)%>">
					<button type="submit" class="btn-rd btn-primary-rd btn-checkout-rd" <%=cartItems.isEmpty() ? "disabled" : ""%>>
                        Proceed to Checkout
                    </button>
				</form>
			</div>
			<% } %>
		</div>
	</div>

    <%-- Confirmation Modal HTML (from home.jsp) --%>
    <div id="customActionConfirmModal" class="popup-overlay-rd">
        <div class="popup-content-rd">
            <h4 id="confirmModalTitle" class="popup-title-rd">Confirm Action</h4>
            <p id="confirmModalMessage" class="popup-message-rd">Are you sure?</p>
            <div class="popup-actions-rd">
                <button id="confirmModalConfirmBtn" class="btn-rd btn-danger-rd">Confirm</button>
                <button id="confirmModalCancelBtn" class="btn-rd btn-secondary-rd">Cancel</button>
            </div>
        </div>
    </div>

    <%-- Toast container --%>
    <div id="toastBox" class="toast-container-rd"></div>


	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
	<script>
        // --- Custom Action Confirmation Modal Logic (from home.jsp) ---
        const customActionConfirmModal = document.getElementById('customActionConfirmModal');
        const confirmModalTitle = document.getElementById('confirmModalTitle');
        const confirmModalMessage = document.getElementById('confirmModalMessage');
        const confirmModalConfirmBtn = document.getElementById('confirmModalConfirmBtn');
        const confirmModalCancelBtn = document.getElementById('confirmModalCancelBtn');
        let formToSubmitForAction = null;

        function showActionConfirmPopup(message, title, formElement) {
            if (!customActionConfirmModal) return;
            confirmModalMessage.textContent = message || 'Are you sure you want to proceed?';
            confirmModalTitle.textContent = title || 'Confirm Action';
            formToSubmitForAction = formElement;

            customActionConfirmModal.style.display = 'flex'; // Show first
            setTimeout(() => {
                customActionConfirmModal.classList.add('active'); // Then trigger transition
            }, 10);
        }

        function hideActionConfirmPopup() {
            if (!customActionConfirmModal) return;
            customActionConfirmModal.classList.remove('active');
            setTimeout(() => {
                customActionConfirmModal.style.display = 'none';
            }, 300); // Match CSS transition duration
            formToSubmitForAction = null;
        }

        function initializeConfirmationButtons() {
             document.querySelectorAll('.js-confirm-cart-action').forEach(button => {
                // Remove existing listener to prevent duplicates if this function is called multiple times
                button.removeEventListener('click', handleConfirmActionClick);
                button.addEventListener('click', handleConfirmActionClick);
            });
        }

        function handleConfirmActionClick(event) {
            event.preventDefault();
            const actionMessage = this.dataset.actionMessage || "perform this action";
            const confirmMessage = `Are you sure you want to remove the item from cart ${actionMessage}?`;
            const parentForm = this.closest('form');
            if (parentForm) {
                showActionConfirmPopup(confirmMessage, 'Confirm Removal', parentForm);
            } else {
                console.error("Could not find parent form for the action button.");
            }
        }


        if (confirmModalConfirmBtn) {
            confirmModalConfirmBtn.addEventListener('click', function() {
                if (formToSubmitForAction) {
                    formToSubmitForAction.submit();
                }
                hideActionConfirmPopup();
            });
        }

        if (confirmModalCancelBtn) {
            confirmModalCancelBtn.addEventListener('click', function() {
                hideActionConfirmPopup();
            });
        }

        if (customActionConfirmModal) {
            customActionConfirmModal.addEventListener('click', function(event) {
                if (event.target === customActionConfirmModal) {
                    hideActionConfirmPopup();
                }
            });
        }

        // --- Toast Notification Logic (consistent with home.jsp's updated version) ---
        function showToast(msgContent, isError) {
            let toast = document.createElement("div");
            toast.classList.add("toast-notification-rd");

            let iconClass = "fas fa-check-circle"; // Default success
            let toastTypeClass = "success";

            if (isError) {
                iconClass = "fas fa-exclamation-circle";
                toastTypeClass = "error";
            } else if (msgContent.toLowerCase().includes("remove")) {
                iconClass = "fas fa-info-circle";
                toastTypeClass = "info";
            } else if (msgContent.toLowerCase().includes("update")) {
                 iconClass = "fas fa-info-circle";
                 toastTypeClass = "info";
            }

            toast.classList.add(toastTypeClass);
            toast.innerHTML = `<i class="${iconClass}"></i> ${msgContent}`;

            let toastContainer = document.getElementById('toastBox');
            if (!toastContainer) {
                toastContainer = document.createElement('div');
                toastContainer.id = 'toastBox';
                toastContainer.className = 'toast-container-rd';
                document.body.appendChild(toastContainer);
            }
            toastContainer.appendChild(toast);

            setTimeout(() => {
                toast.style.animation = 'fadeOutToastRd 0.5s forwards';
                toast.addEventListener('animationend', () => {
                    toast.remove();
                });
            }, 3000);
        }

		document.addEventListener('DOMContentLoaded', function() {
			var cartBadge = document.querySelector('.cart-badge-rd');
			if (cartBadge) {
				var itemCount = <%=cartItemCount%>;
				if (itemCount > 0) {
					cartBadge.innerText = itemCount;
					cartBadge.style.display = 'flex'; // Use flex for centering
				} else {
					cartBadge.style.display = 'none';
				}
			}

			// Handle server-side cart action messages for toast
			<%if (cartActionMessage != null && !cartActionMessage.isEmpty()) {%>
				showToast("<%=cartActionMessage.replace("\"", "\\\"").replace("'", "\\'")%>", <%=cartActionMessage.toLowerCase().contains("error")%>);
			<%}%>

            // Initialize confirmation buttons for dynamically loaded offcanvas content
            const offcanvasCartElement = document.getElementById('offcanvasCart');
            if (offcanvasCartElement) {
                 // Initial call for any static buttons
                initializeConfirmationButtons();
                // Re-initialize if Bootstrap's offcanvas fires a 'shown' event
                offcanvasCartElement.addEventListener('shown.bs.offcanvas', function () {
                    initializeConfirmationButtons();
                });
            }
		});
	</script>
</body>
</html>
