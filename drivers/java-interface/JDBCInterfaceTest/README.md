# connector-j
test sqls supported by connetor/j
ant jar
ant create-mysql-database
ant setup

#interfaces covered

class: java.sql.Connection
void					abort(Executor executor)
void					close()
void                    commit()
Clob				   	createClob()
SQLXML				   	createSQLXML()
Statement              	createStatement()
Statement              	createStatement(int resultSetType, int resultSetConcurrency)
Statement				createStatement(int resultSetType, int resultSetConcurrency, int resultSetHoldability)
boolean					getAutoCommit()
String					getCatalog()
Properties				getClientInfo()
String					getClientInfo(String name)
int						getHoldability()
DatabaseMetaData       	getMetaData()
int						getNetworkTimeout()
String					getSchema()
int						getTransactionIsolation()
CallableStatement	   	prepareCall(String sql)
PreparedStatement      	prepareStatement(String sql)
void                  	rollback()
void                  	rollback(Savepoint savepoint)
Savepoint             	setSavepoint()                       
void                   	setAutoCommit(boolean autoCommit)                       
void                   	setCatalog(String catalog)
#### unsupported
Array					createArrayOf(String typeName, Object[] elements)//MySQL and Java DB currently do not support the ARRAY SQL data type.
NClob					createNClob()//MySQL has no such type
Struct					createStruct(String typeName, Object[] attributes)//MySQL has no such type

class: java.sql.Statement
void				  	addBatch(String sql)
void                  	close()
ResultSet             	execute(String sql)
int[]				  	executeBatch()
ResultSet             	executeQuery(String sql)
int                   	executeUpdate(String sql)
ResultSet             	getResultSet()

class: java.sql.PreparedStatement->Statement
int 				  	executeUpdate()
int                   	executeUpdate(String sql)
void					setBlob(int parameterIndex, Blob x)
void				  	setClob(int parameterIndex, Clob x) 
void                  	setInt(int parameterIndex, int x)
void  				  	setString(int parameterIndex, String x)
void	              	setSQLXML(int parameterIndex, SQLXML xmlObject)
void				  	setURL(int parameterIndex, URL x)



class: java.sql.DatabaseMetaData
int           		  	getResultSetHoldability()
RowIdLifetime 		  	getRowIdLifetime()
boolean       		  	supportsResultSetHoldability(int holdability)


class: java.sql.ResultSet
void                  	beforeFirst()
boolean	              	first()
int                   	getInt(String columnLabel)
float                 	getFloat(String columnLabel)
SQLXML				  	getSQLXML(int columnIndex)
String				  	getString(int columnIndex)
String                	getString(String columnLabel)
URL					  	getURL(int columnIndex)
void                  	insertRow()
void                  	moveToInsertRow()
boolean               	next()
void                  	updateFloat(String columnLabel, float x)
void                  	updateInt(String columnLabel, int x)
void                  	updateRow()
void                  	updateString(String columnLabel, String x)

class: java.sql.Clob
Writer 			      	setCharacterStream(long pos)
int					  	setString(long pos, String str)


class: java.sql.SQLXML
<T extends Result> T  	setResult(Class<T> resultClass)


class: java.sql.CallableStatement
String				  	getString(int parameterIndex)
void				  	registerOutParameter(int parameterIndex, int sqlType)
void				  	setFloat(String parameterName, float x)
void				  	setString(String parameterName, String x)



class: java.sql SQLWarning
String					getSQLState()


# executing command:
java  -jar ${jar_name}








