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
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.Statement;
import net.sf.jsqlparser.statement.delete.Delete;
import net.sf.jsqlparser.statement.insert.Insert;
import net.sf.jsqlparser.statement.select.Select;
import net.sf.jsqlparser.statement.update.Update;
import net.sf.jsqlparser.util.TablesNamesFinder;

/**
 * <pre>
 * Statements
 * </pre>
 *
 * @ClassName   : TestParser.java
 * @Description : 클래스 설명을 기술합니다.
 * @author oh.dongwon
 * @since 2022. 9. 2.
 * @version 1.0
 * @see
 * @Modification Information
 * <pre>
 *     since          author              description
 *  ===========    =============    ===========================
 *  2022. 9. 2.     oh.dongwon     	최초 생성
 * </pre>
 */

public class TestParser {
    
    
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
    public static String allTableTxt = "";
    /**
     * Statements
     *
     * @param args
     * @throws JSQLParserException 
     * @throws IOException 
     */
    public static void main(String[] args) throws JSQLParserException, IOException {
        
        
        
        
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
                extractTableNmList(file);
            }catch(Exception e){
                //e.printStackTrace();
                //System.out.println(e.toString());
                //System.out.println("*(*(*(*(*(*(*(*(*(*(*");
                System.out.println("*(*(*(*(*(*(*(*(*(*(* : filePath : " + filePath);
                totalText = totalText + filePath + "\n";
            }
            i++;
            
            
            if( i > 1 ){
               //break;
            }
        }
        System.out.println("**********************[FINISH]");
        File outPutFile = new File("C:\\01.project\\ALL_ERROR.sql");
        FileUtils.writeStringToFile(outPutFile, totalText,"UTF-8");
        System.out.print(allTableTxt);
        File outPutFileTable = new File("C:\\01.project\\ALL_TABLE.sql");
        FileUtils.writeStringToFile(outPutFileTable, allTableTxt,"UTF-8");
        

    }



    /**
     * Statements
     *
     * @param cobolFile
     * @throws IOException
     * @throws JSQLParserException
     */
    private static void extractTableNmList(File cobolFile) throws IOException, JSQLParserException {
        String filename = cobolFile.getName();
        String filePath = cobolFile.getPath();
        String fileConteonts = FileUtils.readFileToString(cobolFile , "UTF-8");
        fileConteonts = selectRemoveAnnotation(fileConteonts);    
        String[] queryRtn = StringUtils.substringsBetween(fileConteonts , "EXEC SQL" , "END-EXEC");
        
        if( queryRtn == null){
            allTableTxt = filename + "\t" + "NO TABLLE(type1)\t\t\t\t" + "\t" +filePath +  "\n" + allTableTxt;
            return;
        }
        //System.out.println("********************");
        //System.out.println("********************");
        //System.out.println("substringsBetween START ********");
        Map<String,TableCRUD>  tatalTableCRUD = new HashMap<String,TableCRUD>();
        
        int countOfQry = 0;
        for(int i = 0 ; i < queryRtn.length ; i++){
            
            
            String formatQuery = selectFormatQuery2(queryRtn[i]);
            Map<String,TableCRUD>  rtnMap = selectTableList2(formatQuery ,filename, filePath , i + "");
            
            if( rtnMap != null ) {
                countOfQry ++;
                for( String strKey : rtnMap.keySet() ){
                    TableCRUD tableCRUD = rtnMap.get(strKey);
                    String tableName = tableCRUD.tableName;
                    if( tatalTableCRUD.get(tableName) == null  ){
                        tatalTableCRUD.put(tableName ,tableCRUD );
                    }else{
                        
                        TableCRUD tempTableCRUD = tatalTableCRUD.get(tableName);
                        if( !tableCRUD.CRUD_C.equals("X")){
                            tempTableCRUD.CRUD_C = "O";
                        }
                        
                        if( !tableCRUD.CRUD_R.equals("X")){
                            tempTableCRUD.CRUD_R = "O";
                        }
                        
                        if( !tableCRUD.CRUD_U.equals("X")){
                            tempTableCRUD.CRUD_U = "O";
                        }
                        
                        if( !tableCRUD.CRUD_D.equals("X")){
                            tempTableCRUD.CRUD_D = "O";
                        }
                        tatalTableCRUD.put(tableName, tempTableCRUD);
                    }
                }
            }
            
        }
        
        if( countOfQry < 1 ){
            allTableTxt = filename + "\t" + "NO TABLLE(type2)\t\t\t\t" + "\t" +filePath +  "\n" + allTableTxt;
        }
        
        for( String strKey : tatalTableCRUD.keySet() ){
            TableCRUD tableCRUD = tatalTableCRUD.get(strKey);
            //System.out.print(filename + "\t" + tableCRUD.printTableInfo() + "\t" +filePath +  "\n" );
            allTableTxt = filename + "\t" + tableCRUD.printTableInfo() + "\t" +filePath +  "\n" + allTableTxt;
        }
        
    }


    private static String selectFormatQuery2(String query3) {
        String query4  = StringUtils.stripStart(query3, null);
        query4 = StringUtils.replace(query4, "\r\n", " \n");
        query4 = StringUtils.replace(query4, ",", " ,");
        query4 = StringUtils.replace(query4, ")", " )");
        
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
            
            if( StringUtils.startsWith(queryStr , "\n") ){
                continue;
            }
            if( StringUtils.startsWith(queryStr , "\r\n") ){
                continue;
            }
            
           
            
            
            //DECLARE C_MCOQ CURSOR 대응
            //if( StringUtils.indexOf(queryStr, "DECLARE") > -1 && StringUtils.indexOf(queryStr, "CURSOR") > -1 ){
                //continue;
            //}
            // DECLARE CSMPSMITM
            // SCROLL CURSOR FOR
            
            
            //if( StringUtils.startsWith(queryStr , ":")){
                //continue;
            //}
            if( StringUtils.indexOf(queryStr, "SELECT") > -1 && StringUtils.indexOf(queryStr, "DECLARE") > -1  ){
                queryStr = "SELECT * "; 
            }else if( StringUtils.indexOf(queryStr, "DECLARE") > -1  ){
                continue;
            }
            
            if( i == ( arrayList.length -1 )){
                removeAnnotationStr = removeAnnotationStr + queryStr;
            }else{
                removeAnnotationStr = removeAnnotationStr + queryStr + "\n";
            }
            
           
        }
        // CRUD 쿼리 이외에는 제외
        if(!( StringUtils.startsWith(removeAnnotationStr, "INSERT") ||  StringUtils.startsWith(removeAnnotationStr, "SELECT") ||    
            StringUtils.startsWith(removeAnnotationStr, "UPDATE") ||   StringUtils.startsWith(removeAnnotationStr, "DELETE") ))
        {
            return "";
        }
        return removeAnnotationStr;
    }
  
    
    private static Map<String,TableCRUD> selectTableList2(String removeAnnotationQuery , String filePath , String fileNm  , String queryNum){
        if( StringUtils.isEmpty(removeAnnotationQuery)){
            return null;
        }
        
        String tableList = "";
        String firstTable = "";
        int firstQueryIndex = -1;
        
        // 찾을 스크마 복록
        /*
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
                                    "KPTDB00.UPARTFLE",
                                    "KPTDB02.ASEISFLE",
                                    "KPTDB02.GIMSFLE",
                                    "KPTDB03.EPARTFLE",
                                    "KPTDB04.EAIFLE",
                                    "KPTDB09.APARTFLE",
                                    "KPTDB09.APARTLIB",
                                    "KPTDB09.KACPTFLE",
                                    "KPTDB09.KALPTFLE",
                                    "KPTDB09.KAMPTFLE",
                                    "KPTDB09.KASPTFLE",
                                    "KPTDB09.KATPTFLE",
                                    "KPTDB09.SPARTFLE",
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
                                   */
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
    
    
    
    
    /**
     * Statements
     *
     * @param query4
     * @return
     */
    private static String selectFormatQuery(String query3) {
        
        query3 = StringUtils.stripStart(query3, null);
        String query4 = StringUtils.replace(query3, "\"", "'");
        query4 = StringUtils.replace(query4, "/", ".");
        
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
            
            if( StringUtils.startsWith(queryStr , "\n") ){
                continue;
            }
            if( StringUtils.startsWith(queryStr , "\r\n") ){
                continue;
            }
            
            // row 별로 분리해서 INTO :  된건은 제거
            if( StringUtils.startsWith(queryStr , "INTO") && StringUtils.indexOf(queryStr, ":") > -1){
                continue;
            }
            
            
            
            //DECLARE C_MCOQ CURSOR 대응
            //if( StringUtils.indexOf(queryStr, "DECLARE") > -1 && StringUtils.indexOf(queryStr, "CURSOR") > -1 ){
                //continue;
            //}
            // DECLARE CSMPSMITM
            // SCROLL CURSOR FOR
            if( StringUtils.startsWith(queryStr , "SCROLL")){
                continue;
            }
            
            //if( StringUtils.startsWith(queryStr , ":")){
                //continue;
            //}
            
            if( StringUtils.startsWith(queryStr , "DECLARE")){
                continue;
            }
            
            if( StringUtils.indexOf(queryStr, "SELECT") > -1 && StringUtils.indexOf(queryStr, "INTO") > -1  && StringUtils.indexOf(queryStr, "*") > -1 && StringUtils.indexOf(queryStr, ":") > -1){
                queryStr = "SELECT * "; 
                
                //continue;
            }else if( StringUtils.indexOf(queryStr, "SELECT") > -1 && StringUtils.indexOf(queryStr, "INTO") > -1  && StringUtils.indexOf(queryStr, ":") > -1){
                queryStr = StringUtils.replace(queryStr, "INTO", "");
                queryStr = StringUtils.replace(queryStr, ":", "AS ");
                queryStr = StringUtils.replace(queryStr, "-", "_");
                //continue;
            }
            
            
            if( StringUtils.indexOf(queryStr, ":") > -1 ){
                queryStr = StringUtils.replace(queryStr, ":", "");
                queryStr = StringUtils.replace(queryStr, "-", "_");
                //continue;
            }
            
            
            
            if( StringUtils.startsWith(queryStr , "FOR FETCH") ){
                continue;
            }
            
            
            
            if( StringUtils.startsWith(queryStr , "WITH UR") ){
                continue;
            }
            if( StringUtils.startsWith(queryStr , "WITH NC") ){
                continue;
            }
            
            
            /**
             * LEFT OUTER JOIN UPARTLIB/VWUAPUDPM ON
                PS (UTPM_PTNO = UDPM_PTNO )
             */
            if( StringUtils.startsWith(queryStr , "PS") ){
                queryStr = StringUtils.removeStart(queryStr,"PS");
            }
            if( i == ( arrayList.length -1 )){
                removeAnnotationStr = removeAnnotationStr + queryStr;
            }else{
                removeAnnotationStr = removeAnnotationStr + queryStr + "\n";
            }
        }
        // CRUD 쿼리 이외에는 제외
        if(!( StringUtils.startsWith(removeAnnotationStr, "INSERT") ||  StringUtils.startsWith(removeAnnotationStr, "SELECT") ||    
            StringUtils.startsWith(removeAnnotationStr, "UPDATE") ||   StringUtils.startsWith(removeAnnotationStr, "DELETE") ))
        {
            return "";
        }
        
        return removeAnnotationStr;
    }
    
    private static String selectRemoveAnnotation(String query3) {
        String query4 = StringUtils.replace(query3, "\"", "'");
        
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
    
    


    /**
     * Statements
     *
     * @param removeAnnotationStr
     * @throws JSQLParserException
     */
    private static void selectTableList(String removeAnnotationStr) throws JSQLParserException {
        if( StringUtils.isEmpty(removeAnnotationStr)){
            return ;
        }
        
        Statement statement = CCJSqlParserUtil.parse(removeAnnotationStr);
        if( StringUtils.startsWith(removeAnnotationStr, "SELECT") ){ 
            Select selectStatement = (Select) statement;
            TablesNamesFinder tablesNamesFinder = new TablesNamesFinder();
            List<String> tableList = tablesNamesFinder.getTableList(selectStatement);
            for(int i = 0 ; i< tableList.size() ; i++){
                String tableNm = tableList.get(i);
                allTableTxt = allTableTxt + tableNm + "\n";
            }
        }
        
        
        if( StringUtils.startsWith(removeAnnotationStr, "INSERT") ){ 
            Insert selectStatement = (Insert) statement;
            TablesNamesFinder tablesNamesFinder = new TablesNamesFinder();
            List<String> tableList = tablesNamesFinder.getTableList(selectStatement);
            for(int i = 0 ; i< tableList.size() ; i++){
                String tableNm = tableList.get(i);
                allTableTxt = allTableTxt + tableNm + "\n";
            }
        }
        
        if( StringUtils.startsWith(removeAnnotationStr, "UPDATE") ){ 
            Update selectStatement = (Update) statement;
            TablesNamesFinder tablesNamesFinder = new TablesNamesFinder();
            List<String> tableList = tablesNamesFinder.getTableList(selectStatement);
            for(int i = 0 ; i< tableList.size() ; i++){
                String tableNm = tableList.get(i);
                allTableTxt = allTableTxt + tableNm + "\n";
            }
        }
        
        if( StringUtils.startsWith(removeAnnotationStr, "DELETE") ){ 
            Delete selectStatement = (Delete) statement;
            TablesNamesFinder tablesNamesFinder = new TablesNamesFinder();
            List<String> tableList = tablesNamesFinder.getTableList(selectStatement);
            for(int i = 0 ; i< tableList.size() ; i++){
                String tableNm = tableList.get(i);
                allTableTxt = allTableTxt + tableNm + "\n";
            }
        }
        //return rtnText;
    }
    
    
}
