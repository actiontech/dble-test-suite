/*
 * Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace netdriver
{
    class CompareRs
    {
        public static bool CompareRS(List<String> dblers, List<String> mysqlrs,bool allow_diff)
        {
            if (allow_diff)
                return true;
            if (dblers == mysqlrs)
                return true;
            if (null == dblers && null == mysqlrs)
                return true;
            if (null == dblers || null == mysqlrs)
                return false;
            if (dblers.Count != mysqlrs.Count || !dblers.All(mysqlrs.Contains))
                return false;
//            if (allow_diff_sequence)
//            {
//                dblers.Sort();
//                mysqlrs.Sort();
//
//            }
            int nCount = dblers.Count;
            for (int n = 0; n < nCount; n++)
            {
                if (0 != string.Compare(dblers[n], mysqlrs[n], false))
                {
                    return false;
                }
            }
            return true;
        }
    }
}
