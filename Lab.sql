create table student
(Sno Char(7) not null PRIMARY key,Sname varchar(20) not null,
Ssex char(2) not null,
Sage smallint ,
Clno char(5) not null);
create table course(
Cno char(1) not null PRIMARY key,Cname varchar(20) not null,
Credit smallint );
create table class(
Clno char(5) not null PRIMARY key ,Speciality varchar(20) not null,
Inyear char(4) not null ,Clnum Integer,
Monitor char(7));
create table grade(
Sno char(7) not null,Cno char(1) not null,Gmark numeric(4,1));


/*实验三*/
SET SQL_SAFE_UPDATES = 0;-- 是一个用于设置 SQL 安全更新模式的语句
alter table student add Nation Varchar(20);-- 添加属性
alter table student drop column Nation;-- 删除属性
insert into grade values("2001110","3","80"); -- 插入数据
UPDATE Grade SET Gmark=70 WHERE Sno='2001110';-- 修改数据
DELETE FROM Grade WHERE Sno='2001110';-- 删除整条数据
CREATE INDEX IX_Class ON Student(Sno);-- 在Clno上创建索引
DROP INDEX IX_Class ON Student;-- 删除索引
-- 改正后的思考题
SELECT Sno,Sname,Sage,AVG(Sage)
FROM student
having Sage<AVG(Sage);

/*实验四*/
SELECT DISTINCT Cno '课程号' FROM Grade;-- 所有被学生选修过的课程号

SELECT Sno ,Sname ,Ssex ,Sage ,Clno FROM Student 
WHERE Clno='01311' AND Ssex='女';
-- 找出01311班和01312班的学生姓名、性别、出生年份;
SELECT Sname,Ssex,2012-Sage '出生年份'  FROM Student 
WHERE Clno IN('01311','01312');
-- 找出所有姓李的学生的个人信息;
SELECT Sno ,Sname ,Ssex ,Sage ,Clno FROM Student 
WHERE Sname LIKE '李%';

-- 找出学生李勇所在班级的学生人数;
SELECT Clnum '班级人数' FROM Class
WHERE Clno =(
SELECT Clno 
FROM Student 
WHERE Sname = '李勇');

-- 操作系统课的平均分最高分最低分
SELECT AVG(Gmark) '平均分',MAX(Gmark) '最高分',MIN(Gmark) '最低分' FROM Grade 
WHERE Cno =(SELECT Cno FROM Course WHERE Cname='操作系统');

-- 有多少人选修了课程
SELECT COUNT(DISTINCT Sno) '选修课程的人数' FROM Grade;

-- 选修了操作系统的人数
SELECT COUNT(DISTINCT Sno) '选修了操作系统的人数'FROM Grade
WHERE Cno=(SELECT Cno FROM Course WHERE Cname='操作系统');

-- 成绩为空的同学信息
SELECT * FROM Student,Class
WHERE Student.Clno=Class.Clno and Inyear='2000' and Speciality='计算机软件' and Sno in (SELECT Sno FROM Grade where Gmark is null);

/*实验五*/
-- 找出和李勇同班的同学
SELECT * FROM student
WHERE Clno=(SELECT Clno FROM student WHERE Sname='李勇');

-- 和李勇修了同一门课的同学
SELECT * FROM student
where Sno in(select Sno From Grade where Cno in (select cno from grade where Sno in(select Sno from student where sname='李勇')));

-- 李勇年龄和25之间的同学
select * from student
where Sage between (select Sage from student where sname='李勇') and 25;

-- 选修了操作系统的同学
select Sno ,Sname from Student
where Sno in (
select Sno from Grade 
where Cno = (
select Cno from Course
where Cname='操作系统'
));

-- 没有选修1号课的同学姓名
select Sname from student
where Sno not in (select sno from grade where cno='1');

-- 选修所有课程的同学姓名
select sname from student
where not exists(select * from course where not exists(select * from grade where student.sno=grade.sno and course.cno=grade.cno));

-- 14.
-- 选修3号课程同学的升序成绩
select sno,gmark from grade
where cno='3' order by gmark desc;

-- 查询全体学生信息，按班级号升序，同班的按年龄降序
select * from student
order by Clno,Sage desc;

-- 求每个课程号及相应的人数
select cno,count(*) '课程人数' from grade
group by Cno;

-- 选修了3门以上的同学学号
select sno from grade
group by sno having count(*)>3;

/*实验六*/
SET SQL_SAFE_UPDATES = 0;

-- 将01311班级成绩置零
update grade 
set gmark=0
where sno in(select sno from student where clno='01311');

-- 删除2001级计算机软件学生的选课记录
delete from grade
where sno in(select sno from student where clno=(select clno from class where Speciality='计算机软件' and inyear='2001'));

-- 李勇退学，删除库中他的信息
update class set clnum=clnum-1
where clno=(select clno from student where sname='李勇');
update class set monitor=null where monitor = (select Sno from Student where Sname='李勇');
delete from grade where sno=(select sno from student where sname='李勇');
delete from student where sname='李勇';


-- 求每个班同学的平均年龄，存入数据库
SET SQL_SAFE_UPDATES=0;
alter table class 
add avgage smallint null;
update class set avgage=case 
when Clno ='00311' then (select AVG(Sage) from Student where Clno='00311')
when Clno ='00312' then (select Avg(Sage) from Student where Clno='00312')
when Clno ='01311' then (select Avg(Sage) from Student where Clno='01311')
end;

-- 实验七
SET SQL_SAFE_UPDATES = 0;

-- 建立01311班选修了1号课程的学生视图stu_01311_1
create view Stu_01311_1 
as select Student.Sno,Sname,Gmark from Grade,Student
where Cno='1' and Clno ='01311' and Student.Sno=Grade.Sno
with check option;


-- 建立01311班选修了1号课程且成绩不及格的学生视图stu_01311_2
create view Stu_01311_2 as select * from Stu_01311_1 
where Gmark<60;

-- 建立视图Stu_year,由学生学号，姓名，出生年月份组成
create view Stu_year(Sno, Sname,years )
as select Sno,Sname,2023-Sage
from Student;

-- 查询1990年以后出生的学生姓名
select Sname from Stu_year where years>1990;

-- 01311班选修1号课且成绩不及格的学生学号姓名出生年份
select * from Stu_year
where Sno in(select Sno from Stu_01311_2);

-- 建立一视图Class_grade，用来反映每个班的所有选修课的平均成绩，并对其进行更新操作。
create view Class_grade as select Clno, avg(Gmark) as avg from Student,Grade
WHERE Student.Sno=Grade.Sno GROUP BY Clno;


