package com.gms.dao;

import com.gms.dbutil.DBUtil;
import com.gms.model.Order;
import com.gms.model.OrderItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    /**
     * Creates a new order, including its items, and updates product stock.
     * This entire operation is performed within a single database transaction.
     *
     * @param order The Order object (orderId should be set before calling).
     * The Order object should have its List<OrderItem> populated.
     * Each OrderItem should have productId, quantity, and priceAtPurchase set.
     * @return The ORDER_ID if successful, null otherwise.
     */
    public String createOrder(Order order) {
        Connection conn = null;
        PreparedStatement pstmtOrder = null;
        PreparedStatement pstmtOrderItem = null;
        PreparedStatement pstmtUpdateStock = null;
        PreparedStatement pstmtGetProductDetails = null; // To get product name and image
        PreparedStatement pstmtGetItemCount = null;
        String orderId = order.getOrderId();

        String sqlInsertOrder = "INSERT INTO GMSAPP.ORDERS (ORDER_ID, USER_ID, ORDER_DATE, TOTAL_AMOUNT, STATUS, SHIPPING_ADDRESS, CONTACT_ON_ORDER, ITEM_COUNT) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        // UPDATED: Added IMAGE_FILE_NAME to the INSERT
        String sqlInsertOrderItem = "INSERT INTO GMSAPP.ORDER_ITEMS (ORDER_ID, PRODUCT_ID, PRODUCT_NAME, QUANTITY, PRICE_AT_PURCHASE, IMAGE_FILE_NAME) VALUES (?, ?, ?, ?, ?, ?)";
        String sqlGetProductDetailsForOrder = "SELECT AVAILABLE_QUANTITY, PRODUCT_NAME, IMAGE_FILE_NAME FROM GMSAPP.PRODUCTS WHERE PRODUCT_ID = ? FOR UPDATE";
        String sqlUpdateProductStock = "UPDATE GMSAPP.PRODUCTS SET AVAILABLE_QUANTITY = ? WHERE PRODUCT_ID = ?";

        ProductDAO productDAO = new ProductDAO(); // To fetch product details if needed, though direct query is better here

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into ORDERS
            pstmtOrder = conn.prepareStatement(sqlInsertOrder);
            pstmtOrder.setString(1, orderId);
            pstmtOrder.setString(2, order.getUserId());
            pstmtOrder.setTimestamp(3, order.getOrderDate() != null ? order.getOrderDate() : new Timestamp(System.currentTimeMillis()));
            pstmtOrder.setBigDecimal(4, order.getTotalAmount());
            pstmtOrder.setString(5, order.getStatus() != null ? order.getStatus() : "Pending");
            pstmtOrder.setString(6, order.getShippingAddress());
            pstmtOrder.setString(7, order.getContactOnOrder());
            pstmtOrder.setInt(8, order.getItemCount());
            pstmtOrder.executeUpdate();

            // 2. Insert into ORDER_ITEMS table and Update Product Stock
            pstmtOrderItem = conn.prepareStatement(sqlInsertOrderItem);
            pstmtUpdateStock = conn.prepareStatement(sqlUpdateProductStock);
            pstmtGetProductDetails = conn.prepareStatement(sqlGetProductDetailsForOrder);

            for (OrderItem item : order.getOrderItems()) {
                int currentStock = 0;
                String currentProductName = "Unknown Product";
                String currentImageFileName = "placeholder_product_foodmart.jpg"; // Default placeholder

                // Get current stock, product name, and image file name
                pstmtGetProductDetails.setString(1, item.getProductId());
                ResultSet rsDetails = pstmtGetProductDetails.executeQuery();
                if (rsDetails.next()) {
                    currentStock = rsDetails.getInt("AVAILABLE_QUANTITY");
                    currentProductName = rsDetails.getString("PRODUCT_NAME");
                    String dbImageName = rsDetails.getString("IMAGE_FILE_NAME");
                    if (dbImageName != null && !dbImageName.trim().isEmpty()) {
                        currentImageFileName = dbImageName;
                    }
                }
                rsDetails.close();

                if (currentStock < item.getQuantity()) {
                    throw new SQLException("Insufficient stock for product ID: " + item.getProductId() +
                                           ". Available: " + currentStock + ", Requested: " + item.getQuantity());
                }
                int newStock = currentStock - item.getQuantity();
                pstmtUpdateStock.setInt(1, newStock);
                pstmtUpdateStock.setString(2, item.getProductId());
                pstmtUpdateStock.addBatch();

                // Add order item to batch
                pstmtOrderItem.setString(1, orderId);
                pstmtOrderItem.setString(2, item.getProductId());
                pstmtOrderItem.setString(3, currentProductName); // Use fetched product name
                pstmtOrderItem.setInt(4, item.getQuantity());
                pstmtOrderItem.setBigDecimal(5, item.getPriceAtPurchase());
                pstmtOrderItem.setString(6, currentImageFileName); // SETTING THE IMAGE FILENAME
                pstmtOrderItem.addBatch();
            }
            pstmtUpdateStock.executeBatch();
            pstmtOrderItem.executeBatch();

            conn.commit();

        } catch (SQLException e) {
            System.err.println("Error creating order: " + e.getMessage());
            e.printStackTrace();
            orderId = null; // Indicate failure
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error rolling back transaction: " + ex.getMessage());
                }
            }
        } finally {
            DBUtil.closePreparedStatement(pstmtOrder);
            DBUtil.closePreparedStatement(pstmtOrderItem);
            DBUtil.closePreparedStatement(pstmtUpdateStock);
            DBUtil.closePreparedStatement(pstmtGetProductDetails);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            DBUtil.closeConnection(conn);
        }
        return orderId;
    }


    /**
     * Retrieves all orders for a specific user.
     *
     * @param userId The ID of the user.
     * @return A list of Order objects.
     */
    public List<Order> getOrdersByUserId(String userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.ORDERS WHERE USER_ID = ? ORDER BY ORDER_DATE DESC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getString("ORDER_ID"));
                order.setUserId(rs.getString("USER_ID"));
                order.setOrderDate(rs.getTimestamp("ORDER_DATE"));
                order.setTotalAmount(rs.getBigDecimal("TOTAL_AMOUNT"));
                order.setStatus(rs.getString("STATUS"));
                order.setShippingAddress(rs.getString("SHIPPING_ADDRESS"));
                order.setContactOnOrder(rs.getString("CONTACT_ON_ORDER"));
                order.setItemCount(rs.getInt("ITEM_COUNT"));
                
                // Load order items (this will now include imageFileName)
                List<OrderItem> items = loadOrderItemsForOrderId(conn, order.getOrderId());
                order.setOrderItems(items);

                orders.add(order);
            }
        } catch (SQLException e) {
            System.err.println("Error getting orders by user ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return orders;
    }

    /**
     * Helper method to load order items for a given order ID.
     * This method now fetches and sets the IMAGE_FILE_NAME.
     * @param conn The existing database connection (to participate in a transaction if any).
     * @param orderId The ID of the order.
     * @return A list of OrderItem objects.
     * @throws SQLException If a database access error occurs.
     */
    private List<OrderItem> loadOrderItemsForOrderId(Connection conn, String orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        // UPDATED SQL: Select IMAGE_FILE_NAME from ORDER_ITEMS
        String sqlOrderItems = "SELECT ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, PRODUCT_NAME, QUANTITY, PRICE_AT_PURCHASE, IMAGE_FILE_NAME " +
                               "FROM GMSAPP.ORDER_ITEMS " +
                               "WHERE ORDER_ID = ?";
        // Note: PRODUCT_NAME is already stored in ORDER_ITEMS, so no need to join PRODUCTS here unless you want the *current* product name.
        // For historical accuracy, the PRODUCT_NAME in ORDER_ITEMS is preferred.

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            pstmt = conn.prepareStatement(sqlOrderItems);
            pstmt.setString(1, orderId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("ORDER_ITEM_ID"));
                item.setOrderId(rs.getString("ORDER_ID"));
                item.setProductId(rs.getString("PRODUCT_ID")); // Corrected: was PRODUCT_NAME
                item.setProductName(rs.getString("PRODUCT_NAME")); // Name at time of purchase
                item.setQuantity(rs.getInt("QUANTITY"));
                item.setPriceAtPurchase(rs.getBigDecimal("PRICE_AT_PURCHASE"));
                item.setImageFileName(rs.getString("IMAGE_FILE_NAME")); // SETTING IMAGE FILENAME
                items.add(item);
            }
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            // Connection is managed by the calling method
        }
        return items;
    }

    /**
     * Retrieves a specific order by its ID, including its order items with image filenames.
     *
     * @param orderId The ID of the order to retrieve.
     * @return An Order object with its items, or null if not found.
     */
    public Order getOrderById(String orderId) {
        Order order = null;
        String sqlOrder = "SELECT * FROM GMSAPP.ORDERS WHERE ORDER_ID = ?";
        Connection conn = null;
        PreparedStatement pstmtOrder = null;
        ResultSet rsOrder = null;

        try {
            conn = DBUtil.getConnection();
            pstmtOrder = conn.prepareStatement(sqlOrder);
            pstmtOrder.setString(1, orderId);
            rsOrder = pstmtOrder.executeQuery();

            if (rsOrder.next()) {
                order = new Order();
                order.setOrderId(rsOrder.getString("ORDER_ID"));
                order.setUserId(rsOrder.getString("USER_ID"));
                order.setOrderDate(rsOrder.getTimestamp("ORDER_DATE"));
                order.setTotalAmount(rsOrder.getBigDecimal("TOTAL_AMOUNT"));
                order.setStatus(rsOrder.getString("STATUS"));
                order.setShippingAddress(rsOrder.getString("SHIPPING_ADDRESS"));
                order.setContactOnOrder(rsOrder.getString("CONTACT_ON_ORDER"));
                order.setItemCount(rsOrder.getInt("ITEM_COUNT"));

                // Use the updated helper method to load items
                List<OrderItem> items = loadOrderItemsForOrderId(conn, orderId);
                order.setOrderItems(items);
            }
        } catch (SQLException e) {
            System.err.println("Error getting order by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rsOrder);
            DBUtil.closePreparedStatement(pstmtOrder);
            DBUtil.closeConnection(conn);
        }
        return order;
    }

    /**
     * Updates the status of an order. (Admin function)
     * @param orderId The ID of the order to update.
     * @param newStatus The new status.
     * @return true if update was successful, false otherwise.
     */
    public boolean updateOrderStatus(String orderId, String newStatus) {
        String sql = "UPDATE GMSAPP.ORDERS SET STATUS = ? WHERE ORDER_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, orderId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }
    
    
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.ORDERS ORDER BY ORDER_DATE DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getString("ORDER_ID"));
                order.setUserId(rs.getString("USER_ID"));
                order.setOrderDate(rs.getTimestamp("ORDER_DATE"));
                order.setTotalAmount(rs.getBigDecimal("TOTAL_AMOUNT"));
                order.setStatus(rs.getString("STATUS"));
                order.setShippingAddress(rs.getString("SHIPPING_ADDRESS"));
                order.setContactOnOrder(rs.getString("CONTACT_ON_ORDER"));
                order.setItemCount(rs.getInt("ITEM_COUNT"));

                // Load order items (this will now include imageFileName)
                List<OrderItem> items = loadOrderItemsForOrderId(conn, order.getOrderId());
                order.setOrderItems(items);

                orders.add(order);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all orders: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closeStatement(stmt);
            DBUtil.closeConnection(conn);
        }
        return orders;
    }
    
    public List<Order> getOrdersByDateRange(Timestamp startDate, Timestamp endDate) {
        List<Order> orders = new ArrayList<>();
        // Base SQL query
        String sql = "SELECT ORDER_ID, USER_ID, ORDER_DATE, TOTAL_AMOUNT, STATUS, SHIPPING_ADDRESS, CONTACT_ON_ORDER, ITEM_COUNT FROM GMSAPP.ORDERS"; // Adjust table and column names

        // Dynamically build the WHERE clause
        List<Object> params = new ArrayList<>();
        StringBuilder whereClause = new StringBuilder();

        if (startDate != null) {
            whereClause.append("ORDER_DATE >= ?");
            params.add(startDate);
        }
        if (endDate != null) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("ORDER_DATE <= ?");
            params.add(endDate);
        }

        if (whereClause.length() > 0) {
            sql += " WHERE " + whereClause.toString();
        }
        sql += " ORDER BY ORDER_DATE DESC"; // Or your preferred order

