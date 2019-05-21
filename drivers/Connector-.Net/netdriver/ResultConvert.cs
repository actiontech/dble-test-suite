/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace netdriver
{
    class ResultConvert
    {

        public static String CovertListToString(List<String> list)
        {
            String str="";
            for(int i = 0; i < list.Count; i++)
            {
                str = String.Concat(str,list[i]);
            }
            return str;
        } 
    }
}
