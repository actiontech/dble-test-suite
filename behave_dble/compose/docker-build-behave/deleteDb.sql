use mysql;
drop procedure if exists delete_non_sys_db ;
delimiter $
create procedure delete_non_sys_db()
begin
    DECLARE mydbname VARCHAR(60);
    DECLARE done TINYINT DEFAULT 0;
    DECLARE cur CURSOR FOR select SCHEMA_NAME from information_schema.schemata where schema_name not in('performance_schema','sys', 'information_schema','mysql');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH FROM cur into mydbname;
        IF done THEN LEAVE read_loop; END IF;

        set @s=concat("drop database if exists`", mydbname, "`");
        prepare stmt1 from @s;
        execute stmt1 ;
        DEALLOCATE PREPARE stmt1;
    END LOOP;
    CLOSE cur;
END$
delimiter ;
call delete_non_sys_db;
drop procedure delete_non_sys_db;