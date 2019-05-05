import java.sql.*;
import java.util.List;
import java.io.*;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
		try {
		connection = DriverManager.getConnection(url, username, password);
		
        PreparedStatement ps = connection.prepareStatement("SET search_path TO parlgov");
        ps.executeUpdate();
		return true;
		}
		
		catch (SQLException e) {
            System.out.println(e.getMessage());
			return false;
		}
        
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
		try{
			connection.close();
			return true;
		}
		catch (SQLException e) {
        System.out.println(e.getMessage());
        return false;
    	}
	}

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();

		
		
		try{
			
	        String queryString = "DROP VIEW IF EXISTS counelections CASCADE;";
	        PreparedStatement ps1 = connection.prepareStatement(queryString); 
	        ps1.executeUpdate();
	        queryString = "DROP VIEW IF EXISTS nextelec CASCADE;";
	        PreparedStatement ps2 = connection.prepareStatement(queryString); 
	        ps2.executeUpdate();
	        queryString = "DROP VIEW IF EXISTS findcabinets CASCADE;";
	        PreparedStatement ps3 = connection.prepareStatement(queryString); 
	        ps3.executeUpdate();
			
			
			
			
			queryString = "CREATE VIEW counelections AS(SELECT election.id AS eid, election.country_id AS cid, "+
				"election.e_date AS edate, election.e_type AS type "+
				"FROM election, country "+
				"WHERE election.country_id = country.id AND " + 
				"country.name = ?" + 
				"ORDER BY election.e_date DESC);";
			
	        PreparedStatement ps4 = connection.prepareStatement(queryString);
			ps4.setString(1, countryName);
	        ps4.executeUpdate();
			
			queryString = "CREATE VIEW nextelec AS(SELECT ce1.eid AS eid1, ce1.edate AS date1, ce1.type AS type1,"+
				" ce2.eid AS eid2, ce2.edate AS date2, ce2.type AS type2 "+
				"FROM counelections ce1, counelections ce2, counelections ce3 "+
				"WHERE ce1.type=ce2.type AND ce1.edate < ce2.edate AND NOT EXISTS (SELECT ce3.eid, ce3.edate, ce3.type "+
				"FROM counelections ce3 "+
				"WHERE (ce1.type = ce3.type and ce1.edate<ce3.edate and ce3.edate<ce2.edate));";
						
			
	        PreparedStatement ps5 = connection.prepareStatement(queryString);
	        ps5.executeUpdate();
			
			queryString = "CREATE VIEW findcabinets AS(SELECT nextelec.eid1, cabinet.id AS cabinet_id"+
			
			"FROM nextelec, cabinet "+
			"WHERE nextelec.date1<cabinet.start_date AND nextelec.date2<cabinet.start_date "+
			"ORDER BY nextelec.date1 DESC);";
			
	        PreparedStatement ps6 = connection.prepareStatement(queryString);
	        ResultSet rs = ps6.executeQuery();
	        while(rs.next()) {
	            elections.add(rs.getInt(1));
	            cabinets.add(rs.getInt(2));
	        }
			
			
		} catch (SQLException e){
			System.out.println(e.getMessage());
			}
		
		
        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        return null;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
		try{
			
            Assignment2 test = new Assignment2();
            boolean conn_result;
            conn_result = test.connectDB("jdbc:postgresql://localhost:5432/csc343h-caojing8", "caojing8", "");
            
            System.out.println(conn_result);
            ElectionCabinetResult e = test.electionSequence("Canada");
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


