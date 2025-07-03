package able.basic.web;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import able.basic.web.TestParser.TableCRUD;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import net.sf.jsqlparser.JSQLParserException;

/**
 * <pre>
 * Statements
 * </pre>
 *
 * @ClassName   : TestJavaParser.java
 * @Description : 클래스 설명을 기술합니다.
 * @author oh.dongwon
 * @since 2022. 9. 5.
 * @version 1.0
 * @see
 * @Modification Information
 * <pre>
 *     since          author              description
 *  ===========    =============    ===========================
 *  2022. 9. 5.     oh.dongwon     	최초 생성
 * </pre>
 */

public class TestJavaParser {
    
    public static String allTableTxt = "";
    public static class TableCRUD {
        public String tableName = "";
        public String CRUD_C = "X";
        public String CRUD_R = "X";
        public String CRUD_U = "X";
        public String CRUD_D = "X";
        public String printTableInfo(){
            return this.tableName + "\t" +  this.CRUD_C +  "\t" +  this.CRUD_R +"\t" + this.CRUD_U  +  "\t" +this.CRUD_D; 
            
        }
    }
    /**
     * Statements
     *
     * @param args
     * @throws JSQLParserException 
     * @throws IOException 
     */
    public static void main(String[] args) throws IOException, JSQLParserException {
        
        //File basePath2 = new File("C:\\DES_old\\workspace\\asissmartweb\\MobisHPartWEB\\src\\com\\mobis\\hpart\\cw\\services\\impl\\JCHACW120UImpl.java");
        
        
        //extractTableNmList(basePath2);
        
        //if(true) return;
        
        File basePath = new File("C:\\DES_old\\workspace\\asissmartweb");
        String[] extensions = {"java"};
        Collection<File> files = FileUtils.listFiles(basePath, extensions, true);
        
        int i = 0 ;
        int sum = files.size();
        System.out.println("**********************[START]");
        for (File file : files) {
            //String filename = file.getName();
            
            System.out.println("**********************[" + i + "/" + sum + "]");
            String filePath = file.getPath();
            try{
                extractTableNmList(file);
                //System.out.println("*(*(*(*(*(*(*(*(*(*(* : filePath : " + filePath);
            }catch(Exception e){
                //e.printStackTrace();
                //System.out.println(e.toString());
                //System.out.println("*(*(*(*(*(*(*(*(*(*(*");
                System.out.println("*(*(*(*(*(*(*(*(*(*(* : filePath : " + filePath);
            }
            i++;
            
            
            if( i > 1000 ){
               //break;
            }
        }
        
        File outPutFileTable = new File("C:\\01.project\\ALL_JAVA_VS_COBOL.sql");
        FileUtils.writeStringToFile(outPutFileTable, allTableTxt,"UTF-8");
    }
    
