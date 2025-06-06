package com.gms.dao;

import com.gms.dbutil.DBUtil;
import com.gms.model.Product;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    /**
     * Adds a new product to the database.
     *
     * @param product The Product object to add.
     * @return true if the product was added successfully, false otherwise.
     */
    public boolean addProduct(Product product) {
    	String sql = "INSERT INTO GMSAPP.PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, PRICE, AVAILABLE_QUANTITY, CATEGORY, IMAGE_FILE_NAME, IS_AVAILABLE) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, product.getProductId());
            pstmt.setString(2, product.getProductName());
            pstmt.setString(3, product.getProductDescription());
            pstmt.setBigDecimal(4, product.getPrice());
            pstmt.setInt(5, product.getAvailableQuantity());
            pstmt.setString(6, product.getCategory());
            pstmt.setString(7, product.getImageFileName());
            pstmt.setBoolean(8, product.isAvailable());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error adding product: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    /**
     * Finds a product by its ID.
     *
     * @param productId The ID of the product to find.
     * @return A Product object if found, null otherwise.
     */
    public Product findProductById(String productId) {
        String sql = "SELECT * FROM GMSAPP.PRODUCTS WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Product product = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, productId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                product = new Product();
                product.setProductId(rs.getString("PRODUCT_ID"));
                product.setProductName(rs.getString("PRODUCT_NAME"));
                product.setProductDescription(rs.getString("PRODUCT_DESCRIPTION"));
                product.setPrice(rs.getBigDecimal("PRICE"));
                product.setAvailableQuantity(rs.getInt("AVAILABLE_QUANTITY"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageFileName(rs.getString("IMAGE_FILE_NAME"));
                product.setAvailable(rs.getBoolean("IS_AVAILABLE"));
            }
        } catch (SQLException e) {
            System.err.println("Error finding product by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return product;
    }
    
    
    public boolean markProductAsAvailable(String productId, int initialStock) {
        // When making a product available, it's often good to also set its stock.
        // If initialStock is < 0, it means don't change current stock, just the flag.
        // However, a simpler approach is to always require a valid stock when making available.
        // For this version, we'll update both IS_AVAILABLE and AVAILABLE_QUANTITY.
        if (initialStock < 0) {
             // Or throw an IllegalArgumentException, or handle as "don't update stock"
            System.err.println("Initial stock cannot be negative when marking product as available.");
            return false;
        }

        String sql = "UPDATE GMSAPP.PRODUCTS SET IS_AVAILABLE = TRUE, AVAILABLE_QUANTITY = ? WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, initialStock);
            pstmt.setString(2, productId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error marking product as available: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    // Overloaded version if you just want to flip the IS_AVAILABLE flag
    // and assume stock will be managed separately or was non-zero previously.
    // However, explicitly setting stock when making available is often safer.
    public boolean markProductAsAvailable(String productId) {
        // This version just flips the flag. Admin should ensure stock is > 0 via edit product screen.
        String sql = "UPDATE GMSAPP.PRODUCTS SET IS_AVAILABLE = TRUE WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, productId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error marking product as available (without stock update): " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    /**
     * Retrieves all products from the database.
     *
     * @return A list of all Product objects.
     */
    public List<Product> getAllAvailableProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.PRODUCTS WHERE IS_AVAILABLE = TRUE ORDER BY PRODUCT_NAME";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getString("PRODUCT_ID"));
                product.setProductName(rs.getString("PRODUCT_NAME"));
                product.setProductDescription(rs.getString("PRODUCT_DESCRIPTION"));
                product.setPrice(rs.getBigDecimal("PRICE"));
                product.setAvailableQuantity(rs.getInt("AVAILABLE_QUANTITY"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageFileName(rs.getString("IMAGE_FILE_NAME"));
                product.setAvailable(rs.getBoolean("IS_AVAILABLE"));
                products.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all products: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closeStatement(stmt);
            DBUtil.closeConnection(conn);
        }
        return products;
    }
    
    
    
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.PRODUCTS ORDER BY PRODUCT_NAME";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getString("PRODUCT_ID"));
                product.setProductName(rs.getString("PRODUCT_NAME"));
                product.setProductDescription(rs.getString("PRODUCT_DESCRIPTION"));
                product.setPrice(rs.getBigDecimal("PRICE"));
                product.setAvailableQuantity(rs.getInt("AVAILABLE_QUANTITY"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageFileName(rs.getString("IMAGE_FILE_NAME"));
                product.setAvailable(rs.getBoolean("IS_AVAILABLE"));
                products.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all products: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closeStatement(stmt);
            DBUtil.closeConnection(conn);
        }
        return products;
    }

    /**
     * Retrieves all products belonging to a specific category.
     *
     * @param category The category name to filter by.
     * @return A list of Product objects in that category.
     */
    public List<Product> getAvailableProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.PRODUCTS WHERE CATEGORY = ? AND IS_AVAILABLE = TRUE ORDER BY PRODUCT_NAME";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, category);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getString("PRODUCT_ID"));
                product.setProductName(rs.getString("PRODUCT_NAME"));
                product.setProductDescription(rs.getString("PRODUCT_DESCRIPTION"));
                product.setPrice(rs.getBigDecimal("PRICE"));
                product.setAvailableQuantity(rs.getInt("AVAILABLE_QUANTITY"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageFileName(rs.getString("IMAGE_FILE_NAME"));
                product.setAvailable(rs.getBoolean("IS_AVAILABLE"));
                products.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error getting products by category: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return products;
    }

    /**
     * Updates an existing product's details in the database.
     *
     * @param product The Product object with updated details.
     * @return true if the update is successful, false otherwise.
     */
    public boolean updateProduct(Product product) {
    	String sql = "UPDATE GMSAPP.PRODUCTS SET PRODUCT_NAME = ?, PRODUCT_DESCRIPTION = ?, PRICE = ?, AVAILABLE_QUANTITY = ?, CATEGORY = ?, IMAGE_FILE_NAME = ?, IS_AVAILABLE = ? WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, product.getProductName());
            pstmt.setString(2, product.getProductDescription());
            pstmt.setBigDecimal(3, product.getPrice());
            pstmt.setInt(4, product.getAvailableQuantity());
            pstmt.setString(5, product.getCategory());
            pstmt.setString(6, product.getImageFileName());
            pstmt.setBoolean(7, product.isAvailable());
            pstmt.setString(8, product.getProductId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error updating product: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    /**
     * Updates the available quantity (stock) of a product.
     * Can be used to decrease stock after a sale or increase when stock is added.
     *
     * @param productId The ID of the product to update.
     * @param newQuantity The new available quantity.
     * @return true if the update is successful, false otherwise.
     */
    public boolean updateProductStock(String productId, int newQuantity) {
        String sql = "UPDATE GMSAPP.PRODUCTS SET AVAILABLE_QUANTITY = ? WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newQuantity);
            pstmt.setString(2, productId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error updating product stock: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    /**
     * Marks a product as unavailable (soft delete) and sets its stock to 0.
     * This is the preferred way to "delete" products that might have order history.
     *
     * @param productId The ID of the product to mark as unavailable.
     * @return true if successful, false otherwise.
     */
    public boolean markProductAsUnavailable(String productId) {
        String sql = "UPDATE GMSAPP.PRODUCTS SET IS_AVAILABLE = FALSE, AVAILABLE_QUANTITY = 0 WHERE PRODUCT_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, productId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error marking product as unavailable: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    
//    /**
//     * Deletes a product from the database by its ID.
//     * CAUTION: This will fail if the product is referenced in any ORDER_ITEMS due to foreign key constraints,
//     * unless those constraints are set to ON DELETE CASCADE or ON DELETE SET NULL for PRODUCT_ID.
//     * Consider business rules: should an admin be able to delete a product that has been ordered?
//     * A "soft delete" (marking as unavailable) is often preferred for products with history.
//     *
//     * @param productId The ID of the product to delete.
//     * @return true if deletion is successful, false otherwise.
//     */
//    public boolean deleteProduct(String productId) {
//        String sql = "DELETE FROM GMSAPP.PRODUCTS WHERE PRODUCT_ID = ?";
//        Connection conn = null;
//        PreparedStatement pstmt = null;
//
//        try {
//            conn = DBUtil.getConnection();
//            pstmt = conn.prepareStatement(sql);
//            pstmt.setString(1, productId);
//
//            int rowsAffected = pstmt.executeUpdate();
//            return rowsAffected > 0;
//
//        } catch (SQLException e) {
//            if ("23503".equals(e.getSQLState())) {
//                 System.err.println("Error deleting product: Cannot delete product (ID: " + productId +") as it is referenced in existing orders. Consider marking as unavailable instead.");
//            } else {
//                System.err.println("Error deleting product: " + e.getMessage());
//                e.printStackTrace();
//            }
//            return false;
//        } finally {
//            DBUtil.closePreparedStatement(pstmt);
//            DBUtil.closeConnection(conn);
//        }
//    }

    /**
     * Searches for products by name (case-insensitive partial match).
     * @param searchTerm The string to search for in product names.
     * @return A list of matching Product objects.
     */
    public List<Product> searchAvailableProductsByName(String searchTerm) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.PRODUCTS WHERE LOWER(PRODUCT_NAME) LIKE ? AND IS_AVAILABLE = TRUE ORDER BY PRODUCT_NAME";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + searchTerm.toLowerCase() + "%"); // Wildcards for partial match
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getString("PRODUCT_ID"));
                product.setProductName(rs.getString("PRODUCT_NAME"));
                product.setProductDescription(rs.getString("PRODUCT_DESCRIPTION"));
                product.setPrice(rs.getBigDecimal("PRICE"));
                product.setAvailableQuantity(rs.getInt("AVAILABLE_QUANTITY"));
                product.setCategory(rs.getString("CATEGORY"));
                product.setImageFileName(rs.getString("IMAGE_FILE_NAME"));
                product.setAvailable(rs.getBoolean("IS_AVAILABLE"));
                products.add(product);
            }
        } catch (SQLException e) {
            System.err.println("Error searching products by name: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return products;
    }
}