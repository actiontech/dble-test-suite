# 1. sql覆盖测试

## 1.1 sql 覆盖测试策略
通过将同一个sql语句发向mysql得到的结果和发向数据库中间件得到的结果做比对来确定对该sql的支持程度。

比对结果分为以下几类：

1. sql执行成功且结果一致， 将sql及结果存入pass.log
2. sql执行失败且结果一致，将sql及结果存入warn.log
3. sql执行成功但结果不一致，将sql及结果存入fail.log
4. sql执行成功但结果顺序不一致，sql中hint注明允许顺序不一致，将sql及结果存入pass.log
5. sql执行成功但结果不一致，sql中hint注明接受结果不一致，将sql及结果存入pass.log
6. 上述情形外的其它场景，将sql及结果存入serious_warn.log

将复审过跟测试预期一致的日志存到一份标准结果目录下，自动化运行生成的日志结果每次抽取sql语句比对，如果sql语句缺失或增加视为与预期发生变化

###sql覆盖测试策略的待改进点(todo):

1.  区分测试专门设计期望执行失败的反向用例
2.  细分输出dble不支持的sql到unsupport.log
3.  hint注明接受结果不一致的sql做细分
4.  插入sql到现有文件不方便，需要更新sql文件相关所以log文件

## 1.2 sql覆盖测试分类

### [1.2.1 基于python的MySQL数据库驱动-MySQLdb的sql覆盖测试](./1.2.1 基于python的MySQL数据库驱动-MySQLdb的sql覆盖测试.md)

### [1.2.2 基于java的MySQL数据库驱动-jdbc的sql覆盖测试](./1.2.2 基于java的MySQL数据库驱动-jdbc的sql覆盖测试.md)

### [1.2.3 基于c#的MySQL数据库驱动的sql覆盖测试](./1.2.3 基于c-net的MySQL数据库驱动的sql覆盖测试.md)

### [1.2.4 基于c++的MySQL数据库驱动的sql覆盖测试](./1.2.4 基于c++的MySQL数据库驱动的sql覆盖测试.md)

## [1.3 sql文件说明](./1.3 sql文件说明.md)