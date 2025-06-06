<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page import="com.gms.model.User, com.gms.model.Product, com.gms.model.Order, com.gms.dao.ProductDAO" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.math.BigDecimal" %>

<%
    // --- Retrieve data passed from AdminDashboardServlet ---
    User loggedInAdmin = (User) session.getAttribute("loggedInUser");
    String adminName = "Admin"; 
    if (loggedInAdmin != null && "ADMIN".equals(loggedInAdmin.getRole())) {
        adminName = loggedInAdmin.getUserName();
    } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp?message=Admin_access_required");
        return;
    }

    String activeSection = (String) request.getAttribute("activeSection");
    if (activeSection == null || activeSection.trim().isEmpty()) {
        activeSection = "dashboard"; 
    }

    List<User> userList = (List<User>) request.getAttribute("userList");
    if (userList == null) userList = new ArrayList<>();

    List<Order> orderList = (List<Order>) request.getAttribute("orderList");
    if (orderList == null) orderList = new ArrayList<>();
    
    List<Product> productInventoryList = (List<Product>) request.getAttribute("productList");
    if (productInventoryList == null) productInventoryList = new ArrayList<>();

    String formSubmissionMessage = (String) request.getAttribute("formSubmissionMessage"); 

    // Dashboard card data from AdminDashboardServlet
    long totalUsers = (request.getAttribute("dashboardTotalUsers") != null) ? (Long) request.getAttribute("dashboardTotalUsers") : 0L;
    long totalOrders = (request.getAttribute("dashboardTotalOrders") != null) ? (Long) request.getAttribute("dashboardTotalOrders") : 0L;
    long totalProducts = (request.getAttribute("dashboardTotalProducts") != null) ? (Long) request.getAttribute("dashboardTotalProducts") : 0L;
    BigDecimal totalEarningsBigDecimal = (request.getAttribute("dashboardTotalEarnings") != null) ? (BigDecimal) request.getAttribute("dashboardTotalEarnings") : BigDecimal.ZERO;
    String totalEarnings = totalEarningsBigDecimal.toPlainString(); 
    
    // Date filter values for repopulating the form
    String selectedDateRange = (String) request.getAttribute("selectedDateRange");
    if (selectedDateRange == null) selectedDateRange = "all_time";
    String customStartDateVal = (String) request.getAttribute("customStartDateVal");
    String customEndDateVal = (String) request.getAttribute("customEndDateVal");

    String contextPath = request.getContextPath();
    SimpleDateFormat tableDateFormat = new SimpleDateFormat("dd MMM, yy hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%= contextPath %>/css/admin.css" />
    <title>Admin Panel - FoodMart</title>
    <style>
        @import url("https://fonts.googleapis.com/css2?family=Ubuntu:wght@300;400;500;700&display=swap");
        @import url("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css");

        * {
          font-family: "Ubuntu", sans-serif;
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        :root {
          --blue: #2c3e50;
          --white: #fff;
          --gray: #f5f5f5;
          --black1: #222;
          --black2: #999;
          --green: #27ae60;
          --green-hover: #219150;
          --body-color:#f7f9fb;
          --red-status: #e74c3c; 
          --green-status: #2ecc71; 
          --red-danger: #dc3545; /* For modal confirm button */
          --gray-secondary: #6c757d; /* For modal cancel button */
        }

        body {
          min-height: 100vh;
          overflow-x: hidden;
          background-color:var(--body-color) ;
        }

        .details.section { display: none; margin-top: 20px; margin-left:20px; }
        .details.section.active { display: block; }
        
        .navigation ul li a.active-nav { background-color: var(--body-color); color: var(--black1);  border-top-left-radius: 30px;
            border-bottom-left-radius: 30px; }
        .navigation ul li a.active-nav::before {
            content: ""; position: absolute; right: 0; top: -50px; width: 50px; height: 50px;
            background-color: transparent; border-radius: 50%; box-shadow: 35px 35px 0 10px var(--body-color);
            pointer-events: none;
          }
        .navigation ul li a.active-nav::after {
            content: ""; position: absolute; right: 0; bottom: -50px; width: 50px; height: 50px;
            background-color: transparent; border-radius: 50%; box-shadow: 35px -35px 0 10px var(--body-color);
            pointer-events: none;
          }
        .navigation ul li a.active-nav .icon, .navigation ul li a.active-nav .title { color: var(--black1); }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input[type="text"], .form-group input[type="number"], .form-group input[type="file"], .form-group textarea, .form-group select {
            width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;
        }
        .form-group textarea { resize: vertical; }
        
        .btn { padding: 8px 15px; border-radius: 4px; text-decoration: none; cursor: pointer; border: none; }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-primary:hover { background-color: #0056b3; }
        .btn-secondary { background-color: var(--gray-secondary); color: white; } /* Modal cancel */
        .btn-danger { background-color: var(--red-danger); color: white; } /* Modal confirm */

        .btn-action { padding: 5px 10px; font-size: 0.9em; margin-right: 5px; text-decoration:none; color: #007bff; border: 1px solid #007bff; border-radius:3px; border-radius: 20px; cursor: pointer; }
        .btn-action.delete { color: #dc3545; border-color: #dc3545; border-radius: 20px; cursor: pointer; }
        .btn-action:disabled,
        select:disabled + .btn-action {
            color: #6c757d;
            border-color: #adb5bd;
            background-color: #e9ecef;
            cursor: not-allowed;
            opacity: 0.7;
        }
        select:disabled {
             background-color: #e9ecef;
             cursor: not-allowed;
             opacity: 0.7;
        }
        #detailed_order_link{
         text-decoration:none;
        color:blue;
        }
      
        #detailed_order_link:hover{
      
       
         box-shadow: 2px 2px 5px 4px var(--body-color);
        border-radius:12px;
        color:red;
        }
        

        .message.success { color: green; background-color: #e6fffa; padding:10px; border:1px solid green; border-radius:4px; margin-bottom:15px;}
        .message.error { color: red; background-color: #ffe6e6; padding:10px; border:1px solid red; border-radius:4px; margin-bottom:15px;}
        
        .status-badge { padding: 5px 10px; border-radius: 12px; color: white; font-size: 0.85em; font-weight: 500; display: inline-block; }
        .status-active { background-color: var(--green-status); }
        .status-inactive { background-color: var(--red-status); }

        .status-pending { background-color: #f39c12; color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.85em; display: inline-block;}
        .status-processing { background-color: #3498db; color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.85em; display: inline-block;}
        .status-shipped { background-color: #8e44ad; color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.85em; display: inline-block;}
        .status-delivered { background-color: var(--green-status); color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.85em; display: inline-block;}
        .status-cancelled { background-color: var(--red-status); color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.85em; display: inline-block;}
        
        .dashboard-controls { margin-bottom: 20px; background-color: #f9f9f9; padding: 15px; border-radius: 8px;}
        
        .navigation {
            position: fixed; width: 300px; height: 100%; background: var(--blue);
            border-left: 10px solid var(--blue); transition: 0.5s; overflow: hidden; z-index: 100;
        }
        .navigation.active { width: 80px; }
        .navigation ul { position: absolute; top: 0; left: 0; width: 100%; }
        .navigation ul li {
            position: relative; width: 100%; list-style: none;
            border-top-left-radius: 30px; border-bottom-left-radius: 30px;
            margin-bottom: 10px;
        }
        .navigation ul li:hover, .navigation ul li.hovered { background-color: var(--body-color); }
        .navigation ul li:nth-child(1) { margin-bottom: 40px; pointer-events: none; }
        .navigation ul li a {
            position: relative; display: block; width: 100%; display: flex;
            text-decoration: none; color: var(--body-color);
        }
        .navigation ul li:hover a, .navigation ul li.hovered a { color: var(--blue); }
        .navigation ul li a .icon {
            position: relative; display: block; min-width: 60px; height: 60px;
            line-height: 75px; text-align: center;
        }
        .navigation ul li a .icon ion-icon { font-size: 1.75rem; }
        .navigation ul li a .title {
            position: relative; display: block; padding: 0 10px; height: 60px;
            line-height: 60px; text-align: start; white-space: nowrap;
        }
        .navigation ul li:hover a::before, .navigation ul li.hovered a::before {
            content: ""; position: absolute; right: 0; top: -50px; width: 50px; height: 50px;
            background-color: transparent; border-radius: 50%; box-shadow: 35px 35px 0 10px var(--body-color);
            pointer-events: none;
        }
        .navigation ul li:hover a::after, .navigation ul li.hovered a::after {
            content: ""; position: absolute; right: 0; bottom: -50px; width: 50px; height: 50px;
            background-color: transparent; border-radius: 50%; box-shadow: 35px -35px 0 10px var(--body-color);
            pointer-events: none;
        }
        .main { margin-left: 300px; padding: 30px; transition: margin-left 0.5s; min-height: 100vh; }
        .main.active { margin-left: 80px; }

        .section { display: none; animation: fadeIn 0.5s ease; }
        .section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .myTable {
            width: 100%; border-collapse: collapse; margin-top: 20px; background: var(--white);
            box-shadow: 0 7px 25px rgba(0, 0, 0, 0.08); border-radius: 10px; overflow: hidden;
        }
        .myTable th, .myTable td { padding: 12px 15px; text-align: left; border-bottom: 1px solid rgba(0, 0, 0, 0.1); }
        .myTable th { background-color: var(--blue); color: var(--white); font-weight: 500; }
        .myTable tr:hover { background-color: rgba(44, 62, 80, 0.1); }
        .myTable tr:last-child td { border-bottom: none; }
        
        .cardHeader.order-filter-container { 
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap; 
            padding-bottom: 10px; 
        }
        .order-filter-form {
            display: flex;
            align-items: center;
            gap: 12px; 
            padding: 8px 0; 
            margin-left: auto; 
        }
        .order-filter-form label {
            font-weight: 500;
            color: var(--black1);
            margin-right: 4px;
            font-size: 0.9rem; 
        }
        .order-filter-form select,
        .order-filter-form input[type="date"] {
            padding: 7px 10px; 
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 0.85rem; 
            height: 36px; 
            box-sizing: border-box;
        }
        .order-filter-form select { min-width: 140px; }
        .order-filter-form input[type="date"] { min-width: 140px; }
        .order-filter-form button[type="submit"] {
            padding: 7px 15px; 
            background-color: var(--blue);
            color: var(--white);
            border: none;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s ease;
            height: 36px; 
        }
        .order-filter-form button[type="submit"]:hover { background-color: #22303f; }
        .custom-date-range-inputs { align-items: center; gap: 8px; }
        .custom-date-range-inputs span { color: var(--black2); font-size: 0.85rem; }

        #productForm {
          background: var(--white); padding: 20px; border-radius: 10px;
          box-shadow: 0 7px 25px rgba(0, 0, 0, 0.08); max-width: 600px; margin: auto;
        }
        #productForm label { display: block; margin-bottom: 8px; font-weight: 500; color: var(--black1); }
        #productForm input[type="text"],
        #productForm input[type="number"],
        #productForm input[type="file"],
        #productForm textarea,
        #productForm select {
          width: 100%; padding: 10px 15px; font-size: 15px; margin-bottom: 15px;
          border: 1px solid #ddd; border-radius: 5px; transition: border 0.3s;
        }
        #productForm input:focus, #productForm textarea:focus, #productForm select:focus { border-color: var(--blue); outline: none; }
        #productForm button[type="submit"] {
          padding: 12px 25px; font-size: 16px; background-color: var(--green);
          color: white !important; border: none; border-radius: 5px; cursor: pointer; transition: background 0.3s;
        }
        #productForm button[type="submit"]:hover { background-color: var(--green-hover); }
        
        .shiping_status{ border-radius:16px; border: 1px solid #ccc; }
        .shiping_status:hover{ background-color:#f0f0f0; }

        @media (max-width: 991px) {
          .navigation { left: -300px; } 
          .navigation.active { left: 0; width: 80px; } 
          .main { margin-left: 0; width: 100%; }
          .main.active { margin-left: 80px; } 
        }
         @media (max-width: 768px) {
            .myTable { display: block; overflow-x: auto; }
            #productForm { padding: 15px; } 
            .cardBox { grid-template-columns: repeat(2, 1fr); } 
            .order-filter-form { flex-direction: column; align-items: stretch; gap: 8px; }
            .order-filter-form select, .order-filter-form input[type="date"], .order-filter-form button[type="submit"] { width: 100%; min-width: unset; }
            .custom-date-range-inputs { flex-direction: column; align-items: stretch; width: 100%;}
            .custom-date-range-inputs input[type="date"] { width: 100%;}
         }
        @media (max-width: 480px) {
            .main { padding: 15px; }
            .cardBox { grid-template-columns: 1fr; } 
            #productForm input, #productForm textarea, #productForm select { padding: 8px 12px; font-size: 14px; }
            #productForm button { padding: 10px 20px; font-size: 15px; }
            .navigation { width: 100%; height: auto; position: relative; padding-top: 15px; border-left:0; left:0;}
            .navigation.active { width: 100%;} 
            .main.active { margin-left: 0; } 
            .topbar .toggle { display: none; } 
        }

        .topbar {
          width: 99%; height: 60px; display: flex; justify-content: space-between;
          margin-left:14px;
          align-items: center; padding: 0 10px; background: var(--white); box-shadow: 0 2px 5px rgba(0,0,0,0.1);
          position: sticky; top: 0; z-index: 90;
          border-radius: 10px;
        }
        .toggle {
          position: relative; width: 60px; height: 60px; display: flex;
          justify-content: center; align-items: center; font-size: 2.5rem; cursor: pointer;
        }
        .user { position: relative; min-width: 150px; text-align: right; padding-right: 10px; font-weight: 500; color: var(--black1); }

        .cardBox {
          position: relative; width: 101%; padding: 20px 0;
          display: grid; grid-template-columns: repeat(4, 1fr); grid-gap: 30px;
        }
        .cardBox .card {
          position: relative; background: var(--white); padding: 30px; border-radius: 20px;
          display: flex; justify-content: space-between; cursor: pointer;
          box-shadow: 0 7px 25px rgba(0, 0, 0, 0.08);
        }
        .cardBox .card .numbers { position: relative; font-weight: 500; font-size: 2.5rem; color: var(--blue); }
        .cardBox .card .cardName { color: var(--black2); font-size: 1.1rem; margin-top: 5px; }
        .cardBox .card .iconBx { font-size: 3.5rem; color: var(--black2); }
        .cardBox .card:hover { background: var(--blue); }
        .cardBox .card:hover .numbers, .cardBox .card:hover .cardName, .cardBox .card:hover .iconBx { color: var(--white); }

        /* Modal Styles */
        .modal {
            display: none; 
            position: fixed; 
            z-index: 1000; 
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto; 
            background-color: rgba(0,0,0,0.6); 
            align-items: center; 
            justify-content: center; 
        }
        .modal-content {
            background-color: #fff;
            margin: auto; 
            padding: 25px;
            border: 1px solid #888;
            border-radius: 8px;
            width: 90%;
            max-width: 450px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            text-align: center;
        }
        .modal-content h3 {
            margin-top: 0;
            margin-bottom: 15px;
            color: var(--black1);
            font-size: 1.25rem;
        }
        .modal-content p {
            margin-bottom: 20px;
            color: var(--black2);
            font-size: 1rem;
            line-height: 1.5;
        }
        .modal-buttons {
            display: flex;
            justify-content: center; 
            gap: 15px; 
        }
        .modal-buttons .btn { 
            padding: 10px 20px;
            font-size: 0.95rem;
            min-width: 100px;
        }
    </style>
</head>
<body>
    <div class="admin-container">
        <div class="navigation">
            <ul>
                <li>
                    <a href="<%= contextPath %>/adminDashboard?section=dashboard">
                        <span class="icon"><ion-icon name="grid-outline"></ion-icon></span>
                        <span class="title">FoodMart Admin</span>
                    </a>
                </li>
                
                 <li>
                    <a href="<%= contextPath %>/home">
                        <span class="icon"><ion-icon name="home-outline"></ion-icon></span>
                        <span class="title">Home Page</span>
                    </a>
                </li>
                
                 <li>
                    <a href="<%= contextPath %>/adminDashboard?section=dashboard" data-section="dashboard">
                        <span class="icon"><ion-icon name="stats-chart-outline"></ion-icon></span>
                        <span class="title">Dashboard</span>
                    </a>
                </li>
                <li>
                    <a href="<%= contextPath %>/adminDashboard?section=users" data-section="users">
                        <span class="icon"><ion-icon name="people-outline"></ion-icon></span>
                        <span class="title">Manage Users</span>
                    </a>
                </li>
                <li>
                    <a href="<%= contextPath %>/adminDashboard?section=orders" data-section="orders">
                        <span class="icon"><ion-icon name="receipt-outline"></ion-icon></span>
                        <span class="title">All Orders</span>
                    </a>
                </li>
                 <li>
                    <a href="<%= contextPath %>/adminDashboard?section=inventory" data-section="inventory">
                        <span class="icon"><ion-icon name="cube-outline"></ion-icon></span>
                        <span class="title">Product Inventory</span>
                    </a>
                </li>
                <li>
                    <a href="<%= contextPath %>/adminDashboard?section=addItem" data-section="addItem">
                        <span class="icon"><ion-icon name="add-circle-outline"></ion-icon></span>
                        <span class="title"><%= request.getAttribute("productToEdit") != null ? "Edit Product" : "Add Product" %></span>
                    </a>
                </li>
                <li>
                    <a href="<%= contextPath %>/logout?logout=true">
                        <span class="icon"><ion-icon name="log-out-outline"></ion-icon></span>
                        <span class="title">Logout</span>
                    </a>
                </li>
            </ul>
        </div>

        <div class="main">
            <div class="topbar">
                <div class="toggle">
                    <ion-icon name="menu-outline"></ion-icon>
                </div>
                <a href="<%=contextPath%>/profile" class="action-link-rd"
						aria-label="My Profile" title="My Profile" style="text-decoration: none; transition: background-color var(--transition-fast)">
                <div class="user">
                    Welcome, <%= adminName %>!
                </div>
                </a>
            </div>

            <div class="dashboard-controls">
                <div class="cardBox">
                    <div class="card">
                        <div><div class="numbers"><%= totalUsers %></div><div class="cardName">Users</div></div>
                        <div class="iconBx"><ion-icon name="people-outline"></ion-icon></div>
                    </div>
                    <div class="card">
                        <div><div class="numbers"><%= totalOrders %></div><div class="cardName">Total Orders</div></div>
                        <div class="iconBx"><ion-icon name="cart-outline"></ion-icon></div>
                    </div>
                    <div class="card">
                        <div><div class="numbers"><%= totalProducts %></div><div class="cardName">Products</div></div>
                        <div class="iconBx"><ion-icon name="cube-outline"></ion-icon></div>
                    </div>
                    <div class="card">
                        <div><div class="numbers">₹<%= totalEarnings %></div><div class="cardName">Total Earnings</div></div>
                        <div class="iconBx"><ion-icon name="cash-outline"></ion-icon></div>
                    </div>
                </div>
            </div>

            <%-- Dashboard Overview Section --%>
            <div id="dashboard" class="details section">
                <div class="recentOrders">
                    <div class="cardHeader"><h2>Dashboard Overview</h2></div>
                    <p style="padding: 15px;">Welcome, <%= adminName %>! This is your central hub for managing FoodMart. Use the navigation to access different sections.</p>
                </div>
            </div>

                 <%-- Manage Users Section --%>
            <div id="users" class="details section">
                <div class="recentOrders">
                    <div class="cardHeader"><h2>Registered Users</h2></div>
                     <table id="userTable" class="myTable">
                        <thead>
                            <tr class="header">
                                <th>User ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Contact</th>
                                <th>Address</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Actions</th> <%-- Added Actions column --%>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (!userList.isEmpty()) {
                            for (User user : userList) { 
                            if(user.getRole().equalsIgnoreCase("CUSTOMER")) { %>
                            <tr>
                                <td><%= user.getUserId() %></td>
                                <td><%= user.getUserName() %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getContactNumber() == null || user.getContactNumber().isEmpty() ? "N/A" : user.getContactNumber() %></td>
                                <td><%= user.getAddress() == null || user.getAddress().isEmpty() ? "N/A" : user.getAddress() %></td>
                                <td><%= user.getRole() %></td>
                                <td>
                                    <% if (user.isActive()) { %>
                                        <span class="status-badge status-active">Active</span>
                                    <% } else { %>
                                        <span class="status-badge status-inactive">Inactive</span>
                                    <% } %>
                                </td>
                                <td>
                                    <%-- Form for user availability change --%>
                                    <form id="userAvailabilityForm_<%= user.getUserId() %>" action="<%= contextPath %>/AdminUserServlet" method="POST" style="display:none;">
                                        <input type="hidden" name="action" value="<%= user.isActive() ? "DEACTIVATE_USER" : "ACTIVATE_USER" %>">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="sourcePage" value="adminDashboard">
                                        <input type="hidden" name="sourceSection" value="users">
                                    </form>
                                    <button type="button" class="btn-action <%= user.isActive() ? "delete" : "" %>"
                                            onclick="showConfirmationModal(
                                                'Confirm User Status Change',
                                                'Are you sure you want to change the status of \'<%= user.getUserName().replace("'", "\\\\'") %>\'account to \'<%= user.isActive() ? "Inactive" : "Active" %>\'?',
                                                'userAvailabilityForm_<%= user.getUserId() %>'
                                            )">
                                        <%= user.isActive() ? "Deactivate" : "Activate" %>
                                    </button>
                                </td>
                            </tr>
                        <% } }} else { %>
                            <tr><td colspan="8">No users found.</td></tr> <%-- Updated colspan --%>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

	           <%-- All Orders Section --%>
            <div id="orders" class="details section">
                <div class="recentOrders">
                    <div class="cardHeader order-filter-container"> 
                        <h2>All Order History</h2>
                        <form action="<%= contextPath %>/adminDashboard" method="GET" class="order-filter-form">
                            <input type="hidden" name="section" value="orders"> 
                            <label for="dateRange">Filter:</label>
                            <select name="dateRange" id="dateRange" onchange="toggleCustomDateInputs(this.value)">
                                <option value="all_time" <%= "all_time".equals(selectedDateRange) ? "selected" : "" %>>All Time</option>
                                <option value="last_7_days" <%= "last_7_days".equals(selectedDateRange) ? "selected" : "" %>>Last 7 Days</option>
                                <option value="last_30_days" <%= "last_30_days".equals(selectedDateRange) ? "selected" : "" %>>Last 30 Days</option>
                                <option value="custom" <%= "custom".equals(selectedDateRange) ? "selected" : "" %>>Custom Range</option>
                            </select>
                            <div id="customDateInputs" class="custom-date-range-inputs" style="display: <%= "custom".equals(selectedDateRange) ? "flex" : "none" %>;">
                                <input type="date" name="customStartDate" id="customStartDate" value="<%= customStartDateVal != null ? customStartDateVal : "" %>">
                                <span>to</span>
                                <input type="date" name="customEndDate" id="customEndDate" value="<%= customEndDateVal != null ? customEndDateVal : "" %>">
                            </div>
                            <button type="submit">Apply</button>
                        </form>
                    </div>

                    <table id="historyTable" class="myTable">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>User ID</th>
                                <th>Items</th>
                                <th>Total (₹)</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Update Status</th>
                            </tr>
                        </thead>
                           <tbody>
                        <% if (orderList != null && !orderList.isEmpty()) { // Check orderList itself
                            for (Order order : orderList) { 
                            String currentStatus = order.getStatus();
                            // Determine if the status can be updated at all
                            // (i.e., not already Delivered or Cancelled)
                            boolean canUpdate = !("Delivered".equalsIgnoreCase(currentStatus) || "Cancelled".equalsIgnoreCase(currentStatus));
                        %>
                            <tr>
                                <td><a id="detailed_order_link" href="<%= contextPath %>/adminDashboard?section=orderDetails&orderId=<%= order.getOrderId() %>"><%= order.getOrderId() %></a></td>
                                <td><%= order.getUserId() %></td>
                                <td><%= order.getOrderItems() != null ? order.getOrderItems().size() : "0" %></td>
                                <td><%= order.getTotalAmount().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                <td><%= order.getOrderDate() != null ? tableDateFormat.format(order.getOrderDate()) : "N/A" %></td>
                                <td><span class="status-<%= currentStatus.toLowerCase().replaceAll("\\s+", "-") %>"><%= currentStatus %></span></td>
                                <td>
                                     <form action="<%=contextPath%>/AdminOrderUpdateServlet" method="POST" style="display:inline-flex; align-items:center; gap: 5px; background: none; box-shadow: none; padding:0; max-width:none;">
                                        <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                                        <input type="hidden" name="currentSection" value="orders">
                                        <select class="shiping_status" name="newStatus" style="padding:5px 8px; font-size:0.9em;" <%= !canUpdate ? "disabled" : "" %>>
                                            <option value="Pending" 
                                                <%= "Pending".equalsIgnoreCase(currentStatus) ? "selected" : "" %>
                                                <%-- Disable "Pending" if current status is beyond Pending (Processing or Shipped) --%>
                                                <%= ("Processing".equalsIgnoreCase(currentStatus) || "Shipped".equalsIgnoreCase(currentStatus)) ? "disabled" : "" %>>
                                                Pending
                                            </option>
                                           
                                            <option value="Shipped" 
                                                <%= "Shipped".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>
                                                <%-- No additional disabled logic here if canUpdate is true. 
                                                     If current is Pending or Processing, Shipped is a valid next step.
                                                     If current is Shipped, it's selected.
                                                     If Delivered or Cancelled, canUpdate handles the whole select.
                                                --%>
                                                Shipped
                                            </option>
                                            <option value="Delivered" 
                                                <%= "Delivered".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>
                                                <%-- No additional disabled logic here if canUpdate is true.
                                                     If current is Pending, Processing, or Shipped, Delivered is a valid next step.
                                                --%>
                                                Delivered
                                            </option>
                                            <option value="Cancelled" 
                                                <%= "Cancelled".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>
                                                <%-- No additional disabled logic here if canUpdate is true.
                                                     Cancellation is generally possible unless already Delivered.
                                                     The canUpdate variable already prevents this if currentStatus is "Delivered".
                                                --%>
                                                Cancelled
                                            </option>
                                        </select>
                                        <button type="submit" class="btn-action" style="font-size:0.9em; padding: 5px 10px;" <%= !canUpdate ? "disabled" : "" %>>Update</button>
                                    </form>
                                </td>
                            </tr>
                        <% }} else { %> <tr><td colspan="7">No orders found for the selected criteria.</td></tr> <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <%-- Product Inventory Section --%>
            <div id="inventory" class="details section">
                <div class="recentOrders">
                    <div class="cardHeader"><h2>Product Inventory</h2></div>
                    <table id="inventoryTable" class="myTable">
                        <thead>
                            <tr>
                                <th>ID</th><th>Name</th><th>Category</th><th>Price (₹)</th><th>Qty</th><th>Available?</th><th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (!productInventoryList.isEmpty()) { for (Product product : productInventoryList) { %>
                            <tr>
                                <td><%= product.getProductId() %></td><td><%= product.getProductName() %></td>
                                <td><%= product.getCategory() == null ? "N/A" : product.getCategory() %></td>
                                <td><%= product.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                <td><%= product.getAvailableQuantity() %></td>
                                <td>
                                    <span class="status-badge <%= product.isAvailable() ? "status-active" : "status-inactive" %>">
                                        <%= product.isAvailable() ? "Yes" : "No" %>
                                    </span>
                                </td>
                                <td>
                                    <a href="<%= contextPath %>/adminDashboard?section=editItem&productId=<%= product.getProductId() %>" class="btn-action">Edit</a>
                                    <%-- Form for product availability change --%>
                                    <form id="productAvailabilityForm_<%= product.getProductId() %>" action="<%= contextPath %>/AdminProductServlet" method="POST" style="display:none;"> <%-- Hidden form --%>
                                        <input type="hidden" name="action" value="<%= product.isAvailable() ? "MARK_UNAVAILABLE" : "MARK_AVAILABLE" %>">
                                        <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="sourcePage" value="adminDashboard">
                                        <input type="hidden" name="sourceSection" value="inventory">
                                    </form>
                                    <button type="button" class="btn-action <%= product.isAvailable() ? "delete" : "" %>"
                                            onclick="showConfirmationModal(
                                                'Confirm Availability Change',
                                                'Are you sure you want to change availability for \'<%= product.getProductName().replace("'", "\\\\'") %>\' to \'<%= product.isAvailable() ? "Unavailable" : "Available" %>\'?',
                                                'productAvailabilityForm_<%= product.getProductId() %>'
                                            )">
                                        <%= product.isAvailable() ? "Set Unavailable" : "Set Available" %>
                                    </button>
                                </td>
                            </tr>
                        <% }} else { %> <tr><td colspan="7">No products found.</td></tr> <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- Add/Edit Product Section --%>
            <div id="addItem" class="details section">
                <%
                    Product productToEdit = (Product) request.getAttribute("productToEdit");
                    boolean isEditMode = productToEdit != null;
                    String formActionTarget = isEditMode ? "UPDATE_PRODUCT" : "ADD_PRODUCT";
                    String submitButtonText = isEditMode ? "Update Product" : "Add Product";
                    String pageHeader = isEditMode ? "Edit Product Details" : "Add New Product";
                %>
                <div class="recentOrders" style="max-width: 700px; margin: 20px auto;">
                    <div class="cardHeader" style="text-align:center;"><h2><%= pageHeader %></h2></div>
                    <% if (formSubmissionMessage != null && !formSubmissionMessage.isEmpty()) { %>
                        <p class='message <%= formSubmissionMessage.toLowerCase().contains("success") ? "success" : "error" %>' style="text-align:center; margin-bottom:15px;"><%= formSubmissionMessage %></p>
                    <% } %>
                    <form id="productForm" action="<%= contextPath %>/AdminProductServlet" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="<%= formActionTarget %>">
                        <% if (isEditMode) { %>
                            <input type="hidden" name="productId" value="<%= productToEdit.getProductId() %>">
                        <% } %>
                        <input type="hidden" name="sourcePage" value="adminDashboard">
                        <input type="hidden" name="sourceSection" value="inventory">

                        <div class="form-group">
                            <label for="productName">Product Name:</label>
                            <input type="text" id="productName" name="productName" value="<%= isEditMode ? productToEdit.getProductName() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="productDescription">Description:</label>
                            <textarea id="productDescription" name="productDescription" rows="3" required><%= isEditMode && productToEdit.getProductDescription() != null ? productToEdit.getProductDescription() : "" %></textarea>
                        </div>
                        
                        <%-- Retrieve the list of categories passed from the servlet --%>
                        <% List<String> distinctCategories = (List<String>) request.getAttribute("distinctCategories");
                           if (distinctCategories == null) distinctCategories = new ArrayList<>();
                           String currentProductCategory = isEditMode && productToEdit.getCategory() != null ? productToEdit.getCategory() : "";
                        %>
                        <div class="form-group">
                            <label for="productCategorySelect">Category:</label>
                            <select id="productCategorySelect" name="productCategorySelect" onchange="handleCategoryChange(this.value)" required>
                                <option value="">-- Select Category --</option>
                                <% for (String category : distinctCategories) { %>
                                    <option value="<%= category %>" <%= category.equals(currentProductCategory) ? "selected" : "" %>>
                                        <%= category %>
                                    </option>
                                <% } %>
                                <%-- If in edit mode and the current category is not in the distinct list (it's custom and unique), add it as selected --%>
                                <% if (isEditMode && !currentProductCategory.isEmpty() && !distinctCategories.contains(currentProductCategory)) { %>
                                     <option value="<%= currentProductCategory %>" selected><%= currentProductCategory %> (Custom)</option>
                                <% } %>
                                <option value="_new_">Define New Category...</option>
                            </select>
                        </div>
                        <div class="form-group" id="newCategoryGroup" style="display:none;">
                            <label for="newProductCategory">New Category Name:</label>
                            <input type="text" id="newProductCategory" name="newProductCategory" placeholder="Enter new category name">
                        </div>
                        <div class="form-group">
                            <label for="productPrice">Price (₹):</label>
                            <input type="number" id="productPrice" name="productPrice" step="0.01" min="0" value="<%= isEditMode && productToEdit.getPrice() != null ? productToEdit.getPrice().toPlainString() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="itemQuantity">Available Quantity:</label>
                            <input type="number" id="itemQuantity" name="itemQuantity" min="0" value="<%= isEditMode ? String.valueOf(productToEdit.getAvailableQuantity()) : "0" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="productImageFile">Product Image:</label>
                            <input type="file" id="productImageFile" name="productImageFile" accept="image/jpeg, image/png, image/gif">
                            <% if (isEditMode && productToEdit.getImageFileName() != null && !productToEdit.getImageFileName().isEmpty()) { %>
                                <p style="margin-top:5px;">Current image: <%= productToEdit.getImageFileName() %> <br>
                                <img src="<%= contextPath %>/images/<%= productToEdit.getImageFileName() %>" alt="Current Product Image" style="max-width: 100px; max-height: 100px; margin-top: 5px; border:1px solid #ccc; border-radius: 4px;">
                                <br>(Leave file input empty to keep current image)</p>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label for="isAvailable">Is Available for Sale?</label>
                            <select name="isAvailable" id="isAvailable" style="padding: 8px;">
                                <option value="true" <%= (isEditMode && productToEdit.isAvailable()) || !isEditMode ? "selected" : "" %>>Yes</option>
                                <option value="false" <%= isEditMode && !productToEdit.isAvailable() ? "selected" : "" %>>No</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary"><%= submitButtonText %></button>
                         <% if (isEditMode) { %>
                            <a href="<%= contextPath %>/adminDashboard?section=inventory" class="btn btn-secondary" style="margin-left:10px;">Cancel</a>
                        <% } %>
                    </form>
                </div>
            </div>

           <%-- Order Details Section --%>
            <div id="orderDetails" class="details section">
                <div class="recentOrders" style="max-width: 900px; margin: 20px auto;">
                     <% Order detailedOrder = (Order) request.getAttribute("detailedOrder");
                        if (detailedOrder != null) { %>
                        <div class="cardHeader" style="display:flex; justify-content:space-between; align-items:center; margin: 10px;">
                            <h2>Order Details: #<%= detailedOrder.getOrderId() %></h2>
                            <a href="<%= contextPath %>/adminDashboard?section=orders" class="btn btn-secondary" style="padding: 6px 10px; font-size: 0.9em;">Back to All Orders</a>
                        </div>
                        <div style="padding:15px; background: #fff; border-radius:8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                            <p style="margin: 10px;"><strong>User ID:</strong> <%= detailedOrder.getUserId() %></p>
                            <p style="margin: 10px;"><strong>Order Date:</strong> <%= detailedOrder.getOrderDate() != null ? tableDateFormat.format(detailedOrder.getOrderDate()) : "N/A" %></p>
                            <p style="margin: 10px;"><strong>Total Amount:</strong> ₹<%= detailedOrder.getTotalAmount().setScale(2, BigDecimal.ROUND_HALF_UP) %></p>
                            <p style="margin: 10px;"><strong>Status:</strong> <span class="status-<%= detailedOrder.getStatus().toLowerCase().replaceAll("\\s+", "-") %>"><%= detailedOrder.getStatus() %></span></p>
                            <p style="margin: 10px;"><strong>Shipping Address:</strong> <%= detailedOrder.getShippingAddress() != null ? detailedOrder.getShippingAddress() : "N/A" %></p>
                            <p style="margin: 10px;"><strong>Contact on Order:</strong> <%= detailedOrder.getContactOnOrder() != null ? detailedOrder.getContactOnOrder() : "N/A" %></p>

                            <h4 style="margin-top:15px; margin-bottom:10px; border-bottom:1px solid #eee; padding-bottom:5px; margin-left: 10px;">Items in this Order:</h4>
                            <% if (detailedOrder.getOrderItems() != null && !detailedOrder.getOrderItems().isEmpty()) { %>
                                <table class="myTable" style="margin-top:0;">
                                    <thead><tr><th>Product ID</th><th>Name</th><th>Qty</th><th>Price Paid (₹)</th><th>Subtotal (₹)</th></tr></thead>
                                    <tbody>
                                    <%  // ProductDAO tempProductDAO = new ProductDAO(); // Not needed if product name is in OrderItem
                                        for (com.gms.model.OrderItem item : detailedOrder.getOrderItems()) {
                                        
                                        String productNameForDisplay = item.getProductName() != null ? item.getProductName() : "Product Name N/A";
                                    %>
                                    	
                                        <tr>
                                            <td><%= item.getProductId() %></td>
                                            <td><%= productNameForDisplay %></td>
                                            <td><%= item.getQuantity() %></td>
                                            <td><%= item.getPriceAtPurchase().setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                            <td><%= item.getPriceAtPurchase().multiply(new BigDecimal(item.getQuantity())).setScale(2, BigDecimal.ROUND_HALF_UP) %></td>
                                        </tr>
                                    <% } %>
                                    </tbody>
                                </table>
                            <% } else { %><p>No items found for this order.</p><% } %>
                        </div>
                    <% } else if ("orderDetails".equals(activeSection)) { %>
                        <p style="text-align:center; padding:20px;">Order details could not be loaded or order not found.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div id="confirmationModal" class="modal">
      <div class="modal-content">
        <h3 id="modalTitle">Confirm Action</h3>
        <p id="modalMessage">Are you sure?</p>
        <div class="modal-buttons">
            <button type="button" id="modalCancelBtn" class="btn btn-secondary">Cancel</button>
            <button type="button" id="modalConfirmBtn" class="btn btn-danger">Confirm</button>
        </div>
      </div>
    </div>

    <script>
    
	    function handleCategoryChange(selectedValue) {
	        var newCategoryGroup = document.getElementById('newCategoryGroup');
	        var newProductCategoryInput = document.getElementById('newProductCategory');
	        if (selectedValue === '_new_') {
	            newCategoryGroup.style.display = 'block';
	            newProductCategoryInput.setAttribute('required', 'required'); // Make it required if new is chosen
	        } else {
	            newCategoryGroup.style.display = 'none';
	            newProductCategoryInput.removeAttribute('required'); // No longer required
	            newProductCategoryInput.value = ''; // Clear it if user switches away
	        }
	    }
	    
	    function validateNoNumbersInText(inputId, errorId, fieldName) {
            const inputElement = document.getElementById(inputId);
            const errorElement = document.getElementById(errorId);
            if (!inputElement || !errorElement) return true;

            const value = inputElement.value; 

            // Regex to check if the string contains any digit
            const hasNumberRegex = /\d/;

            if (value === "" && inputElement.hasAttribute('required')) {
                 errorElement.textContent = ""; 
                 errorElement.style.display = 'none';
                 return true; 
            } else if (hasNumberRegex.test(value)) {
                errorElement.textContent = fieldName + " cannot contain numbers. Only text/letters are allowed.";
                errorElement.style.display = 'block';
                return false;
            } else if (value.length > 0 && !/^[a-zA-Z\s]*$/.test(value)) {
                 // This regex checks if it's only letters and spaces.
                 errorElement.textContent = fieldName + " should only contain letters and spaces.";
                 errorElement.style.display = 'block';
                 return false;
            }
            else {
                errorElement.textContent = "";
                errorElement.style.display = 'none';
                return true;
            }
        }

        var productNameInput = document.getElementById('productName');
        if (productNameInput) {
            productNameInput.oninput = function() {
                validateNoNumbersInText('productName', 'productNameError', 'Product Name');
            };
        }

        var newProductCategoryInputForValidation = document.getElementById('newProductCategory');
        if (newProductCategoryInputForValidation) {
            newProductCategoryInputForValidation.oninput = function() {
                validateNoNumbersInText('newProductCategory', 'newProductCategoryError', 'New Category Name');
            };
        }

        var productForm = document.getElementById('productForm');
        if (productForm) {
            productForm.addEventListener('submit', function(event) {
                let formIsValid = true;
                // Validate Product Name
                formIsValid = validateNoNumbersInText('productName', 'productNameError', 'Product Name') && formIsValid;

                // Validate New Category Name if that option is selected
                const categorySelect = document.getElementById('productCategorySelect');
                const newProductCategoryInput = document.getElementById('newProductCategory');
                if (categorySelect && categorySelect.value === '_new_') {
                    if (newProductCategoryInput.value.trim() === "" && newProductCategoryInput.hasAttribute('required')) {
                         const newCategoryErrorElement = document.getElementById('newProductCategoryError');
                         if(newCategoryErrorElement) {
                            newCategoryErrorElement.textContent = 'New Category Name cannot be empty.';
                            newCategoryErrorElement.style.display = 'block';
                         }
                         formIsValid = false;
                    } else {
                        formIsValid = validateNoNumbersInText('newProductCategory', 'newProductCategoryError', 'New Category Name') && formIsValid;
                    }
                }

                if (!formIsValid) {
                    event.preventDefault(); // Stop form submission
                    alert("Please correct the highlighted errors. Fields should only contain text/letters and no numbers.");
                }
            });
        }


        function toggleCustomDateInputs(selectedValue) {
            var customDateDiv = document.getElementById('customDateInputs');
            if (!customDateDiv) return;
            if (selectedValue === 'custom') {
                customDateDiv.style.display = 'flex'; 
            } else {
                customDateDiv.style.display = 'none';
                var startDateInput = document.getElementById('customStartDate');
                var endDateInput = document.getElementById('customEndDate');
                if(startDateInput) startDateInput.value = '';
                if(endDateInput) endDateInput.value = '';
            }
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            let toggle = document.querySelector('.main .topbar .toggle ion-icon');
            let navigation = document.querySelector('.navigation');
            let mainContent = document.querySelector('.main');
            let categorySelect = document.getElementById('productCategorySelect');
            
            if (categorySelect) {
                handleCategoryChange(categorySelect.value); // Initialize based on current selection
            
                <% if (isEditMode && !currentProductCategory.isEmpty() && !distinctCategories.contains(currentProductCategory)) { %>
                   
                  
                    categorySelect.value = "_new_";
                    document.getElementById('newProductCategory').value = "<%= currentProductCategory.replace("'", "\\\\'") %>";
                    handleCategoryChange("_new_");
                <% } %>
            }

            if(toggle && navigation && mainContent) {
                toggle.onclick = function(){
                    navigation.classList.toggle('active');
                    mainContent.classList.toggle('active'); 
                }
            }
            
            const urlParams = new URLSearchParams(window.location.search);
            const currentSectionFromUrl = urlParams.get('section') || 'dashboard';
            const navLinks = document.querySelectorAll('.navigation ul li a');

            navLinks.forEach(link => {
                const linkSection = link.getAttribute('data-section') || (link.href.includes('section=addItem') ? 'addItem' : null);
                link.classList.remove('active-nav'); 
                if(link.parentElement) link.parentElement.classList.remove('hovered');

                if (linkSection === currentSectionFromUrl) {
                    link.classList.add('active-nav');
                    if(link.parentElement) link.parentElement.classList.add('hovered');
                } else if (linkSection === 'addItem' && currentSectionFromUrl === "editItem") {
                     link.classList.add('active-nav'); 
                     if(link.parentElement) link.parentElement.classList.add('hovered');
                }
            });
            
            const sections = document.querySelectorAll('.details.section');
            sections.forEach(section => {
                section.classList.remove('active'); // Remove active from all first
                if (section.id === currentSectionFromUrl) {
                    section.classList.add('active');
                }
            });
             if (currentSectionFromUrl === "editItem") { 
                const addItemSection = document.getElementById('addItem');
                if(addItemSection) {
                    addItemSection.classList.add('active');
                }
            }

            var dateRangeDropdown = document.getElementById('dateRange');
            if(dateRangeDropdown) {
                 toggleCustomDateInputs(dateRangeDropdown.value);
            }
        });

        // Custom Modal JavaScript
        const confirmationModal = document.getElementById('confirmationModal');
        const modalTitleElem = document.getElementById('modalTitle'); // Renamed to avoid conflict
        const modalMessageElem = document.getElementById('modalMessage'); // Renamed
        const modalConfirmBtn = document.getElementById('modalConfirmBtn');
        const modalCancelBtn = document.getElementById('modalCancelBtn');
        let currentFormToSubmit = null;

        function showConfirmationModal(title, message, formId) {
            if (!confirmationModal || !modalTitleElem || !modalMessageElem) {
                // Fallback for safety, though ideally modal elements are always present
                if (confirm(message.replace(/<br\s*\/?>/ig, "\\n"))) { 
                     const formToSubmit = document.getElementById(formId);
                     if (formToSubmit) formToSubmit.submit();
                }
                return;
            }
            modalTitleElem.textContent = title;
            modalMessageElem.innerHTML = message; 
            currentFormToSubmit = document.getElementById(formId);
            confirmationModal.style.display = "flex";
        }

        if (modalConfirmBtn) {
            modalConfirmBtn.onclick = function() {
                if (currentFormToSubmit) {
                    currentFormToSubmit.submit();
                }
                confirmationModal.style.display = "none";
                currentFormToSubmit = null;
            }
        }

        if (modalCancelBtn) {
            modalCancelBtn.onclick = function() {
                confirmationModal.style.display = "none";
                currentFormToSubmit = null;
            }
        }

        window.onclick = function(event) {
            if (event.target == confirmationModal) {
                confirmationModal.style.display = "none";
                currentFormToSubmit = null;
            }
        }

    </script>
    <script type="module" src="https://unpkg.com/ionicons@5.5.2/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@5.5.2/dist/ionicons/ionicons.js"></script>
</body>
</html>