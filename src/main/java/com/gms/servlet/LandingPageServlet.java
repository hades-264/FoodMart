package com.gms.servlet;

import com.gms.dao.ProductDAO;
import com.gms.model.Product;
import com.gms.model.User; // Import the User model

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // Import HttpSession
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/welcome") // This is the servlet for your landing page (index.jsp)
public class LandingPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false); // Get existing session, don't create new
        User loggedInUser = null;
        boolean isUserLoggedIn = false;

        if (session != null && session.getAttribute("loggedInUser") != null) {
            loggedInUser = (User) session.getAttribute("loggedInUser");
            isUserLoggedIn = true;
            request.setAttribute("userName", loggedInUser.getUserName()); // Pass username to JSP
        }
        request.setAttribute("isUserLoggedIn", isUserLoggedIn); // Pass login status to JSP

        // Your existing code to fetch products and categories
        List<Product> allProducts = productDAO.getAllAvailableProducts();
        request.setAttribute("productList", allProducts != null ? allProducts : new ArrayList<Product>());

        if (allProducts != null) {
            List<String> categories = allProducts.stream()
                                                 .map(Product::getCategory)
                                                 .filter(c -> c != null && !c.isEmpty())
                                                 .distinct()
                                                 .sorted()
                                                 .collect(Collectors.toList());
            request.setAttribute("categoryList", categories);
        } else {
            request.setAttribute("categoryList", new ArrayList<String>());
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}