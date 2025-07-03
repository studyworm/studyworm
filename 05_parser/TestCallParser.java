package able.basic.web;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import net.sf.jsqlparser.JSQLParserException;

/**
 * <pre>
 * Statements
 * </pre>
 *
 * @ClassName   : TestCallParser.java
 * @Description : 클래스 설명을 기술합니다.
 * @author oh.dongwon
 * @since 2022. 9. 21.
 * @version 1.0
 * @see
 * @Modification Information
 * <pre>
 *     since          author              description
 *  ===========    =============    ===========================
 *  2022. 9. 21.     oh.dongwon     	최초 생성
 * </pre>
 */

public class TestCallParser {

   
    public static String allTableTxt = "";
    /**
     * Statements
     *
     * @param args
     * @throws JSQLParserException 
     * @throws IOException 
     */
    public static void main(String[] args) throws JSQLParserException, IOException {
        
        
        if( 1 == 2 ){
            File testFile = new File("C:\\DES_old\\workspace\\asisdbsrc\\USFPGM\\UPARTSRC\\USFPGM\\CBUALW050R.cob");
            
            extractCallList(testFile);
            
            if(1 == 1 ){
                return;
            }
        }
        
        //File file2 = new File("C:\\DES_old\\workspace\\asisdbsrc\\USFPGM\\UPARTSRC\\USFPGM\\CBUATW021U.cob");
        
        
        //extractTableNmList(file2);
        
        //if(true) return;
        
        
        File basePath = new File("C:\\DES_old\\workspace\\asisdbsrc");
        String[] extensions = {"cob"};
        Collection<File> files = FileUtils.listFiles(basePath, extensions, true);
        
        int i = 0 ;
        String totalText = "";
        
        int sum = files.size();
        System.out.println("**********************[START]");
        for (File file : files) {
            //String filename = file.getName();
            
            System.out.println("**********************[" + i + "/" + sum + "]");
            String filePath = file.getPath();
            try{
                extractCallList(file);
            }catch(Exception e){
                //e.printStackTrace();
                //System.out.println(e.toString());
                //System.out.println("*(*(*(*(*(*(*(*(*(*(*");
                System.out.println("*(*(*(*(*(*(*(*(*(*(* : filePath : " + filePath);
                totalText = totalText + filePath + "\n";
            }
            i++;
            
            
            if( i > 100 ){
               //break;
            }
        }
        System.out.println("**********************[FINISH]");
        File outPutFile = new File("C:\\01.project\\ALL_ERROR_CALL.sql");
        FileUtils.writeStringToFile(outPutFile, totalText,"UTF-8");
        System.out.print(allTableTxt);
        File outPutFileTable = new File("C:\\01.project\\ALL_CALL.sql");
        FileUtils.writeStringToFile(outPutFileTable, allTableTxt,"UTF-8");
        

    }


    /**
     * Statements
     *
     * @param cobolFile
     * @throws IOException
     * @throws JSQLParserException
     */
    private static void extractCallList(File cobolFile) throws IOException, JSQLParserException {
        String filename = cobolFile.getName();
        String filePath = cobolFile.getPath();
        String fileConteonts = FileUtils.readFileToString(cobolFile , "UTF-8");
        fileConteonts = selectRemoveAnnotation(fileConteonts);    
        //System.out.println(fileConteonts);

        // \nCALL 과 \n 사이의 글자를 추출한다. => String[]
        String[] queryRtn = StringUtils.substringsBetween(fileConteonts , "\nCALL " , "\n");
        
        
        if( queryRtn == null){
            allTableTxt = filename + "\t" + "NOCALL" + "\t" +filePath +  "\n" + allTableTxt;
            return;
        }
        
        
        
        Map<String,String> mapReduce = new HashMap<String,String> ();
        
        int length = queryRtn.length;
        String allTxt = "";
        String cobolNm = "";
        for(int i = 0 ; i < length ;i++){
            allTxt =  queryRtn[i];
            
            // 따옴표 사이의 글자를 추출한다. => cobolNm
            cobolNm = StringUtils.substringBetween(allTxt , "'" , "'");
            
            // cobolNm 이 비었으면 (null, ""), 이 구문 안의 로직은 이해 안감
            if( cobolNm == null || StringUtils.isEmpty(cobolNm)){
                int index = StringUtils.indexOf(allTxt, " ");
                if( index < 0 ){
                    cobolNm = "추출실패";
                }else{
                    cobolNm = StringUtils.substring(allTxt, 0,index).trim();
                    if( StringUtils.contains(cobolNm, "(")){
                        int index2 = StringUtils.indexOf(allTxt, "(");
                        cobolNm = StringUtils.substring(allTxt, 0,index2).trim();
                    }
                    
                }
                
            }
            
            // mapReduce 맵에 cobolNm을 넣는다. 이걸 map에 넣는 이유는 중복 제거로 보임. 
            mapReduce.put(cobolNm ,cobolNm);
            //System.out.println("****** between call[" +allTxt +"] COBOL NM [" + cobolNm + "]");
        }
        String value = "";
        for( String strKey : mapReduce.keySet() ){
            value = mapReduce.get(strKey);
            allTableTxt = filename + "\t" + value + "\t" +filePath +  "\n" + allTableTxt;
        }
    }

    // 주석제거 
    private static String selectRemoveAnnotation(String query3) {
        String query4 = StringUtils.replace(query3, "\"", "'");
        query4 = StringUtils.replace(query4, "\r\n", " \n");
        
        
        
        String[] arrayList = StringUtils.split(query4, "\n");
        String removeAnnotationStr = "";
        // row 별로 분리해서 * 된건은 제거
        // row 별로 분리해서 INTO 된건은 제거
        for(int i = 0 ; i < arrayList.length ; i++){
            
            String queryStr =  arrayList[i];
            queryStr = StringUtils.stripStart(queryStr, null);
            
            // row 별로 분리해서 * 된건은 제거
            if( StringUtils.startsWith(queryStr , "*") ){
                continue;
            }
            removeAnnotationStr = removeAnnotationStr + queryStr + "\n";
        }
        // 멀티 " " ==> 단일" "
        removeAnnotationStr = removeAnnotationStr.replaceAll("[ ]+", " ");
        
        return removeAnnotationStr;
    }
    
    

}
