# -*- coding: utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/4/16 AM11:08
# @Author  : zhaohongjie@actionsky.com
# coding=utf-8
"""
    Author:     Andy Liu
    Email :     liuan@actionsky.com
    Created:    2022/6/16
    opyright (C) 2016-2023 ActionTech.
    License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
"""
from typing import Dict, List

import parse
from behave import register_type


@parse.with_pattern(r"should( not)?")
def parse_should_or_not(text: str) -> bool:
    return text == "should"


register_type(should_or_not=parse_should_or_not)


@parse.with_pattern(r'[^\s]+')
def parse_strings(text: str) -> str:
    return text.strip(' ,')


register_type(strings=parse_strings)


@parse.with_pattern(r'[^\s]+')
def parse_string(text: str) -> str:
    return text.strip()


register_type(string=parse_string)


@parse.with_pattern(r"[^\s]+")
def table_string(text: str) -> List[str]:
    return text.strip().split('.')


register_type(table=table_string)


@parse.with_pattern(r"(\s*[^\s]+\s*:\s*[^\s]+,?)+")
def parse_option_values(text: str) -> Dict[str, str]:
    temp = text.split(', ')
    dict_values = {}
    for value in temp:
        arr = value.split(":")
        dict_values[arr[0].strip()] = arr[1].strip()
    return dict_values


register_type(option_values=parse_option_values)
