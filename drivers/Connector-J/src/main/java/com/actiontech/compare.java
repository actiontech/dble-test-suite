/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
package com.actiontech;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

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
//            if((dblers.get(i) instanceof HashMap<>) &&(mysqlrs.get(i) instanceof HashMap<>) ){
//            }
//        }
        return true;
    }
}
