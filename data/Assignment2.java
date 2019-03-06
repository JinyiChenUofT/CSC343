import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
    //global connection to the database
    Connection conn;
    PreparedStatement ps;

    private static String database_url = "jdbc:postgresql://localhost:5432/csc343";
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try{
            System.out.println("Connecting to the PostgreSQL server.");
            conn = DriverManager.getConnection(url,username,password);
            System.out.println("Connected to the PostgreSQL server successfully.");

            ps = conn.prepareStatement("SET search-path TO parlgov");
            ps.executeUpdate();
            System.out.println("SET search-path TO parlgov successfully.");
            return true;
        }
        catch(SQLException e){
            System.out.println(e.getMessage());
        }
        return false;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try{
            conn.close();
            return true;
        }
        catch(SQLException e){
            System.out.println(e.getMessage());
        }
        return false;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!

        return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        return null;
    }
    
    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        try{
            System.out.println("Start.");
            Assignment2 a2 = new Assignment2();
            System.out.println("assignment2.");
            boolean conn_result;
            conn_result = a2.connectDB(database_url, "JinyiChen", "");
            
            System.out.println(conn_result);
        }
        catch(ClassNotFoundException e){
            System.out.println("Connection failed.");
            System.out.println(e.getMessage());
        }

    }

}

