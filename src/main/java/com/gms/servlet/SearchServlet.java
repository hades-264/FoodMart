package com.gms.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;

/**
 * Servlet to handle search queries from the landing page (index.jsp)
 * and redirect to the ProductListingServlet to display results.
 */
@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public SearchServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the search query parameter from the request
        String searchQuery = request.getParameter("searchQuery");

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            // If a search query is provided, redirect to the ProductListingServlet
            // The ProductListingServlet is already configured to handle the 'searchQuery' parameter
            // We need to URL encode the searchQuery to handle spaces and special characters safely in the URL
            String encodedSearchQuery = URLEncoder.encode(searchQuery.trim(), "UTF-8");
            response.sendRedirect(request.getContextPath() + "/products?searchQuery=" + encodedSearchQuery);
        } else {
            // If no search query is provided, or it's empty,
            // redirect to the general products page (or home page, as appropriate)
            // Redirecting to /products will show all products as per ProductListingServlet logic
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // The search form on index.jsp uses method="get", so doPost is not expected to be called.
        // However, it's good practice to handle it, perhaps by forwarding to doGet.
        doGet(request, response);
    }
}
