<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.List, java.util.ArrayList, com.gms.model.User, com.gms.model.Product, com.gms.model.CartItem, java.math.BigDecimal, java.net.URLEncoder"%>

<%
// --- User and Page Data ---
String userNameForGreeting = (String) request.getAttribute("userNameForGreeting");
if (userNameForGreeting == null || userNameForGreeting.trim().isEmpty()) {
	userNameForGreeting = "Valued Customer"; // Fallback
}

List<Product> productList = (List<Product>) request.getAttribute("productList");
if (productList == null) {
	productList = new ArrayList<>();
}

List<String> categoryList = (List<String>) request.getAttribute("categoryList");
if (categoryList == null) {
	categoryList = new ArrayList<>();
}

String contextPath = request.getContextPath();

// --- Cart Data ---
HttpSession currentSession = request.getSession(false);
User loggedInUser = null;
if (currentSession != null && currentSession.getAttribute("loggedInUser") != null) {
	loggedInUser = (User) currentSession.getAttribute("loggedInUser");
	if (loggedInUser.getUserName() != null && !loggedInUser.getUserName().trim().isEmpty()) {
		userNameForGreeting = loggedInUser.getUserName();
	}
}

List<CartItem> cartItems = new ArrayList<>();
BigDecimal cartTotal = BigDecimal.ZERO;
int cartItemCount = 0;

if (currentSession != null) {
	List<CartItem> sessionCart = (List<CartItem>) currentSession.getAttribute("cart");
	if (sessionCart != null) {
		cartItems.addAll(sessionCart);
		cartItemCount = cartItems.size(); // Correctly get cart item count
	}
	BigDecimal sessionCartTotal = (BigDecimal) currentSession.getAttribute("cartTotal");
	if (sessionCartTotal != null) {
		cartTotal = sessionCartTotal;
	}
}
cartTotal = cartTotal.setScale(2, BigDecimal.ROUND_HALF_UP);

