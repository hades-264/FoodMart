package com.gms.servlet;
import com.gms.dao.ProductDAO;
import com.gms.dbutil.IdGenerator;
import com.gms.model.Product;
import com.gms.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig; // IMPORTANT!
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part; // IMPORTANT!
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.math.BigDecimal;
import java.sql.Timestamp; // If you are setting created_at or updated_at

@WebServlet("/AdminProductServlet") // Or your chosen URL for this servlet
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 10, // 10 MB
    maxRequestSize = 1024 * 1024 * 15 // 15 MB
)
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO;
    // private UserDAO userDAO; // If needed for admin session validation

    @Override
    public void init() {
        productDAO = new ProductDAO();
        // userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        // --- Admin Authentication/Authorization Check ---
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please_login_as_admin");
            return;
        }
        User loggedInAdmin = (User) session.getAttribute("loggedInUser");
        if (!"ADMIN".equals(loggedInAdmin.getRole())) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Access_denied_Admin_login_required");
            return;
        }
        // --- End Admin Check ---


        String action = request.getParameter("action");
        String sourcePage = request.getParameter("sourcePage"); // e.g., "adminDashboard"
        String sourceSection = request.getParameter("sourceSection"); // e.g., "inventory"
        String redirectParams = "?section=" + (sourceSection != null ? sourceSection : "inventory");

        // Append date filter parameters to redirect if they exist
        String dateRange = request.getParameter("dateRange");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        if (dateRange != null) redirectParams += "&dateRange=" + dateRange;
        if (startDate != null && "custom".equals(dateRange)) redirectParams += "&startDate=" + startDate;
        if (endDate != null && "custom".equals(dateRange)) redirectParams += "&endDate=" + endDate;


        try {
            if ("ADD_PRODUCT".equals(action) || "UPDATE_PRODUCT".equals(action)) {
                boolean isEditMode = "UPDATE_PRODUCT".equals(action);

                String productId;
                Product product;

                if (isEditMode) {
                    productId = request.getParameter("productId");
                    product = productDAO.findProductById(productId);
                    if (product == null) {
                        session.setAttribute("formSubmissionMessage", "Error: Product not found for editing.");
                        response.sendRedirect(request.getContextPath() + "/" + sourcePage + redirectParams);
                        return;
                    }
                } else { // Adding new product
                    // 1. Generate UNIQUE Product ID
                    productId = IdGenerator.generateUniqueProductId(productDAO);
                    product = new Product();
                    product.setProductId(productId);
                }

                // 2. Handle File Upload and Determine serverImageFileName
                Part filePart = request.getPart("productImageFile"); // Matches name in <input type="file">
                String serverImageFileName = isEditMode ? product.getImageFileName() : "placeholder.jpg"; // Default to existing or placeholder

                if (filePart != null && filePart.getSize() > 0) {
                    String originalSubmittedFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    if (originalSubmittedFileName != null && !originalSubmittedFileName.isEmpty()) {
                        String fileExtension = "";
                        int i = originalSubmittedFileName.lastIndexOf('.');
                        if (i > 0) {
                            fileExtension = originalSubmittedFileName.substring(i); // e.g., ".jpg"
                        }

                        // Construct the unique server filename using the product's ID
                        serverImageFileName = productId + fileExtension; // e.g., "3-4521-7384-9.jpg"

                        // Define the upload path on the server (directly into webapp/images/)
                        String applicationPath = getServletContext().getRealPath("");
                        String uploadDirectory = applicationPath + File.separator + "images";

                        File uploadDirFile = new File(uploadDirectory);
                        if (!uploadDirFile.exists()) {
                            uploadDirFile.mkdirs();
                        }

                        File imageFileOnDisk = new File(uploadDirFile, serverImageFileName);

                        try (InputStream fileContent = filePart.getInputStream()) {
                            Files.copy(fileContent, imageFileOnDisk.toPath(), StandardCopyOption.REPLACE_EXISTING);
//                            System.out.println("AdminProductServlet: Image saved as: " + imageFileOnDisk.getAbsolutePath());
                        } catch (IOException e) {
                            System.err.println("AdminProductServlet: Error saving uploaded image: " + e.getMessage());
                            // If saving fails, and it's a new product, revert to placeholder.
                            // If it's an edit and new image fails, keep the old image name (already set in serverImageFileName)
                            if (!isEditMode) {
                                serverImageFileName = "placeholder.jpg";
                            }
                            session.setAttribute("formSubmissionMessage", "Error: Could not save product image. " + e.getMessage());
                            // Continue to save product data but with placeholder/old image name
                        }
                    }
                }
                // If it's an edit and no new file was uploaded, serverImageFileName already holds the existing image name.
                // If it's ADD and no file was uploaded, serverImageFileName remains "placeholder.png".


                // 3. Populate Product Object
                product.setProductName(request.getParameter("productName"));
                product.setProductDescription(request.getParameter("productDescription"));
                product.setCategory(request.getParameter("productCategory"));
                product.setPrice(new BigDecimal(request.getParameter("productPrice")));
                product.setAvailableQuantity(Integer.parseInt(request.getParameter("itemQuantity")));
                product.setImageFileName(serverImageFileName); // THIS IS WHAT'S STORED IN DB
                product.setAvailable(Boolean.parseBoolean(request.getParameter("isAvailable")));
                // product.setUpdatedAt(new Timestamp(System.currentTimeMillis())); // Set update time

                // 4. Save to Database
                boolean dbSuccess;
                if (isEditMode) {
                    dbSuccess = productDAO.updateProduct(product);
                } else {
                    dbSuccess = productDAO.addProduct(product);
                }

                if (dbSuccess) {
                    session.setAttribute("formSubmissionMessage", "Success: Product " + (isEditMode ? "updated" : "added") + " successfully (ID: " + product.getProductId() + ").");
                } else {
                    session.setAttribute("formSubmissionMessage", "Error: Failed to " + (isEditMode ? "update" : "add") + " product in database.");
                    // Consider deleting the uploaded image if DB operation failed for a new product
                    if (!isEditMode && !serverImageFileName.equals("placeholder.png")) {
                        String applicationPath = getServletContext().getRealPath("");
                        String uploadDirectory = applicationPath + File.separator + "images";
                        File potentiallyOrphanedImage = new File(uploadDirectory, serverImageFileName);
                        if (potentiallyOrphanedImage.exists()) {
                            potentiallyOrphanedImage.delete();
                        }
                    }
                }

            } else if ("MARK_UNAVAILABLE".equals(action) || "MARK_AVAILABLE".equals(action)) {
                String prodId = request.getParameter("productId");
                boolean makeAvailable = "MARK_AVAILABLE".equals(action);
                boolean success = false;
                if (prodId != null && !prodId.isEmpty()) {
                    if (makeAvailable) {
                        success = productDAO.markProductAsAvailable(prodId);
                    } else {
                        success = productDAO.markProductAsUnavailable(prodId);
                    }
                }
                if (success) {
                    session.setAttribute("formSubmissionMessage", "Success: Product " + prodId + " availability updated.");
                } else {
                    session.setAttribute("formSubmissionMessage", "Error: Failed to update product " + prodId + " availability.");
                }
            } else {
                 session.setAttribute("formSubmissionMessage", "Error: Unknown product action.");
            }

        } catch (Exception e) {
            e.printStackTrace(); // Log properly
            session.setAttribute("formSubmissionMessage", "Error: An unexpected error occurred. " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/" + (sourcePage != null ? sourcePage : "adminDashboard") + redirectParams);
    }
}