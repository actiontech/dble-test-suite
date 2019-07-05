#!default_db:schema1
drop table if exists er_parent;
drop table if exists er_child;
create table er_parent(id int,name varchar(40));
create table er_child(id int,name varchar(40));
insert into er_parent values(1,'a'),(2,'b'),(3,'c'),(6,'f'),(7,'g'),(8,'h');
insert into er_child values(1,'a');
insert into er_child values(2,'b');
select a.id,b.name from er_parent a left join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a right join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a left outer join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a right outer join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a inner join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a cross join er_child b on a.id=b.id and a.id=1;
select a.id,b.name from er_parent a  straight_join er_child b on a.id=b.id and a.id=1;
drop table if exists er_parent;
drop table if exists er_child;