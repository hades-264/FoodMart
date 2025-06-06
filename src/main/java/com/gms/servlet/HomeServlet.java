package com.gms.servlet;

import com.gms.dao.ProductDAO;
import com.gms.dao.UserDAO;
import com.gms.model.CartItem;
import com.gms.model.Product;
import com.gms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please login to access the home page.");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        String userIdFromSession = loggedInUser.getUserId();
        User freshUser = userDAO.findUserById(userIdFromSession);
        String userNameForGreeting = "User";
        String userRole = "CUSTOMER";

        if (freshUser != null) {
            loggedInUser = freshUser; // Use the fresh user data
            userNameForGreeting = loggedInUser.getUserName() != null && !loggedInUser.getUserName().isEmpty() ? loggedInUser.getUserName() : "Valued Customer";
            userRole = loggedInUser.getRole();
            // Update session with fresh user data
            session.setAttribute("loggedInUser", loggedInUser);
            session.setAttribute("userName", userNameForGreeting); // Use the determined greeting name
            session.setAttribute("userRole", userRole);
        } else {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Session error. Please login again.");
            return;
        }

        request.setAttribute("userNameForGreeting", userNameForGreeting);
        request.setAttribute("userRoleForPage", userRole);

        List<Product> availableProducts = productDAO.getAllAvailableProducts();
        request.setAttribute("productList", availableProducts != null ? availableProducts : new ArrayList<Product>());

        if (availableProducts != null) {
            List<String> categories = availableProducts.stream()
                                                 .map(Product::getCategory)
                                                 .filter(c -> c != null && !c.isEmpty())
                                                 .distinct()
                                                 .sorted()
                                                 .collect(Collectors.toList());
            request.setAttribute("categoryList", categories);
        } else {
            request.setAttribute("categoryList", new ArrayList<String>());
        }

        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please login to perform cart actions.");
            return;
        }

        String action = request.getParameter("action");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
        }

        String cartMessage = null;

        try {
            if (productId != null && !productId.isEmpty()) {
                Product product = productDAO.findProductById(productId); // Fetch product details

                if (product == null) {
                    cartMessage = "Error: Product not found.";
                } else {
                    if ("ADD".equalsIgnoreCase(action)) {
                        int quantity = 1; // Default quantity for quick add
                        if (quantityStr != null && !quantityStr.isEmpty()) {
                            try {
                                quantity = Integer.parseInt(quantityStr);
                                if (quantity < 1) quantity = 1;
                            } catch (NumberFormatException e) {
                                quantity = 1; // Default if parsing fails
                            }
                        }

                        boolean itemExists = false;
                        for (CartItem item : cart) {
                            if (item.getProductId().equals(productId)) {
                                // Item already in cart, update quantity
                                int newQuantity = item.getQuantity() + quantity;
                                if (newQuantity <= product.getAvailableQuantity()) {
                                    item.setQuantity(newQuantity);
                                    cartMessage = product.getProductName() + " quantity updated in cart.";
                                } else {
                                    cartMessage = "Error: Not enough stock for " + product.getProductName() + ". Max available: " + product.getAvailableQuantity();
                                }
                                itemExists = true;
                                break;
                            }
                        }
                        if (!itemExists) {
                            if (quantity <= product.getAvailableQuantity()) {
                                CartItem newItem = new CartItem();
                                newItem.setProductId(product.getProductId());
                                newItem.setProductName(product.getProductName());
                                newItem.setUnitPrice(product.getPrice());
                                newItem.setQuantity(quantity);
                                newItem.setImageFileName(product.getImageFileName());
                                cart.add(newItem);
                                cartMessage = product.getProductName() + " added to cart.";
                            } else {
                                 cartMessage = "Error: Not enough stock to add " + product.getProductName() + ". Available: " + product.getAvailableQuantity();
                            }
                        }
                    } else if ("UPDATE".equalsIgnoreCase(action)) {
                        int quantity = 1;
                        if (quantityStr != null && !quantityStr.isEmpty()) {
                            try {
                                quantity = Integer.parseInt(quantityStr);
                            } catch (NumberFormatException e) {
                                cartMessage = "Error: Invalid quantity format.";
                                // No further processing if quantity is invalid
                                session.setAttribute("cartMessage", cartMessage);
                                response.sendRedirect(request.getContextPath() + "/home");
                                return;
                            }
                        }

                        if (quantity < 1) { // If user tries to set quantity to 0 or less, remove item
                            cart.removeIf(item -> item.getProductId().equals(productId));
                            cartMessage = product.getProductName() + " removed from cart.";
                        } else {
                            for (CartItem item : cart) {
                                if (item.getProductId().equals(productId)) {
                                    if (quantity <= product.getAvailableQuantity()) {
                                        item.setQuantity(quantity);
                                        cartMessage = product.getProductName() + " quantity updated.";
                                    } else {
                                        cartMessage = "Error: Not enough stock for " + product.getProductName() + ". Max available: " + product.getAvailableQuantity();
                                    }
                                    break;
                                }
                            }
                        }
                    } else if ("REMOVE".equalsIgnoreCase(action)) {
                        cart.removeIf(item -> item.getProductId().equals(productId));
                        cartMessage = product.getProductName() + " removed from cart.";
                    }
                }
            } else {
                cartMessage = "Error: Product ID is missing for cart action.";
            }
        } catch (Exception e) {
            e.printStackTrace(); // Log this
            cartMessage = "Error: An unexpected error occurred while updating your cart.";
        }

        // Recalculate total
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cart) {
            total = total.add(item.getSubtotal()); // Assuming CartItem has getSubtotal()
        }

        session.setAttribute("cart", cart);
        session.setAttribute("cartTotal", total);
        if (cartMessage != null) {
            session.setAttribute("cartMessage", cartMessage);
        }

        // Redirect back to the home page (or specific cart page if you have one)
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
