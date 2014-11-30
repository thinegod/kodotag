
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Seba
 */
public class ImprovedExecutable {
	
	public static String[] folders = {"heroes","abilities","items","units","addon_english"};
	public static String[] keys = {"DOTAHeroes","DOTAAbilities","DOTAAbilities","DOTAUnits","lang"};
	public static String[] files = {"npc_heroes_custom.txt","npc_abilities_custom.txt","npc_items_custom.txt","npc_units_custom.txt","addon_english.txt "};
	
	public static void main(String[] args){
            doThings();
            //long time = getLastModified();
            while (true)
            {
			long time = getLastModified();
                try {
                    Thread.sleep(500);
                } catch (InterruptedException ex) {
                }
                if (time < getLastModified())
                {
                    doThings();
                }
            }
	}
        
        private static long getLastModified()
        {
            long r = 0;
            
            for (String s : folders)
            {
                File f = new File(s);
                if (!f.exists()) { System.err.println("File not found: "+s); continue;}
                for (File fp : f.listFiles())
                {
                    if (fp.lastModified() > r) { r = fp.lastModified(); }
                }
            }
            
            return r;
        }
        
        private static void doThings()
        {
		
		for(int i=0 ;i < folders.length ;i++)
                {
			System.out.println(generateFileForFolder(folders[i], files[i], keys[i]));
		}
        }
	
	
	public static String generateFileForFolder(String folder,String filename,String key){
		
		System.out.println("Generating " + filename + " file");
		
		File heroesFolder = new File(folder);
		if (!heroesFolder.isDirectory())
			return "No folder named '" + folder + "' found. '" + filename + "' will not be generated";
		
		FileWriter f;
		try
		{
			f = new FileWriter(filename);
			PrintWriter newFile = new PrintWriter(f);
			
			newFile.println("//");
			newFile.println('"'+key+'"');
			newFile.println("{");
			
			//time to write on the new file the file content of all the source file
			for(File file : heroesFolder.listFiles()){
				FileReader fr = new FileReader(file);
				BufferedReader fileSource = new BufferedReader(fr);
				
				newFile.println("\n");
				newFile.println("\t//Start of file " + file.getName());
				
				String line = "";
				while(line!=null)
				{
					line = fileSource.readLine();
					if(line!=null)
						newFile.println("\t" + line);
				}
				fr.close();
				
				newFile.println("\t//End of file " + file.getName());
			}
			newFile.println("}");
			newFile.flush();
			f.close();
			
		} catch (IOException e)
		{
			return "Error: fatal error, operation not completed.\nPlease report to the developer the following: " + e.toString();
		}
		
		return "OK";
		
	}
}
