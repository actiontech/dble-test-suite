# -*- coding: UTF-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import os
import time

def makedirfile(dirname, *filenames):
    curr_path = os.path.abspath(__file__)
    currdir = os.path.dirname(curr_path)
    resultpath = os.path.dirname(currdir) + '\\' + dirname
    os.chdir(resultpath)
    print 'resultpath:' + os.getcwd()
    timestamp = str(int(round(time.time() * 1000)))
    os.mkdir('./' + timestamp)
    os.chdir('./' + timestamp)
    newdir = os.getcwd()

    # create files
    filedic = {}
    aa = len(filenames)
    if len(filenames) > 0:
        for index in range(len(filenames)):
            filepath = newdir + '\\' + filenames[index]
            if not os.path.exists(filepath):
                f = open(filepath, 'w')
                print filepath
                f.close()
                print filenames[index] + " created."
            else:
                print filenames[index] + " already existed."
            filedic[filenames[index]] = filepath
    return filedic


# makedirfile('result','dbleResults.txt','mysqlResults.txt','compareResults.txt')

# get the latest result file
def getNewResultFile(path):
    list = os.listdir(path)
    list_dir = []
    list_file = []
    for val in list:
        if os.path.isdir(path + '\\' + val):
            list_dir.append(val)
        else:
            list_file.append(val)
    return list_dir, list_file


# aa = getNewResultFile('C:\\Users\\ThinkPad\\PycharmProjects\\DriverSupportTest\\result')

# init(dble align with mysql), update env will init as well ?
def initDatabase():
    try:
        conn = mysql.connector.connect(**dble_config)
        print 'dble is connected !'
    except mysql.connector.Error as e:
        print('connect fails!{}'.format(e))

    try:
        conn = mysql.connector.connect(**mysql_config)
        print 'mysql is connected !'
    except mysql.connector.Error as e:
        print('connect fails!{}'.format(e))


# clear the result files
def clearfile(filename):
    curr_path = os.path.abspath(__file__)
    currdir = os.path.dirname(curr_path)
    os.chdir('..\\result')
    result_path = os.getcwd()
    file = result_path + '\\' + filename
    f = open(file, 'r+')
    f.truncate()
    f.close()

