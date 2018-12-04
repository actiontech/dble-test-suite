package com.actiontech;

import java.util.ArrayList;
import java.util.Collections;

public class compare {

    public static boolean compareList(ArrayList<String> dblers, ArrayList<String> mysqlrs){
        //Collections.sort(dblers);
        //Collections.sort(mysqlrs);
        if (dblers.equals(mysqlrs)){
            return true;
        }
        if (dblers == null && mysqlrs == null){
            return true;
        }
        if(dblers.size() != mysqlrs.size() ){
            return false;
        }
        for (Object line : dblers){
            if(!mysqlrs.contains(line)){
                return false;
            }
        }

//        for (int i=0;i<dblers.size();i++){
//            if(!dblers.get(i).equals(dblers.get(i))){
//                return false;
//            }
//        }
        return true;
    }
}
