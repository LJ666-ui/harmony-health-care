package com.medical;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnectionTest {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/medical_health?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8";
        String username = "root";
        String password = "123456";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection(url, username, password);
            System.out.println("数据库连接成功！");
            connection.close();
        } catch (ClassNotFoundException e) {
            System.out.println("找不到数据库驱动：" + e.getMessage());
        } catch (SQLException e) {
            System.out.println("数据库连接失败：" + e.getMessage());
        }
    }
}