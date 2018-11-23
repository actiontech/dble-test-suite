# -*- coding: UTF-8 -*-
import operator

def comparelist(list1,list2):
    # sameEles = []
    # addEles = []
    # deleteEles = []
    if operator.eq(list1,list2) == True:
        return list1
    else:
        sameEles = [x for x in list1 if x in list2]
        addEles = [y for y in (list1 + list2) if y not in list2]
        deleteEles = [z for z in (list1 + list2) if z not in list1]
        if len(sameEles) == len(list1):
            return list1
        else:
            # diff = ['same:'] + sameEles + ['add:'] + addEles + ['del:'] + deleteEles
            diff = ['dble:'] + list1 + ['mysql:'] + list2
            return diff
            # return sameEles,addEles,deleteEles



