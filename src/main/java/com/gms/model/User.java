package com.gms.model;

public class User {
    private String userId;
    private String userName;
    private String email;
    private String password; 
    private String address;
    private String contactNumber;
    private String role; // e.g., "CUSTOMER", "ADMIN"
    private boolean isActive; // True if account is active, false if deactivated

    public User() {
        this.isActive = true; // Default to active for new User objects
    }

    public User(String userId, String userName, String email, String password, String address, String contactNumber, String role, boolean isActive) {
        this.userId = userId;
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.address = address;
        this.contactNumber = contactNumber;
        this.role = role;
        this.isActive = isActive;
    }
    
    
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
    
    @Override
    public String toString() {
        return "User{" +
               "userId='" + userId + '\'' +
               ", userName='" + userName + '\'' +
               ", email='" + email + '\'' +
               // Avoid printing password in logs for security
               ", address='" + address + '\'' +
               ", contactNumber='" + contactNumber + '\'' +
               ", role='" + role + '\'' +
               ", isActive=" + isActive +
               '}';
    }
}