//        System.out.println("Executing SQL (getOrdersByDateRange): " + sql);
        if(startDate != null) System.out.println("Start Date Param: " + startDate);
        if(endDate != null) System.out.println("End Date Param: " + endDate);


        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getString("ORDER_ID"));
                order.setUserId(rs.getString("USER_iD"));
                order.setOrderDate(rs.getTimestamp("ORDER_DATE"));
                order.setTotalAmount(rs.getBigDecimal("TOTAL_AMOUNT"));
                order.setStatus(rs.getString("STATUS"));
                order.setShippingAddress(rs.getString("SHIPPING_ADDRESS"));
                order.setContactOnOrder(rs.getString("CONTACT_ON_ORDER"));
                order.setItemCount(rs.getInt("ITEM_COUNT"));
                // Optionally fetch order items here if needed for display or further processing
                // order.setOrderItems(getOrderItemsForOrder(order.getOrderId(), conn)); // Example
                orders.add(order);
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in getOrdersByDateRange: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }

    // You might already have a method like this, or need to create one
    // to fetch items for a specific order, especially for the order details view.
    // This is just an example structure.
    public List<OrderItem> getOrderItemsForOrder(int orderId, Connection conn) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT orderItemId, productid, quantity, priceAtPurchase, productName FROM GMSAPP.ORDER_ITEMS WHERE orderId = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("orderItemID"));
                item.setProductId(rs.getString("productId"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPriceAtPurchase(rs.getBigDecimal("priceAtPurchase"));
                item.setProductName(rs.getString("productName")); // Assuming you store product_name in order_items
                items.add(item);
            }
        }
        return items;
    }
    // Make sure your Order model has a setOrderItems(List<OrderItem> items) method.
     /**
     * Retrieves all orders for a specific user (Admin context, same as getOrdersByUserId).
     * @param userId The ID of the user.
     * @return A list of Order objects.
     */
    public List<Order> getOrdersByUserIdAdmin(String userId) {
        // This method is functionally identical to getOrdersByUserId
        // You can either call getOrdersByUserId or keep it separate if you anticipate
        // different logic for admins in the future.
        return getOrdersByUserId(userId);
    }
}
