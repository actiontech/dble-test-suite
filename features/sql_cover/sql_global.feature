# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: global table sql cover test

   @current
    Scenario Outline:cover empty line in file, no line in file, chinese character in file, special character in file for load data [local] infile ...#4
      #1.1 no line in file
      Given create local and server file "test1.txt" and fill with text
      """
      """
      #1.2 empty line in file
      Given create local and server file "test2.txt" and fill with text
      """

      """
      #1.3 chinese character and special character
      Given create local and server file "test3.txt" and fill with text
      """
      1,aaa,0,0,3.1415,20180905121530
      2,中,1,1,-3.1415,20180905121530
      3,$%'";:@#^&*_+-=|\<.>/?`~,5,0,0.0010,20180905
      """
      #1.4 with replace into in load data
      Given create local and server file "test4.txt" and fill with text
      """
      1,1,,
      """
      #1.5 abnormal test for lack column
#      Given create local and server file "test5.txt" and fill with text
#      """
#      ,1,a,20181018163000,20181018,163000,0,0
#      b,,b,20181018163000,20181018,163000,0,0
#      c,3,,20181018163000,20181018,163000,0,0
#      d,4,d,,20181018,163000,0,0b00
#      e,5,e,20181018163000,,163000,0,0b00
#      f,6,f,20181018163000,20181018,,0,0b00
#      g,7,g,20181018163000,20181018,163000,,0
#      h,8,h,20181018163000,20181018,163000,0,
#
#      ,,i,20181018163000,20181018,163000,0,1
#      ,,,20181018163000,20181018,163000,0,1
#      ,,,,20181018,163000,0,0b00
#      ,,,,,163000,0,0b00
#      ,,,,,,0,0b00
#      ,,,,,,,0b00
#      ,,,,,,,
#      ,,,,,,
#      ,,,,,
#      ,,,,
#      ,,,
#      ,,
#      ,
#
#      j,9,j,20181018163000,20181018,163000,0,1
#      k,10,k,20181018163000,20181018,163000,0,
#      l,11,l,20181018163000,20181018,163000,
#      m,12,m,20181018163000,20181018,
#      o,13,o,20181018163000,
#      p,14,p,
#      q,15,
#      r,
#
#      s,16,s,20181018163000,20181018,163000,0
#      t,17,t,20181018163000,20181018,163000
#      u,18,u,20181018163000,20181018
#      v,19,v,20181018163000
#      w,20,w
#      x,21
#      y
#
#
#      z,22,z,20181018163000,20181018,163000,0,0
#      aa,0x17,1,20181018163000,20181018,163000,0,0
#
#
#      """
      Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
      Given clear dirty data yield by sql
      Given remove local and server file "test1.txt"
      Given remove local and server file "test2.txt"
      Given remove local and server file "test3.txt"
      Given remove local and server file "test4.txt"
#      Given remove local and server file "test5.txt"

      Examples:Types
        | filename                                    |
        | syntax/loaddata.sql                         |

    Scenario: #5 compare new generated results is same with the standard ones
        When compare results with the standard results in "std_result_global"