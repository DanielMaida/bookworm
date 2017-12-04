package converter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;

public class TxtToJsonConverter {
	
	private static StringBuilder builder = new StringBuilder();
	private static boolean firstIteration = true;
	
	public static void main(String[] args) {
		builder.append("{");
		convertInvertedIndex(new File("../InvertedFile/inverted_index.txt"));
		builder.append("}");		
		
		try {
			PrintWriter out = new PrintWriter("../InvertedFile/inverted-index.json");
			out.print(builder.toString());
			out.flush();
			out.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static void convertInvertedIndex(File file) {
		
		try (BufferedReader br = new BufferedReader(new FileReader(file))) {
		    String line;
		    while ((line = br.readLine()) != null) {
		    	line = line.replace('\u0022', '~'); //using ~ as placeholder for "
		    	
		    	String[] values = line.substring(lastIndexOfKey(line)+1).split(",");		    			    	
		    	if(!firstIteration)
					builder.append(",\n");
				builder.append('"');
				builder.append(line.substring(0, lastIndexOfKey(line))); //key
				builder.append('"');
				builder.append(":");
				builder.append('[');
				boolean firstValue = true;
				for (String value : values) {
					if(!firstValue)
						builder.append(',');
					builder.append("{");
					builder.append('"');
					builder.append("id");
					builder.append('"');
					builder.append(':');					
					builder.append(value.substring(0,value.indexOf("(")));
					
					builder.append(",");
					builder.append('"');
					builder.append("qtd");
					builder.append('"');
					builder.append(":");
					builder.append(value.substring(value.indexOf("(")+1,value.indexOf(")")));
					builder.append("}");
					firstValue = false;
					
				}
				//builder.append(line.substring(lastIndexOfKey(line)+1));
				builder.append(']');
				firstIteration=false;
		    }
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
						
	}
	
	public static int lastIndexOfKey(String line) {
		int indexOfComma = line.indexOf(",");
		char chartToBeTested = line.charAt(indexOfComma+1);
		while(!Character.isDigit(chartToBeTested)) {	//(chartToBeTested != '-' && !Character.isDigit(line.charAt(indexOfComma+1))) &&  
			indexOfComma = line.indexOf(",",indexOfComma+1);
			chartToBeTested = line.charAt(indexOfComma+1);									
		}
		return indexOfComma;		
	}
}
