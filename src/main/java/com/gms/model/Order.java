package com.gms.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List; // To hold associated OrderItems

public class Order {
    private String orderId;
    private String userId; 
    private Timestamp orderDate;
    private BigDecimal totalAmount;
    private String status;
    private String shippingAddress;
    private String contactOnOrder;
    private int itemCount;

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }

    private List<OrderItem> orderItems;

    public Order() {
    }

    public Order(String orderId, String userId, Timestamp orderDate, BigDecimal totalAmount,
                 String status, String shippingAddress, String contactOnOrder) {
        this.orderId = orderId;
        this.userId = userId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
        this.shippingAddress = shippingAddress;
        this.contactOnOrder = contactOnOrder;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = BigDecimal.valueOf(totalAmount);
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getContactOnOrder() {
        return contactOnOrder;
    }

    public void setContactOnOrder(String contactOnOrder) {
        this.contactOnOrder = contactOnOrder;
    }

    public List<OrderItem> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItem> orderItems) {
        this.orderItems = orderItems;
    }
    
   


    @Override
    public String toString() {
        return "Order{" +
               "orderId='" + orderId + '\'' +
               ", userId='" + userId + '\'' +
               ", orderDate=" + orderDate +
               ", totalAmount=" + totalAmount +
               ", status='" + status + '\'' +
               ", shippingAddress='" + shippingAddress + '\'' +
               ", contactOnOrder='" + contactOnOrder + '\'' +
               ", numberOfItems=" + (orderItems != null ? orderItems.size() : 0) +
               '}';
    }
}