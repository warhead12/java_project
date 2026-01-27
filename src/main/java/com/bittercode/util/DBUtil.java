package com.bittercode.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import com.bittercode.constant.ResponseCode;
import com.bittercode.model.StoreException;

public class DBUtil {

    private static Connection connection;

    static {

        try {

            // Load MySQL Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Read environment variables
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String username = System.getenv("DB_USER");
            String password = System.getenv("DB_PASS");

            // Build JDBC URL
            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;

            // Create connection
            connection = DriverManager.getConnection(url, username, password);

            System.out.println("Connected to database successfully");

        } catch (SQLException | ClassNotFoundException e) {

            e.printStackTrace();
        }

    }

    public static Connection getConnection() throws StoreException {

        if (connection == null) {
            throw new StoreException(ResponseCode.DATABASE_CONNECTION_FAILURE);
        }

        return connection;
    }
}