    private static void extractTableNmList(File cobolFile) throws IOException, JSQLParserException {
        String filename = cobolFile.getName();
        String filePath = cobolFile.getPath();
        String fileConteonts = FileUtils.readFileToString(cobolFile , "UTF-8");
        
        
        String findStr = ".invoke";
        int countInvoke = StringUtils.countMatches(fileConteonts, findStr);
        
        
        
        if( countInvoke < 1){
            allTableTxt = filename + "\t" + "NO_INVOKE(type1)\t" +filePath +  "\n" + allTableTxt;
            return;
        }
        // .invoke("HPARTLIB","XXXXBBBCCC",param) 이런형식임
        
        
        HashMap < String ,String> cobolMap = new HashMap<String,String>();
        int nIndex = -1;
        for(int i = 0 ; i < countInvoke ; i++){
            List<TableCRUD> rtnListTable = new ArrayList<TableCRUD>();
            
            nIndex = StringUtils.indexOf(fileConteonts, findStr , nIndex );
            
            //StringUtils.indexOfAny("zzabyycdxx", ["ab", "cd"])   = 2
            int indexOfInvokeStringStart = StringUtils.indexOf(fileConteonts, "(" , nIndex );
            
            
            int indexOfInvokeStringEnd = StringUtils.indexOf(fileConteonts, ")" , nIndex + 5 );
            
            String strInner = StringUtils.mid(fileConteonts, indexOfInvokeStringStart, indexOfInvokeStringEnd - indexOfInvokeStringStart);
            //System.out.println("*(*(*(*(*(*(*(*(*(*(* : strInner : " + strInner);
            
            
            if( strInner != null ){
                strInner = StringUtils.replace(strInner , "(" , "");
                strInner = StringUtils.replace(strInner , ")" , "");
                strInner = StringUtils.replace(strInner , " " , "");
                strInner = StringUtils.replace(strInner , "\"" , "");
            }
            
            String [] cobolSrcArray = StringUtils.split(strInner, ",");
            
            String coboleSrcName = "";
            if( cobolSrcArray != null && cobolSrcArray.length > 1 ){
                coboleSrcName = cobolSrcArray[0] + "." + cobolSrcArray[1];
                
            }
            //System.out.println("*(*(*(*(*(*(*(*(*(*(* : coboleSrcName : " + coboleSrcName);
            
            cobolMap.put(coboleSrcName, "1");
            
            
            
            TableCRUD tableData = new TableCRUD();
            int tableIndex = StringUtils.indexOf(fileConteonts, " " , nIndex );
            String talbeNm =  StringUtils.substring(fileConteonts, nIndex, tableIndex);
            nIndex ++;
        }
        if( nIndex < 1 ){
            allTableTxt = filename + "\t" + "NO_INVOKE(type2)\t" +filePath +  "\n" + allTableTxt;
            return;
        }
        
        for( String strKey : cobolMap.keySet() ){
            String cobol = strKey;
            allTableTxt = filename + "\t" + strKey + "\t" +filePath +  "\n" + allTableTxt;
            System.out.println(filename + "\t" + strKey + "\t" +filePath);
        }
        
    }
    
    
    private static Map<String,TableCRUD> selectTableList2(String removeAnnotationQuery , String filePath , String fileNm  , String queryNum){
        if( StringUtils.isEmpty(removeAnnotationQuery)){
            return null;
        }
        String [] findListStr = {   "ACTLIB",
                "APARTFLE",
                "APARTSAM",
                "EAILIB",
                "EDILIB",
                "GIMSFLE",
                "HIERPFLE",
                "HPARTFLE",
                "HPARTRCV",
                "HPARTSAM",
                "KACPTFLE",
                "KALPTFLE",
                "KAMPTFLE",
                "KASPTFLE",
                "KPTDB00",
                "KPTDB02",
                "KPTDB03",
                "KPTDB04",
                "KPTDB09",
                "PSNLIB",
                "QTEMP",
                "RESLIB",
                "RPARTFLE",
                "SESSION",
                "SPARTFLE",
                "SYSIBM",
                "SYSJOB",
                "TESTLIB",
                "TPARTFLE",
                "TPARTSAM",
                "TRSLIB",
                "UIERFLE",
                "UIERPFLE",
                "UPART890",
                "UPARTBAK",
                "UPARTFLE",
                "UPARTLIB",
                "UPARTSAM",
                "UPARTSAV",
                "UTESTFLE",
                "WOSFLE",
                "WPARTFLE",
                "ZPARTFLE"
               };
        List<TableCRUD> rtnListAllTable = new ArrayList<TableCRUD>();
        for(int i = 0 ; i< findListStr.length ; i++ ){
            String findStr = findListStr[i];
            TableCRUD tableData = new TableCRUD();
            List<TableCRUD> rtnListTable = getTable(removeAnnotationQuery, findStr , tableData);
            if( rtnListTable != null){
                rtnListAllTable.addAll(rtnListTable);
            }
        }
        Map<String,TableCRUD> tableMap = new HashMap<String,TableCRUD>();
        String tableName = "";
        for(int i = 0 ; i < rtnListAllTable.size() ; i++){
            
            TableCRUD listTblData = rtnListAllTable.get(i);
            tableName = listTblData.tableName;
            
            if( tableMap.get(tableName) == null  ){
                tableMap.put(tableName , rtnListAllTable.get(i) );
            }else{
                
                TableCRUD tempTableCRUD = tableMap.get(tableName);
                if( !listTblData.CRUD_C.equals("X")){
                    tempTableCRUD.CRUD_C = "O";
                }
                
                if( !listTblData.CRUD_R.equals("X")){
                    tempTableCRUD.CRUD_R = "O";
                }
                
                if( !listTblData.CRUD_U.equals("X")){
                    tempTableCRUD.CRUD_U = "O";
                }
                
                if( !listTblData.CRUD_D.equals("X")){
                    tempTableCRUD.CRUD_D = "O";
                }
                tableMap.put(tableName, tempTableCRUD);
            }
        }
        
        for( String strKey : tableMap.keySet() ){
            TableCRUD tableCRUD = tableMap.get(strKey);
            //System.out.println(" tableCRUD +:"+ tableCRUD.printTableInfo() );
        }
        return tableMap;
    }
    
    /**
     * Statements
     *
     * @param removeAnnotationQuery
     * @param findStr
     */
    private static List<TableCRUD> getTable(String removeAnnotationQuery, String findStr , TableCRUD tableData2 ) {
        int countMatch = StringUtils.countMatches(removeAnnotationQuery,findStr);
        
        if( countMatch < 1 ){
            return null;
        };
        removeAnnotationQuery = StringUtils.replace(removeAnnotationQuery, "\n", " \n");
        removeAnnotationQuery = StringUtils.replace(removeAnnotationQuery, "(", " ");
        int nIndex = -1;
        List<TableCRUD> rtnListTable = new ArrayList<TableCRUD>();
        for(int i = 0 ; i< countMatch ; i++){
            nIndex = StringUtils.indexOf(removeAnnotationQuery, findStr , nIndex );
            String crudString = "";
            if( i == 0 ){
                if( StringUtils.startsWith(removeAnnotationQuery, "INSERT") ){
                    crudString = "C";
                }
                if( StringUtils.startsWith(removeAnnotationQuery, "SELECT") ){
                    crudString = "R";
                }
                if( StringUtils.startsWith(removeAnnotationQuery, "UPDATE") ){
                    crudString = "U";
                }
                if( StringUtils.startsWith(removeAnnotationQuery, "DELETE") ){
                    crudString = "D";
                }
            }else{
                crudString = "R";
            }
            
            TableCRUD tableData = new TableCRUD();
            int tableIndex = StringUtils.indexOf(removeAnnotationQuery, " " , nIndex );
            //table = table + StringUtils.substring(removeAnnotationQuery, nIndex, tableIndex) + "\t" ;
            String talbeNm =  StringUtils.substring(removeAnnotationQuery, nIndex, tableIndex);
            tableData.tableName = talbeNm;
            if(crudString.equals("C")){
                tableData.CRUD_C = "O";
            }
            
            if(crudString.equals("R")){
                tableData.CRUD_R = "O";
            }
            
            if(crudString.equals("U")){
                tableData.CRUD_U = "O";
            }
            
            if(crudString.equals("D")){
                tableData.CRUD_D = "O";
            }
            
            rtnListTable.add(tableData);
            nIndex++;
        }
        return rtnListTable;
        
    }

}
