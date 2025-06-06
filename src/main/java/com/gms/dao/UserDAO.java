package com.gms.dao;

import com.gms.dbutil.DBUtil;
import com.gms.model.User;   

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * Registers a new user (customer) in the database.
     *
     * @param user The User object containing registration details.
     * @return true if registration is successful, false otherwise.
     */
    public boolean registerUser(User user) {
     
        String sql = "INSERT INTO GMSAPP.USERS (USER_ID, USER_NAME, EMAIL, PASSWORD, ADDRESS, CONTACT_NUMBER, ROLE, IS_ACTIVE) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, user.getUserId());
            pstmt.setString(2, user.getUserName());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getPassword()); 
            pstmt.setString(5, user.getAddress());
            pstmt.setString(6, user.getContactNumber());
            pstmt.setString(7, user.getRole() != null ? user.getRole() : "CUSTOMER");
            pstmt.setBoolean(8, user.isActive());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error registering user: " + e.getMessage());
            e.printStackTrace(); 
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }

    /**
     * Finds a user by their email address.
     *
     * @param email The email address of the user to find.
     * @return A User object if found, null otherwise.
     */
    public User findUserByEmail(String email) {
        String sql = "SELECT * FROM GMSAPP.USERS WHERE EMAIL = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        User user = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("USER_ID"));
                user.setUserName(rs.getString("USER_NAME"));
                user.setEmail(rs.getString("EMAIL"));
                user.setPassword(rs.getString("PASSWORD")); 
                user.setAddress(rs.getString("ADDRESS"));
                user.setContactNumber(rs.getString("CONTACT_NUMBER"));
                user.setRole(rs.getString("ROLE"));
                user.setActive(rs.getBoolean("IS_ACTIVE"));
            }
        } catch (SQLException e) {
            System.err.println("Error finding user by email: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return user;
    }

    /**
     * Finds a user by their USER_ID.
     *
     * @param userId The ID of the user to find.
     * @return A User object if found, null otherwise.
     */
    public User findUserById(String userId) {
        String sql = "SELECT * FROM GMSAPP.USERS WHERE USER_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        User user = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("USER_ID"));
                user.setUserName(rs.getString("USER_NAME"));
                user.setEmail(rs.getString("EMAIL"));
                user.setPassword(rs.getString("PASSWORD"));
                user.setAddress(rs.getString("ADDRESS"));
                user.setContactNumber(rs.getString("CONTACT_NUMBER"));
                user.setRole(rs.getString("ROLE"));
                user.setActive(rs.getBoolean("IS_ACTIVE"));
            }
        } catch (SQLException e) {
            System.err.println("Error finding user by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
        return user;
    }


    /**
     * Checks if an email already exists in the database.
     * @param email The email to check.
     * @return true if email exists, false otherwise.
     */
    public boolean emailExists(String email) {
        return findUserByEmail(email) != null;
    }


    /**
     * Retrieves all users (customers and admins).
     * This might be more for an admin panel.
     * @return A list of all User objects.
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM GMSAPP.USERS ORDER BY USER_NAME";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getString("USER_ID"));
                user.setUserName(rs.getString("USER_NAME"));
                user.setEmail(rs.getString("EMAIL"));
                user.setAddress(rs.getString("ADDRESS"));
                user.setContactNumber(rs.getString("CONTACT_NUMBER"));
                user.setRole(rs.getString("ROLE"));
                user.setActive(rs.getBoolean("IS_ACTIVE"));
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResultSet(rs);
            DBUtil.closeStatement(stmt);
            DBUtil.closeConnection(conn);
        }
        return users;
    }

    /**
     * Updates an existing user's details in the database.
     * Assumes password changing is handled separately or with specific checks.
     *
     * @param user The User object with updated details.
     * @return true if the update is successful, false otherwise.
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE GMSAPP.USERS SET USER_NAME = ?, EMAIL = ?, ADDRESS = ?, CONTACT_NUMBER = ?, ROLE = ?, IS_ACTIVE = ? WHERE USER_ID = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, user.getUserName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getAddress());
            pstmt.setString(4, user.getContactNumber());
            pstmt.setString(5, user.getRole());
            pstmt.setBoolean(6, user.isActive());
            pstmt.setString(7, user.getUserId());
 
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }
    
 

    /**
     * Updates a user's password.
     *
     * @param userId The ID of the user whose password is to be updated.
     * @param newPassword The new password (should be hashed before calling this).
     * @return true if the password update is successful, false otherwise.
     */
    public boolean updateUserPassword(String userId, String newPassword) {
        String sql = "UPDATE GMSAPP.USERS SET PASSWORD = ? WHERE USER_ID = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, newPassword);
            pstmt.setString(2, userId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error updating user password: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.closePreparedStatement(pstmt);
            DBUtil.closeConnection(conn);
        }
    }
    
 // Method to update the IS_ACTIVE status of a user
    public boolean updateUserActiveStatus(String userId, boolean isActive) {
        String sql = "UPDATE GMSAPP.USERS SET IS_ACTIVE = ? WHERE USER_ID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, isActive);
            pstmt.setString(2, userId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating active status for user: " + userId + " - " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

}