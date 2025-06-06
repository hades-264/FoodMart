<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.List, java.util.ArrayList, com.gms.model.Product, com.gms.model.User, java.math.BigDecimal, java.net.URLEncoder"%>

<%
List<String> categoryList = (List<String>) request.getAttribute("categoryList");
List<Product> productList = (List<Product>) request.getAttribute("productList");

// Initialize to empty lists if null to prevent NullPointerExceptions in the loops
if (categoryList == null) {
	categoryList = new ArrayList<String>();
}
if (productList == null) {
	productList = new ArrayList<Product>();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Welcome to FoodMart - Fresh Groceries Delivered!</title>

<%-- Using a more modern font from Google Fonts --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Roboto:wght@300;400;500;700&display=swap"
	rel="stylesheet">
<%-- Font Awesome (already present and newer version) --%>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
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
    --transition-smooth: 0.3s ease-in-out; /* Added for consistency */
    --transition-fast: 0.2s ease-in-out; /* Added for consistency */
}

*, *::before, *::after {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

html {
	scroll-behavior: smooth;
}

body {
	font-family: var(--font-secondary);
	line-height: 1.7;
	color: var(--text-dark);
	background-color: var(--bg-light);
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

.container {
	width: 90%;
	max-width: 1200px;
	margin: 0 auto;
	padding: 0 15px;
}

.main-header {
	background-color: var(--bg-white);
	padding: 1rem 0;
	box-shadow: var(--shadow-md);
	position: sticky;
	top: 0;
	z-index: 1000;
	transition: background-color 0.3s ease, box-shadow 0.3s ease;
}

.header-content {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.logo-container img {
	height: 45px;
	width: auto;
	transition: transform 0.3s ease;
}

.logo-container img:hover {
	transform: scale(1.05);
}

.search-container {
	flex-grow: 1;
	margin: 0 2rem;
	max-width: 600px;
}

.search-form {
	position: relative;
	display: flex;
	align-items: center;
}

.search-input {
	width: 100%;
	padding: 0.90rem 1.25rem;
	font-size: 0.95rem;
	font-family: var(--font-secondary);
	border: 1px solid var(--border-color);
	border-radius: var(--radius-lg);
	transition: border-color 0.3s ease, box-shadow 0.3s ease;
	border-right: none;
	border-top-right-radius: 0;
	border-bottom-right-radius: 0;
}

.search-input:focus {
	outline: none;
	border-color: var(--primary-color);
	box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.2);
	z-index: 1;
}

.search-btn {
	background-color: var(--primary-color);
	color: var(--text-on-primary);
	border: 1px solid var(--primary-color);
	border-left: none;
	padding: 0.75rem 1.5rem;
	border-radius: 0 var(--radius-lg) var(--radius-lg) 0;
	cursor: pointer;
	font-weight: 500;
	font-family: var(--font-primary);
	transition: background-color 0.3s ease;
	display: flex;
	align-items: center;
	gap: 0.5rem;
	height: calc(1.5rem + 2 * 0.75rem + 2 * 1px); /* Matches input height */
}

.search-btn:hover {
	background-color: var(--primary-dark);
	border-color: var(--primary-dark);
}

.search-btn svg {
	width: 18px;
	height: 18px;
}

.auth-buttons .btn {
	font-family: var(--font-primary);
	font-weight: 500;
	padding: 0.6rem 1.5rem;
	border-radius: var(--radius-md);
	text-decoration: none;
	transition: all 0.3s ease;
	font-size: 0.9rem;
	margin-left: 0.5rem;
}

.btn-login {
	background-color: transparent;
	color: var(--primary-color);
	border: 2px solid var(--primary-color);
}

.btn-login:hover {
	background-color: var(--primary-color);
	color: var(--text-on-primary);
}

.btn-signup {
	background-color: var(--primary-color);
	color: var(--text-on-primary);
	border: 2px solid var(--primary-color);
}

.btn-signup:hover {
	background-color: var(--primary-dark);
	border-color: var(--primary-dark);
}

.hero-section {
	background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
		url('<%=request.getContextPath()%>/images/grocery.png');
	background-size: cover;
	background-position: center center;
	background-repeat: no-repeat;
	color: var(--text-on-primary);
	padding: 6rem 0;
	text-align: center;
	position: relative;
	overflow: hidden;
}

.hero-section::before {
	content: "";
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	z-index: 0;
}

.hero-content {
	position: relative;
	z-index: 1;
	max-width: 700px;
	margin: 0 auto;
}

.hero-title {
	font-family: var(--font-primary);
	font-size: clamp(2.5rem, 6vw, 4.5rem);
	font-weight: 700;
	line-height: 1.2;
	margin-bottom: 1.5rem;
	text-shadow: 0 3px 6px rgba(0, 0, 0, 0.3);
}

.hero-subtitle {
	font-size: clamp(1rem, 2.5vw, 1.3rem);
	font-weight: 300;
	margin-bottom: 2.5rem;
	opacity: 0.9;
	max-width: 550px;
	margin-left: auto;
	margin-right: auto;
}

.hero-cta {
	background-color: var(--primary-color); /* Use index.jsp primary color */
	color: var(--text-on-primary); /* Ensure contrast */
	padding: 0.9rem 2.5rem;
	font-size: 1.1rem;
	font-family: var(--font-primary);
	font-weight: 600;
	border: none;
	border-radius: var(--radius-lg);
	text-decoration: none;
	transition: all 0.3s ease;
	box-shadow: var(--shadow-md);
	display: inline-block;
}

.hero-cta:hover {
	background-color: var(--primary-dark); /* Use index.jsp primary dark color */
	transform: translateY(-3px) scale(1.03);
	box-shadow: var(--shadow-lg);
}

.section {
	padding: 4rem 0;
}

.section-bg-light {
	background-color: var(--bg-white);
}

.section-title {
	font-family: var(--font-primary);
	font-size: 2.5rem;
	font-weight: 700;
	text-align: center;
	margin-bottom: 1rem;
	color: var(--text-dark);
}

.section-subtitle {
	font-family: var(--font-secondary);
	font-size: 1.1rem;
	text-align: center;
	color: var(--text-light);
	margin-bottom: 3rem;
	max-width: 600px;
	margin-left: auto;
	margin-right: auto;
}

.categories-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
	gap: 1.5rem;
}

.category-card-rd { 
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	text-align: center;
	padding: 1.25rem 0.75rem;
	background-color: var(--bg-white); 
	border-radius: var(--radius-lg);
	box-shadow: var(--shadow-sm);
	transition: transform var(--transition-smooth), box-shadow var(--transition-smooth), border-color var(--transition-fast);
	text-decoration: none;
	min-height: 150px; 
	border: 1px solid var(--border-color);
}

.category-card-rd:hover {
	transform: translateY(-6px);
	box-shadow: var(--shadow-md); /* Using index.jsp var */
	border-color: var(--primary-color); /* Using index.jsp var */
}

.category-icon-rd { /* Styled like home.jsp's category icons */
	font-size: 2.5rem; /* Adjusted for index.jsp grid */
	color: var(--primary-color); /* Using index.jsp var */
	margin-bottom: 0.8rem;
	line-height: 1;
	transition: color var(--transition-fast);
}

.category-card-rd:hover .category-icon-rd {
	color: var(--secondary-color); /* Using index.jsp var for hover icon color */
}

.category-name-rd { /* Styled like home.jsp's category names */
	font-family: var(--font-primary); /* Using index.jsp var */
	font-size: 1rem; /* Adjusted for index.jsp grid */
	font-weight: 600; /* Using Poppins, so 600 is good */
	color: var(--text-dark); /* Using index.jsp var */
	margin-top: 0.25rem;
}
/* === END OF UPDATED CATEGORY STYLES === */


.products-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	gap: 2rem;
}

