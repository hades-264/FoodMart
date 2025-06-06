package com.gms.servlet;

import com.gms.dao.ProductDAO;
import com.gms.model.CartItem;
import com.gms.model.OrderItem;
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
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List; // For potential related products

@WebServlet("/productDetail")
public class ProductDetailServlet extends HttpServlet {
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
        String userRoleForPage = "GUEST"; // Default role
        User loggedInUser = null;

        if (session != null && session.getAttribute("loggedInUser") != null) {
            loggedInUser = (User) session.getAttribute("loggedInUser");
            userNameForGreeting = loggedInUser.getUserName();
            userRoleForPage = loggedInUser.getRole();
        }
        request.setAttribute("userNameForGreeting", userNameForGreeting);
        request.setAttribute("userRoleForPage", userRoleForPage); // Pass role to JSP

        String productId = request.getParameter("id");
        Product product = null;
        String errorMessage = null;

        if (productId == null || productId.trim().isEmpty()) {
            errorMessage = "Product ID is missing.";
        } else {
            product = productDAO.findProductById(productId.trim()); // Fetches product details
            if (product == null) {
                errorMessage = "Product not found.";
            } else if (!product.isAvailable() && !"ADMIN".equals(userRoleForPage)) {
                // If product is marked as unavailable and user is not admin, show different message or limit view
                errorMessage = "This product is currently unavailable.";
                // Optionally, still allow viewing some details but disable "Add to Cart"
                // For now, we'll still pass the product to the JSP if found,
                // and the JSP can handle the display based on product.isAvailable()
            }
        }

        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
        }
        request.setAttribute("product", product); // Pass product (even if null or unavailable, JSP handles display)

             // Optional: Fetch related products by category (excluding the current one)
        if (product != null && product.getCategory() != null && product.isAvailable()) {
            List<Product> fetchedRelatedProducts = productDAO.getAvailableProductsByCategory(product.getCategory());

            if (fetchedRelatedProducts != null) {
                List<Product> relatedProducts = new ArrayList<>(fetchedRelatedProducts);

                final Product currentProductForLambda = product;

                if (currentProductForLambda.getProductId() != null) {
                    relatedProducts.removeIf(p -> p != null && p.getProductId() != null && p.getProductId().equals(currentProductForLambda.getProductId()));
                }

                if (relatedProducts.size() > 4) {
                    relatedProducts = relatedProducts.subList(0, Math.min(relatedProducts.size(), 4));
                }
                request.setAttribute("relatedProducts", relatedProducts);
            } else {
                request.setAttribute("relatedProducts", new ArrayList<Product>());
            }
        } else if (product != null) { 
             request.setAttribute("relatedProducts", new ArrayList<Product>());
        }

        request.getRequestDispatcher("/productDetail.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        
        System.out.println(loggedInUser.getUserName() + "1");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please_login_to_perform_this_action");
            return;
        }

        String action = request.getParameter("action");
        String returnUrlFromRequest = request.getParameter("returnUrl"); // Get the returnUrl

        if (action == null || action.trim().isEmpty()) {
            // Default to viewing the cart if no action
            response.sendRedirect(request.getContextPath() + "/cart.jsp");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        // Default redirect URL is cart.jsp, but can be overridden by returnUrlFromRequest
        String finalRedirectUrl = request.getContextPath() + "/cart.jsp"; 

        try {
            switch (action.toUpperCase()) {
                case "ADD":
                	System.out.println(loggedInUser.getUserName() + "2") ;
                    handleAddAction(request, cart);
                    System.out.println(loggedInUser.getUserName() + "3");
                    break;
           
                default:
                    session.setAttribute("cartMessage", "Unknown cart action: " + action);
                    finalRedirectUrl = request.getContextPath() + "/home"; // Or some default page
                    break;
            }
        } catch (NumberFormatException e) {
            System.err.println("CartServlet: Invalid number format. " + e.getMessage());
            session.setAttribute("cartMessage", "Error: Invalid quantity or number format.");
            // Redirect back to a sensible page, maybe the referer if available or home
            finalRedirectUrl = (returnUrlFromRequest != null && !returnUrlFromRequest.isEmpty()) ? 
                               URLDecoder.decode(returnUrlFromRequest, "UTF-8") : 
                               request.getContextPath() + "/home";
        } catch (Exception e) {
            System.err.println("CartServlet: Error processing cart action. " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("cartMessage", "Error: Could not update cart due to a system error.");
            finalRedirectUrl = (returnUrlFromRequest != null && !returnUrlFromRequest.isEmpty()) ? 
                               URLDecoder.decode(returnUrlFromRequest, "UTF-8") : 
                               request.getContextPath() + "/home";
        }

        // Update cart total needs to happen BEFORE the "PROCEED_TO_CHECKOUT" case
        // if that case relies on the latest total from session (though OrderReviewServlet recalculates).
        // It's good to keep it updated generally.
        updateCartTotal(session, cart); 

        response.sendRedirect(finalRedirectUrl);
    }
    
    private void handleAddAction(HttpServletRequest request, List<CartItem> cart) {
        String productId = request.getParameter("productId");
        int quantityToAdd = 1; 
        System.out.println(request.getParameter("productName"));

        try {
            if (request.getParameter("quantity") != null && !request.getParameter("quantity").isEmpty()) {
                quantityToAdd = Integer.parseInt(request.getParameter("quantity"));
            }
            if (quantityToAdd <= 0) {
                request.getSession().setAttribute("cartMessage", "Error: Quantity must be at least 1.");
                return; // Early exit if quantity is invalid
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("cartMessage", "Error: Invalid quantity format.");
            return; // Early exit
        }

        if (productId != null && !productId.isEmpty()) {
            Product product = productDAO.findProductById(productId); //

            if (product != null && product.isAvailable()) {
                boolean itemExistsInCart = false;
                for (CartItem item : cart) {
                    if (item.getProductId().equals(productId)) {
                        int newQuantity = item.getQuantity() + quantityToAdd;
                        if (newQuantity <= product.getAvailableQuantity()) {
                            item.setQuantity(newQuantity);
                            request.getSession().setAttribute("cartMessage", product.getProductName() + " quantity updated in cart.");
                        } else {
                            // Optionally, set to max available or just show error
                            item.setQuantity(product.getAvailableQuantity()); // Set to max available
                            request.getSession().setAttribute("cartMessage", "Max stock for " + product.getProductName() + " is " + product.getAvailableQuantity() + ". Cart updated to max.");
                        }
                        itemExistsInCart = true;
                        break;
                    }
                }

                if (!itemExistsInCart) {
                    if (quantityToAdd <= product.getAvailableQuantity()) {
                        CartItem newItem = new CartItem(product, quantityToAdd); // Assuming constructor sets details from Product
                        cart.add(newItem);
                        request.getSession().setAttribute("cartMessage", product.getProductName() + " (Qty: " + quantityToAdd + ") added to cart.");
                    } else {
                         request.getSession().setAttribute("cartMessage", "Error: Requested quantity for " + product.getProductName() + " (" + quantityToAdd + ") exceeds available stock (" + product.getAvailableQuantity() + ").");
                    }
                }
            } else if (product != null && !product.isAvailable()) {
                request.getSession().setAttribute("cartMessage", "Error: " + product.getProductName() + " is currently unavailable.");
            } else {
                request.getSession().setAttribute("cartMessage", "Error: Product not found.");
            }
        } else {
            request.getSession().setAttribute("cartMessage", "Error: Product ID missing.");
        }
    }

    private void handleUpdateAction(HttpServletRequest request, List<CartItem> cart) {
        String productId = request.getParameter("productId");
        int newQuantity = 0;
        try {
            newQuantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("cartMessage", "Error: Invalid quantity for update.");
            return;
        }

        if (productId != null && !productId.isEmpty()) {
            Product product = productDAO.findProductById(productId); //
            if (product == null) {
                request.getSession().setAttribute("cartMessage", "Error: Product not found for update.");
                return;
            }

            Iterator<CartItem> iterator = cart.iterator();
            while (iterator.hasNext()) {
                CartItem item = iterator.next();
                if (item.getProductId().equals(productId)) {
                    if (newQuantity <= 0) {
                        iterator.remove();
                        request.getSession().setAttribute("cartMessage", item.getProductName() + " removed from cart.");
                    } else if (newQuantity <= product.getAvailableQuantity()) {
                        item.setQuantity(newQuantity); 
                        request.getSession().setAttribute("cartMessage", item.getProductName() + " quantity updated to " + newQuantity + ".");
                    } else {
                        item.setQuantity(product.getAvailableQuantity()); 
                        request.getSession().setAttribute("cartMessage", "Max available stock for " + item.getProductName() + " is " + product.getAvailableQuantity() + ". Quantity updated.");
                    }
                    break; 
                }
            }
        } else {
             request.getSession().setAttribute("cartMessage", "Error: Product ID missing for update.");
        }
    }

    private void handleRemoveAction(HttpServletRequest request, List<CartItem> cart) {
        String productId = request.getParameter("productId");
        if (productId != null && !productId.isEmpty()) {
            final String[] removedProductName = {null}; // To capture product name for message
            boolean removed = cart.removeIf(item -> {
                if (item.getProductId().equals(productId)) {
                    removedProductName[0] = item.getProductName();
                    return true;
                }
                return false;
            });

            if(removed && removedProductName[0] != null){
                 request.getSession().setAttribute("cartMessage", removedProductName[0] + " removed from cart.");
            } else {
                 request.getSession().setAttribute("cartMessage", "Item not found for removal or already removed.");
            }
        } else {
            request.getSession().setAttribute("cartMessage", "Error: Product ID missing for removal.");
        }
    }
    
    // setRemoveMessage helper is not needed if logic is inside handleRemoveAction

    private void updateCartTotal(HttpSession session, List<CartItem> cart) {
        BigDecimal cartTotalValue = BigDecimal.ZERO;
        int totalDistinctItems = 0; 
        int totalQuantityOfAllItems = 0;

        if (cart != null) {
            totalDistinctItems = cart.size();
            for (CartItem item : cart) {
                // Ensure subtotal is calculated if not already (CartItem should handle this ideally)
                item.getSubtotal(); // Assuming getSubtotal() calculates if needed and returns the value
                if (item.getSubtotal() != null) { 
                    cartTotalValue = cartTotalValue.add(item.getSubtotal());
                }
                totalQuantityOfAllItems += item.getQuantity();
            }
        }
        if (session != null) { // Check session again before setting attributes
             session.setAttribute("cartTotal", cartTotalValue.setScale(2, BigDecimal.ROUND_HALF_UP));
             session.setAttribute("cartItemCount", totalDistinctItems); // Number of unique product lines
             session.setAttribute("cartTotalQuantity", totalQuantityOfAllItems); // Total number of all units
        }
    }
}