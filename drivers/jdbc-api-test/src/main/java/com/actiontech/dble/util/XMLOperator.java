///* Copyright (C) 2016-2020 ActionTech.
// * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
// */
//package com.actiontech.dble.util;
//
//import org.dom4j.*;
//import org.dom4j.io.OutputFormat;
//import org.dom4j.io.SAXReader;
//import org.dom4j.io.XMLWriter;
//
//import java.io.*;
//import java.util.List;
//
///**
// * @author wangjuan
// * @version 1.0
// * @date 2020/12/24 10:47
// * @description XMLOperator
// * @modifiedBy
// **/
//public class XMLOperator {
//
//
//    /**
//     * 创建DOM4j的XML解析器并返回一个document对象
//     * @param xmlPath
//     * @return
//     * @throws Exception
//     */
//    public static Document getDocument(String xmlPath) {
//        try {
//            InputStream inputStream = new FileInputStream(xmlPath);
//            Reader reader = new InputStreamReader(inputStream,"utf-8");
//            SAXReader saxReader = new SAXReader();
//            Document document =  saxReader.read(xmlPath);
//            return document;
//        }catch (Exception e){
//            e.printStackTrace();
//        }
//        return null;
//    }
//
//    /**
//     * 将更新后的document对象写入到XML文件中去
//     * @param dom
//     * @param xmlPath
//     * @throws Exception
//     */
//    public static void writeToXML(Document dom ,String xmlPath) throws Exception{
//
//        //首先创建样式和输出流
//        OutputFormat format = new OutputFormat().createPrettyPrint();
//        OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(xmlPath),"utf-8");
//        XMLWriter writer = new XMLWriter(out,format);
//
//        //写入之后关闭流
//        writer.write(dom);
//        writer.close();
//    }
//
//    /**
//     * 增加xml数据
//     * @param filePath
//     * @param xmlText
//     * @throws Exception
//     */
//    public static void addXmlText(String filePath, String xmlText) throws Exception{
//        File dir = new File(filePath);
//        if (!dir.exists()) {
//            dir.createNewFile();
//        }
//
//        Document dom = getDocument(filePath);
//        Element root = dom.getRootElement();
//        root.addText(xmlText);
//        writeToXML(dom, filePath);
//    }
//
//    /**
//     * 根据filePath, removeKey删除数据
//     * @param filePath
//     * @param removeKey
//     * @throws Exception
//     */
//    public static void deleteElementByKey(String filePath, String removeKey) throws Exception{
//        Document dom = getDocument(filePath);
//        Element root = dom.getRootElement();
//        List<Node> deleteList = root.selectNodes(removeKey);
//        if(deleteList != null && !deleteList.isEmpty()) {
//            for (Node node : deleteList) {
//                node.getParent().remove(node);
//            }
//        }
//        writeToXML(dom, filePath);
//    }
//
//    public static void main(String[] args) throws Exception {
//        String path = "D:\\PycharmProjects\\dble-test-suite\\behave_dble\\dble_conf\\template_bk\\user.xml";
//        addXmlText(path, "<managerUser name=\"admin\" password=\"111111\"/>");
////        deleteElementByKey(path, "//managerUser");
//    }
//
//}