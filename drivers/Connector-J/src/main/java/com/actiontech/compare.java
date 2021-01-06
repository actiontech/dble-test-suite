/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

public class compare {

    public static boolean compareList(ArrayList<String> dblers, ArrayList<String> mysqlrs,boolean allow_diff){
        //Collections.sort(dblers);
        //Collections.sort(mysqlrs);
    	if (allow_diff)
            return true;
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
