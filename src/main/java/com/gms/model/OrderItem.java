package com.gms.model;

import java.math.BigDecimal;

public class OrderItem {
    private int orderItemId; 
    private String orderId;
    private String productId;
    private String productName;
    private int quantity;
    private BigDecimal priceAtPurchase;
    private String imageFileName; 

    // Constructors
    public OrderItem() {
    }

    // Getters and Setters
    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPriceAtPurchase() {
        return priceAtPurchase;
    }

    public void setPriceAtPurchase(BigDecimal priceAtPurchase) {
        this.priceAtPurchase = priceAtPurchase;
    }

    public String getImageFileName() { 
        return imageFileName;
    }

    public void setImageFileName(String imageFileName) {
        this.imageFileName = imageFileName;
    }

    public BigDecimal getSubtotal() {
        if (priceAtPurchase == null) {
            return BigDecimal.ZERO;
        }
        return priceAtPurchase.multiply(new BigDecimal(quantity));
    }

    @Override
    public String toString() {
        return "OrderItem{" +
               "orderItemId=" + orderItemId +
               ", orderId='" + orderId + '\'' +
               ", productId='" + productId + '\'' +
               ", productName='" + productName + '\'' +
               ", quantity=" + quantity +
               ", priceAtPurchase=" + priceAtPurchase +
               ", imageFileName='" + imageFileName + '\'' + 
               '}';
    }
}
