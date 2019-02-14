#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(ID INT NOT NULL,FirstName VARCHAR(20),LastName VARCHAR(20),Department VARCHAR(20),Salary INT)
create index ID_index on test1(ID)
INSERT INTO test1 VALUES(201,'Mazojys','Fxoj','Finance',7800),(202,'Jozzh','Lnanyo','Finance',45800),(203,'Syllauu','Dfaafk','Finance',57000),(204,'Gecrrcc','Srlkrt','Finance',62000),(205,'Jssme','Bdnaa','Development',75000),(206,'Dnnaao','Errllov','Development',55000),(207,'Tyoysww','Osk','Development',49000)
select * from test1
select id, firstname,lastname,department,salary  from test1
select id, salary  from test1
select id, salary as "salary_alias" from test1
select id, salary  salary_alias from test1
select id, salary  'salary_alias' from test1
select id, salary+10  'salary_alias' from test1
select lower(id) as "Lower",upper(salary) as "upper" from test1
select id,Concat(firstname,'.',lastname) as name,salary,department from test1
SELECT FirstName, LastName,Department = CASE Department WHEN 'F' THEN 'Financial' WHEN 'D' THEN 'Development'  ELSE 'Other' END FROM test1
select all * from test1
select distinct id,firstname,lastname,salary from test1
select distinctrow * from test1
select straight_join * from test1
select SQL_SMALL_RESULT * from test1
select SQL_BIG_RESULT * from test1
select SQL_BUFFER_RESULT * from test1
select SQL_CACHE * from test1
select SQL_NO_CACHE * from test1
select SQL_CALC_FOUND_ROWS * from test1
select avg(salary) from test1
select avg(salary) as avg1 from test1
select count(*) from test1
select count(id) from test1
select count(distinct salary) from test1
select max(salary) from test1
select max(salary + 10) from test1
select max(salary * id) as MAX from test1
select min(salary) from test1
select sum(salary) from test1
select avg(salary+10) avg1 from test1
select avg(salary*id) as avg1 from test1
select id,firstname,lastname,salary,department from test1 order by id
select * from test1 order by id asc
select * from test1 order by id desc
select id,firstname,lastname,salary,department from test1 order by id desc
select * from test1 order by department,salary
select id,firstname,lastname,salary,department from test1 order by salary,department
select * from test1 order by id limit 4
select id,firstname,lastname,salary,department from test1 order by id limit 1,5
select id, firstname,lastname,department,salary  from test1 group by id
select id, firstname,lastname,department,salary  from test1 group by firstname
select department from test1 group by department
select department,id from test1 group by id,department
select department,id,concat(firstname,'.',lastname) as NAME from test1 group by id,department
select id, sum(salary) from test1 group by id
select department,count(*) as COUNT from test1 group by department
select department,max(salary) as max_salary from test1 group by department
select department,min(salary) as min_salary from test1 group by department
select department,sum(salary) as sum_salary from test1 group by department
select department,avg(salary) as avg1 from test1 group by department
select department,sum(salary) as sum_salary from test1 group by department order by sum_salary
select department,avg(salary) as avg2 from test1 group by department order by department desc
select department,sum(salary) as sum_salary from test1 group by department order by department desc,sum_salary asc
drop table if exists test1
create table test1(ID int(10) NOT NULL,name varchar(50),brithday date,Email varchar(60),mobile varchar(50),IDcard varchar(100),address varchar(100),zipcode varchar(100),age int(10),Position varchar(100),department varchar(100),cloum varchar(100),cloum2 varchar(100),cloum3 varchar(100),cloum4 varchar(100),cloum5 varchar(100),cloum6 varchar(100),cloum7 varchar(100),cloum8 varchar(100),cloum9 varchar(100),cloum10 varchar(100),PRIMARY KEY (ID))
create index Name_I on test1 (name(20))
INSERT INTO test1 VALUES (100,'Samantha','2011/11/29','Eric@Duis.com','210-086-6295','844-02-2300','92363 West Akron Ct.','56752',22,'Gilbert','Saint Vincent and The Grenadines','Nulla ridiculus','Nulla posuere ultricies Cras','enim magna blandit imperdiet justo','dictum Aenean taciti egestas Ut','Cras tempor pulvinar pellentesque','mi Aenean dapibus justo','Pellentesque consectetuer Pellentesque libero velit','fames convallis Vivamus netus','fermentum nisi dapibus cursus blandit','velit senectus tempus mollis'),(101,'Adrian','2016/4/28','Chandler@quis.net','194-286-4153','241-73-7704','1664 South Lower Burrell Blvd.','17119',20,'Diamond Bar','Bahrain','accumsan','consequat In ultrices nec aptent','Donec Curae congue tellus felis','tristique vulputate felis ornare nunc','Suspendisse scelerisque iaculis accumsan','sodales fermentum','In bibendum viverra','taciti dolor','Mauris','vehicula Nunc eros'),(102,'Yetta','1990/10/21','Allistair@tellus.edu','529-937-3103','541-34-5383','82957 East Charlotte Way','51229',20,'City of Industry','Singapore','taciti mus Vestibulum','quis a Maecenas','vestibulum elementum tincidunt','lorem primis porttitor penatibus Pellentesque','Donec urna sodales ipsum venenatis','vestibulum arcu vel placerat justo','magnis ligula Cras Quisque','sapien Cras mus dis','elementum pede mus euismod','felis imperdiet Suspendisse'),(103,'Kylan','1989/2/22','Jason@dis.org','340-306-9435','033-23-8472','89534 West Kuwait Blvd.','80172',21,'Jersey City','Macao','habitant nunc vitae mi','placerat blandit Duis','sit volutpat consectetuer','consectetuer mus','gravida ante','orci cubilia per sed','sit vehicula dolor molestie','nisl ut ligula tempus','convallis pretium','tincidunt Cras Integer urna'),(104,'Judah','1991/8/13','Kaye@consectetuer.edu','010-391-9970','309-94-5211','20325 South Egypt Ln.','84999',25,'South Burlington','Iran, Islamic Republic of','elit iaculis interdum','In blandit vestibulum','dapibus dui Aenean','semper justo Curabitur','Pellentesque convallis dolor hendrerit','pellentesque Maecenas','arcu Cras','nunc Nullam vestibulum Integer','primis eget','auctor morbi ac rhoncus placerat'),(105,'Madison','2016/2/19','Quentin@pretium.net','953-964-4632','481-67-3606','29113  Niue Ln.','49327',28,'Bozeman','Svalbard and Jan Mayen','convallis justo nisi ultricies porttitor','Pellentesque Praesent justo augue','sed blandit dignissim','euismod laoreet quis enim semper','id Nam','Nunc facilisi Nullam gravida','Nulla','vel','at','Pellentesque pharetra urna'),(106,'Quin','2003/12/5','Karly@bibendum.com','327-814-3156','382-82-7322','32230  Cranston Way','14074',28,'Canandaigua','Zimbabwe','ligula Class inceptos ante','hymenaeos pellentesque Nulla faucibus lacus','aliquam','quam Aliquam ut ante','a interdum lectus vitae','natoque','purus felis primis nascetur','dapibus Cum arcu aliquet faucibus','eget nisl semper eleifend habitant','Sed'),(107,'TaShya','2011/2/14','Odette@semper.us','612-682-5462','924-75-1812','38307 West Tanzania, United Republic of St.','31796',29,'Cumberland','Jamaica','egestas Vestibulum enim','quam dis In','odio Nam Curabitur congue','imperdiet Curae','Cum vel tincidunt','enim lorem litora elit dis','imperdiet placerat vehicula','ut','blandit torquent','lacinia rhoncus massa arcu'),(108,'Kelsey','2005/11/3','Renee@nulla.gov','435-174-7762','422-26-4856','3415 East Auburn Hills Blvd.','12620',23,'Marietta','Cameroon','Aenean Cras','convallis ad','eget Etiam orci netus','euismod et Class sociosqu','justo ante tellus sodales consectetuer','ligula tempus taciti litora neque','condimentum volutpat sociis','et Curabitur nibh eu','non sollicitudin lorem','mauris pellentesque'),(109,'Jane','2004/6/3','Sydney@mi.gov','195-687-3764','029-48-1259','20807 West Argentina Ln.','70168',24,'Steubenville','Ireland','Nam blandit Praesent faucibus','iaculis lacinia','rhoncus eu rutrum litora','Vivamus dis cursus','et ultrices amet','diam ac','erat Nunc bibendum','Pellentesque ultrices','viverra','Morbi sem facilisi')
INSERT INTO test1 VALUES (600,'Chava','2004/10/25','Declan@aptent.net','026-455-9818','258-75-0705','94200 South Burkina Faso Way','89120',30,'Artesia','Mexico','litora','elementum sem','imperdiet metus nunc morbi','accumsan eget In semper vestibulum','Etiam','Cras','convallis Aliquam vitae Class posuere','metus euismod quis Aenean','penatibus hymenaeos tempus','libero tristique Pellentesque conubia Proin'),(601,'Deanna','2012/8/16','Uriah@netus.net','991-993-4108','999-95-2670','11684 East Belgium Blvd.','37456',30,'La Palma','French Polynesia','ipsum nisi Morbi quis','Morbi Nunc','consequat','metus vel sodales tempor mattis','laoreet','pharetra felis turpis cursus ipsum','molestie hymenaeos et','ornare','facilisis','faucibus Proin'),(602,'Francesca','2010/1/24','Zorita@Morbi.com','567-191-8265','796-88-4586','10813  Angola Blvd.','09706',20,'Chicago Heights','Korea, Republic of','cursus posuere pede habitant adipiscing','felis aptent','aliquet scelerisque nec leo','Praesent ultricies','Sed gravida ultrices Nunc','varius','Proin aliquam','cubilia Pellentesque tincidunt tristique eget','Donec','ultrices sagittis varius'),(603,'Zachery','1996/8/12','Hyacinth@viverra.org','776-629-7688','545-39-3731','80838 West Bhutan Ln.','54582',30,'Quincy','Madagascar','Etiam a orci','habitant at augue amet','vestibulum sociis pretium nascetur Duis','nostra','vehicula orci','lacinia Aenean','rutrum eu cursus','dui','ad','Class senectus'),(604,'Georgia','1994/7/1','Bertha@mi.org','379-719-5542','751-78-0794','478 West Armenia Ave.','18999',30,'Bartlesville','Thailand','cubilia lacus','Lorem blandit Duis commodo tempor','parturient condimentum eu','elit','Etiam Cum dignissim','penatibus dis non natoque','imperdiet','Nullam','erat Cras dignissim venenatis','dapibus feugiat sem pulvinar'),(605,'Orson','2009/12/4','Uriah@Donec.net','965-325-2777','980-31-9265','78971 North Puerto Rico Blvd.','67628',28,'Mobile','Indonesia','purus','Fusce sodales vel','sed','purus dapibus lobortis taciti','sagittis Proin','Morbi lobortis Curabitur lobortis','accumsan rutrum','Curabitur','mauris augue natoque Etiam','dictum sollicitudin'),(606,'Quinn','2010/8/7','MacKenzie@Maecenas.us','053-199-6092','391-40-4548','4410 North Vanuatu Ct.','48630',30,'East Rutherford','Grenada','convallis varius Class diam a','facilisis felis lectus Nulla urna','habitant pharetra','Quisque Pellentesque','Nam','Nulla','Cras tortor','ligula at','eros','tortor'),(607,'Cleo','1995/10/27','Amal@adipiscing.edu','885-002-0184','213-80-7859','10686 West Micronesia Way','61326',30,'Yazoo City','Martinique','morbi Nunc blandit','sapien litora','senectus ad ipsum','Maecenas morbi sollicitudin','dignissim montes','varius quam nec','augue magna Curabitur mattis','porttitor amet tincidunt Class','blandit Morbi','luctus'),(608,'Hayden','2001/8/8','Ori@euismod.net','336-406-9705','545-55-4678','73509  Azerbaijan Way','39118',28,'Covington','Ethiopia','suscipit eget non euismod Integer','justo','Nam','fermentum scelerisque ut Curae scelerisque','Cum iaculis dolor','congue Vivamus','tempus Aenean nisi','mus eget aliquet eu augue','mollis','sem nonummy vehicula fermentum nascetur'),(609,'Roary','2014/7/1','Audrey@libero.com','700-083-6284','386-93-6018','20092 South South Georgia and The South Sandwich Islands Ct.','89577',29,'Hayward','Uganda','Donec metus rhoncus vel interdum','sociosqu Nulla mauris augue','congue','penatibus convallis sapien','gravida est ipsum nulla','Curabitur Curae','venenatis','senectus augue dis in','libero consequat Class iaculis euismod','In facilisis bibendum malesuada imperdiet')
INSERT INTO test1 VALUES (1100,'Byron','2008/9/20','Noel@odio.com','201-164-8432','388-13-7090','65818 North Estonia Way','32395',22,'Hackensack','Burundi','nibh penatibus viverra convallis','sagittis natoque sapien','cubilia nisi','facilisi','amet sollicitudin fringilla rutrum','Pellentesque facilisis lorem Duis','ullamcorper sagittis hymenaeos','conubia laoreet Duis dictum','parturient vulputate consequat','id mauris adipiscing'),(1101,'Callum','2011/2/8','Calvin@tristique.net','607-246-6363','438-38-7805','65793 South Leominster Ave.','94405',25,'Oak Ridge','Rwanda','erat metus at','at neque Cum','odio magna sed molestie','vulputate facilisis','ante bibendum sed Vivamus ipsum','Curabitur neque Vivamus facilisis Integer','vulputate montes','Cum sem Curabitur non','laoreet elit tristique sociis mattis','tincidunt morbi commodo tempus'),(1102,'Norman','1992/8/2','Candice@tempor.org','724-442-4721','271-95-4537','35367 West Australia St.','51574',27,'Hamilton','Japan','faucibus molestie ad','ullamcorper aliquam','facilisi','Aenean dis facilisi','nibh','Integer mus Mauris sollicitudin','arcu','auctor Aliquam venenatis placerat','fermentum sociis semper vulputate amet','auctor metus venenatis'),(1103,'Bryar','1995/9/11','Jana@mus.net','455-978-5716','130-34-1710','24366 North Lakeland Ave.','86257',28,'Monongahela','Ghana','varius ullamcorper mi','Ut ligula inceptos eu nonummy','nec erat','In Morbi Aenean congue','est sit tincidunt hymenaeos pulvinar','mus facilisi magnis','lacus augue ipsum sollicitudin Etiam','magnis rhoncus euismod iaculis','torquent litora Ut vel sollicitudin','dui cursus montes inceptos fames'),(1104,'Lev','2010/10/22','Jared@at.gov','014-604-7909','322-24-6877','45433 West Passaic Ave.','98475',20,'Moreno Valley','Albania','cubilia pede','senectus','parturient sagittis volutpat','tempus aptent erat aptent','pede sed','purus In','lacinia Aenean facilisis viverra est','Duis vestibulum nostra Mauris sociosqu','nisl','Nam nostra'),(1105,'Herrod','1999/5/18','Kasper@Cum.com','114-906-5591','170-61-5848','96852 West Lynn Blvd.','66952',23,'Gastonia','Netherlands','condimentum','nibh','sodales cursus ligula inceptos','sociis nec cursus','ridiculus venenatis felis','ut viverra Cum elit','tortor accumsan porttitor Phasellus','ultricies Sed venenatis nascetur','Pellentesque felis nunc litora','tempor eu Cum luctus euismod'),(1106,'Azalia','2014/8/31','Berk@malesuada.com','647-575-5574','129-37-3967','78065 West Belize Ct.','93452',28,'Palmdale','Ghana','nibh pretium','Nulla','facilisi scelerisque ante libero','Nullam Etiam placerat Duis tempus','mi dapibus felis Praesent nunc','blandit Donec ultrices','mauris velit vestibulum aliquam eleifend','dictum ligula','lacus bibendum','Ut fringilla sapien sodales'),(1107,'Rowan','1989/4/24','Callum@lectus.com','170-966-9704','103-30-5064','64806 West Peru Ave.','89246',28,'Bell','Tonga','placerat mauris cursus imperdiet','ultricies','malesuada leo','purus Nam ac sem scelerisque','Nam dapibus','Pellentesque odio odio','sit turpis facilisi libero','taciti Donec','mattis turpis inceptos libero erat','congue et libero habitant auctor'),(1108,'Abigail','2001/6/9','Vaughan@Morbi.edu','331-874-2079','215-04-9684','83404 South Saint Helena Ln.','39102',21,'Farrell','Central African Republic','placerat fringilla lectus sodales','lorem Class Ut libero','lobortis Nunc Integer consectetuer nascetur','Class taciti turpis','mi metus diam Nam','hymenaeos suscipit montes metus','vulputate a orci dapibus','tellus enim Duis scelerisque','Cras lobortis condimentum tempus','neque fringilla litora'),(1109,'Fuller','2013/5/27','Marsden@blandit.com','053-261-2857','525-53-7977','28075 West Tanzania, United Republic of Ave.','59433',24,'Pulaski','Sweden','enim molestie','ullamcorper facilisis porttitor','nulla purus Nunc sapien','arcu Integer Ut nulla','dictum pulvinar nisi','ligula fermentum cursus hymenaeos erat','quis vitae fringilla pede','eros ut per luctus accumsan','gravida','Nullam sollicitudin parturient nisi libero')
INSERT INTO test1 VALUES (1600,'Lacota','2013/11/22','Elijah@Curae.net','292-344-3387','968-14-6413','64598 East Swaziland Ln.','49041',20,'Pueblo','Nigeria','metus feugiat Maecenas','nonummy pulvinar commodo scelerisque','sapien non sodales sit','Nulla Donec varius','Curae tempor','In habitant sollicitudin','metus laoreet egestas ultricies','sed rhoncus bibendum nulla','feugiat ullamcorper Proin dapibus eleifend','eros'),(1601,'Paki','2004/3/2','Aaron@aliquet.net','860-885-5736','288-12-6431','57528 North Fiji Ct.','35317',24,'Beverly','Saint Kitts and Nevis','nascetur Cum hendrerit nunc vehicula','scelerisque feugiat pretium sapien','dolor Ut odio justo elit','sit Curae taciti quam magna','lobortis malesuada torquent justo ante','facilisis','venenatis','felis nulla ante penatibus','Nam Vivamus Aliquam ac euismod','primis mauris tortor Integer'),(1602,'Clark','2017/1/24','Lionel@conubia.org','405-824-4979','559-07-2195','63225  Aruba Ct.','59195',20,'Santa Cruz','Sao Tome and Principe','est libero','pede in','Integer','mauris Nullam dui','metus semper','molestie auctor','In quam ipsum lacinia nisi','posuere ut','penatibus volutpat ac porttitor fringilla','convallis massa risus condimentum'),(1603,'Nash','2002/5/4','Yeo@et.us','288-991-4626','925-52-5014','83444 East Libyan Arab Jamahiriya Ct.','12514',29,'Kearns','Hong Kong','Nunc pellentesque consequat','odio taciti nulla','metus purus ipsum','sodales enim Lorem feugiat','tempor cubilia dui','Cum tristique cursus blandit','ullamcorper','Suspendisse ligula','eu ultricies inceptos suscipit','Cras libero'),(1604,'Theodore','2004/3/7','Mari@euismod.net','631-990-1628','844-35-2454','58515 West Gambia Way','05055',21,'Harrisburg','Jordan','Lorem justo','pharetra','amet Phasellus magna aptent ut','vehicula sodales','metus id','et tempus litora nostra Donec','aptent magna In','rhoncus nostra mattis eros','varius vitae mus Praesent euismod','Nullam magna'),(1605,'Trevor','1994/6/4','Kirsten@mollis.edu','535-551-4965','911-86-1180','28426 East Virgin Islands, British Blvd.','20024',23,'Richmond','South Georgia and The South Sandwich Islands','vel litora sociosqu nibh','commodo magnis sed In','elit','mattis nulla Aenean inceptos','cursus Cras in','consequat ullamcorper metus massa Curabitur','molestie nisi','odio Morbi taciti','Proin scelerisque nec','Curae magna'),(1607,'Sybill','2014/8/1','Baxter@gravida.edu','671-782-0567','382-53-1480','31450  Benin Blvd.','53241',27,'Fredericksburg','Cyprus','non libero Duis','in nibh parturient Phasellus Suspendisse','vestibulum eros lorem amet','rutrum hymenaeos Maecenas','nulla mauris vehicula','Nunc Morbi eu suscipit dignissim','mauris interdum vulputate','purus lectus Cum Pellentesque faucibus','cursus','dictum habitant et Sed consequat'),(1608,'Moses','2009/1/21','Carolyn@conubia.org','811-026-3512','718-01-7422','39879 East Decatur Way','83005',26,'Ypsilanti','Canada','nulla semper','velit Morbi ornare','diam primis enim Aenean','nec nostra','est volutpat','elementum','sodales dolor imperdiet facilisi','Fusce erat ligula fames molestie','accumsan eleifend','Pellentesque iaculis Nam Class scelerisque'),(1609,'Kyle','1996/1/16','Malachi@non.gov','637-166-8245','527-38-4591','46592 West Rwanda Blvd.','67735',25,'Lebanon','Slovenia','ligula pellentesque lacus a','Proin varius tortor','Nunc blandit','Pellentesque','elit dapibus pede natoque','convallis adipiscing elit torquent','pede vitae','augue dapibus','nunc fames','quam'),(2050,'Elmo','2004/1/15','Rose@ridiculus.com','529-730-6489','462-54-0637','43130  Bahrain Way','95539',28,'Newport Beach','Mexico','urna ut quis vulputate amet','vulputate ornare ridiculus','Nam massa','in Nullam torquent','rhoncus vestibulum','in vulputate elit odio','ac ad convallis fringilla','lorem elit sed augue','leo eu','elementum lectus elit sit')
INSERT INTO test1 VALUES (2100,'Keith','1991/3/26','Dante@blandit.gov','084-258-7661','461-34-9560','53878 South Japan Ln.','17458',28,'Richmond','Poland','aptent quam','nostra placerat turpis dis ut','nonummy dapibus odio','nonummy litora','placerat mollis','nec placerat','at','In pulvinar mauris','Cras suscipit metus natoque','vel euismod eget'),(2150,'Jin','1995/4/12','Hayden@eros.us','560-009-6958','174-40-6817','26669  Slovenia Blvd.','44992',24,'Anchorage','Costa Rica','parturient sociis Cras feugiat','hymenaeos elit tempor blandit','vel fermentum sociis justo aliquet','urna Fusce','taciti blandit justo convallis nonummy','Duis pellentesque in','sociosqu penatibus bibendum sociis','gravida at quam enim placerat','adipiscing tincidunt quis','dolor'),(2200,'Adria','2014/3/18','Kane@Nam.org','809-465-5322','852-00-6592','14051 West Netherlands Way','38037',22,'Newton','Iraq','montes In','neque','iaculis fames Nam nulla quam','auctor venenatis','pulvinar nec suscipit ultrices','imperdiet','Curabitur senectus felis adipiscing feugiat','pede nec porttitor ipsum','primis','est Maecenas egestas sagittis'),(2250,'Kirk','2003/5/3','Mariam@aliquam.org','747-902-5968','760-88-6779','52 East Pottsville Way','77065',30,'Taunton','Timor-leste','rutrum facilisis at','arcu','quis facilisis','morbi nostra nisl faucibus molestie','Quisque iaculis ac','ut posuere aliquam imperdiet','Curae eu commodo auctor','eget','nec lacus faucibus mauris','in ipsum mi'),(2300,'Myra','1999/4/13','Jin@In.net','210-177-4204','926-05-5460','80988 South Bell Way','27948',29,'Fort Wayne','Zambia','eget litora sollicitudin suscipit','cursus interdum habitant','sociis libero','iaculis tortor tincidunt pulvinar Sed','luctus Ut nulla quam Duis','aliquet pede','auctor hymenaeos pede odio rhoncus','lorem ac magnis','mus pede malesuada Cum vulputate','sed feugiat'),(2350,'Addison','1990/8/28','Silas@justo.gov','387-772-0029','611-64-4589','20501 South Burkina Faso Ln.','21957',21,'Knoxville','Bhutan','Quisque pulvinar','turpis commodo conubia inceptos','viverra litora Pellentesque conubia','Quisque bibendum mi','metus aliquam consectetuer','est ridiculus commodo vehicula facilisis','vel facilisis per','tristique nisi augue tellus Cras','Maecenas dignissim','ridiculus vel consectetuer tortor lobortis'),(2400,'Marsden','2008/10/1','Chandler@mauris.us','188-829-7073','778-02-9744','38190 South Haiti St.','82081',25,'Two Rivers','Montserrat','tempor adipiscing blandit','dolor','pulvinar','Nam molestie','In eu egestas','ad mi aliquam','Etiam sagittis','Cum nostra consequat','gravida ultrices pharetra metus','justo suscipit'),(2450,'Kaitlin','1996/4/18','Amery@sit.com','207-616-2187','159-59-2528','63595 West Argentina Ave.','01389',26,'Chicago','Virgin Islands, British','auctor lectus','ultricies pede','arcu Praesent et libero facilisi','euismod porta pede morbi','pulvinar ultricies egestas dictum Cum','Sed','lectus magnis sollicitudin et aptent','Phasellus','dolor congue montes','ante fermentum'),(2500,'Derek','2006/1/2','Callum@dis.net','465-566-9301','362-90-4947','33651  Plymouth St.','54006',30,'Concord','Latvia','Nulla cubilia','dapibus risus quis','Nunc laoreet Maecenas','aliquet imperdiet tempor imperdiet','condimentum','lorem aliquet luctus ultrices dui','ultrices sem Etiam mattis vestibulum','litora id tempus felis vitae','id justo pede','parturient ultricies nostra Nunc Donec'),(2550,'Palmer','1992/7/10','Frances@Quisque.gov','661-287-0592','526-31-0987','5909  Lynn Ave.','48653',29,'Scranton','Panama','hymenaeos auctor litora velit vitae','aliquet','placerat massa neque lacus Etiam','nulla ad tempor','vitae nulla','Suspendisse','id lobortis','risus aliquet volutpat','Mauris ligula','Nam Quisque hymenaeos semper nisl')
select ID,name,brithday,mobile from test1 where ID=600
select ID,name,brithday,mobile from test1 where ID >=600
select ID,name,brithday,mobile from test1 where ID>100
select ID,name,brithday,mobile from test1 where ID <= 600
select ID,name,brithday,mobile from test1 where ID < 1100
select ID,name,brithday,mobile from test1 where ID <>1100
select ID,name,brithday,mobile from test1 where ID != 1100
select ID,name,brithday,mobile from test1 where name = 'Samantha'
select ID,name,brithday,mobile from test1 where binary name = 'samantha'
select ID,name,brithday,mobile from test1 where name > 'Samantha'
select ID,name,brithday,mobile from test1 where name >= 'Samantha'
select ID,name,brithday,mobile from test1 where name < 'Samantha'
select ID,name,brithday,mobile from test1 where name <= 'Samantha'
select ID,name,brithday,mobile from test1 where name <> 'Samantha'
select ID,name,brithday,mobile from test1 where ID=1 or ID=500 or ID=600 or ID=1100 or ID=2100
select ID,name,brithday,mobile from test1 where ID>=400 and ID <1100
select ID,name,brithday,mobile from test1 where ID>600 and ID <1600
select ID,name,brithday,mobile from test1 where ID>1100 and ID <=1100
select ID,name,brithday,mobile from test1 where ID>=200 and ID <=620
select ID,name,brithday,mobile from test1 where not (ID>=200) and ID <=620
select ID,name,brithday,mobile from test1 where not (ID>=200 and ID <=620)
select ID,name from test1 where ID>=450 and ID <650
select ID,name from test1 where ID between 480 and 650
select * from test1 where ID=(id>>1)<<1
select ID,name from test1 where name='cathy' order by ID asc
select a.name,a.brithday,if(ID in (100,101,600,601,602,603),1,null) test from test1 a group by a.name order by name asc
(select ID,name,brithday,mobile from test1 where ID>450 and ID <650) union (select ID,name,brithday,mobile from test1 where name='sunny')
select id,name,brithday,mobile from test1 where name like 'Samantha'
select ID,name,brithday,mobile from test1 where name like '%a%'
select ID,name,brithday,mobile from test1 where name like 'Sa%'
insert into test1 values (500,'!aaa','2011/11/29','Eric@Duis.com','210-086-6295','844-02-2300','92363 West Akron Ct.','56752',22,'Gilbert','Saint Vincent and The Grenadines','Nulla ridiculus','Nulla posuere ultricies Cras','enim magna blandit imperdiet justo','dictum Aenean taciti egestas Ut','Cras tempor pulvinar pellentesque','mi Aenean dapibus justo','Pellentesque consectetuer Pellentesque libero velit','fames convallis Vivamus netus','fermentum nisi dapibus cursus blandit','velit senectus tempus mollis')
select ID,name,brithday,mobile from test1 where name like '%!%%' escape '!'
delete from test1 where id = 500
select ID,name,brithday,mobile from test1 where name regexp '^Sa'
select ID,name,brithday,mobile from test1 where name like binary 'Sa%'
select ID,name,brithday,mobile from test1 where name not like 'Samantha'
select ID,name,brithday,mobile from test1 where name not like upper('Samantha')
select ID,name,brithday,mobile from test1 where mobile not like '210-___-____' and mobile not like '379-___-%' and mobile not like '336-%'
select ID,name,brithday,mobile from test1 where name like 'ca%' and ID >100 and ID<5000
select ID,name,brithday,mobile from test1 where name like 'a%' and ID >=100 and ID<=5000
select ID,name,brithday,mobile from test1 where name like 'fre%' and ID >1000 and ID<5000
insert into test1 values (500,null,'2011/11/29','Eric@Duis.com','210-086-6295','844-02-2300','92363 West Akron Ct.','56752',22,'Gilbert','Saint Vincent and The Grenadines','Nulla ridiculus','Nulla posuere ultricies Cras','enim magna blandit imperdiet justo','dictum Aenean taciti egestas Ut','Cras tempor pulvinar pellentesque','mi Aenean dapibus justo','Pellentesque consectetuer Pellentesque libero velit','fames convallis Vivamus netus','fermentum nisi dapibus cursus blandit','velit senectus tempus mollis')
select id,name,brithday,mobile from test1 where name is null
select id,name,brithday,mobile from test1 where name = null
select id,name,brithday,mobile from test1 where name is not null
delete from test1 where id = 500
select ID,name,brithday,mobile from test1 where ID in (109,609,1109,1609,2609,100,600,1100,2600,3800,4000,4300)
select ID,name,brithday,mobile from test1 where brithday > '2000-01-10' and brithday <'2005-01-20'
select ID,name,brithday,mobile from test1 where brithday >='2001-01-10' and brithday <='2002-01-20'
select ID,name,brithday,mobile from test1 where YEAR(brithday)< YEAR(0)
select distinct name,brithday,mobile from test1
select id,name from test1 where id between 100 and 103
select id,name from test1 where id between 100 and 104
select  ID,name from test1 where ID  not between 100 and 1500
select DISTINCTROW ID,name from test1 where ID between 100 and 1500
select ALL  ID,name from test1 where ID between 100 and 1500
select HIGH_PRIORITY ID,name from test1 where ID between 100 and 1500
select STRAIGHT_JOIN ID,name from test1 where ID between 100 and 1500
select SQL_SMALL_RESULT ID,name from test1 where ID between 100 and 1500
select SQL_BIG_RESULT ID,name from test1 where ID between 100 and 1500
select SQL_BUFFER_RESULT ID,name from test1 where ID between 100 and 1500
select SQL_CACHE  ID,name from test1 where ID between 100 and 1500
select SQL_NO_CACHE ID,name from test1 where ID between 100 and 1500
select SQL_CALC_FOUND_ROWS ID,name from test1 where ID between 100 and 1500
select Concat(name,',',mobile) as a from test1 where ID between 480 and 550
select id,name,mobile,brithday,Email from test1 group by name order by ID asc
#select id,name,mobile as phone,brithday,Email from test1 group by name order by ID,phone
#select distinct id, name,mobile,brithday,Email from test1 group by name order by ID asc
select name,mobile,brithday,Email from test1 order by name asc limit 480,600
select distinct name from test1 order by name asc
select all id,name,mobile,brithday,Email from test1 group by name order by ID asc
select name,count(age) from test1 group by name desc
select ID,name,age+10 as ages,IDcard from test1 where id in (100) order by ID
select ID,name,age+10 as ages,IDcard from test1 where id in (100) order by ages
select ID,name,count(age) from test1 where id in (101) order by ID
select ID,name,count(age) as age from test1 where id in (101)
select ID,name,count(age) as age from test1 where id in (101) group by age
select ID,name,count(age) as age from test1 where id in (101) group by age order by ID
select ID,name,count(age) as age,sum(age) total_age, avg(age) avg_age from test1 where ID in (600) order by ID
select ID,name,count(age) as age,sum(age) total_age, avg(age) avg_age from test1 where ID in (600) group by age
select ID,name,count(age) as age,sum(age) total_age, avg(age) avg_age from test1 where ID in (600) group by age
select ID,name,age+10 as ages,IDcard from test1 where id in (100,109) order by ID
select ID,name,age+10 as ages,IDcard from test1 where id in (1100,109) order by ages
select ID,name,count(age) from test1 where id in (600,1600) order by ID
select ID,name,count(age) as age from test1 where id in (600,1600)
select count(age) as age from test1 where id in (600,1600) group by age
select count(age) as age from test1 where id in (600,1600) group by age order by age
select age,count(age) as count_age,sum(age) total_age, avg(age) avg1 from test1 where ID in (600,601,602,603,1600) group by age
select age,count(age) as count_age,sum(age) total_age, avg(age) avg1 from test1 where ID in (600,601,602,603,1600,100) group by age
select ID,name,age+10 as ages,IDcard from test1 where id in (1,100,102,101,103,609,1600,1601,1605) order by ID
select ID,name,age+10 as ages,IDcard from test1 where id in (1,100,102,101,103,609,1600,1601,1605) order by ages/*allow_diff_sequence*/
#select ID,name,count(age) as age from test1 where id in (109,609,1109,1609,2609,100,600,1100,2600,3800,4000,4300)
select age,count(age) as count_age from test1 where id in (1,100,102,101,103,609,1600,1601,1605) group by age
select age,count(age) as age_count from test1 where id in (1,100,102,101,103,609,1600,1601,1605) group by age order by age
select age,count(age) as count_age,sum(age) total_age, avg(age) avg1 from test1 where ID in (1,100,102,101,103,609,1600,1601,1605) group by age order by age
drop table if exists test1
create table test1(id int(6) NOT NULL ,productID int(11),saleNum int,postion varchar(100),total_price decimal(10,2),person varchar(100),primary key(id)) ENGINE=InnoDB
INSERT INTO test1 VALUES (0,100,1175,'Moldova',144.51,'aaa'),(1,220,1008,'Suriname',105.09,'ccc'),(2,340,1021,'Panama',118.19,'fff'),(3,460,1167,'Malawi',126.67,'bbb'),(4,580,1039,'Canada',103.75,'ddd'),(5,700,1005,'Suriname',108.03,'ccc'),(6,820,1004,'Canada',111.77,'ddd'),(7,940,1081,'Panama',103.92,'fff'),(8,1060,1189,'Panama',131.31,'fff'),(9,1180,1170,'Suriname',135.27,'ccc'),(10,1300,1026,'Malawi',125.06,'bbb'),(11,1420,1088,'Canada',127.20,'ddd'),(12,1540,1082,'Panama',117.38,'fff'),(13,1660,1081,'Malawi',138.86,'bbb'),(14,1780,1178,'Malawi',117.99,'bbb'),(15,1900,1013,'Canada',129.03,'ddd'),(16,2020,1068,'Moldova',123.73,'aaa'),(17,2140,1019,'Suriname',108.06,'ccc'),(18,2260,1008,'Moldova',114.01,'aaa'),(19,2380,1141,'Malawi',138.24,'bbb'),(20,2500,1057,'Moldova',113.57,'aaa'),(21,2620,1005,'Uganda',148.70,'eee'),(22,2740,1059,'Uganda',133.49,'eee'),(23,2860,1126,'Moldova',148.81,'aaa'),(24,2980,1021,'Canada',140.00,'ddd'),(25,3100,1100,'Malawi',144.57,'bbb'),(26,3220,1069,'Uganda',102.76,'eee'),(27,3340,1061,'Suriname',119.64,'ccc'),(28,3460,1100,'Suriname',106.34,'ccc'),(29,3580,1161,'Canada',121.93,'ddd'),(30,3700,1085,'Canada',118.46,'ddd'),(31,3820,1014,'Uganda',135.63,'eee'),(32,3940,1056,'Suriname',141.47,'ccc'),(33,4060,1003,'Uganda',121.23,'eee'),(34,4180,1191,'Panama',117.25,'fff'),(35,4300,1069,'Uganda',148.81,'eee'),(36,4420,1094,'Uganda',141.06,'eee'),(37,4540,1113,'Suriname',127.04,'ccc'),(38,4660,1073,'Malawi',147.26,'bbb'),(39,4780,1005,'Canada',112.84,'ddd'),(40,4900,1001,'Malawi',132.18,'bbb'),(41,5020,1025,'Moldova',123.64,'aaa'),(42,5140,1027,'Moldova',139.98,'aaa'),(43,5260,1120,'Panama',122.14,'fff'),(44,5380,1174,'Malawi',134.27,'bbb'),(45,5500,1090,'Uganda',130.96,'eee'),(46,5620,1194,'Malawi',135.28,'bbb'),(47,5740,1067,'Malawi',120.69,'bbb'),(48,5860,1175,'Suriname',115.42,'ccc'),(49,5980,1027,'Moldova',111.35,'aaa')
INSERT INTO test1 VALUES (50,6100,1195,'Moldova',102.56,'aaa'),(51,6220,1129,'Moldova',115.71,'aaa'),(52,6340,1109,'Malawi',126.92,'bbb'),(53,6460,1019,'Panama',144.27,'fff'),(54,6580,1187,'Canada',110.33,'ddd'),(55,6700,1011,'Panama',100.47,'fff'),(56,6820,1177,'Panama',148.87,'fff'),(57,6940,1024,'Canada',123.25,'ddd'),(58,7060,1086,'Uganda',131.95,'eee'),(59,7180,1081,'Moldova',144.51,'aaa'),(60,7300,1031,'Uganda',144.76,'eee'),(61,7420,1051,'Canada',123.92,'ddd'),(62,7540,1170,'Malawi',112.25,'bbb'),(63,7660,1142,'Suriname',108.05,'ccc'),(64,7780,1016,'Panama',127.39,'fff'),(65,7900,1138,'Uganda',137.14,'eee'),(66,8020,1138,'Moldova',147.42,'aaa'),(67,8140,1177,'Moldova',101.01,'aaa'),(68,8260,1169,'Suriname',129.47,'ccc'),(69,8380,1013,'Moldova',115.11,'aaa'),(70,8500,1064,'Uganda',107.59,'eee'),(71,8620,1070,'Panama',119.02,'fff'),(72,8740,1042,'Moldova',134.27,'aaa'),(73,8860,1068,'Malawi',136.03,'bbb'),(74,8980,1055,'Uganda',113.19,'eee'),(75,9100,1024,'Suriname',112.32,'ccc'),(76,9220,1038,'Panama',122.22,'fff'),(77,9340,1184,'Malawi',137.74,'bbb'),(78,9460,1063,'Panama',133.15,'fff'),(79,9580,1018,'Canada',136.78,'ddd'),(80,9700,1184,'Suriname',127.05,'ccc'),(81,9820,1186,'Panama',116.89,'fff'),(82,9940,1073,'Panama',121.74,'fff'),(83,10060,1147,'Canada',138.30,'ddd'),(84,10180,1091,'Suriname',136.89,'ccc'),(85,10300,1167,'Canada',109.68,'ddd'),(86,10420,1036,'Malawi',143.61,'bbb'),(87,10540,1016,'Panama',144.16,'fff'),(88,10660,1199,'Malawi',103.21,'bbb'),(89,10780,1095,'Uganda',115.25,'eee'),(90,10900,1003,'Suriname',100.31,'ccc'),(91,11020,1103,'Uganda',147.51,'eee'),(92,11140,1110,'Suriname',114.50,'ccc'),(93,11260,1060,'Moldova',117.58,'aaa'),(94,11380,1058,'Panama',110.59,'fff'),(95,11500,1045,'Panama',110.02,'fff'),(96,11620,1078,'Panama',112.51,'fff'),(97,11740,1067,'Suriname',102.47,'ccc'),(98,11860,1061,'Malawi',149.50,'bbb'),(99,11980,1052,'Suriname',121.21,'ccc')
INSERT INTO test1 VALUES (100,12100,1148,'Panama',104.12,'fff'),(101,12220,1097,'Panama',141.38,'fff'),(102,12340,1176,'Canada',113.62,'ddd'),(103,12460,1093,'Panama',105.05,'fff'),(104,12580,1192,'Malawi',142.87,'bbb'),(105,12700,1114,'Malawi',140.91,'bbb'),(106,12820,1012,'Moldova',132.11,'aaa'),(107,12940,1150,'Malawi',127.74,'bbb'),(108,13060,1105,'Panama',116.97,'fff'),(109,13180,1096,'Suriname',140.81,'ccc'),(110,13300,1004,'Suriname',121.99,'ccc'),(111,13420,1104,'Moldova',148.03,'aaa'),(112,13540,1025,'Moldova',100.58,'aaa'),(113,13660,1195,'Suriname',122.57,'ccc'),(114,13780,1068,'Canada',131.74,'ddd'),(115,13900,1165,'Uganda',135.74,'eee'),(116,14020,1015,'Panama',102.43,'fff'),(117,14140,1157,'Panama',136.78,'fff'),(118,14260,1069,'Canada',145.47,'ddd'),(119,14380,1037,'Panama',116.80,'fff'),(120,14500,1046,'Canada',115.51,'ddd'),(121,14620,1115,'Canada',146.36,'ddd'),(122,14740,1066,'Canada',111.78,'ddd'),(123,14860,1055,'Malawi',122.52,'bbb'),(124,14980,1158,'Malawi',100.35,'bbb'),(125,15100,1194,'Moldova',131.36,'aaa'),(126,15220,1188,'Moldova',116.39,'aaa'),(127,15340,1078,'Canada',142.10,'ddd'),(128,15460,1124,'Malawi',129.99,'bbb'),(129,15580,1070,'Panama',126.90,'fff'),(130,15700,1071,'Suriname',128.28,'ccc'),(131,15820,1125,'Moldova',108.80,'aaa'),(132,15940,1010,'Canada',105.54,'ddd'),(133,16060,1178,'Panama',134.80,'fff'),(134,16180,1025,'Uganda',124.42,'eee'),(135,16300,1034,'Uganda',132.15,'eee'),(136,16420,1136,'Canada',116.05,'ddd'),(137,16540,1099,'Uganda',148.17,'eee'),(138,16660,1118,'Panama',114.36,'fff'),(139,16780,1137,'Moldova',123.02,'aaa'),(140,16900,1024,'Canada',122.41,'ddd'),(141,17020,1197,'Suriname',125.85,'ccc'),(142,17140,1185,'Moldova',134.91,'aaa'),(143,17260,1095,'Panama',135.15,'fff'),(144,17380,1160,'Panama',129.23,'fff'),(145,17500,1080,'Moldova',133.97,'aaa'),(146,17620,1069,'Moldova',126.42,'aaa'),(147,17740,1052,'Suriname',107.58,'ccc'),(148,17860,1082,'Uganda',113.03,'eee'),(149,17980,1027,'Canada',144.85,'ddd')
INSERT INTO test1 VALUES (150,18100,1199,'Suriname',129.94,'ccc'),(151,18220,1108,'Panama',134.70,'fff'),(152,18340,1101,'Uganda',137.35,'eee'),(153,18460,1031,'Moldova',128.47,'aaa'),(154,18580,1061,'Uganda',147.81,'eee'),(155,18700,1139,'Canada',119.68,'ddd'),(156,18820,1038,'Suriname',122.10,'ccc'),(157,18940,1004,'Moldova',102.86,'aaa'),(158,19060,1145,'Canada',131.08,'ddd'),(159,19180,1014,'Canada',102.24,'ddd'),(160,19300,1047,'Suriname',135.61,'ccc'),(161,19420,1036,'Uganda',132.71,'eee'),(162,19540,1150,'Uganda',102.96,'eee'),(163,19660,1165,'Suriname',138.45,'ccc'),(164,19780,1012,'Malawi',112.19,'bbb'),(165,19900,1166,'Canada',132.65,'ddd'),(166,20020,1142,'Moldova',125.75,'aaa'),(167,20140,1053,'Canada',130.95,'ddd'),(168,20260,1104,'Panama',145.42,'fff'),(169,20380,1094,'Panama',126.84,'fff'),(170,20500,1160,'Suriname',119.76,'ccc'),(171,20620,1187,'Suriname',105.47,'ccc'),(172,20740,1113,'Panama',132.29,'fff'),(173,20860,1119,'Panama',142.32,'fff'),(174,20980,1146,'Canada',110.49,'ddd'),(175,21100,1037,'Canada',116.01,'ddd'),(176,21220,1138,'Suriname',137.40,'ccc'),(177,21340,1007,'Moldova',114.56,'aaa'),(178,21460,1147,'Moldova',111.14,'aaa'),(179,21580,1150,'Uganda',131.89,'eee'),(180,21700,1091,'Canada',149.66,'ddd'),(181,21820,1024,'Suriname',148.36,'ccc'),(182,21940,1132,'Uganda',145.21,'eee'),(183,22060,1011,'Uganda',146.62,'eee'),(184,22180,1042,'Malawi',131.24,'bbb'),(185,22300,1130,'Moldova',112.95,'aaa'),(186,22420,1158,'Uganda',146.27,'eee'),(187,22540,1144,'Uganda',143.34,'eee'),(188,22660,1147,'Uganda',110.63,'eee'),(189,22780,1121,'Moldova',125.32,'aaa'),(190,22900,1097,'Uganda',138.53,'eee'),(191,23020,1073,'Uganda',100.89,'eee'),(192,23140,1090,'Panama',121.52,'fff'),(193,23260,1104,'Canada',123.09,'ddd'),(194,23380,1016,'Uganda',116.65,'eee'),(195,23500,1050,'Suriname',123.54,'ccc'),(196,23620,1004,'Canada',130.83,'ddd'),(197,23740,1155,'Suriname',139.16,'ccc'),(198,23860,1187,'Uganda',147.02,'eee'),(199,23980,1110,'Panama',148.05,'fff')
INSERT INTO test1 VALUES (200,24100,1080,'Uganda',120.25,'eee'),(201,24220,1181,'Panama',125.83,'fff'),(202,24340,1085,'Panama',149.39,'fff'),(203,24460,1119,'Malawi',124.18,'bbb'),(204,24580,1071,'Malawi',127.81,'bbb'),(205,24700,1143,'Canada',113.49,'ddd'),(206,24820,1033,'Uganda',130.18,'eee'),(207,24940,1189,'Canada',101.94,'ddd'),(208,25060,1035,'Malawi',121.51,'bbb'),(209,25180,1063,'Canada',100.82,'ddd'),(210,25300,1189,'Moldova',130.08,'aaa'),(211,25420,1178,'Panama',109.53,'fff'),(212,25540,1034,'Uganda',139.85,'eee'),(213,25660,1013,'Canada',130.86,'ddd'),(214,25780,1152,'Uganda',142.89,'eee'),(215,25900,1015,'Malawi',103.01,'bbb'),(216,26020,1033,'Canada',123.39,'ddd'),(217,26140,1171,'Moldova',127.95,'aaa'),(218,26260,1117,'Moldova',120.07,'aaa'),(219,26380,1087,'Panama',104.26,'fff'),(220,26500,1023,'Canada',101.38,'ddd'),(221,26620,1027,'Moldova',101.50,'aaa'),(222,26740,1123,'Malawi',102.44,'bbb'),(223,26860,1129,'Malawi',113.23,'bbb'),(224,26980,1050,'Uganda',111.37,'eee'),(225,27100,1037,'Uganda',108.32,'eee'),(226,27220,1159,'Malawi',103.73,'bbb'),(227,27340,1157,'Malawi',118.06,'bbb'),(228,27460,1001,'Malawi',129.91,'bbb'),(229,27580,1004,'Suriname',104.23,'ccc'),(230,27700,1136,'Canada',114.28,'ddd'),(231,27820,1070,'Canada',149.48,'ddd'),(232,27940,1066,'Moldova',133.71,'aaa'),(233,28060,1130,'Malawi',138.59,'bbb'),(234,28180,1199,'Malawi',133.86,'bbb'),(235,28300,1102,'Uganda',147.66,'eee'),(236,28420,1169,'Uganda',134.97,'eee'),(237,28540,1054,'Moldova',148.22,'aaa'),(238,28660,1036,'Moldova',113.01,'aaa'),(239,28780,1099,'Panama',135.04,'fff'),(240,28900,1162,'Canada',104.27,'ddd'),(241,29020,1133,'Moldova',131.55,'aaa'),(242,29140,1060,'Moldova',113.42,'aaa'),(243,29260,1071,'Moldova',128.26,'aaa'),(244,29380,1033,'Panama',106.08,'fff'),(245,29500,1107,'Uganda',121.46,'eee'),(246,29620,1159,'Moldova',104.06,'aaa'),(247,29740,1140,'Canada',142.78,'ddd'),(248,29860,1118,'Moldova',113.91,'aaa'),(249,29980,1052,'Malawi',140.52,'bbb')
select count(*)  from test1 where id between 0 and 0
select count(*)  from test1 where id between 0 and 2
select count(*)  from test1 where id between 0 and 4
select count(saleNum)  from test1 where id between 0 and 250
select max(saleNum)  from test1 where id between 0 and 250
select max( distinct saleNum)  from test1 where id between 0 and 250
select min(saleNum)  from test1 where id between 0 and 250
select avg(saleNum)  from test1 where id between 0 and 250
select sum(saleNum) from test1 where id between 0 and 250
select person from test1 group by person
select person,sum(saleNum) from test1 group by person
select person,max(saleNum) from test1 group by person
select person,min(saleNum) from test1 group by person
select person,avg(total_price) from test1 group by person
select person, max(saleNum) MAX from test1 group by person
select person, max(saleNum) as MAX from test1 group by person
select person,max(saleNum) max, min(saleNum) min, avg(saleNum) avg1, sum(saleNum) sum from test1 group by person
select id,person from test1 where id = 1 group by person
select person from test1 where id > 1 group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id > 1 group by person
select person from test1 where id like '1'
select person from test1 where id like '1%' group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id like '%1' group by person
select person from test1 where id not like '2%' group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id not like '%1' group by person
select person from test1 where person  like 'm%' group by person
select postion from test1 where person in (null) group by postion
select postion from test1 where id in (1,2,3,4,5) group by postion
select postion from test1 where id not in (1,2,3,4,5) group by postion
select postion, sum(postion) SUM from test1 where id in (1,2,3,4,5) group by postion
select postion from test1 where person in ('aaa','bbb','ccc') group by postion
select postion from test1 where person not in ('aaa','bbb','ccc') group by postion
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where person in ('aaa','bbb','ccc') group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where person not in ('aaa','bbb','ccc') group by person
select person from test1 where id between 1 and 4 group by person
select person from test1 where id between 1 and 5 group by person
select person from test1 where id between 1 and 50 group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id between 1 and 50 group by person
select person from test1 where id is null group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id is null group by person
select person from test1 where id is not null group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id is not null group by person
select person from test1 where id is not null and id > 1 and person in ('aaa','bbb') group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where id is not null and id > 1 and person in ('aaa','bbb') group by person
select person from test1 where ( id is not null and id > 1) or person in ('aaa','bbb') group by person
select person, count(person) count, avg(saleNum) as avg1, max(saleNum) as max, min(saleNum) min, sum(saleNum) sum from test1 where (id is not null and id > 1) or person in ('aaa','bbb') group by person
select id,person from test1 where id = 1 order by id
select id,person from test1 where id = 1 order by id,person
select person from test1 where id > 1 order by person limit 100
select person from test1 where id like '1' order by person
select person from test1 where id like '1%' order by person limit 100
select person from test1 where id not like '2%' order by person limit 100
select person from test1 where postion  like 'm%' order by person
select id,person from test1 where postion  like 'm%' order by id
select id,person,saleNum from test1 where postion  like 'm%' order by person,saleNum/*allow_diff_sequence*/
select id,person,saleNum from test1 where postion  like 'm%' order by person,saleNum desc/*allow_diff_sequence*/
select postion from test1 where person in (null) order by postion
select postion,saleNum from test1 where person in (null) order by postion desc,saleNum
select postion from test1 where id in (1,2,3,4,5) order by postion
select postion from test1 where id in (1,2,3,4,5) order by postion desc
select id,saleNum,postion from test1 where id in (1,2,3,4,5) order by postion, saleNum
select postion from test1 where id not in (1,2,3,4,5) order by postion limit 100
select id,saleNum,postion from test1 where id not in (1,2,3,4,5) order by postion, saleNum limit 100/*allow_diff_sequence*/
select postion from test1 where person in ('aaa','bbb','ccc') order by postion limit 100
select postion from test1 where person not in ('aaa','bbb','ccc') order by postion limit 100
select person from test1 where id between 1 and 4 order by person
select person from test1 where id between 1 and 5 order by person
select person from test1 where id between 1 and 50 order by person
select person,saleNum from test1 where id between 1 and 51 order by person,saleNum
select person from test1 where id is null order by person
select person,saleNum from test1 where id is null order by person,saleNum
select person from test1 where id is not null order by person limit 100
select person from test1 where id is not null and id > 1 and person in ('aaa','bbb') order by person limit 100
select person from test1 where ( id is not null and id > 1) or person in ('aaa','bbb') order by person limit 100
select person from test1 group by person order by person
select person from test1 group by person order by person desc
select id,productID,saleNum,postion,total_price,person from test1 group by id order by saleNum desc limit 100/*allow_diff_sequence*/
select id,productID,saleNum,postion,total_price,person from test1 group by id order by saleNum desc,total_price limit 100/*allow_diff_sequence*/
select id,productID,saleNum,postion,total_price,person from test1 group by id order by person desc,total_price limit 100
select person,sum(saleNum) from test1 group by person order by person
select person,max(saleNum) from test1 group by person order by person
select person,max(saleNum) MAX_SALE from test1 group by person order by max_sale/*allow_diff_sequence*/
select person,min(saleNum) from test1 group by person
select person,avg(total_price) from test1 group by person
select person, max(saleNum) MAX from test1 group by person
select person, max(saleNum) as MAX from test1 group by person
select person,max(saleNum) max, min(saleNum) min, avg(saleNum) avg1, sum(saleNum) sum from test1 group by person
select person,max(saleNum) max, min(saleNum) min, avg(saleNum) avg2, sum(saleNum) sum from test1 group by person order by person desc
#
#clear tables
#
drop table if exists test1