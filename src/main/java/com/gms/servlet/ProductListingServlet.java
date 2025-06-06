package com.gms.servlet;

import com.gms.dao.ProductDAO;
import com.gms.model.Product;
import com.gms.model.User;
import com.gms.model.CartItem; // Import CartItem for cart count

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/products")
public class ProductListingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userNameForGreeting = "Guest";
        String userRoleForPage = "GUEST";
        User loggedInUser = null;
        int cartItemCount = 0; // Variable for cart item count

        if (session != null) {
            if (session.getAttribute("loggedInUser") != null) {
                loggedInUser = (User) session.getAttribute("loggedInUser");
                userNameForGreeting = loggedInUser.getUserName();
                userRoleForPage = loggedInUser.getRole();
            }
            // Get cart item count
            List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
            if (cart != null) {
                // You can choose to count distinct items or total quantity
                // For distinct items:
                cartItemCount = cart.size();
                // For total quantity of all items:
                // for (CartItem item : cart) {
                //     cartItemCount += item.getQuantity();
                // }
            }
        }
        request.setAttribute("userNameForGreeting", userNameForGreeting);
        request.setAttribute("userRoleForPage", userRoleForPage);
        request.setAttribute("cartItemCount", cartItemCount); // Pass cart count to JSP

        String category = request.getParameter("category");
        // Use "searchQuery" from SearchServlet or "search" from a direct form in this page
        String searchQuery = request.getParameter("searchQuery"); 
        if (searchQuery == null) {
            searchQuery = request.getParameter("search"); // Fallback for direct search
        }


        List<Product> productList;
        String pageTitle = "Our Products";

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            productList = productDAO.searchAvailableProductsByName(searchQuery.trim()); //
            pageTitle = "Search Results for \"" + sanitizeHTML(searchQuery.trim()) + "\"";
            request.setAttribute("searchQuery", sanitizeHTML(searchQuery.trim()));
        } else if (category != null && !category.trim().isEmpty()) {
            productList = productDAO.getAvailableProductsByCategory(category.trim()); //
            pageTitle = "Products in " + sanitizeHTML(category.trim());
        } else {
            productList = productDAO.getAllAvailableProducts(); //
        }

        if (productList == null) {
            productList = new ArrayList<>();
        }
        request.setAttribute("productList", productList);
        request.setAttribute("pageTitle", pageTitle);

        List<Product> allDbProducts = productDAO.getAllAvailableProducts(); //
        if (allDbProducts != null) {
            List<String> allCategories = allDbProducts.stream()
                                                 .map(Product::getCategory)
                                                 .filter(c -> c != null && !c.isEmpty())
                                                 .distinct()
                                                 .sorted()
                                                 .collect(Collectors.toList());
            request.setAttribute("allCategoriesList", allCategories);
        } else {
            request.setAttribute("allCategoriesList", new ArrayList<String>());
        }

        request.getRequestDispatcher("/productListing.jsp").forward(request, response);
    }

    private String sanitizeHTML(String input) {
        if (input == null) return null;
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
}