package com.actiontech;

import java.util.ArrayList;

public class compare {

    public static boolean compareList(ArrayList<String> dblers, ArrayList<String> mysqlrs){
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
            if (!mysqlrs.contains(line)){
                return false;
            }
        }
        return true;
    }
}
