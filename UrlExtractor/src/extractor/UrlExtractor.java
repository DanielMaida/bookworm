package extractor;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.RandomAccessFile;

public class UrlExtractor {
	private static StringBuilder builder = new StringBuilder();
	private static boolean firstIteration = true;
	
	public static void main(String[] args) {
		File[] files = new File("../Pages").listFiles();
		builder.append("{");
		showFiles(files);		
		builder.append("}");
		
		try {
			PrintWriter out = new PrintWriter("../InvertedFile/linkIdMap.json");
			out.print(builder.toString());
			out.flush();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public static void showFiles(File[] files) {
		for (File file : files) {
			if (file.isDirectory()) {
				showFiles(file.listFiles()); // Calls same method again.
			} else {
				String fileName = file.getName();
				switch (file.getParent().substring(9)) {
				case "casasbahia":					
					fileName = "1"+fileName.substring("casasbahia".length());
					break;
					
				case "estantevirtual":					
					fileName = "2"+fileName.substring("estantevirtual".length());
					break;
					
				case "livrariacultura":					
					fileName = "3"+fileName.substring("livrariacultura".length());
					break;
					
				case "livrariafolha":					
					fileName = "4"+fileName.substring("livrariafolha".length());
					break;
					
				case "saraiva":					
					fileName = "5"+fileName.substring("saraiva".length());
					break;
					
				case "submarino":					
					fileName = "6"+fileName.substring("submarino".length());
					break;
					
				case "amazon":					
					fileName = "7"+fileName.substring("amazon".length());
					break;
					
				default:
					break;
				}
				
				fileName = fileName.substring(0,fileName.lastIndexOf('.'));
				
				String link = tail(file).substring(10);
				link = link.replace('\u0022','~'); //using ~ as placeholder for "
				
				if(!firstIteration)
					builder.append(",\n");
				builder.append('"');
				builder.append(fileName);
				builder.append('"');
				builder.append(":");
				builder.append('"');
				builder.append(link);
				builder.append('"');
				
				firstIteration = false;
			}
		}
	}
	
	public static String tail( File file ) {
	    RandomAccessFile fileHandler = null;
	    try {
	        fileHandler = new RandomAccessFile( file, "r" );
	        long fileLength = fileHandler.length() - 1;
	        StringBuilder sb = new StringBuilder();

	        for(long filePointer = fileLength; filePointer != -1; filePointer--){
	            fileHandler.seek( filePointer );
	            int readByte = fileHandler.readByte();

	            if( readByte == 0xA ) {
	                if( filePointer == fileLength ) {
	                    continue;
	                }
	                break;

	            } else if( readByte == 0xD ) {
	                if( filePointer == fileLength - 1 ) {
	                    continue;
	                }
	                break;
	            }

	            sb.append( ( char ) readByte );
	        }

	        String lastLine = sb.reverse().toString();
	        return lastLine;
	    } catch( java.io.FileNotFoundException e ) {
	        e.printStackTrace();
	        return null;
	    } catch( java.io.IOException e ) {
	        e.printStackTrace();
	        return null;
	    } finally {
	        if (fileHandler != null )
	            try {
	                fileHandler.close();
	            } catch (IOException e) {
	                /* ignore */
	            }
	    }
	}
}
