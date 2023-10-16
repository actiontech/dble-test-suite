package com.actiontech.dble.manual;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * openSSL and gmSSL，需手动执行
 */
public class Ssl {

    private static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";

    private static final String LOCAL_SSL_FILE_PATH = "file:C:\\Users\\admin\\Downloads\\openssl\\";
    private static final String OPEN_SSL_TRUST_PASSWD = "123456";
    private static final String OPEN_SSL_CLIENT_PASSWD = "123456";
    private static final String DBLE_SSL_HOST = "10.186.*.*";
    private static final Integer DBLE_SSL_PORT = 18066;

    private static final String LOCAL_GM_SSL_FILE_PATH = "file:C:\\Users\\admin\\Downloads\\gmssl\\";
    private static final String GM_PROJECT_NAME = "dble-test";
    private static final String DBLE_GM_HOST = "10.186.*.*";
    private static final Integer DBLE_GM_PORT = 18066;

    private static final String DBLE_SHARDING_DB = "schema1";
    private static final String DBLE_SHARDING_USER = "test";
    private static final String DBLE_SHARDING_PASSWD = "111111";

    private static final String DBLE_RWSPLIT_DB = "db1";
    private static final String DBLE_RWSPLIT_USER = "split1";
    private static final String DBLE_RWSPLIT_PASSWD = "111111";

    public static void main(String[] args) throws SQLException, ClassNotFoundException {
        sslMode();
        // gmSsl要用特定的jdbc驱动包
        // gmSslMode();
    }

