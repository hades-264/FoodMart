package com.gms.model;

import java.math.BigDecimal;

public class CartItem {
    private String productId;
    private String productName;
    private String imageFileName; // To display product image in cart
    private BigDecimal unitPrice;   // Price of a single unit of the product
    private int quantity;
    private BigDecimal subtotal;    // unitPrice * quantity

    // Constructors
    public CartItem() {
    }

    public CartItem(Product product, int quantity) {
        this.productId = product.getProductId();
        this.productName = product.getProductName();
        this.imageFileName = product.getImageFileName();
        this.unitPrice = product.getPrice();
        this.quantity = quantity;
        this.calculateSubtotal();
    }

    // Getters and Setters
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

    public String getImageFileName() {
        return imageFileName;
    }

    public void setImageFileName(String imageFileName) {
        this.imageFileName = imageFileName;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
        calculateSubtotal(); // Recalculate if unit price changes
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
        calculateSubtotal(); // Recalculate if quantity changes
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    // Private method to calculate subtotal internally
    private void calculateSubtotal() {
        if (this.unitPrice != null && this.quantity > 0) {
            this.subtotal = this.unitPrice.multiply(new BigDecimal(this.quantity));
        } else {
            this.subtotal = BigDecimal.ZERO;
        }
    }

    // To increment quantity
    public void incrementQuantity(int amount) {
        this.quantity += amount;
        calculateSubtotal();
    }

    @Override
    public String toString() {
        return "CartItem{" +
                "productId='" + productId + '\'' +
                ", productName='" + productName + '\'' +
                ", unitPrice=" + unitPrice +
                ", quantity=" + quantity +
                ", subtotal=" + subtotal +
                '}';
    }

    // It's good practice to override equals() and hashCode() if you store CartItems
    // in collections like Sets or use them as keys in Maps, especially based on productId.
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CartItem cartItem = (CartItem) o;
        return productId.equals(cartItem.productId);
    }

    @Override
    public int hashCode() {
        return productId.hashCode();
    }
}