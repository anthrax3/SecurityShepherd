package dbProcs;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.log4j.Logger;

import servlets.Register;

import java.sql.PreparedStatement;

public class Module implements Comparable<Module> {
	
	private static org.apache.log4j.Logger log = Logger.getLogger(Module.class);

	String moduleNameLangPointer, moduleCategory, moduleId, finishTime;
	int incrementalRank, scoreValue, week;
	String defaultStatus, classStatus;
	
	
	static int compareValues(Comparable a, Comparable b) {
		if (a != null && b != null) return a.compareTo(b);
		else if (a != null) return -1;
		else if (b != null) return 1;
		else return 0;
	}
	
	public int compareTo(Module o) {
		if (o == null) return -1;
		int order = compareValues(week, o.week);		
		if (order == 0) order = compareValues(incrementalRank, o.incrementalRank);
		if (order == 0) order = compareValues(scoreValue, o.scoreValue);
		if (order == 0) order = compareValues(moduleNameLangPointer, o.moduleNameLangPointer);
		return order;
	}

	public static List<Module> getModules(Connection con, String userId) throws Exception {
		LinkedHashMap<String, Module> m = new LinkedHashMap<String, Module>();
		CallableStatement cs = null;
		PreparedStatement ps = null;
		ResultSet levels = null;
		try {
			cs = con.prepareCall("call moduleTournamentOpenInfo(?)");
			cs.setString(1, userId);
			log.debug("Gathering moduleTournamentOpenInfo ResultSet for user " + userId);
			levels = cs.executeQuery();
			log.debug("Opening Result Set from moduleTournamentOpenInfo");
			while(levels.next()) {
				Module module = new Module();
				module.moduleNameLangPointer = levels.getString(1);
				module.moduleCategory = levels.getString(2);
				module.moduleId = levels.getString(3);
				module.finishTime = levels.getString(4);
				module.incrementalRank = levels.getInt(5);
				module.scoreValue = levels.getInt(6);
				module.week = levels.getInt(7);
				module.defaultStatus = levels.getString(8);
				m.put(module.moduleId, module);
			}
			
			levels.close();
			cs.close();
			
			List<Module> modules = new ArrayList<Module>();
			
			String classId = getClassId(con, userId);
			if (classId != null && !classId.isEmpty()) {
				ps = con.prepareStatement("select moduleId, moduleStatus, week from class_modules where classId = ?"); 
				ps.setString(1, classId);
				levels = ps.executeQuery();
				while (levels.next()) {
					String moduleId = levels.getString("moduleId");
					if (moduleId != null) {
						Module module = m.get(moduleId);
						if (module != null) {
							module.week = levels.getInt("week");
							module.classStatus = levels.getString("moduleStatus");
						} else {
							log.error("Module not found: " + moduleId);
						}
					}
				}
			

				levels.close();
				ps.close();
			
			} 
			
			for (Module module : m.values()) {
				String status = module.classStatus != null && !module.classStatus.isEmpty() ? module.classStatus : module.defaultStatus;
				if (status != null && status.equals("open")) {
					modules.add(module);
				}
			}
			
			Collections.sort(modules);
			
			return modules;
		} finally {
			//con.close();
		}
	}
	
	private static String getClassId(Connection con, String userId) throws Exception {
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = con.prepareStatement("select classId from users where userId = ?"); 
			ps.setString(1, userId);
			rs = ps.executeQuery();
			
			return rs.next() ? rs.getString("classId") : "";
		} finally {
			rs.close();
			ps.close();
		}
	}
	
	


}
