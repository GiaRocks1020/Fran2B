/*
* @Desc:
*	Utility Class for Property Code Generator. 
* 	Logic in this class is defined based on rules mentioned in the document
* @Author:
*	Jagan Gorre
*/
public with sharing class PropertyCodeGenUtil {
    
    //Map with predefined ending codes and corresponding next codes
    public static Map<String,String> startStringMap = new Map<String,String>{
        '999' => 'A00',
        'Z99' => '0A0',
        '9Z9' => '00A',
        '99Z' => 'AA0',
        'ZZ9' => 'A0A',
        'Z9Z' => '0AA',
        '9ZZ' => 'AAA'
    };
    
    //Generate Next code based on current one
    public static String getNextCode(String currentCode){
        if(!String.isBlank(currentCode) && currentCode != 'ZZZ'){
        	currentCode = currentCode.toUpperCase();
            //If current code is one of the end codes then just return the next 
            //code from the map
            if(startStringMap.keySet().contains(currentCode)){
                return startStringMap.get(currentCode);
            }
            else{
                /* Get the Category of the code. 
                 * There are 4 different categories for 3 digit code
                 * 1) ALL_NUM : All are Numbers in the string (000).
                 * 2) ONE_NUM : One Number and Two characters (AA0,A0A,0AA).
                 * 3) TWO_NUM : Two Numbers and one character (A00,0A0,00A).
                 * 4) ALL_CHAR : All are characters in the string (AAA).
                 * Each Category has different approach for incrementation
                */
                pcwrapper pcw = getCategory(currentCode);
                //If the category is ALL_NUM, simply increment the number and return
                if(pcw!=null && pcw.categorytype == 'ALL_NUM'){
                    return incrementNumbers(currentCode,3);
                }
                //If the Category is "TWO_NUM"
                else if(pcw.categorytype == 'TWO_NUM'){
                    //Get the character in the string
                    String actChar = pcw.actChar;
                    //Get the Character position in the string
                    integer charpos = pcw.charPos;
                    //Get the rest of numbers in string
                    String restNums = pcw.restNums;
                    
                    String incAlpha = actChar;
                    String incNumber = restNums;
                    
                    //If the numbers in the string is 99, then 
                    //make it 00 and increment the character
                    if(restNums == '99'){
                        incNumber = '00';
                        incAlpha = incrementAlphabet(actChar);
                    }
                    //else just increment the number
                    else{
                        incNumber = incrementNumbers(restNums,2);
                    }
                    //Frame the final string by joining the character with number
                    //based on its initial position
                    String finalString;
                    //Skip I,O as any character
                    if(incAlpha == 'I' || incAlpha == 'O')
                        incAlpha = incrementAlphabet(incAlpha);
                    if(charpos == 1){
                        finalString = incAlpha+incNumber;
                    }
                    else if(charpos == 2){
                        String[] temp = incNumber.split('');
                        finalString=temp[0]+incAlpha+temp[1];
                    }
                    else if(charpos == 3){
                        finalString = incNumber+incAlpha;
                    }
                    return finalString;
                }
                //If the Category is "ONE_NUM"
                else if(pcw.categorytype == 'ONE_NUM'){
                    //Get the actual number in the string
                    String actNum = pcw.actNum;
                    //Get the position of the number
                    integer numPos = pcw.numPos;
                    //Get the rest of characters in the string
                    String restChars = pcw.restChars;
                    //Split the characters
                    String[] tempchars = restChars.split('');
                    
                    /* If the number in the string is 9, then,
                    *  make it zero and increment the second character.
                    *  If the second character is Z, then make it A
                    *  and increment the first character else increment
                    *  the second character.
                    *  If the number is not 9, then just increment the number
                    */
                    if(actNum == '9'){
                        actNum = '0';
                        if(tempchars[1] == 'Z'){
                            tempchars[1] = 'A';
                            tempchars[0] = incrementAlphabet(tempchars[0]);
                        }
                        else{
                            tempchars[1] = incrementAlphabet(tempchars[1]);
                        }
                        
                    }
                    else{
                        integer temp = integer.valueOf(actNum);
                        temp++;
                        actNum = String.valueOf(temp);
                    }
                    //Join the number and characters based on number position
                    String finalString;
                    //Skip I,O as any character
                    if(tempchars[0] == 'I' || tempchars[0] == 'O')
                        tempchars[0] = incrementAlphabet(tempchars[0]);
                    if(tempchars[1] == 'I' || tempchars[1] == 'O')
                        tempchars[1] = incrementAlphabet(tempchars[1]);
                    if(numPos == 1){
                        finalString = actNum+tempchars[0]+tempchars[1];
                    }
                    else if(numPos == 2){
                        finalString = tempchars[0]+actNum+tempchars[1];
                    }
                    else if(numPos == 3){
                        finalString = tempchars[0]+tempchars[1]+actNum;
                    }
                    return finalString;
                }
                //If the Category is All Characters, verify and increment the
                //characters starting from the last position
                else if(pcw.categorytype == 'ALL_CHAR'){
                    //Split the characters
                    String[] tempchars = currentCode.split('');
                    /* If the last character is Z, Make it A and
                     * increment the second character. If second is Z, Make it A and
                     * increment the first character. If second is not Z then just increment second.
                     * If the last character is not Z, then just increment the last character.
					*/
                    if(tempchars[2]=='Z'){
                        tempchars[2] = 'A';
                        if(tempchars[1]=='Z'){
                            tempchars[1] = 'A';
                            tempchars[0] = incrementAlphabet(tempchars[0]);
                        }
                        else{
                            tempchars[1] = incrementAlphabet(tempchars[1]);
                        }
                    }
                    else{
                        tempchars[2] = incrementAlphabet(tempchars[2]);
                    }
                    //Skip I,O as any character
                    if(tempchars[0] == 'I' || tempchars[0] == 'O')
                        tempchars[0] = incrementAlphabet(tempchars[0]);
                    if(tempchars[1] == 'I' || tempchars[1] == 'O')
                        tempchars[1] = incrementAlphabet(tempchars[1]);
                    if(tempchars[2] == 'I' || tempchars[2] == 'O'){
                        tempchars[2] = incrementAlphabet(tempchars[2]);
                    }
                    return String.join(tempchars,'');
                }
                
            }
        }
        return null;
    }
    
    // Method to increment numbers and frame it as string,
    // 0 or 00 is prefix based on current number and total number of digits in actual string
    static String incrementNumbers(String currentCode, Integer totalNumDigs){
        String newCodeChar;
        String prefix;
        Integer newCodeNum = Integer.valueOf(currentCode);
        newCodeNum++;
        if(totalNumDigs == 3) prefix= '00';
        if(totalNumDigs == 2) prefix= '0';
        if(totalNumDigs == 3 && newCodeNum > 9 && newCodeNum <= 99)
        	newCodeChar = '0'+newCodeNum;
        else if(newCodeNum <= 9)
        	newCodeChar = prefix+newCodeNum;
        else
    		newCodeChar = string.valueOf(newCodeNum);
        return newCodeChar;
    }
    
    //Method to increment Alphabets
    static String incrementAlphabet(String currentChar){
        String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZA';
        Integer index = key.indexOfChar(currentChar.charAt(0));
     	return index == -1? null: key.substring(index+1, index+2);
    }
    
    //Method to get the category of the string by
    //verifying each character of the string
    static pcwrapper getCategory(String currentCode){
        pcwrapper pcw = new pcwrapper();
        String[] charArray =  currentCode.split('');
        if(charArray !=null && charArray.size()>0){
            pcw.numofints=0;
        	String firstChar = charArray[0];
            String secondChar = charArray[1];
            String thirdChar = charArray[2];
            if(firstChar.isNumeric()){
                pcw.numofints++;
                pcw.numPos = 1;
                pcw.actNum = firstChar;
            }
            else if(firstChar.isAlpha()){
                pcw.charPos = 1;
                pcw.actChar = firstChar;
            }
            if(secondChar.isNumeric()){
                pcw.numofints++;
                pcw.numPos = 2;
                pcw.actNum = secondChar;
            }
            else if(secondChar.isAlpha()){
                pcw.charPos = 2;
                pcw.actChar = secondChar;
            }
            if(thirdChar.isNumeric()){
                pcw.numofints++;
                pcw.numPos = 3;
                pcw.actNum = thirdChar;
            }
            else if(thirdChar.isAlpha()){
                pcw.charPos = 3;
                pcw.actChar = thirdChar;
            }
            
            if(pcw.numofints == 0) pcw.categorytype = 'ALL_CHAR';
            else if(pcw.numofints == 1) {
                pcw.categorytype = 'ONE_NUM';
                pcw.restChars=getRestChars(firstChar,secondChar,thirdChar);
            }
            else if(pcw.numofints == 2) {
                pcw.categorytype = 'TWO_NUM';
                String rns = getRestNums(firstChar,secondChar,thirdChar); 
                pcw.restNums = rns;
            }
            else if(pcw.numofints == 3) pcw.categorytype = 'ALL_NUM';
        }
        return pcw;
    }
    
    //Method to extract the characters in the string
    static string getRestChars(string fc,string sc,string tc){
        string finalstr='';
        if(fc.isAlpha()) finalstr += fc;
        if(sc.isAlpha()) finalstr += sc;
        if(tc.isAlpha()) finalstr += tc;
        return finalstr;
    }
    
    //Method to extract the numbers in the string
    static string getRestNums(string fc,string sc,string tc){
        string finalstr='';
        if(fc.isNumeric()) finalstr += fc;
        if(sc.isNumeric()) finalstr += sc;
        if(tc.isNumeric()) finalstr += tc;
        return finalstr;
    }
    
    //Wrapper class to categorize the string
    public class pcwrapper{
        Integer numofints;
        String categorytype;
        Integer charPos;
        Integer numPos;
        String restChars;
        String restNums;
        String actChar;
        String actNum;
    }

}