    /**
     * DBLE0REQ-1748  <br>
     * 1、本地下载支持国密的jdbc驱动jar  <br>
     * 2、服务端、本地替换以下jar包： <br>
     * &nbsp;&nbsp;&nbsp;&nbsp; gmssl_provider.jar放到jre/lib/ext下  <br>
     * &nbsp;&nbsp;&nbsp;&nbsp; local_policy.jar、US_export_policy.jar放到jre/lib/security下  <br>
     * 3、下载专门的dble-gmssl包安装dble  <br>
     * 4、在国密官网生成数字证书（包括服务器和个人）  <br>
     * 5、复制生成的服务器证书到dble所在主机，个人证书放在本地  <br>
     * 6、bootstrap.cnf配置如下，配置成功后管理端查看isSupportGMSSL显示为true <br>
     * &nbsp;&nbsp; -DsupportSSL=true  <br>
     * &nbsp;&nbsp; -DgmsslBothPfx=/sm2.dble-test.both.pfx  <br>
     * &nbsp;&nbsp; -DgmsslBothPfxPwd=12345678  <br>
     * &nbsp;&nbsp; -DgmsslRcaPem=/sm2.rca.pem  <br>
     * &nbsp;&nbsp; -DgmsslOcaPem=/sm2.oca.pem  <br>
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    public static void gmSslMode() throws SQLException, ClassNotFoundException {
        //disabled
        String gmDisabledUrl = "?useSSL=false";
        //PREFERRED
        String gmPreferredUrl = "?requireSSL=false&useSSL=true&useGMSSL=true&verifyServerCertificate=false";
        //REQUIRED
        String gmRequiredUrl = "?requireSSL=true&useSSL=true&useGMSSL=true&verifyServerCertificate=false";
        //VERIFY_CA_SINGLE
        String gmVerifySingle = "?requireSSL=true&useSSL=true&useGMSSL=true&verifyServerCertificate=true&trustRootCertificateKeyStoreUrl="
                + LOCAL_GM_SSL_FILE_PATH + "sm2.rca.pem&trustMiddleCertificateKeyStoreUrl="
                + LOCAL_GM_SSL_FILE_PATH + "sm2.oca.pem&clientCertificateKeyStoreType=PKCS12";
        //VERIFY_CA_DOUBLE
        String gmVerifyDouble = "?requireSSL=true&useSSL=true&useGMSSL=true&verifyServerCertificate=true&trustRootCertificateKeyStoreUrl="
                + LOCAL_GM_SSL_FILE_PATH + "sm2.rca.pem&trustMiddleCertificateKeyStoreUrl="
                + LOCAL_GM_SSL_FILE_PATH + "sm2.oca.pem&clientCertificateKeyStoreType=PKCS12&clientCertificateKeyStoreUrl="
                + LOCAL_GM_SSL_FILE_PATH + "sm2." + GM_PROJECT_NAME + ".both.pfx&clientCertificateKeyStorePassword=12345678";

        String sslType = "GMSSL";

        System.out.println("========== gm ssl-mode=DISABLED begin ==========");
        Connection conn1 = getClientConnection(gmDisabledUrl, sslType, "SHARDING");
        Connection conn2 = getClientConnection(gmDisabledUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- gm ssl-mode=DISABLED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- gm ssl-mode=DISABLED rwSplitUser end ----------");
        System.out.println("========== gm ssl-mode=DISABLED end ==========");
        System.out.println();

        System.out.println("========== gm ssl-mode=PREFERRED begin ==========");
        conn1 = getClientConnection(gmPreferredUrl, sslType, "SHARDING");
        conn2 = getClientConnection(gmPreferredUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- gm ssl-mode=PREFERRED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- gm ssl-mode=PREFERRED rwSplitUser end ----------");
        System.out.println("========== gm ssl-mode=PREFERRED end ==========");
        System.out.println();

        System.out.println("========== gm ssl-mode=REQUIRED begin ==========");
        conn1 = getClientConnection(gmRequiredUrl, sslType, "SHARDING");
        conn2 = getClientConnection(gmRequiredUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- gm ssl-mode=REQUIRED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- gm ssl-mode=REQUIRED rwSplitUser end ----------");
        System.out.println("========== gm ssl-mode=REQUIRED end ==========");
        System.out.println();

        System.out.println("========== gm ssl-mode=VERIFY_CA SINGLE begin ==========");
        conn1 = getClientConnection(gmVerifySingle, sslType, "SHARDING");
        conn2 = getClientConnection(gmVerifySingle, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- gm ssl-mode=VERIFY_CA SINGLE shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- gm ssl-mode=VERIFY_CA SINGLE rwSplitUser end ----------");
        System.out.println("========== gm ssl-mode=VERIFY_CA SINGLE end ==========");
        System.out.println();

        System.out.println("========== gm ssl-mode=VERIFY_CA DOUBLE begin ==========");
        conn1 = getClientConnection(gmVerifyDouble, sslType, "SHARDING");
        conn2 = getClientConnection(gmVerifyDouble, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- gm ssl-mode=VERIFY_CA DOUBLE shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- gm ssl-mode=VERIFY_CA DOUBLE rwSplitUser end ----------");
        System.out.println("========== gm ssl-mode=VERIFY_CA DOUBLE end ==========");
        System.out.println();
    }

    /**
     * DBLE0REQ-1720 <br>
     * 1、根据issue描述文档链接里的shell脚本生成ca证书 <br>
     * 2、复制生成的证书到本地目录  <br>
     * 3、bootstrap.cnf配置相关参数 <br>
     * &nbsp;&nbsp; -DsupportSSL=true    <br>
     * &nbsp;&nbsp; -DserverCertificateKeyStoreUrl=/serverkeystore.jks  <br>
     * &nbsp;&nbsp; -DserverCertificateKeyStorePwd=123456  <br>
     * &nbsp;&nbsp; -DtrustCertificateKeyStoreUrl=/truststore.jks  <br>
     * &nbsp;&nbsp; -DtrustCertificateKeyStorePwd=123456  <br>
     * 注：使用双向认证时，服务端jdk版本不能过高
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    public static void sslMode() throws SQLException, ClassNotFoundException {
        //disabled
        String disableUrl = "?useSSL=false";
        //PREFERRED
        String preferredUrl = "?requireSSL=false&useSSL=true&verifyServerCertificate=false";
        //REQUIRED
        String requiredUrl = "?requireSSL=true&useSSL=true&verifyServerCertificate=false";
        //VERIFY_CA_SINGLE
        String verifySingle = "?requireSSL=true&useSSL=true&verifyServerCertificate=true&trustCertificateKeyStoreUrl="
                + LOCAL_SSL_FILE_PATH + "truststore.jks&trustCertificateKeyStorePassword=" + OPEN_SSL_TRUST_PASSWD;
        //VERIFY_CA_DOUBLE
        String verifyDouble = "?requireSSL=true&useSSL=true&verifyServerCertificate=true&trustCertificateKeyStoreUrl="
                + LOCAL_SSL_FILE_PATH + "truststore.jks&trustCertificateKeyStorePassword=" + OPEN_SSL_TRUST_PASSWD
                + "&clientCertificateKeyStoreUrl=" + LOCAL_SSL_FILE_PATH
                + "clientkeystore.jks&clientCertificateKeyStorePassword=" + OPEN_SSL_CLIENT_PASSWD;

        String sslType = "SSL";

        System.out.println("========== ssl-mode=DISABLED begin ==========");
        Connection conn1 = getClientConnection(disableUrl, sslType, "SHARDING");
        Connection conn2 = getClientConnection(disableUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- ssl-mode=DISABLED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- ssl-mode=DISABLED rwSplitUser end ----------");
        System.out.println("========== ssl-mode=DISABLED end ==========");
        System.out.println();

        System.out.println("========== ssl-mode=PREFERRED begin ==========");
        conn1 = getClientConnection(preferredUrl, sslType, "SHARDING");
        conn2 = getClientConnection(preferredUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- ssl-mode=PREFERRED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- ssl-mode=PREFERRED rwSplitUser end ----------");
        System.out.println("========== ssl-mode=PREFERRED end ==========");
        System.out.println();

        System.out.println("========== ssl-mode=REQUIRED begin ==========");
        conn1 = getClientConnection(requiredUrl, sslType, "SHARDING");
        conn2 = getClientConnection(requiredUrl, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- ssl-mode=REQUIRED shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- ssl-mode=REQUIRED rwSplitUser end ----------");
        System.out.println("========== ssl-mode=REQUIRED end ==========");
        System.out.println();

        System.out.println("========== ssl-mode=VERIFY_CA SINGLE begin ==========");
        conn1 = getClientConnection(verifySingle, sslType, "SHARDING");
        conn2 = getClientConnection(verifySingle, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- ssl-mode=VERIFY_CA SINGLE shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- ssl-mode=VERIFY_CA SINGLE rwSplitUser end ----------");
        System.out.println("========== ssl-mode=VERIFY_CA SINGLE end ==========");
        System.out.println();

        System.out.println("========== ssl-mode=VERIFY_CA DOUBLE begin ==========");
        conn1 = getClientConnection(verifyDouble, sslType, "SHARDING");
        conn2 = getClientConnection(verifyDouble, sslType, "RWSPLIT");

        prepareData(conn1);
        System.out.println(selectUser(conn1));
        System.out.println("---------- ssl-mode=VERIFY_CA DOUBLE shardingUser end ----------");

        prepareData(conn2);
        System.out.println(selectUser(conn2));
        System.out.println("---------- ssl-mode=VERIFY_CA DOUBLE rwSplitUser end ----------");
        System.out.println("========== ssl-mode=VERIFY_CA DOUBLE end ==========");
        System.out.println();
    }

    public static Connection getClientConnection(String param, String sslType, String userType) throws ClassNotFoundException{

        Class.forName(JDBC_DRIVER);
        String url = "";
        if (sslType != null && sslType.equals("SSL")) {
            url = "jdbc:mysql://" + DBLE_SSL_HOST + ":" + DBLE_SSL_PORT;
        } else {
            url = "jdbc:mysql://" + DBLE_GM_HOST + ":" + DBLE_GM_PORT;
        }
        String fullUrlString = url + param + "&allowMultiQueries=true";
        System.out.println("jdbc fullUrlString: " + fullUrlString);

        Connection conn = null;
        try {
            if (userType != null && userType.equals("SHARDING")) {
                conn = DriverManager.getConnection(fullUrlString, DBLE_SHARDING_USER, DBLE_SHARDING_PASSWD);
                conn.setCatalog(DBLE_SHARDING_DB);
            } else {
                conn = DriverManager.getConnection(fullUrlString, DBLE_RWSPLIT_USER, DBLE_RWSPLIT_PASSWD);
                conn.setCatalog(DBLE_RWSPLIT_DB);
            }
            System.out.println("get connection ok");
        } catch (SQLException e) {
            System.out.println("get connection failed");
            e.printStackTrace();
        }

        return conn;
    }

    public static void prepareData(Connection conn) {
        try {
            assert conn != null;
            Statement stm = conn.createStatement();
            String multipleSql = "drop table if exists sharding_4_t1;" +
                    "create table sharding_4_t1 (id int, name varchar(15));" +
                    "insert into sharding_4_t1 values (1,'aa'),(2,'bb'),(3,'cc'),(4,'dd'),(5,'ee');" +
                    "update sharding_4_t1 set name='test' where id=1;" +
                    "delete from sharding_4_t1 where id=5;" +
                    "begin;update sharding_4_t1 set name='1111' where id=1;commit;" +
                    "select count(0) from sharding_4_t1;";
            boolean hasMoreResultSets = stm.execute(multipleSql);
            System.out.println("hasMoreResultSets : " + hasMoreResultSets);
        } catch (SQLException e) {
            System.out.println("execute prepare sql failed");
            e.printStackTrace();
        }
    }

    public static List<User> selectUser(Connection conn) throws SQLException {
        List<User> usersList = new ArrayList<>();
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            assert conn != null;
            ps = conn.prepareStatement("select id, name from sharding_4_t1 order by id");
            rs = ps.executeQuery();
            while(rs.next()){
                Integer id = rs.getInt("id");
                String name = rs.getString("name");
                usersList.add(new User(id, name));
            }
        } catch (SQLException e) {
            System.out.println("execute sql failed, " + e.getMessage());
            e.printStackTrace();
        }finally {
            if(ps != null){
                ps.close();
            }
            if(rs != null){
                rs.close();
            }
            if (conn != null){
                conn.close();
            }
        }
        return usersList;
    }
}

class User {
    private Integer id;
    private String name;

    public User(Integer id, String name) {
        this.id = id;
        this.name = name;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ",name='" + name + '\'' +
                '}';
    }
}