String cartMessage = null; // This is used for toast and in-panel messages on home.jsp
if (currentSession != null) {
	cartMessage = (String) currentSession.getAttribute("cartMessage");
	if (cartMessage != null) {
		currentSession.removeAttribute("cartMessage"); // Clear after retrieving
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Welcome to FoodMart, <%=userNameForGreeting%>!
</title>

<%-- Fonts --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=Open+Sans:wght@300;400;600;700&display=swap"
	rel="stylesheet">


<%-- Libraries CSS --%>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.css" />
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<%-- Updated Font Awesome --%>
<%-- Bootstrap CSS (if not already included or if using a different version than productDetail.jsp) --%>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css"
	rel="stylesheet">


<style>
@import
	url('https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=Open+Sans:wght@300;400;600;700&display=swap')
	;

/* --- CSS Variables --- */
:root {
	--font-primary: 'Montserrat', sans-serif;
	--font-secondary: 'Open Sans', sans-serif;
	--color-brand-primary: #5cb85c; /* A fresh, friendly green */
	--color-brand-primary-dark: #4cae4c;
	--color-brand-primary-light: #dff0d8;
	--color-brand-accent: #4CAF50; /* A warm, inviting orange/yellow */
	--color-brand-accent-dark: #45a049; /* Darker accent for hover */
	--color-text-dark: #333740;
	--color-text-medium: #555b68;
	--color-text-light: #888f99;
	--color-text-on-dark: #ffffff;
	--color-text-on-primary: #ffffff;
	--color-background-body: #f9fafb;
	/* Very light grey for overall page */
	--color-background-card: #ffffff;
	--color-background-section-alt: #f0f2f5;
	/* Slightly darker grey for alternating sections */
	--color-border: #e1e4e8;
	--color-border-light: #ebeef0;
	--color-border-medium: #d1d5db; /* Added for out of stock button */
	--color-success: #5cb85c;
	--color-error: #d9534f;
	--color-info: #5bc0de;
	--shadow-soft: 0 2px 8px rgba(0, 0, 0, 0.07);
	--shadow-medium: 0 5px 15px rgba(0, 0, 0, 0.1);
	--shadow-strong: 0 8px 25px rgba(0, 0, 0, 0.12);
	--radius-default: 8px;
	--radius-large: 12px;
	--radius-small: 4px;
	--container-max-width: 1240px;
	--header-height-rd: 75px;
	--transition-fast: 0.2s ease-in-out;
	--transition-smooth: 0.3s ease-in-out;
}

/* --- Global Resets & Base Styles --- */
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
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	display: flex; /* Added for footer push */
	flex-direction: column; /* Added for footer push */
	min-height: 100vh; /* Added for footer push */
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
	margin-bottom: 0.75em; /* Default bottom margin for headings */
}

a {
	color: var(--color-brand-primary);
	text-decoration: none;
	transition: color var(--transition-fast);
}

a:hover {
	color: var(--color-brand-primary-dark);
	text-decoration: none;
	/* Often prefer no underline on hover for modern look */
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
	line-height: 1.5; /* Ensure text is centered vertically */
}

.btn-primary-rd {
	background-color: var(--color-brand-primary);
	color: var(--color-text-on-primary);
	border-color: var(--color-brand-primary);
}

.btn-primary-rd:hover {
	background-color: var(--color-brand-primary-dark);
	border-color: var(--color-brand-primary-dark);
	color: var(--color-text-on-primary);
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

.py-rd-5 {
	padding-top: 4rem;
	padding-bottom: 4rem;
}

.mt-rd-2 {
	margin-top: 0.5rem;
}

.mt-rd-4 {
	margin-top: 1.5rem;
}

.text-center-rd {
	text-align: center;
}

.text-muted-rd {
	color: var(--color-text-light);
}

.col-12-rd {
	width: 100%;
} /* Basic grid helper */

/* --- Site Header Redesign --- */
.site-header-rd {
	background-color: var(--color-background-card);
	padding: 0; /* Let container handle padding */
	box-shadow: var(--shadow-soft);
	position: sticky;
	top: 0;
	z-index: 1000; /* Header z-index */
	height: var(--header-height-rd);
	display: flex;
	align-items: center;
}

.header-main-rd {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 1rem;
	width: 100%;
}

.header-logo-rd {
	display: flex;
	align-items: center;
	text-decoration: none;
}

.header-logo-rd .logo-img-rd {
	height: 40px; /* Adjust */
	margin-right: 0.6rem;
}

.header-logo-rd .logo-text-rd {
	font-family: var(--font-primary);
	font-size: 1.6rem;
	font-weight: 700;
	color: var(--color-brand-primary);
}

.header-search-rd {
	flex-grow: 1;
	max-width: 450px;
}

.header-search-rd .search-form-rd {
	display: flex;
	align-items: center;
	background-color: var(--color-background-body);
	border-radius: var(--radius-large); /* More rounded search bar */
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

.header-search-rd .search-button-rd:hover svg {
	color: var(--color-brand-primary);
}

.header-actions-rd {
	display: flex;
	align-items: center;
	gap: 0.75rem;
}

.header-actions-rd .user-greeting-rd {
	font-size: 0.9rem;
	color: var(--color-text-medium);
	white-space: nowrap;
	margin-right: 0.5rem;
}

.header-actions-rd .action-link-rd {
	color: var(--color-text-medium);
	padding: 0.5rem;
	position: relative;
	display: flex;
	align-items: center;
	border-radius: 50%; /* Make icon links circular */
	transition: background-color var(--transition-fast);
}

.header-actions-rd .action-link-rd:hover {
	background-color: var(--color-background-body);
	color: var(--color-brand-primary); /* Icon color change on hover */
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
	display: flex; /* Use flex for centering */
	justify-content: center;
	align-items: center;
	font-weight: 600;
	border: 1px solid white;
}

/* Login/Logout button styles from productDetail.jsp for consistency */
.header-actions-rd .btn-rd { /* Base for header action buttons */
	font-size: 0.85rem;
	padding: 0.4rem 0.9rem;
	white-space: nowrap;
	text-decoration: none;
	border-radius: 4px;
	display: inline-block;
	text-align: center;
	transition: background-color 0.2s ease, color 0.2s ease, border-color
		0.2s ease;
	line-height: 1.5;
}

.header-actions-rd .pdp-style-login-btn { /* Login button */
	background-color: transparent;
	color: var(--color-brand-primary);
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
	color: var(--color-brand-accent-dark);
	border: 1px solid var(--color-brand-accent-dark);
}

.header-actions-rd .btn-logout-rd:hover {
	background-color: var(--color-brand-accent-dark);
	color: white;
}

/* --- Hero Section Redesign --- */
.hero-main-rd {
	background-size: cover;
	background-position: center 70%; /* Adjust vertical position */
	color: var(--color-text-on-dark);
	padding: 7rem 0;
	text-align: left; /* Align text to left for a common modern look */
	position: relative;
	min-height: calc(100vh - var(--header-height-rd)- 100px);
	/* Example height */
	display: flex;
	align-items: center;
}

.hero-overlay-rd { /* Darker overlay for better text contrast */
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.55);
	z-index: 1;
}

.hero-content-rd {
	position: relative; /* Above overlay */
	z-index: 2;
	max-width: 600px;
	/* animation: fadeInSlideUp 1s ease-out 0.2s backwards; Removed for brevity, can be added back */
}

.hero-title-rd {
	font-size: clamp(2.8rem, 6vw, 4.2rem);
	font-weight: 700; /* Slightly less bold than before for Montserrat */
	margin-bottom: 1.2rem;
	line-height: 1.2;
	color: var(--color-text-on-dark);
}

.hero-subtitle-rd {
	font-size: clamp(1.1rem, 3vw, 1.4rem);
	margin-bottom: 2.5rem;
	opacity: 0.95;
	font-weight: 300;
	max-width: 550px;
}

.btn-hero-rd {
	background-color: var(--color-brand-accent);
	color: var(--color-text-on-dark);
	padding: 0.8rem 2.2rem;
	font-size: 1.05rem;
	font-weight: 600;
	border-radius: var(--radius-default);
	box-shadow: var(--shadow-medium);
}

.btn-hero-rd:hover {
	background-color: var(--color-brand-accent-dark);
	color: var(--color-text-on-dark);
	transform: translateY(-2px);
	box-shadow: var(--shadow-strong);
}

/* --- Section Title Redesign --- */
.section-title-rd {
	font-size: clamp(2rem, 4.5vw, 2.8rem);
	font-weight: 700;
	text-align: center;
	margin-bottom: 3.5rem;
	position: relative;
	color: var(--color-text-dark);
}

.section-title-rd span {
	position: relative;
	padding-bottom: 0.5rem;
}

.section-title-rd span::after {
	content: '';
	position: absolute;
	bottom: -8px; /* Slightly lower */
	left: 50%;
	transform: translateX(-50%);
	width: 80px; /* Wider underline */
	height: 5px;
	background-color: var(--color-brand-accent);
	/* Accent color for underline */
	border-radius: 3px;
}

/* --- Category Carousel Redesign --- */
.category-carousel-container-rd {
	position: relative;
	padding: 0 10px; /* Give some space for shadow/overflow */
}

.category-swiper-rd {
	padding-top: 10px;
	padding-bottom: 50px; /* Space for navigation */
}

.category-card-rd {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	text-align: center;
	padding: 1.25rem 0.75rem;
	background-color: var(--color-background-card);
	border-radius: var(--radius-large); /* More rounded */
	box-shadow: var(--shadow-soft);
	transition: transform var(--transition-smooth), box-shadow
		var(--transition-smooth);
	text-decoration: none;
	height: 160px;
	border: 1px solid var(--color-border-light);
}

.category-card-rd:hover {
	transform: translateY(-6px);
	box-shadow: var(--shadow-medium);
	border-color: var(--color-brand-primary);
}

.category-icon-rd {
	font-size: 2.8rem; /* Larger icons */
	color: var(--color-brand-primary);
	margin-bottom: 0.8rem;
	line-height: 1; /* Ensure icon is centered if it's text-based */
	transition: color var(--transition-fast);
}

.category-card-rd:hover .category-icon-rd {
	color: var(--color-brand-accent);
}

.category-name-rd {
	font-size: 0.95rem;
	font-weight: 500;
	color: var(--color-text-medium);
}

/* Swiper Navigation Buttons */
.swiper-button-next-rd, .swiper-button-prev-rd {
	color: var(--color-brand-primary);
	background-color: rgba(255, 255, 255, 0.9);
	border-radius: 50%;
	width: 40px;
	height: 40px;
	box-shadow: var(--shadow-soft);
	transition: background-color var(--transition-fast), color
		var(--transition-fast), box-shadow var(--transition-fast);
	position: absolute;
	top: calc(10px + ( 160px/ 2));
	transform: translateY(-50%);
	z-index: 10;
	display: flex;
	align-items: center;
	justify-content: center;
}

.swiper-button-prev-rd {
	left: -5px;
}

.swiper-button-next-rd {
	right: -5px;
}

.swiper-button-next-rd:hover, .swiper-button-prev-rd:hover {
	background-color: var(--color-brand-primary);
	color: white;
	box-shadow: var(--shadow-medium);
}

.swiper-button-next-rd::after, .swiper-button-prev-rd::after {
	font-size: 1rem;
	font-weight: 600;
}

/* --- Product Grid Redesign --- */
.section-products-rd {
	background-color: var(--color-background-section-alt);
	/* Alternating bg */
}

.product-grid-rd {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	/* Slightly wider cards */
	gap: 2rem;
}

.product-card-rd {
	background-color: var(--color-background-card);
	border-radius: var(--radius-default);
	box-shadow: var(--shadow-soft);
	overflow: hidden;
	transition: transform var(--transition-smooth), box-shadow
		var(--transition-smooth);
	display: flex;
	flex-direction: column;
	border: 1px solid transparent; /* For hover effect */
}

.product-card-rd:hover {
	transform: translateY(-5px);
	box-shadow: var(--shadow-medium);
	border-color: var(--color-brand-primary-light);
}

.product-link-rd {
	text-decoration: none;
	color: inherit;
	display: flex;
	flex-direction: column;
	flex-grow: 1;
}

.product-image-wrapper-rd {
	background-color: var(--color-background-card); /* Cleaner look */
	padding: 0.5rem; /* Less padding */
	text-align: center;
	aspect-ratio: 4/3; /* More rectangular aspect ratio */
	display: flex;
	align-items: center;
	justify-content: center;
	overflow: hidden; /* Ensure image doesn't break out */
}

.product-img-rd {
	max-width: 100%;
	max-height: 180px; /* Max height for consistency */
	object-fit: contain;
	transition: transform var(--transition-smooth);
}

.product-card-rd:hover .product-img-rd {
	transform: scale(1.08);
}

.product-info-rd { /* Used in product card */
	padding: 1rem 1.25rem;
	flex-grow: 1;
	text-align: left; /* Align text left */
}

.product-category-rd {
	font-size: 0.75rem;
	color: var(--color-text-light);
	margin-bottom: 0.25rem;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	font-weight: 500;
}

.product-name-rd { /* Used in product card */
	font-size: 1.05rem;
	font-weight: 600;
	color: var(--color-text-dark);
	margin-bottom: 0.4rem;
	line-height: 1.4;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
	min-height: 2.9em; /* Approx 2 lines */
}

.product-price-rd { /* Used in product card */
	font-size: 1.4rem;
	font-weight: 700;
	color: var(--color-brand-primary);
	margin-bottom: 0.75rem;
}

.product-actions-rd { /* Used in product card */
	padding: 0 1.25rem 1.25rem 1.25rem;
	margin-top: auto; /* Pushes actions to bottom of card */
}

.btn-add-to-cart-rd {
	width: 100%;
	background-color: var(--color-brand-accent);
	color: var(--color-text-on-dark);
	font-size: 0.9rem;
	padding: 0.7rem 1rem;
	border-color: var(--color-brand-accent);
}

.btn-add-to-cart-rd:hover {
	background-color: var(--color-brand-accent-dark);
	border-color: var(--color-brand-accent-dark);
	color: var(--color-text-on-dark);
}

.btn-add-to-cart-rd i {
	margin-right: 0.5rem;
}

.btn-out-of-stock-rd {
	width: 100%;
	background-color: var(--color-border-light);
	color: var(--color-text-light);
	border: 1px solid var(--color-border-medium);
	font-size: 0.9rem;
	padding: 0.7rem 1rem;
	cursor: not-allowed;
}

.product-stock-alert-rd {
	position: absolute;
	top: 10px;
	right: 10px;
	background-color: var(--color-error);
	color: white;
	padding: 0.2rem 0.5rem;
	font-size: 0.75rem;
	border-radius: var(--radius-small);
	font-weight: 500;
}

.btn-view-all-rd {
	background-color: var(--color-brand-primary);
	color: white;
	font-weight: 500;
	padding: 0.8rem 2rem;
}

.btn-view-all-rd:hover {
	background-color: var(--color-brand-primary-dark);
	color: white;
}

/* --- Service Promises Redesign --- */
.section-promises-rd {
	background-color: var(--color-background-card);
	/* White background for this section */
}

.promises-grid-rd {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
	gap: 2rem;
	margin-top: 1rem; /* Reduced top margin as title has more */
}

.promise-item-rd {
	text-align: center;
	padding: 2rem 1.5rem;
}

.promise-icon-rd {
	font-size: 3rem;
	color: var(--color-brand-accent);
	margin-bottom: 1.25rem;
	display: inline-block;
	transition: transform var(--transition-smooth);
}

.promise-item-rd:hover .promise-icon-rd {
	transform: scale(1.1) rotate(-5deg);
}

.promise-title-rd {
	font-size: 1.3rem;
	font-weight: 600;
	margin-bottom: 0.6rem;
	color: var(--color-text-dark);
}

.promise-desc-rd {
	font-size: 0.95rem;
	color: var(--color-text-medium);
	line-height: 1.6;
}

/* --- Footer Redesign --- */
.site-footer-rd {
	background-color: #2c3e50; /* Dark blue/grey footer */
	color: #bdc3c7;
	font-size: 0.9rem;
	margin-top: auto; /* Pushes footer to bottom */
}

.footer-content-rd {
	display: grid;
	grid-template-rows: repeat(auto-fit, minmax(200px, 1fr));
	gap: 2.5rem;
	margin-bottom: 2.5rem;
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
	filter: brightness(0) invert(0.8); /* Adjust to look good on dark bg */
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
	transition: color var(--transition-fast), padding-left
		var(--transition-fast);
}

.footer-column-rd ul li a:hover {
	color: var(--color-brand-accent);
	padding-left: 8px;
}

.social-links-rd a {
	color: #bdc3c7;
	font-size: 1.4rem;
	margin-right: 1.2rem;
	display: inline-block;
	transition: color var(--transition-fast), transform
		var(--transition-fast);
}

.social-links-rd a:hover {
	color: var(--color-brand-accent);
	transform: scale(1.15);
}

.footer-bottom-rd {
	text-align: center;
	padding-top: 2rem;
	border-top: 1px solid #34495e; /* Slightly lighter border */
	font-size: 0.85rem;
	color: #95a5a6; /* Muted color for copyright */
}

/* --- Offcanvas Cart Redesign (from productDetail.jsp, adapted for home.jsp) --- */
.offcanvas {
	z-index: 1048;
	/* Ensure it's above other content but can be configured */
}

.offcanvas-header {
	background-color: var(--color-background-section-alt);
	/* Consistent with productDetail */
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
	color: var(--color-border); /* Softer color for icon */
	margin-bottom: 1.5rem;
}

.empty-cart-display-rd p { /* Style for text in empty cart */
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
	width: 60px; /* Slightly larger image */
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
	padding: 0.3rem;
	cursor: pointer;
	font-size: 1rem;
	transition: color var(--transition-fast);
}

.btn-remove-item-rd:hover {
	color: #a94442; /* Darker red on hover */
}

.cart-total-section-rd {
	padding: 1.25rem 0;
	border-top: 2px solid var(--color-brand-primary);
	/* Primary color border */
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

/* --- Toast Notifications Redesign (ensure consistency with productDetail.jsp) --- */



to {
	opacity: 0;
	transform: translateX(110%);
}

}

/* --- Custom Confirmation Popup Styles (already in home.jsp) --- */
.popup-overlay-rd {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.6);
	display: none; /* Changed to none, JS will change to flex */
	justify-content: center;
	align-items: center;
	z-index: 20000; /* Very high z-index */
	opacity: 0;
	visibility: hidden;
	transition: opacity var(--transition-smooth), visibility 0s linear
		var(--transition-smooth);
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
	justify-content: center; /* Center buttons */
	gap: 1rem;
}

.popup-actions-rd .btn-rd {
	padding: 0.6rem 1.5rem;
	min-width: 100px;
}

/* Specific button styling for danger/confirm */
.btn-danger-rd {
	background-color: var(--color-error);
	color: var(--color-text-on-dark);
	border-color: var(--color-error);
}

.btn-danger-rd:hover {
	background-color: #c9302c; /* Darker red */
	border-color: #ac2925;
	color: var(--color-text-on-dark);
}

/*
  Assuming your .cart-item-entry-rd (the <li>) is a flex container.
  Example styling for the parent li to provide context:
*/
.cart-item-entry-rd {
	display: flex;
	align-items: center;
	/* Vertically aligns items if they have different heights */
	gap: 10px; /* Adjust spacing between elements inside the cart item */
	padding: 12px 5px; /* Example padding for each cart item */
	border-bottom: 1px solid var(--border-color, #e0e0e0);
	/* Separator line */
}

/* This is the key CSS for your image to prevent cropping */
.cart-item-image-rd {
	width: 65px; /* Set a specific width for the image area */
	height: 65px;
	/* Set a specific height (often same as width for a square aspect) */
	object-fit: contain;
	/* Crucial: Scales the image to fit within the bounds, maintaining aspect ratio */
	object-position: center center;
	/* Centers the image within its 65x65px box */
	border: 1px solid var(--border-color, #f0f0f0);
	/* Optional: a light border around the image */
	border-radius: var(--radius-sm, 4px);
	/* Optional: if you want rounded corners for the image */
	background-color: #ffffff;
	/* Optional: if images have transparency or to fill letterbox space */
	flex-shrink: 0;
	/* Important in a flex layout: prevents the image from shrinking if other content is too wide */
}

/* Optional: Styling for other elements to help with layout consistency */
.cart-item-details-rd {
	flex-grow: 1; /* Allows this section to take up available space */
	display: flex;
	flex-direction: column;
	justify-content: center;
	min-width: 0; /* Helps prevent text overflow issues in flex items */
}

.cart-item-name-rd {
	font-size: 0.9rem;
	font-weight: 500;
	/* Or var(--font-primary) and a weight if you have it */
	color: var(--text-dark, #212121);
	white-space: nowrap;
	/* Prevent wrapping if too long, use with overflow and text-overflow */
	overflow: hidden;
	text-overflow: ellipsis;
	margin-bottom: 4px;
}

.cart-item-price-rd {
	font-size: 0.85rem;
	color: var(--text-light, #757575);
}

.cart-item-subtotal-rd {
	font-size: 0.9rem;
	font-weight: 600;
	color: var(--text-dark, #212121);
	padding: 0 10px; /* Some spacing */
	text-align: right;
	min-width: 70px; /* Ensure it has some minimum space */
}

.remove-item-form-rd {
	margin-left: 5px; /* Spacing from subtotal */
}

.btn-remove-item-rd {
	background: transparent;
	border: none;
	color: #F44336; /* A clear remove/danger color */
	cursor: pointer;
	padding: 5px; /* Make it easier to click */
	font-size: 1.1rem; /* Adjust icon size */
	line-height: 1;
	/* Ensure button doesn't take too much vertical space */
}

.btn-remove-item-rd:hover {
	color: #D32F2F; /* Darker shade on hover */
}

.btn-remove-item-rd i.fas.fa-times {
	display: block; /* Helps with consistent alignment if only icon */
}
</style>

</head>
<body>

	<%-- SVG Icons Definition --%>
	<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
        <defs>
            <symbol id="icon-user" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" /></symbol>
            <symbol id="icon-cart" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59L3.62 17H19v-2H7l1.1-2h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0 0 20 4H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" /></symbol>
            <symbol id="icon-search" viewBox="0 0 24 24">
		<path fill="currentColor"
			d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5A6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" /></symbol>
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
					<form id="search-form-header-rd" class="search-form-rd"
						action="<%=contextPath%>/SearchServlet" method="get">
						<input type="text" name="searchQuery" class="search-input-rd"
							placeholder="Search for fresh groceries..." />
						<button type="submit" class="search-button-rd" aria-label="Search">
							<svg width="20" height="20" viewBox="0 0 24 24">
								<use xlink:href="#icon-search"></use></svg>
						</button>
					</form>
				</div>

				<div class="header-actions-rd">
					<%
					if (loggedInUser != null) {
					%>
					<span class="user-greeting-rd">Hello, <%=userNameForGreeting%>!
					</span> 
					<a href="<%=contextPath%>/profile" class="action-link-rd"
						aria-label="My Profile" title="My Profile"> <svg width="22"
							height="22" viewBox="0 0 24 24">
							<use xlink:href="#icon-user"></use></svg>
					</a> <a href="#" class="action-link-rd cart-trigger-rd"
						aria-label="My Cart" title="My Cart" data-bs-toggle="offcanvas"
						data-bs-target="#offcanvasCart" aria-controls="offcanvasCart">
						<svg width="22" height="22" viewBox="0 0 24 24">
							<use xlink:href="#icon-cart"></use></svg> <%
 if (cartItemCount > 0) {
 %>
						<span class="cart-badge-rd"><%=cartItemCount%></span> <%
 }
 %>
					</a> <a href="<%=contextPath%>/logout" class="btn-rd btn-logout-rd">Logout</a>
					<%
					} else {
					%>
					<a href="<%=contextPath%>/login" class="btn-rd pdp-style-login-btn">Login</a>
					<a href="<%=contextPath%>/register.jsp"
						class="btn-rd pdp-style-register-btn">Register</a> 
					<a href="<%=contextPath %>/cart.jsp"
						class="action-link-rd cart-trigger-rd" aria-label="My Cart"
						title="My Cart" data-bs-toggle="offcanvas"
						data-bs-target="#offcanvasCart" aria-controls="offcanvasCart">
						<svg width="22" height="22" viewBox="0 0 24 24">
							<use xlink:href="#icon-cart"></use></svg> <%
 if (cartItemCount > 0) {
 %>
						<span class="cart-badge-rd"><%=cartItemCount%></span> <%
 }
 %>
					</a>
					<%
					}
					%>
				</div>
			</div>
		</div>
	</header>
	



	<section class="hero-main-rd"
		style="background-image: url('<%=contextPath%>/images/grocery.png');">
		<div class="hero-overlay-rd"></div>
		<div class="container-rd">
			<div class="hero-content-rd">
				<h1 class="hero-title-rd">Your Daily Dose of Freshness.</h1>
				<p class="hero-subtitle-rd">Discover quality groceries,
					delivered fast. Simple, fresh, and convenient.</p>
				<a href="<%=contextPath%>/products" class="btn-rd btn-hero-rd">Explore
					Products</a>
			</div>
		</div>
	</section>

	<section class="section-categories-rd py-rd-5">
		<div class="container-rd">
			<h2 class="section-title-rd">
				<span>Browse Categories</span>
			</h2>
			<%
			if (!categoryList.isEmpty()) {
			%>
			<div class="category-carousel-container-rd">
				<div class="swiper category-swiper-rd">
					<div class="swiper-wrapper">
						<%
						for (String category : categoryList) {
						%>
						<div class="swiper-slide">
							<a
								href="<%=contextPath%>/products?category=<%=URLEncoder.encode(category, "UTF-8")%>"
								class="category-card-rd">
								<div class="category-icon-rd">
									<%-- Using Font Awesome icons as placeholders --%>
									<%
									if (category.toLowerCase().contains("fruit") || category.toLowerCase().contains("vege")) {
									%>
									<i class="fas fa-carrot"></i>
									<%
									} else if (category.toLowerCase().contains("dairy") || category.toLowerCase().contains("egg")) {
									%>
									<i class="fas fa-cheese"></i>
									<%
									} else if (category.toLowerCase().contains("bakery") || category.toLowerCase().contains("bread")) {
									%>
									<i class="fas fa-bread-slice"></i>
									<%
									} else if (category.toLowerCase().contains("drink") || category.toLowerCase().contains("juice")) {
									%>
									<i class="fas fa-wine-bottle"></i>
									<%
									} else if (category.toLowerCase().contains("snack")) {
									%>
									<i class="fas fa-cookie-bite"></i>
									<%
									} else {
									%>
									<i class="fas fa-tag"></i>
									<%
									}
									%>
								</div>
								<h3 class="category-name-rd"><%=category%></h3>
							</a>
						</div>
						<%
						}
						%>
					</div>
				</div>
			</div>
			<%
			} else {
			%>
			<p class="text-center-rd text-muted-rd">Categories are being
				stocked up!</p>
			<%
			}
			%>
		</div>
	</section>

	<section class="section-products-rd py-rd-5">
		<div class="container-rd">
			<h2 class="section-title-rd">
				<span>Hot Deals & Fresh Picks</span>
			</h2>
			<%
			if (!productList.isEmpty()) {
				int productCountDisplay = 0; // Renamed to avoid conflict with cartItemCount
			%>
			<div class="product-grid-rd">
				<%
				for (Product product : productList) {
					if (product.isAvailable()) { // Only show available products
						productCountDisplay++;
				%>
				<div class="product-card-rd">
					<a
						href="<%=contextPath%>/productDetail?id=<%=product.getProductId()%>"
						class="product-link-rd">
						<div class="product-image-wrapper-rd">
							<%
							String imagePath = (product.getImageFileName() != null && !product.getImageFileName().isEmpty()
									&& !product.getImageFileName().equals("placeholder.jpg")
									&& !product.getImageFileName().equals("placeholder.png"))
									? contextPath + "/images/" + product.getImageFileName()
									: contextPath + "/images/placeholder_product_foodmart.png"; // Consistent placeholder
							%>
							<img src="<%=imagePath%>" alt="<%=product.getProductName()%>"
								class="product-img-rd"
								onerror="this.src='<%=contextPath%>/images/placeholder_product_foodmart.png';">
						</div>
						<div class="product-info-rd">
							<%-- product-info-rd for card --%>
							<span class="product-category-rd"><%=product.getCategory()%></span>
							<h3 class="product-name-rd"><%=product.getProductName()%></h3>
							<%-- product-name-rd for card --%>
							<div class="product-price-rd">
								₹<%=product.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP)%></div>
							<%-- product-price-rd for card --%>
						</div>
					</a>
					<div class="product-actions-rd">
						<%-- product-actions-rd for card --%>
						<%
						if (product.getAvailableQuantity() > 0) {
						%>
						<form action="<%=contextPath%>/home" method="post"
							class="add-to-cart-form-rd">
							<input type="hidden" name="action" value="ADD"> <input
								type="hidden" name="productId"
								value="<%=product.getProductId()%>"> <input
								type="hidden" name="quantity" value="1">
							<%-- Default quantity for quick add --%>
							<button type="submit" class="btn-rd btn-add-to-cart-rd">
								<i class="fas fa-cart-plus"></i> Add to Cart
							</button>
						</form>
						<%
						} else {
						%>
						<button type="button" class="btn-rd btn-out-of-stock-rd" disabled>Out
							of Stock</button>
						<%
						}
						%>
					</div>
					<%
					if (product.getAvailableQuantity() <= 5 && product.getAvailableQuantity() > 0) {
					%>
					<div class="product-stock-alert-rd">Low Stock!</div>
					<%
					}
					%>
				</div>
				<%
				if (productCountDisplay >= 20)
					break; // Limit featured products for this design
				}
				}
				if (productCountDisplay == 0 && !productList.isEmpty()) { // If there are products but none are available
				%>
				<p class="text-center-rd text-muted-rd col-12-rd">No featured
					products currently available. Check back soon!</p>
				<%
				} else if (productList.isEmpty()) { // If product list itself is empty
				%>
				<p class="text-center-rd text-muted-rd col-12-rd">Our products
					are coming soon!</p>
				<%
				}
				} else { // Fallback if productList is null (though initialized above)
				%>
				<p class="text-center-rd text-muted-rd col-12-rd">Our products
					are coming soon!</p>
				<%
				}
				%>
			</div>
			<%
			if (productList.size() > 20) {
			%>
			<div class="text-center-rd mt-rd-4">
				<a href="<%=contextPath%>/products" class="btn-rd btn-view-all-rd">View
					All Products</a>
			</div>
			<%
			}
			%>
		</div>
	</section>

	<section class="section-promises-rd py-rd-5">
		<div class="container-rd">
			<div class="promises-grid-rd">
				<div class="promise-item-rd">
					<div class="promise-icon-rd">
						<i class="fas fa-shipping-fast"></i>
					</div>
					<h3 class="promise-title-rd">Speedy Delivery</h3>
					<p class="promise-desc-rd">Fresh groceries at your door in
						record time.</p>
				</div>
				<div class="promise-item-rd">
					<div class="promise-icon-rd">
						<i class="fas fa-check-circle"></i>
					</div>
					<h3 class="promise-title-rd">Quality Assured</h3>
					<p class="promise-desc-rd">Handpicked for freshness and quality
						you can trust.</p>
				</div>
				<div class="promise-item-rd">
					<div class="promise-icon-rd">
						<i class="fas fa-percent"></i>
					</div>
					<h3 class="promise-title-rd">Great Value</h3>
					<p class="promise-desc-rd">Competitive prices and exciting
						offers daily.</p>
				</div>
			</div>
		</div>
	</section>

	<footer class="site-footer-rd">
			<div class="footer-bottom-rd">
					<p>Your favorite online grocery store, committed to bringing
						you the best.</p>
				<p>
					&copy;
					<%=new java.text.SimpleDateFormat("yyyy").format(new java.util.Date())%>
					FoodMart. Freshness Delivered.
				</p>
			</div>
	</footer>

	<%-- Offcanvas Cart Panel (Structure from productDetail.jsp, adapted for home.jsp) --%>
	<div class="offcanvas offcanvas-end" data-bs-scroll="true"
		tabindex="-1" id="offcanvasCart" aria-labelledby="offcanvasCartLabel">
		<div class="offcanvas-header">
			<h5 class="offcanvas-title" id="offcanvasCartLabel">Your
				Shopping Cart</h5>
			<button type="button" class="btn-close text-reset"
				data-bs-dismiss="offcanvas" aria-label="Close"></button>
		</div>
		<div class="offcanvas-body">
			<%-- Use cartMessage from home.jsp's session attributes for in-panel alerts --%>
			<%
			if (cartMessage != null && !cartMessage.isEmpty() && !cartMessage.toLowerCase().contains("added to cart")
					&& !cartMessage.toLowerCase().contains("updated in cart")
					&& !cartMessage.toLowerCase().contains("removed from cart")) {
				// Only show non-toast messages here, or messages that are specifically errors not handled by toast.
			%>
			<div
				class="alert <%=cartMessage.toLowerCase().contains("error") ? "alert-danger" : "alert-success"%> alert-dismissible fade show"
				role="alert">
				<%=cartMessage%>
				<button type="button" class="btn-close" data-bs-dismiss="alert"
					aria-label="Close"></button>
			</div>
			<%
			}
			%>

			<%
			if (cartItems.isEmpty()) {
			%>
			<div class="empty-cart-display-rd">
				<i class="fas fa-shopping-basket empty-cart-icon-rd"></i>
				<p>Your cart is currently empty.</p>
				<a href="<%=contextPath%>/products" class="btn-rd btn-primary-rd"
					data-bs-dismiss="offcanvas">Start Shopping</a>
			</div>
			<%
			} else {
			%>
			<ul class="list-unstyled cart-items-list-rd">
				<%
				for (CartItem item : cartItems) {
				%>
				<li class="cart-item-entry-rd"><img
					src="<%=contextPath%>/images/<%=(item.getImageFileName() != null && !item.getImageFileName().isEmpty()
		? item.getImageFileName()
		: "placeholder_product_foodmart.png")%>"
					alt="<%=item.getProductName()%>" class="cart-item-image-rd"
					onerror="this.src='<%=contextPath%>/images/placeholder_product_foodmart.png';">
					<div class="cart-item-details-rd">
						<div class="cart-item-name-rd"><%=item.getProductName()%></div>
						<div class="cart-item-price-rd">
							Qty:
							<%=item.getQuantity()%>
							&times; ₹<%=item.getUnitPrice().setScale(2)%>
						</div>
					</div>
					<div class="cart-item-subtotal-rd">
						₹<%=item.getSubtotal().setScale(2)%>
					</div> <%-- Form action points to HomeServlet for cart modifications from home page --%>
					<form action="<%=contextPath%>/home" method="post"
						class="remove-item-form-rd d-inline">
						<input type="hidden" name="action" value="REMOVE"> <input
							type="hidden" name="productId" value="<%=item.getProductId()%>">
						<%-- returnUrl for home page might be simpler, but this is more robust if query params are ever used --%>
						<input type="hidden" name="returnUrl"
							value="<%=request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "")%>">
						<button type="button"
							class="btn-remove-item-rd js-confirm-cart-action"
							data-action-message="Remove <%=item.getProductName().replace("\"", "&quot;").replace("'", "\\'")%> from your cart"
							aria-label="Remove item">
							<i class="fas fa-times"></i>
						</button>
					</form></li>
				<%
				}
				%>
			</ul>
			<div class="cart-total-section-rd">
				<strong>Total: ₹<%=cartTotal.setScale(2)%></strong>
			</div>
			<div class="cart-actions-buttons-rd">
				<a href="<%=contextPath%>/cart.jsp"
					class="btn-rd btn-secondary-rd btn-view-cart-rd">View Full Cart</a>
				<%-- Checkout form action consistent with productDetail.jsp --%>
				<form action="<%=contextPath%>/CartServlet" method="get"
					style="display: contents;">
					<input type="hidden" name="amount"
						value="<%=cartTotal.setScale(2)%>">
					<button type="submit" class="btn-rd btn-primary-rd btn-checkout-rd"
						<%=cartItems.isEmpty() ? "disabled" : ""%>>Proceed to
						Checkout</button>
				</form>
			</div>
			<%
			}
			%>
		</div>
	</div>

	<div id="customActionConfirmModal" class="popup-overlay-rd">
		<div class="popup-content-rd">
			<h4 id="confirmModalTitle" class="popup-title-rd">Confirm Action</h4>
			<p id="confirmModalMessage" class="popup-message-rd">Are you
				sure?</p>
			<div class="popup-actions-rd">
				<button id="confirmModalConfirmBtn" class="btn-rd btn-danger-rd">Confirm</button>
				<button id="confirmModalCancelBtn" class="btn-rd btn-secondary-rd">Cancel</button>
			</div>
		</div>
	</div>




	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>

	<script>
        // --- Custom Action Confirmation Modal Logic (already in home.jsp) ---
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

        // Attach event listeners to all buttons that need this custom confirmation
        // This needs to be run after the offcanvas content might be dynamically loaded or on DOMContentLoaded
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
            const confirmMessage = `Are you sure you want to ${actionMessage}?`;
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

        // --- Toast Notification Logic (using the more robust version from productDetail.jsp) ---
    


        document.addEventListener('DOMContentLoaded', function () {
            // Initialize Swiper for categories
            if (document.querySelector('.category-swiper-rd')) {
                new Swiper(".category-swiper-rd", {
                    slidesPerView: 2,
                    spaceBetween: 10,
                    loop: false, // Better not to loop if not many categories
                    grabCursor: true,
                    navigation: {
                        nextEl: ".swiper-button-next-rd", // Ensure these elements exist if using navigation
                        prevEl: ".swiper-button-prev-rd",
                    },
                    breakpoints: {
                        576: { slidesPerView: 3, spaceBetween: 15 },
                        768: { slidesPerView: 4, spaceBetween: 20 },
                        992: { slidesPerView: 5, spaceBetween: 25 },
                        1200: { slidesPerView: 6, spaceBetween: 25 }
                    }
                });
            }

            // Cart Badge Update (from productDetail.jsp logic)
            var cartBadge = document.querySelector('.cart-badge-rd');
            if (cartBadge) {
                var itemCount = <%=cartItemCount%>;
                if (itemCount > 0) {
                    cartBadge.innerText = itemCount;
                    cartBadge.style.display = 'flex'; // Use flex if it's for centering content
                } else {
                    cartBadge.style.display = 'none';
                }
            }
            
            // Display cart message from session as a toast
         

            // Initialize confirmation buttons for dynamically loaded offcanvas content
            const offcanvasCartElement = document.getElementById('offcanvasCart');
            if (offcanvasCartElement) {
                // Initial call for any static buttons
                initializeConfirmationButtons();
                // Re-initialize if Bootstrap's offcanvas fires a 'shown' event
                // (or use MutationObserver if content is loaded via AJAX without Bootstrap events)
                offcanvasCartElement.addEventListener('shown.bs.offcanvas', function () {
                    initializeConfirmationButtons();
                });
            }
        });
    </script>
</body>
</html>