.product-card {
	background: var(--bg-white);
	border-radius: var(--radius-lg);
	overflow: hidden;
	border: 1px solid var(--border-color);
	transition: all 0.3s ease-in-out;
	box-shadow: var(--shadow-sm);
	display: flex;
	flex-direction: column;
}

.product-card:hover {
	transform: translateY(-5px);
	box-shadow: var(--shadow-lg);
	border-color: var(--primary-color);
}

.product-image-container {
	position: relative;
	background-color: #f9f9f9;
	padding: 1rem;
	text-align: center;
	overflow: hidden;
	aspect-ratio: 4/3;
}

.product-image {
	width: 100%;
	height: 100%;
	object-fit: contain;
	transition: transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.product-card:hover .product-image {
	transform: scale(1.1);
}

.product-info {
	padding: 1.25rem;
	flex-grow: 1;
	display: flex;
	flex-direction: column;
}

.product-name {
	font-family: var(--font-primary);
	font-size: 1.15rem;
	font-weight: 600;
	margin-bottom: 0.5rem;
	line-height: 1.4;
	color: var(--text-dark);
	min-height: 2.8em;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
}

.product-price {
	font-size: 1.5rem;
	font-weight: 700;
	color: var(--primary-color);
	margin-bottom: 1rem;
}

.product-actions {
	margin-top: auto;
}

.btn-view-details {
	width: 100%;
	background-color: var(--primary-color);
	color: var(--text-on-primary);
	border: none;
	padding: 0.75rem;
	border-radius: var(--radius-md);
	font-family: var(--font-primary);
	font-weight: 500;
	text-decoration: none;
	display: inline-block;
	text-align: center;
	transition: all 0.3s ease;
}

.btn-view-details:hover {
	background-color: var(--primary-dark);
	color: var(--text-on-primary);
	transform: scale(1.02);
}

.btn-view-details:disabled, .btn-view-details.out-of-stock {
	background-color: var(--text-light);
	cursor: not-allowed;
	opacity: 0.7;
}

.out-of-stock-badge {
	font-size: 0.8rem;
	color: var(--danger-color, #D32F2F); /* Added fallback */
	font-weight: 500;
	margin-top: 0.5rem;
	display: block;
}

.promises-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
	gap: 2rem;
}

.promise-card {
	background: var(--bg-white);
	padding: 2rem 1.5rem;
	border-radius: var(--radius-lg);
	text-align: center;
	border: 1px solid var(--border-color);
	transition: all 0.3s ease-in-out;
	box-shadow: var(--shadow-sm);
}

.promise-card:hover {
	transform: translateY(-5px);
	box-shadow: var(--shadow-md);
	border-left: 5px solid var(--accent-color);
}

.promise-icon {
	width: 50px;
	height: 50px;
	margin: 0 auto 1.25rem;
	color: var(--accent-color);
	transition: transform 0.3s ease;
}

.promise-card:hover .promise-icon {
	transform: rotateY(360deg);
}

.promise-title {
	font-family: var(--font-primary);
	font-size: 1.3rem;
	font-weight: 600;
	margin-bottom: 0.75rem;
}

.promise-description {
	color: var(--text-light);
	font-size: 0.95rem;
}

.main-footer {
	background-color: var(--text-dark);
	color: var(--bg-light);
	padding: 2rem 0;
	margin-top: 4rem;
	text-align: center;
	font-size: 0.9rem;
}

.footer-content p {
	margin-bottom: 0.5rem;
}

.footer-content a {
	color: var(--primary-light);
	text-decoration: none;
	transition: color 0.3s ease;
}

.footer-content a:hover {
	color: var(--secondary-color);
	text-decoration: underline;
}

.empty-state {
	text-align: center;
	padding: 3rem 1rem;
	background-color: var(--bg-white);
	border-radius: var(--radius-lg);
	box-shadow: var(--shadow-sm);
}

.empty-state-icon {
	font-size: 3rem;
	color: var(--text-light);
	margin-bottom: 1rem;
}

.empty-state p {
	font-size: 1.1rem;
	color: var(--text-light);
}
</style>

</head>
<body>
	<%
	String contextPath = request.getContextPath();
	%>

	<header class="main-header">
		<div class="container">
			<div class="header-content">
				<a href="<%=contextPath%>/welcome" class="logo-container"> <img
					src="<%=contextPath%>/images/logo.png" alt="FoodMart Logo">
				</a>

				<div class="search-container">
					<form class="search-form" action="<%=contextPath%>/SearchServlet"
						method="get">
						<input type="text" name="searchQuery" class="search-input"
							placeholder="Search for fresh groceries, snacks, and more..."
							autocomplete="off">
						<button type="submit" class="search-btn">
							<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
								fill="currentColor" width="24" height="24">
								<path
									d="M18.031 16.6168L22.3137 20.8995L20.8995 22.3137L16.6168 18.031C15.0769 19.263 13.124 20 11 20C6.032 20 2 15.968 2 11C2 6.032 6.032 2 11 2C15.968 2 20 6.032 20 11C20 13.124 19.263 15.0769 18.031 16.6168ZM16.0247 15.8748C17.2475 14.6146 18 12.8956 18 11C18 7.1325 14.8675 4 11 4C7.1325 4 4 7.1325 4 11C4 14.8675 7.1325 18 11 18C12.8956 18 14.6146 17.2475 15.8748 16.0247L16.0247 15.8748Z"></path></svg>
							Search
						</button>
					</form>
				</div>

				<div class="auth-buttons">
					<%
					// Retrieve the attributes set by LandingPageServlet
					Boolean isUserLoggedIn = (Boolean) request.getAttribute("isUserLoggedIn");
					String userName = (String) request.getAttribute("userName");

					// Ensure isUserLoggedIn is not null to avoid NullPointerException
					if (isUserLoggedIn == null) {
						isUserLoggedIn = false;
					}

					if (isUserLoggedIn) {
					%>
					<%-- User is logged in --%>
					<span style="margin-right: 15px; color: #333;">Welcome, <%=userName%>!
					</span> <a href="<%=contextPath%>/profile" class="btn btn-profile">Profile</a>

					<%-- Example Profile Button --%>
					<a href="<%=contextPath%>/logout" class="btn btn-logout">Logout</a>
					<%
					} else {
					%>
					<%-- User is not logged in --%>
					<a href="<%=contextPath%>/login.jsp" class="btn btn-login">Login</a>
					<a href="<%=contextPath%>/register.jsp" class="btn btn-signup">Register</a>
					<%
					}
					%>
				</div>
			</div>
		</div>
	</header>

	<section class="hero-section"
		style="background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('<%=request.getContextPath()%>/images/grocery.png');">
		<div class="container">
			<div class="hero-content">
				<h1 class="hero-title">Your Daily Dose of Freshness, Delivered.</h1>
				<p class="hero-subtitle">Discover top-quality groceries,
					farm-fresh produce, and pantry staples. Fast, reliable delivery
					straight to your home.</p>
				<a href="<%=contextPath%>/products" class="hero-cta">Explore
					Products Now</a>
			</div>
		</div>
	</section>

	<section class="section">
		<div class="container">
			<h2 class="section-title">Shop By Category</h2>
			<p class="section-subtitle">Find exactly what you need from our
				wide range of categories.</p>

			<%
			if (!categoryList.isEmpty()) {
			%>
			<div class="categories-grid">
				<%
				int categoryCount = 0;
				for (String category : categoryList) {
					if (categoryCount >= 6)
						break; // Limit displayed categories
					String encodedCategory = URLEncoder.encode(category, "UTF-8");
				%>
				<a href="<%=contextPath%>/products?category=<%=encodedCategory%>"
					class="category-card-rd"> <%-- UPDATED CLASS --%>
					<div class="category-icon-rd"> <%-- NEW WRAPPER DIV --%>
					    <%-- UPDATED ICON LOGIC USING FONT AWESOME --%>
                        <%
                        String categoryNameLower = category.toLowerCase();
                        if (categoryNameLower.contains("fruit")) { %>
                            <i class="fas fa-apple-alt"></i>
                        <% } else if (categoryNameLower.contains("vegetable")) { %>
                            <i class="fas fa-carrot"></i>
                        <% } else if (categoryNameLower.contains("dairy") || categoryNameLower.contains("egg")) { %>
                            <i class="fas fa-cheese"></i>
                        <% } else if (categoryNameLower.contains("bakery") || categoryNameLower.contains("bread")) { %>
                            <i class="fas fa-bread-slice"></i>
                        <% } else if (categoryNameLower.contains("drink") || categoryNameLower.contains("beverage") || categoryNameLower.contains("juice")) { %>
                            <i class="fas fa-wine-bottle"></i>
                        <% } else if (categoryNameLower.contains("snack")) { %>
                            <i class="fas fa-cookie-bite"></i>
                        <% } else if (categoryNameLower.contains("meat") || categoryNameLower.contains("poultry")) { %>
                            <i class="fas fa-drumstick-bite"></i>
                        <% } else if (categoryNameLower.contains("seafood")) { %>
                            <i class="fas fa-fish"></i>
                        <% } else if (categoryNameLower.contains("pantry") || categoryNameLower.contains("staple")) { %>
                            <i class="fas fa-archive"></i> 
                        <% } else if (categoryNameLower.contains("frozen")) { %>
                            <i class="fas fa-ice-cream"></i>
                        <% } else { %>
                            <i class="fas fa-store"></i> <%-- Generic store/category icon --%>
                        <% } %>
					</div>
					<h3 class="category-name-rd"><%=category%></h3> <%-- UPDATED TAG AND CLASS --%>
				</a>
				<%
				categoryCount++;
				}
				%>
			</div>
			<%
			} else {
			%>
			<div class="empty-state">
				<div class="empty-state-icon">🛒</div>
				<p>Categories are being curated. Check back soon!</p>
			</div>
			<%
			}
			%>
		</div>
	</section>

	<section class="section section-bg-light">
		<div class="container">
			<h2 class="section-title">Featured Products</h2>
			<p class="section-subtitle">Handpicked selections, popular
				choices, and great deals.</p>

			<%
			if (!productList.isEmpty()) {
			%>
			<div class="products-grid">
				<%
				int productCount = 0;
				for (Product product : productList) {
					if (productCount >= 20)
						break; // Limit to 20 featured products

					String imageFileName = product.getImageFileName();
					String imagePath = contextPath + "/images/" + imageFileName;
				%>
				<div class="product-card">
					<div class="product-image-container">
						<a
							href="<%=contextPath%>/productDetail?id=<%=product.getProductId()%>">
							<img src="<%=imagePath%>" alt="<%=product.getProductName()%>"
							class="product-image"
                            onerror="this.onerror=null; this.src='<%=contextPath%>/images/placeholder_product_foodmart.png';">
						</a>
					</div>

					<div class="product-info">
						<h3 class="product-name">
							<a
								href="<%=contextPath%>/productDetail?id=<%=product.getProductId()%>"
								style="text-decoration: none; color: inherit;"> <%=product.getProductName()%>
							</a>
						</h3>
						<div class="product-price">
							₹<%=product.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP)%></div>

						<div class="product-actions">
							<%
							if (product.getAvailableQuantity() > 0) {
							%>
							
							<a
								href="<%=contextPath%>/productDetail?id=<%=product.getProductId()%>"
                            class="btn-view-details">
								View Details </a>
							<%
							} else {
							%>
							<button class="btn-view-details out-of-stock" disabled>
								Out of Stock</button>
							<%
							}
							%>
						</div>
					</div>
				</div>
				<%
				productCount++;
				}
				%>
			</div>
			<%
			} else {
			%>
			<div class="empty-state">
				<div class="empty-state-icon">🛍️</div>
				<p>Our shelves are being stocked! Amazing products coming very
					soon.</p>
			</div>
			<%
			}
			%>
		</div>
	</section>

	<section class="section">
		<div class="container">
			<h2 class="section-title">Why Choose FoodMart?</h2>
			<p class="section-subtitle">We're committed to bringing you the
				best online grocery shopping experience.</p>

			<div class="promises-grid">
				<div class="promise-card">
					<div class="promise-icon">
						<svg fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M19.5 12.5c0 .28-.22.5-.5.5h-1.53c.34.84.53 1.74.53 2.68 0 2.84-1.96 5.22-4.67 5.85C12.92 21.81 12.47 22 12 22s-.92-.19-1.33-.52c-2.71-.63-4.67-3.01-4.67-5.85 0-.94.19-1.84.53-2.68H5c-.28 0-.5-.22-.5-.5s.22-.5.5-.5h1.08c-.05-.33-.08-.66-.08-1s.03-.67.08-1H5c-.28 0-.5-.22-.5-.5s.22-.5.5-.5h1.53C6.19 8.66 6 7.76 6 6.82c0-2.84 1.96-5.22 4.67-5.85C11.08 .69 11.53 .5 12 .5s.92.19 1.33.52c2.71.63 4.67 3.01 4.67 5.85 0 .94-.19 1.84-.53 2.68H19c.28 0 .5.22.5.5s-.22.5-.5.5h-1.08c.05.33.08.66.08 1s-.03.67-.08 1H19c.28 0 .5.22.5.5zM12 2.5c-2.21 0-4 1.79-4 4.32 0 .75.17 1.46.48 2.09h7.04c.31-.63.48-1.34.48-2.09C16 4.29 14.21 2.5 12 2.5zm0 14.18c2.21 0 4-1.79 4-4.32 0-.75-.17-1.46-.48-2.09H8.48c-.31.63-.48 1.34-.48 2.09 0 2.53 1.79 4.32 4 4.32z" /></svg>
					</div>
					<h5 class="promise-title">Ultra-Fast Delivery</h5>
					<p class="promise-description">Get your essentials delivered at
						lightning speed, often within minutes.</p>
				</div>

				<div class="promise-card">
					<div class="promise-icon">
						<svg fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 16.17l7.59-7.59L19 10l-9 9z" /></svg>
					</div>
					<h5 class="promise-title">Premium Quality</h5>
					<p class="promise-description">Only the freshest produce and
						highest quality products, guaranteed.</p>
				</div>

				<div class="promise-card">
					<div class="promise-icon">
						<svg fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1s3.1 1.39 3.1 3.1v2z" /></svg>
					</div>
					<h5 class="promise-title">Secure & Easy Payments</h5>
					<p class="promise-description">Shop with confidence using our
						secure, hassle-free payment options.</p>
				</div>
			</div>
		</div>
	</section>

	<footer class="main-footer">
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

	<%-- Bootstrap JS (if needed, usually for dropdowns, modals etc. but this page is simple) --%>
	<%-- <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script> --%>

	<script>
        // Minimal JavaScript for essential interactions

        // Smooth scroll for anchor links (if any)
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });

        // Simple header shrink on scroll (optional visual touch)
        const header = document.querySelector('.main-header');
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

        // Basic form validation for search (can be expanded)
        const searchForm = document.querySelector('.search-form');
        if (searchForm) {
            searchForm.addEventListener('submit', function(e) {
                const searchInput = this.querySelector('.search-input');
                if (searchInput.value.trim().length < 2 && searchInput.value.trim().length > 0) {
                    e.preventDefault();
                    searchInput.focus();
                } else if (searchInput.value.trim().length === 0) {
                     e.preventDefault(); // Prevent empty search
                     searchInput.focus();
                }
            });
        }
    </script>
</body>
</html>
