package com.gms.dbutil;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class DBUtil implements ServletContextListener {

    private static final String JDBC_DRIVER = "org.apache.derby.jdbc.EmbeddedDriver";
    private static final String DB_URL = "jdbc:derby:(path to Database)\\GroceryDB;create=true";
    private static Connection connection = null;

    static {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("Error loading JDBC Driver: " + e.getMessage());
            e.printStackTrace();
            // throw new RuntimeException("Failed to load JDBC driver.", e);
        }
    }

    
    public static Connection getConnection() throws SQLException {
       // if (connection == null || connection.isClosed()) {
        //     connection = DriverManager.getConnection(DB_URL);
        // }
        // return connection;

        return DriverManager.getConnection(DB_URL);
    }

   
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

 
    public static void closeStatement(java.sql.Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                System.err.println("Error closing statement: " + e.getMessage());
                // Handle exception
            }
        }
    }

   
    public static void closePreparedStatement(java.sql.PreparedStatement pstmt) {
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) {
                System.err.println("Error closing prepared statement: " + e.getMessage());
                
            }
        }
    }

   
    public static void closeResultSet(java.sql.ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.err.println("Error closing result set: " + e.getMessage());
               
            }
        }
    }
    

    
    public static void main(String[] args) {
        Connection conn = null;
        try {
            System.out.println("Attempting to connect to database...");
            conn = DBUtil.getConnection();
            if (conn != null) {
                System.out.println("Database connection successful!");
                System.out.println("Schema: " + conn.getSchema()); 
                 try (java.sql.Statement stmt = conn.createStatement();
                      java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM GMSAPP.USERS")) {
                     if (rs.next()) {
                         System.out.println("Number of users: " + rs.getInt(1));
                     }
                 }
            } else {
                System.out.println("Failed to make connection!");
            }
        } catch (SQLException e) {
            System.err.println("SQL Exception: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                DBUtil.closeConnection(conn);
                
                System.out.println("Database connection closed.");
            }
        }
    }
}