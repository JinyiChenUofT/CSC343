import java.sql.*;
import java.util.List;
import java.io.*;
import java.util.ArrayList;

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
    //Connection conn;
    //PreparedStatement ps;

    private static String database_url = "jdbc:postgresql://localhost:5432/csc343h-chenj173";
    
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try{
            connection = DriverManager.getConnection(url,username,password);

            PreparedStatement ps = connection.prepareStatement("SET search_path TO parlgov");
            ps.executeUpdate();
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
            connection.close();
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
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();
        
        try{

        String queryString = "DROP VIEW IF EXISTS countryElection";
        PreparedStatement ps = connection.prepareStatement(queryString); 
        ps.executeUpdate();

        queryString = "create view countryElection as (select election.id, election.e_type, election.e_date, election.country_id " + 
        "from election where election.country_id = (select country.id from country where country.name = '" +  countryName +
        "' ) order by election.e_date DESC)";
        ps = connection.prepareStatement(queryString);
        //ps.setString(1, countryName);
        ps.executeUpdate();
        
        queryString = "select ce1.id as election_id, c.id as cabinet_id " + 
        "from countryElection ce1, cabinet c " +
        "where c.start_date>=ce1.e_date and ce1.country_id = c.country_id "+
        "and (c.start_date < (select min(ce2.e_date) from countryElection ce2 "+
        "where ce1.country_id = ce2.country_id and ce1.e_type = ce2.e_type and ce1.e_date<ce2.e_date) " +
        "or not exists (select * from countryElection ce3 "+
        "where ce1.country_id = ce3.country_id "+
        "and ce1.e_type = ce3.e_type "+
        "and ce1.e_date<ce3.e_date ))"+
        "order by ce1.e_date DESC";
        ps = connection.prepareStatement(queryString);
        ResultSet rs = ps.executeQuery();
        while(rs.next()) {
            elections.add(rs.getInt(1));
            cabinets.add(rs.getInt(2));
        }
        
        }

        catch (SQLException e){
            System.out.println(e.getMessage());
        }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
    	List<Integer> answer = new ArrayList<Integer>();
    	
    	try {
    		String queryString = "SELECT t2.id, " + 
    									"t1.comment AS t1_c, t1.description AS t1_d, " +
    									"t2.comment AS t2_c, t2.description AS t2_d " + 
    							 "FROM politician_president AS t1, politician_president AS t2 " +
    							 "WHERE t1.id = ? AND t1.id != t2.id;";
    		PreparedStatement ps = connection.prepareStatement(queryString);
    		ps.setInt(1, politicianName);
    		ResultSet rs = ps.executeQuery();
    		
    		while(rs.next()) {
    			if(similarity(rs.getString(2) + " " + rs.getString(3),
    						  rs.getString(4) + " " + rs.getString(5)) >= threshold) {
    				answer.add(rs.getInt(1));
    			}
    		}
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception findSimilarPoliticians." + "<Message>: " + se.getMessage());
    		System.exit(1);
    	}
        return answer;
    }
    
    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        try{

            Assignment2 a2 = new Assignment2();
            System.out.println("assignment2.");
            boolean conn_result;
            conn_result = a2.connectDB(database_url, "chenj173", "");
            
            System.out.println(conn_result);
            String s ="Japan";
            ElectionCabinetResult e = a2.electionSequence(s);
            System.out.print(e.cabinets);
            System.out.println();
            System.out.print(e.elections);
        }
        catch(ClassNotFoundException e){
            System.out.println("Connection failed.");
            System.out.println(e.getMessage());
        }

    }

}

