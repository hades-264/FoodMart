<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, com.gms.model.Product, com.gms.model.User, java.math.BigDecimal, java.net.URLEncoder" %>

<%
    // Page Title
    String pageTitle = (String) request.getAttribute("pageTitle");
    pageTitle = (pageTitle == null || pageTitle.trim().isEmpty()) ? "Our Products" : pageTitle;
    
    // User Greeting & Role
    String userNameForGreeting = (String) request.getAttribute("userNameForGreeting");
    userNameForGreeting = (userNameForGreeting == null || userNameForGreeting.trim().isEmpty()) ? "Guest" : userNameForGreeting;

    String userRoleForPage = (String) request.getAttribute("userRoleForPage");
    userRoleForPage = (userRoleForPage == null) ? "GUEST" : userRoleForPage;

    // Cart Item Count (from ProductListingServlet)
    Integer cartItemCountAttribute = (Integer) request.getAttribute("cartItemCount");
    int cartItemCount = (cartItemCountAttribute == null) ? 0 : cartItemCountAttribute.intValue();

    // Product List
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    if (productList == null) productList = new ArrayList<>();

    // Category List
    List<String> allCategoriesList = (List<String>) request.getAttribute("allCategoriesList");
    if (allCategoriesList == null) allCategoriesList = new ArrayList<>();

    // Current Filters
    String currentCategory = request.getParameter("category");
    String currentSearchQuery = (String) request.getAttribute("searchQuery"); // From SearchServlet
    if (currentSearchQuery == null) {
        currentSearchQuery = request.getParameter("search"); // From direct search form on this page
    }

    String contextPath = request.getContextPath();
    
    // For returnUrl in Add to Cart form - to redirect back to this page with filters
    String currentRequestUri = request.getRequestURI(); // e.g., /GMS/products
    String currentQueryString = request.getQueryString(); // e.g., category=Fruits or search=Apple
    String fullCurrentUrl = currentRequestUri;
    if (currentQueryString != null && !currentQueryString.isEmpty()) {
        fullCurrentUrl += "?" + currentQueryString;
    }
    String encodedReturnUrl = URLEncoder.encode(fullCurrentUrl, "UTF-8");

    String cartMessage = (String) session.getAttribute("cartMessage");
    if (cartMessage != null) {
        session.removeAttribute("cartMessage"); // Clear after displaying once
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - FoodMart</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
       :root { /* CSS Variables remain the same */
            --primary-color: #4CAF50; 
            --primary-dark: #388E3C;
            --secondary-color: #FFC107; 
            --accent-color: #E91E63; 
            --text-dark: #212529;
            --text-light: #f8f9fa;
            --bg-main: #f4f6f8; 
            --bg-card: #ffffff;
            --border-color: #dee2e6;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.05);
            --shadow-md: 0 3px 8px rgba(0,0,0,0.1);
            --font-body: 'Poppins', sans-serif;
            --font-heading: 'Playfair Display', serif;
            --radius-sm: 4px;
            --radius-md: 8px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: var(--font-body);
            line-height: 1.6;
            color: var(--text-dark);
            background-color: var(--bg-main);
        }

        a { text-decoration: none; color: var(--primary-color); }
        a:hover { color: var(--primary-dark); }

       /* Header Styles */
        .site-header {
            background: linear-gradient(to right, var(--primary-dark), var(--primary-color));
            color: var(--text-light);
            padding: 0.8rem 0;
            box-shadow: var(--shadow-md);
            position: sticky;
            top: 0;
            z-index: 1020; 
        }
        .header-container {
            max-width: 1350px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo-link {
            font-family: var(--font-heading);
            font-size: 2rem; 
            font-weight: 700;
            color: var(--text-light);
        }
        .logo-link i { margin-right: 10px; color: var(--secondary-color); }

        .header-search-form { display: flex; flex-grow: 0.5; max-width: 550px; margin: 0 1.5rem; }
        .header-search-input {
            flex-grow: 1;
            padding: 0.75rem 1.2rem;
            border: 1px solid var(--primary-dark);
            border-right: none;
            border-radius: var(--radius-md) 0 0 var(--radius-md);
            font-size: 0.95rem;
            outline: none;
        }
        .header-search-btn {
            padding: 0.75rem 1.5rem;
            background: var(--secondary-color);
            color: var(--text-dark); 
            border: 1px solid var(--secondary-color);
            border-left: none;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            cursor: pointer;
            font-weight: 600;
            transition: background-color 0.3s, color 0.3s;
        }
        .header-search-btn:hover { background-color: #ffac00; } 
        .header-search-btn i { margin-right: 6px; }
        
        .header-nav-links { display: flex; align-items: center; gap: 0.8rem; }
        .header-nav-link {
            color: var(--text-light);
            padding: 0.6rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            font-weight: 500;
            transition: background-color 0.2s;
            position: relative;
            display: flex; align-items: center; gap: 6px;
        }
        .header-nav-link i {font-size: 1.1em;}
        .header-nav-link:hover { background-color: rgba(255,255,255,0.1); }
        .user-greeting-header { color: #e8f5e9; font-size: 0.9rem; margin-right: 0.5rem; }

        .cart-link .cart-badge {
            background-color: var(--accent-color);
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 0.75em;
            font-weight: bold;
            position: absolute;
            top: 2px;
            right: 2px;
        }

        /* Main Content Wrapper */
        .page-content-wrapper {
            max-width: 1350px;
            margin: 2.5rem auto;
            padding: 0 20px;
        }
        .page-section-title {
            font-family: var(--font-heading);
            font-size: 2.5rem; 
            font-weight: 700;
            color: var(--text-dark);
            text-align: center;
            margin-bottom: 2.5rem;
            position: relative;
        }
        .page-section-title::after {
            content: ''; display: block; width: 100px; height: 4px;
            background: var(--primary-color);
            margin: 0.6rem auto 0; border-radius: 2px;
        }

        /* Flex Layout for Sidebar & Products */
        .product-page-layout { display: flex; gap: 1.5rem; align-items: flex-start; } /* Reduced gap */

        /* Categories Sidebar */
        .categories-sidebar-nav {
            flex: 0 0 240px; /* Slightly narrower sidebar */
            background: var(--bg-card);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            padding: 1.2rem; /* Adjusted padding */
            position: sticky; top: 90px; /* Adjust based on actual header height */
        }
        .sidebar-title-text {
            font-size: 1.15rem; font-weight: 600; color: var(--text-dark);
            margin-bottom: 1rem; padding-bottom: 0.6rem;
            border-bottom: 2px solid var(--primary-light); 
            display: flex; align-items: center; gap: 8px;
        }
        .sidebar-title-text i { color: var(--primary-color); }
        .categories-link-list { list-style: none; }
        .category-list-item a {
            display: flex; align-items: center;
            padding: 0.7rem 0.8rem; color: #495057; /* Slightly adjusted padding */
            border-radius: var(--radius-sm); transition: all 0.25s ease;
            font-size: 0.9rem; margin-bottom: 0.2rem; /* Reduced margin */
        }
        .category-list-item a i { margin-right: 10px; width: 18px; text-align: center; color: var(--secondary-color);}
        .category-list-item a:hover { background-color: #e9ecef; color: var(--primary-dark); }
        .category-list-item a.active {
            background-color: var(--primary-color); color: var(--text-light);
            font-weight: 500; box-shadow: 0 2px 5px rgba(76,175,80,0.2);
        }
        .category-list-item a.active i { color: var(--text-light); }
        
        /* Product Listing Area - MODIFIED */
        .products-main-content { flex: 1; }
        .search-info-banner {
            background: #e6fff0; 
            padding: 0.8rem 1.2rem; border-radius: var(--radius-md); /* Adjusted padding */
            margin-bottom: 1.5rem; color: var(--primary-dark); border: 1px solid #b2dfdb;
        }

        .products-display-grid {
            display: grid;
            /* Adjusted minmax for smaller cards, allowing more per row */
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); 
            gap: 1.2rem; /* Slightly reduced gap */
        }

        .product-card-item {
            background: var(--bg-card);
            border-radius: var(--radius-md); /* Consistent radius */
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            display: flex; flex-direction: column;
            transition: transform 0.2s ease-out, box-shadow 0.2s ease-out;
        }
        .product-card-item:hover {
            transform: translateY(-4px); /* Reduced hover lift */
            box-shadow: var(--shadow-md);
        }

        .product-card-image-link { display: block; }
        .product-image-container {
            height: 180px; /* MODIFIED: Reduced height for smaller image area */
            background-color: #f8f9fa; /* Lighter fallback */
            display: flex; align-items: center; justify-content: center;
            overflow: hidden;
            border-bottom: 1px solid var(--border-color);
            padding: 0.5rem; /* Added padding around the image */
        }
        .product-image-container img {
            max-width: 100%; max-height: 100%;
            width: auto; height: auto; 
            object-fit: contain; 
            transition: transform 0.3s ease;
        }
        .product-card-item:hover .product-image-container img { transform: scale(1.03); }
        
        .product-card-details {
            padding: 0.8rem; /* MODIFIED: Reduced padding */
            display: flex; flex-direction: column;
            flex-grow: 1; text-align: center; 
        }
        .product-name-link {
            font-size: 0.95rem; /* MODIFIED: Smaller font for name */
            font-weight: 500; /* Slightly less bold */
            color: var(--text-dark);
            line-height: 1.3; margin-bottom: 0.4rem;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
            overflow: hidden; text-overflow: ellipsis; min-height: 2.6em; 
        }
        .product-name-link:hover { color: var(--primary-color); }

        .product-price-display {
            font-size: 1.15rem; /* MODIFIED: Smaller price font */
            color: var(--primary-dark);
            font-weight: 600; /* Slightly less bold */
            margin-bottom: 0.6rem;
        }
        
        .product-form-actions { margin-top: auto; } 
        .quantity-control-group {
            display: flex; align-items: center; justify-content: center; 
            gap: 0.4rem; margin-bottom: 0.6rem; /* Reduced margin */
        }
        .quantity-control-group label { font-size: 0.8rem; color: #555; } /* Smaller label */
        .quantity-input-field {
            width: 50px; /* MODIFIED: Smaller qty input */
            padding: 0.3rem; /* MODIFIED */
            border: 1px solid var(--border-color); border-radius: var(--radius-sm);
            text-align: center; font-size: 0.9rem;
        }
        .quantity-input-field:focus { outline: 2px solid var(--primary-color); }

        .btn-add-cart-main {
            display: flex; align-items: center; justify-content: center; gap: 6px; /* Reduced gap */
            width: 100%; padding: 0.6rem; /* MODIFIED: Reduced padding */
            background-color: var(--secondary-color); color: var(--text-dark);
            border: none; border-radius: var(--radius-sm); cursor: pointer;
            font-weight: 500; font-size: 0.85rem; /* MODIFIED: Smaller button text */
            text-align: center;
            transition: background-color 0.2s, transform 0.1s;
        }
        .btn-add-cart-main:hover { background-color: #ffb300; transform: translateY(-1px); } 
        .btn-add-cart-main:disabled, .btn-add-cart-main.product-out-of-stock {
            background-color: #e0e0e0; color: #9e9e9e; cursor: not-allowed;
        }
        .btn-add-cart-main.product-out-of-stock { font-style: italic; }
        
        /* Cart Message, No Products, Footer CSS - KEEP AS IS from previous full response */
        /* ... */
         .cart-action-message {
            padding: 1rem; margin: 0 0 1.5rem 0;
            border-radius: var(--radius-md); text-align: center; font-weight: 500;
        }
        .cart-action-message.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb;}
        .cart-action-message.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}

        .no-products-info {
            text-align: center; padding: 3rem 1rem;
            background: var(--bg-card); border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
        }
        .no-products-info i { font-size: 4rem; color: var(--text-muted); margin-bottom: 1.5rem; }
        .no-products-info h3 { font-size: 1.5rem; margin-bottom: 1rem; }
        .no-products-info p { color: #6c757d; margin-bottom: 1.5rem; }
        .no-products-info .btn-link-styled {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }
        .no-products-info .btn-link-styled:hover { text-decoration: underline; }

        .site-footer-main {
            background: var(--text-dark); color: #adb5bd;
            text-align: center; padding: 3rem 1rem; margin-top: 4rem;
        }
        .footer-logo-main { font-family: var(--font-heading); font-size: 1.8rem; font-weight: 700; margin-bottom: 1rem; color:var(--text-light); }
        .footer-logo-main i { color: var(--primary-color); }
        .footer-copyright-text { font-size: 0.9rem; margin-bottom: 0.5rem; }
        .footer-tagline-text { font-style: italic; font-size: 0.85rem; opacity: 0.8;}

      
    </style>
</head>
<body>
     <header class="site-header">
        <div class="header-container">
            <div class="logo-link">
                <a href="<%= contextPath %>/welcome"><i class="fas fa-leaf"></i> FoodMart</a>
            </div>
            
            <form class="header-search-form" action="<%= contextPath %>/products" method="get">
                <input type="text" name="search" class="header-search-input" 
                       placeholder="Search for fresh groceries..." 
                       value="<%= currentSearchQuery != null ? currentSearchQuery : "" %>" 
                       autocomplete="off">
                <button type="submit" class="header-search-btn"><i class="fas fa-search"></i> Search</button>
            </form>

            <nav class="header-nav-links">
                <% if ("GUEST".equals(userRoleForPage)) { %>
                    <a href="<%= contextPath %>/login.jsp" class="header-nav-link"><i class="fas fa-sign-in-alt"></i> Login</a>
                    <a href="<%= contextPath %>/register.jsp" class="header-nav-link"><i class="fas fa-user-plus"></i> Sign Up</a>
                <% } else { %>
                    <span class="user-greeting-header">Hi, <%= userNameForGreeting %>!</span>
                    <a href="<%= contextPath %>/profile" class="header-nav-link"><i class="fas fa-user-circle"></i> Profile</a>
                    <% if ("ADMIN".equals(userRoleForPage)) { %>
                        <a href="<%= contextPath %>/adminDashboard" class="header-nav-link"><i class="fas fa-user-shield"></i> Admin</a>
                    <% } %>
                    <a href="<%= contextPath %>/CartServlet" class="header-nav-link cart-link">
                        <i class="fas fa-shopping-cart"></i> Cart 
                        <% if (cartItemCount > 0) { %>
                            <span class="cart-badge"><%= cartItemCount %></span>
                        <% } %>
                    </a>
                    <a href="<%= contextPath %>/logout" class="header-nav-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
                <% } %>
            </nav>
        </div>
    </header>

    <div class="page-content-wrapper">
        <h1 class="page-section-title"><%= pageTitle %></h1>

        <% if (cartMessage != null && !cartMessage.isEmpty()) { %>
            <div class="cart-action-message <%= cartMessage.toLowerCase().contains("error") ? "error" : "success" %>">
                <%= cartMessage %>
            </div>
        <% } %>

        <div class="product-page-layout">
            <aside class="categories-sidebar-nav">
                <h3 class="sidebar-title-text"><i class="fas fa-stream"></i> Categories</h3>
                <ul class="categories-link-list">
                    <li class="category-list-item">
                        <a href="<%= contextPath %>/products" 
                           class="category-nav-link <%= (currentCategory == null && (currentSearchQuery == null || currentSearchQuery.isEmpty())) ? "active" : "" %>">
                           <i class="fas fa-store-alt"></i> All Products
                        </a>
                    </li>
                    <% for (String cat : allCategoriesList) { 
                        String encodedCat = URLEncoder.encode(cat, "UTF-8"); %>
                        <li class="category-list-item">
                            <a href="<%= contextPath %>/products?category=<%= encodedCat %>" 
                               class="category-nav-link <%= cat.equals(currentCategory) ? "active" : "" %>">
                               <i class="fas fa-tag fa-xs"></i> <%= cat %>
                            </a>
                        </li>
                    <% } %>
                </ul>
            </aside>

            <main class="products-main-content">
                <% if (currentSearchQuery != null && !currentSearchQuery.isEmpty()) { %>
                    <div class="search-info-banner">
                        Showing results for: <strong>"<%= currentSearchQuery %>"</strong>
                    </div>
                <% } %>

                <% if (!productList.isEmpty()) { %>
                    <div class="products-display-grid">
                        <% for (Product product : productList) { %>
                           <div class="product-card-item">
                                <a href="<%= contextPath %>/productDetail?id=<%= product.getProductId() %>" class="product-card-image-link">
                                    <div class="product-image-container">
                                        <% String imagePath = (product.getImageFileName() != null && !product.getImageFileName().isEmpty() && !"placeholder.jpg".equals(product.getImageFileName())) ?
                                                    contextPath + "/images/" + product.getImageFileName() :
                                                    contextPath + "/images/placeholder.jpg"; // Fallback to a generic placeholder
                                        %>
                                        <img src="<%= imagePath %>" alt="<%= product.getProductName() %>">
                                    </div>
                                </a>
                                <div class="product-card-details">
                                    <a href="<%= contextPath %>/productDetail?id=<%= product.getProductId() %>" class="product-name-link">
                                        <%= product.getProductName() %>
                                    </a>
                                    <p class="product-price-display">₹<%= product.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></p>
                                    
                                    <form action="<%= contextPath %>/CartServlet" method="post" class="product-form-actions">
                                        <input type="hidden" name="action" value="ADD"> 
                                        <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="returnUrl" value="<%= encodedReturnUrl %>">
                                        
                                        <div class="quantity-control-group">
                                            <label for="qty-<%= product.getProductId() %>">Qty:</label>
                                            <input type="number" id="qty-<%= product.getProductId() %>" name="quantity" value="1" min="1" 
                                                   max="<%= product.getAvailableQuantity() > 0 ? Math.min(product.getAvailableQuantity(), 10) : 1 %>" 
                                                   class="quantity-input-field"
                                                   <%= product.getAvailableQuantity() <= 0 ? "disabled" : "" %>>
                                        </div>
                                        
                                        <button type="submit" 
                                                class="btn-add-cart-main <%= product.getAvailableQuantity() <= 0 ? "product-out-of-stock" : "" %>" 
                                                <%= product.getAvailableQuantity() <= 0 ? "disabled" : "" %>>
                                            <i class="fas fa-cart-plus"></i> 
                                            <%= product.getAvailableQuantity() <= 0 ? "Out of Stock" : "Add to Cart" %>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="no-products-info">
                        <i class="fas fa-box-open"></i>
                        <h3>No Products Found</h3>
                        <% if (currentSearchQuery != null && !currentSearchQuery.isEmpty()) { %>
                            <p>Sorry, we couldn't find any products matching your search for "<%= currentSearchQuery %>". Try a different term.</p>
                        <% } else if (currentCategory != null && !currentCategory.isEmpty()) { %>
                             <p>There are currently no products available in the "<%= currentCategory %>" category.</p>
                        <% } else { %>
                            <p>Our product selection is currently empty. Please check back soon!</p>
                        <% } %>
                        <p><a href="<%= contextPath %>/products" class="btn-link-styled">View All Products</a></p>
                    </div>
                <% } %>
            </main>
        </div>
    </div>

    <footer class="site-footer-main">
        <div class="footer-logo-main"><i class="fas fa-leaf"></i> FoodMart</div>
        <p class="footer-copyright-text">&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> FoodMart. All Rights Reserved.</p>
        <p class="footer-tagline-text">Freshness Delivered to Your Doorstep.</p>
    </footer>
</body>
</html>