# 贡献指南

dble是一个社区驱动的开源项目，本指南记录了为dble做出各种贡献的最佳方式，包括提出bug，改进文档和报告等等。

## 一. 最佳提bug方式

1.对于有足够代码经验的贡献者而言，提bug的同时可以附上解决该bug的代码。

2.对于普通贡献者而言，提交的bug描述中应该包含足够的信息，提供重现步骤。不能重现的bug或者只有寥寥几句描述的bug可能会被关闭。

3.贡献者们也可以提出新的功能需求，但是得附上详细的信息，比如设计文档或者更新的代码。

## 二.修改文档：
通过pull request把你编辑的内容提交回原仓库

## 三.提交 pull request 流程
1. github上fork该项目

   1）登陆项目地址：[https://github.com/actiontech/dble-test-suite](https://github.com/actiontech/dble-test-suite)  
   2）点击"Fork"按钮

2. 在本地完成 clone，操作如下：
```   
   mkdir -p $working_dir
   cd $working_dir
   git clone git@github.com:$user/dble-test-suite.git
   # the following is recommended
   # or: git clone https://$user@github.com/actiontech/dble-test-suite.git

   cd $working_dir/dble
   git remote add upstream git@github.com:actiontech/dble-test-suite.git
   # or:git remote add upstream https://github.com/actiontech/dble-test-suite.git

   # Never push to upstream master since you do not have write access
   git remote set-url --push upstream no_push

   # Confirm that your remotes make sense:
   # It should look like:
   # origin    git@github.com:$(user)/dble-test-suite.git (fetch)
   # origin    git@github.com:$(user)/dble-test-suite.git (push)
   # upstream  https://github.com/actiontech/dble-test-suite.git (fetch)
   # upstream  no_push (push)
   git remote -v
```   
3. 创建分支

   1)更新本地master代码为最新，操作如下：
   ```
     cd $working_dir/dble
     git fetch upstream
     git checkout master
     git rebase upstream/master
   ```
   2）从master上创建新的分支并切换到此分支：
   ```
     git checkout -b your_branch
   ```
4. 做自己的更新
5. commit
```
git add <自己的更新>
git commit -m "对更新的描述"
```
6. push
```
git push origin your_branch
```
7. 登陆github，创建pull request

   1）打开 fork 的项目     
   2）点击按钮 "Compare & pull request"  
   3）确认提交的内容无误后，再点击按钮 "Create pull request"

## 四.commit 信息规范

为了使项目能更容易维护，提交变更时填写的信息请遵循以下方式：

```
  <what changed>
  <BLANK LINE>
  <why this change was made>
  <BLANK LINE>
  <footer>(optional)
 ```
  说明：1.第一行是主题，控制在70个字之内
        2.第二行是空白行
        3.其他行控制在80个字符之内。
  这样做的目的是使提交的信息在github上更方便浏览。对于第三行原因部分，如果没有具体的改变原因，您可以使用一些通用的原因，如“改进文档”，“提高性能。”，“提高稳健性。”，“提高测试覆盖率”。


