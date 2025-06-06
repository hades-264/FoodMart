package com.gms.model;

import java.math.BigDecimal;

public class Product {
    private String productId;
    private String productName;
    private String productDescription;
    private BigDecimal price; 
    private int availableQuantity;
    private String category;
    private String imageFileName; 
    private boolean isAvailable;

    public Product() {
    }

    public Product(String productId, String productName, String productDescription,
                   BigDecimal price, int availableQuantity, String category, String imageFileName) {
        this.productId = productId;
        this.productName = productName;
        this.productDescription = productDescription;
        this.price = price;
        this.availableQuantity = availableQuantity;
        this.category = category;
        this.imageFileName = imageFileName;
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

    public String getProductDescription() {
        return productDescription;
    }

    public void setProductDescription(String productDescription) {
        this.productDescription = productDescription;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public void setPrice(double price) {
        this.price = BigDecimal.valueOf(price);
    }


    public int getAvailableQuantity() {
        return availableQuantity;
    }

    public void setAvailableQuantity(int availableQuantity) {
        this.availableQuantity = availableQuantity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImageFileName() {
        return imageFileName;
    }

    public void setImageFileName(String imageFileName) {
        this.imageFileName = imageFileName;
    }
    
    public boolean isAvailable() { 
    	return isAvailable; 
    }
    
    public void setAvailable(boolean available) { 
    	isAvailable = available; 
    }

    @Override
    public String toString() {
        return "Product{" +
               "productId='" + productId + '\'' +
               ", productName='" + productName + '\'' +
               ", productDescription='" + (productDescription != null ? productDescription.substring(0, Math.min(productDescription.length(), 30)) + "..." : "N/A") + '\'' + // Truncate for brevity
               ", price=" + price +
               ", availableQuantity=" + availableQuantity +
               ", category='" + category + '\'' +
               ", imageFileName='" + imageFileName + '\'' +
               '}';
    }
}