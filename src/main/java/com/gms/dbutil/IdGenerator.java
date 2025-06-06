package com.gms.dbutil;

import com.gms.dao.UserDAO;
import com.gms.dao.ProductDAO;
import com.gms.dao.OrderDAO;

import java.security.SecureRandom;
import java.util.UUID;

public class IdGenerator {

    private static SecureRandom random = new SecureRandom();
    private static final int MAX_GENERATION_ATTEMPTS = 100; // To prevent infinite loops

    // --- User ID Generation ---
    private static final int USER_ID_LENGTH = 5;

    /**
     * Generates a candidate for a User ID (5-digit number as a string).
     * Does not check for uniqueness here.
     * @return A 5-digit string.
     */
    private static String generateUserIdCandidate() {
        // Generates a number between 10000 and 99999 (inclusive for 5 digits)
        int number = 10000 + random.nextInt(90000);
        return String.valueOf(number);
    }

    /**
     * Generates a unique User ID (5-digit string).
     * Checks against the database using UserDAO to ensure uniqueness.
     *
     * @param userDAO An instance of UserDAO to check for ID existence.
     * @return A unique 5-digit User ID string, or null if a unique ID couldn't be generated after max attempts.
     */
    public static String generateUniqueUserId(UserDAO userDAO) {
        String candidateId;
        int attempts = 0;
        do {
            candidateId = generateUserIdCandidate();
            attempts++;
            if (userDAO.findUserById(candidateId) == null) {
                return candidateId; // Found a unique ID
            }
            if (attempts >= MAX_GENERATION_ATTEMPTS) {
                System.err.println("IdGenerator: Max attempts reached for generating unique User ID. Returning null.");
                return null; // Or throw an exception
            }
        } while (true); // Loop until unique ID is found or max attempts are reached
    }

    // --- Product ID Generation ---
    // Format: X-XXXX-XXXX-X (all random digits)

    /**
     * Generates a candidate for a Product ID in the format X-XXXX-XXXX-X.
     * Does not check for uniqueness here.
     * @return A Product ID string candidate.
     */
    private static String generateProductIdCandidate() {
        // X (1 digit, 1-9 to avoid leading zero if it matters, or 0-9)
        int part1 = random.nextInt(10); // 0-9
        // XXXX (4 digits, 0000-9999)
        int part2 = random.nextInt(10000);
        // XXXX (4 digits, 0000-9999)
        int part3 = random.nextInt(10000);
        // X (1 digit, 0-9)
        int part4 = random.nextInt(10);

        return String.format("%d-%04d-%04d-%d", part1, part2, part3, part4);
    }

    /**
     * Generates a unique Product ID in the format X-XXXX-XXXX-X.
     * Checks against the database using ProductDAO to ensure uniqueness.
     *
     * @param productDAO An instance of ProductDAO to check for ID existence.
     * @return A unique Product ID string, or null if a unique ID couldn't be generated after max attempts.
     */
    public static String generateUniqueProductId(ProductDAO productDAO) {
        String candidateId;
        int attempts = 0;
        do {
            candidateId = generateProductIdCandidate();
            attempts++;
            if (productDAO.findProductById(candidateId) == null) {
                return candidateId; // Found a unique ID
            }
            if (attempts >= MAX_GENERATION_ATTEMPTS) {
                System.err.println("IdGenerator: Max attempts reached for generating unique Product ID. Returning null.");
                return null; // Or throw an exception
            }
        } while (true);
    }

    // --- Order ID Generation ---
    // Format: ORD-XXXXXXXX (8 random uppercase alphanumeric characters)
    // Reusing logic from the previous OrderIdGenerator artifact.

    private static final String ORDER_ID_PREFIX = "ORD-";
    private static final int ORDER_ID_RANDOM_PART_LENGTH = 8;
    private static final String ORDER_ID_ALPHANUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    /**
     * Generates a candidate for an Order ID using a portion of a UUID.
     * Format: ORD-XXXXXXXX
     * Does not check for uniqueness here.
     * @return An Order ID string candidate.
     */
    private static String generateOrderIdCandidate() {
        String uuid = UUID.randomUUID().toString().toUpperCase().replaceAll("-", "");
        String randomPart = uuid.substring(0, Math.min(uuid.length(), ORDER_ID_RANDOM_PART_LENGTH));
        return ORDER_ID_PREFIX + randomPart;
    }

    /**
     * Generates a unique Order ID in the format ORD-XXXXXXXX.
     * Checks against the database using OrderDAO to ensure uniqueness.
     *
     * @param orderDAO An instance of OrderDAO to check for ID existence.
     * @return A unique Order ID string, or null if a unique ID couldn't be generated after max attempts.
     */
    public static String generateUniqueOrderId(OrderDAO orderDAO) {
        String candidateId;
        int attempts = 0;
        do {
            candidateId = generateOrderIdCandidate();
            attempts++;
            // Assuming OrderDAO has a method like findOrderById(String orderId)
            // If it's getOrderById, it should return null if not found.
            if (orderDAO.getOrderById(candidateId) == null) {
                return candidateId; // Found a unique ID
            }
            if (attempts >= MAX_GENERATION_ATTEMPTS) {
                System.err.println("IdGenerator: Max attempts reached for generating unique Order ID. Returning null.");
                return null; // Or throw an exception
            }
        } while (true);
    }

    /**
     * Main method for testing the ID generators.
     * Note: For this test to fully work with uniqueness checks,
     * you'd need to mock or provide actual DAO instances connected to a database.
     */
//    public static void main(String[] args) {
//        // Mock DAOs for testing (replace with actual DAOs in your application)
//        // These mock DAOs will always report an ID as "not found" for simplicity here.
//        UserDAO mockUserDAO = new UserDAO() {
//            @Override
//            public com.gms.model.User findUserById(String userId) { return null; }
//        };
//        ProductDAO mockProductDAO = new ProductDAO() {
//            @Override
//            public com.gms.model.Product findProductById(String productId) { return null; }
//        };
//        OrderDAO mockOrderDAO = new OrderDAO() {
//            @Override
//            public com.gms.model.Order getOrderById(String orderId) { return null; }
//        };
//
//        System.out.println("--- Unique User IDs ---");
//        for (int i = 0; i < 3; i++) {
//            System.out.println(generateUniqueUserId(mockUserDAO));
//        }
//
//        System.out.println("\n--- Unique Product IDs ---");
//        for (int i = 0; i < 3; i++) {
//            System.out.println(generateUniqueProductId(mockProductDAO));
//        }
//
//        System.out.println("\n--- Unique Order IDs ---");
//        for (int i = 0; i < 3; i++) {
//            System.out.println(generateUniqueOrderId(mockOrderDAO));
//        }
//    }
}
