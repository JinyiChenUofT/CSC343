import java.sql.*;
import java.util.List;

public class test {
    public static void main(String[] args) {
        try{
        Class.forName("org.postgresql.jdbc.Driver");
        System.out.println("Connecting to the PostgreSQL server.");
        String url = "jdbc:postgresql://localhost:5432/csc343-jinyichen";
        Connection conn = DriverManager.getConnection(url,"jinyichen","");
        System.out.println("Connected to the PostgreSQL server successfully.");
        }
        catch(SQLException e){
            System.out.println(e.getMessage());
        }
        return;
    }
  }