package dbProcs;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.List;

public class ModuleTest {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/core","root","CowSaysMoo");
			//LinkedHashMap<Integer, List<Module>> modules = getModulesByWeek(con, "eb148ddef25dd5a1765090718f80f03f5c298dc8");
			List<Module> modules = Module.getModules(con, "eb148ddef25dd5a1765090718f80f03f5c298dc8");
			System.out.println("Modules: " + modules.size());
			for (Module module : modules) {
				System.out.println(module.week + ": " + module.moduleNameLangPointer);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
