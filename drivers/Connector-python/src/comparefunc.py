# -*- coding: UTF-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import operator

def comparelist(list1, list2):
    # covert str to list if have any
    if not isinstance(list1, list):
        list1 = [list1]
    if not isinstance(list2, list):
        list2 = [list2]

    if operator.eq(list1, list2) == True:
        ret = {'s': list1}
        return ret
    else:
        sameEles = [x for x in list1 if x in list2]
        # addEles = [y for y in (list1 + list2) if y not in list2]
        # deleteEles = [z for z in (list1 + list2) if z not in list1]
        if len(sameEles) == len(list1):
            ret = {'s': list1}
            return ret
        else:
            # diff = ['same:'] + sameEles + ['add:'] + addEles + ['del:'] + deleteEles
            diff = ['dble:'] + list1 + ['mysql:'] + list2
            ret = {'d': diff}
            return ret