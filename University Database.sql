-- Creating University Database -- 
CREATE DATABASE University
GO

USE University
GO

-- Creating Tables and Assigning Constraints -- 

CREATE TABLE regions (
region_id INT IDENTITY(1,1) PRIMARY KEY,
region_name VARCHAR(100) NOT NULL
)

CREATE TABLE staffs (
staff_id INT IDENTITY(1,1) PRIMARY KEY,
region_id INT NOT NULL,
staff_name VARCHAR(100) NOT NULL,
FOREIGN KEY (region_id) REFERENCES regions (region_id)
)

CREATE TABLE students (
student_id INT IDENTITY(1,1) PRIMARY KEY,
region_id INT NOT NULL,
councelor_id INT NOT NULL,
student_name VARCHAR(100) NOT NULL,
registration_year DATE NOT NULL,
FOREIGN KEY (region_id) REFERENCES regions (region_id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (councelor_id) REFERENCES staffs (staff_id) ON UPDATE CASCADE ON DELETE CASCADE
)



CREATE TABLE courses (
course_id INT IDENTITY(1,1),
staff_id INT NOT NULL,
course_title VARCHAR(100) NOT NULL,
credit_point INT NOT NULL,
quota INT NOT NULL,
PRIMARY KEY (course_id),
FOREIGN KEY (staff_id) REFERENCES staffs (staff_id) ON UPDATE CASCADE ON DELETE CASCADE,
)




CREATE TABLE students_courses (
student_id INT NOT NULL,
course_id INT NOT NULL,
enrollment_date DATE NOT NULL,
FOREIGN KEY (student_id) REFERENCES students (student_id),
FOREIGN KEY (course_id) REFERENCES courses (course_id) ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (student_id,course_id)
)


CREATE TABLE assignments(
student_id INT NOT NULL,
course_id INT NOT NULL,
assignment_id INT NOT NULL,
grade INT,
FOREIGN KEY (student_id,course_id) REFERENCES students_courses (student_id,course_id),
PRIMARY KEY(student_id, course_id, assignment_id)
)




/*Councelor should be at the same region with student*/

GO
CREATE FUNCTION get_staff(@councelor_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT staffs.region_id FROM staffs WHERE staffs.staff_id = @councelor_id)
END;
GO


ALTER TABLE students 
ADD CONSTRAINT councelor_id 
CHECK(region_id = dbo.get_staff(councelor_id))

/*Every course should have a quota*/

GO
CREATE FUNCTION get_count(@course_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(*) FROM students_courses WHERE course_id = @course_id)
END;
GO

GO
CREATE FUNCTION get_quota(@course_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT quota FROM courses WHERE course_id = @course_id)
END;
GO


ALTER TABLE students_courses
ADD CONSTRAINT course_id 
	CHECK(dbo.get_count(course_id) <= dbo.get_quota(course_id))


/*Each course has 15 point or 30 point credit*/


ALTER TABLE courses
ADD CONSTRAINT credit_point CHECK(credit_point=15 OR credit_point=30)



/*If a course has 15 credit point, students can have assignments up to 3. 
This number is raising up to 5 if course has 30 credit points*/


GO
CREATE FUNCTION higher_num_assign(@course_id INT)
RETURNS INT
AS
BEGIN
		DECLARE @credit INT
		SELECT @credit = credit_point FROM courses WHERE course_id = @course_id
		DECLARE @num INT
		IF @credit = 30
			BEGIN
				SET @num = 5
			END
		IF @credit = 15
			BEGIN
				SET @num = 3
			END
RETURN	@num
END;
GO


GO
CREATE FUNCTION get_studentcourse(@course_id INT)
RETURNS INT
AS 
BEGIN

RETURN (SELECT COUNT(assignment_id) FROM assignments 
		WHERE course_id = @course_id
		GROUP BY  student_id) 
END;
GO




ALTER TABLE assignments
ADD CONSTRAINT  course_id CHECK(get_studentcourse(course_id) <= higher_num_assign(course_id))



/*Each student's total_credit should be equal or less than 180 
and
Students should be in the same region with tutors*/


GO
CREATE FUNCTION get_total_credit(@student_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT SUM(credit_point) FROM students_courses s 
LEFT JOIN courses c ON c.course_id=s.course_id 
WHERE student_id = @student_id)
END;
GO




GO
CREATE FUNCTION get_student_region(@student_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT region_id FROM students WHERE student_id = @student_id)
END;
GO


GO
CREATE FUNCTION get_staff_region(@course_id INT)
RETURNS INT
AS
BEGIN
RETURN (SELECT s.region_id FROM courses c INNER JOIN staffs s ON  s.staff_id = c.staff_id  WHERE course_id = @course_id)
END;
GO

ALTER TABLE students_courses
ADD CONSTRAINT student_id CHECK((dbo.get_total_credit(student_id) <= 180) AND (dbo.get_student_region(student_id) = dbo.get_staff_region(course_id)))


-- Inserting Values -- 

INSERT INTO [dbo].[regions] VALUES('England')
INSERT INTO [dbo].[regions] VALUES('Scotland')
INSERT INTO [dbo].[regions] VALUES('Wales')
INSERT INTO [dbo].[regions] VALUES('Northern Ireland')



INSERT INTO [dbo].[staffs] VALUES(1,'Jack HALL')
INSERT INTO [dbo].[staffs] VALUES(1,'Mary HALT')
INSERT INTO [dbo].[staffs] VALUES(2,'John FALL')
INSERT INTO [dbo].[staffs] VALUES(4,'Rosie DELL')
INSERT INTO [dbo].[staffs] VALUES(3,'Evelyn JACKSON')
INSERT INTO [dbo].[staffs] VALUES(3,'Clay RIVER')
INSERT INTO [dbo].[staffs] VALUES(2,'Suzan LOVE')
INSERT INTO [dbo].[staffs] VALUES(4,'Luis PAYNE')
INSERT INTO [dbo].[staffs] VALUES(3,'Tolisso GABRIELA')
INSERT INTO [dbo].[staffs] VALUES(1,'Henry WELL')


INSERT INTO [dbo].[students] VALUES(1,1,'David JONES', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'Hall THORNHILL', '2017')
INSERT INTO [dbo].[students] VALUES(3,5,'Sully DAVID', '2018')
INSERT INTO [dbo].[students] VALUES(4,4,'Catherine BELL', '2019')
INSERT INTO [dbo].[students] VALUES(3,6,'Jim CLAY', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'Eric ROOSEVELT', '2016')
INSERT INTO [dbo].[students] VALUES(1,1,'Celine RIISE', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'Peter JACK', '2016')
INSERT INTO [dbo].[students] VALUES(3,5,'Zlatan SUBOTIC', '2017')
INSERT INTO [dbo].[students] VALUES(4,4,'Keira COLE', '2016')
INSERT INTO [dbo].[students] VALUES(2,3,'Karim PAYNE', '2018')
INSERT INTO [dbo].[students] VALUES(3,6,'George LAST', '2016')
INSERT INTO [dbo].[students] VALUES(1,1,'Rui PATRICK', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'Ibrahim HAWK', '2016')
INSERT INTO [dbo].[students] VALUES(1,1,'Emmelie TREE', '2017')
INSERT INTO [dbo].[students] VALUES(3,5,'Emiliano RICE', '2016')
INSERT INTO [dbo].[students] VALUES(2,3,'Adele TOWER', '2018')
INSERT INTO [dbo].[students] VALUES(4,4,'Taylor JOURNEY', '2016')
INSERT INTO [dbo].[students] VALUES(2,3,'Roy HALT', '2017')
INSERT INTO [dbo].[students] VALUES(1,1,'Oliver SPINOZA', '2016')
INSERT INTO [dbo].[students] VALUES(1,1,'Emily FALL', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'John HIGH', '2016')
INSERT INTO [dbo].[students] VALUES(3,6,'Adele JANE', '2018')
INSERT INTO [dbo].[students] VALUES(3,5,'Taylor BRAND', '2016')
INSERT INTO [dbo].[students] VALUES(4,4,'Roy WALK', '2017')
INSERT INTO [dbo].[students] VALUES(4,4,'Oliver AXE', '2016')
INSERT INTO [dbo].[students] VALUES(4,4,'Sully TERRY', '2018')
INSERT INTO [dbo].[students] VALUES(1,10,'Cathirene FLOWER', '2019')
INSERT INTO [dbo].[students] VALUES(1,10,'Jim ROSE', '2018')
INSERT INTO [dbo].[students] VALUES(2,3,'Eric HAILEY', '2017')
INSERT INTO [dbo].[students] VALUES(1,10,'Celine PRATT', '2016')
INSERT INTO [dbo].[students] VALUES(4,4,'Peter RIVER', '2018')
INSERT INTO [dbo].[students] VALUES(3,5,'Zlatan JACKSON', '2020')
INSERT INTO [dbo].[students] VALUES(3,6,'Keira HOLLY', '2020')



INSERT INTO [dbo].[courses] VALUES(1,'Math',30,5)
INSERT INTO [dbo].[courses] VALUES(2,'Art',15,5)
INSERT INTO [dbo].[courses] VALUES(3,'Physics',30,4)
INSERT INTO [dbo].[courses] VALUES(4,'History',15,3)
INSERT INTO [dbo].[courses] VALUES(5,'Dance',15,5)
INSERT INTO [dbo].[courses] VALUES(6,'Geography',15,6)
INSERT INTO [dbo].[courses] VALUES(7,'Statistics',30,5)




INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(1,1)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(3,5)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(7,2)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(2,3)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(9,6)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(3,6)
INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(5,6)

--------------------------------------------------

/*Change a student's grade by creating a SQL script that updates a student's grade in
the assignment table*/

UPDATE students_courses
SET assignment_1 = 85, assignment_2 = 90
WHERE student_id = 1 AND course_id = 1;


/* Update the credit for a course*/

UPDATE courses
SET credit_point = 30
WHERE course_id = 2

/* Swap the responsible staff of two students with each other in the student table*/

UPDATE students
SET councelor_id = ( SELECT SUM(councelor_id) 
            FROM students 
            WHERE student_id IN (1,29)
          ) - councelor_id
WHERE student_id IN (1,29)


/*Remove a staff member who is not assigned to any student from the staff table*/

DELETE FROM staffs WHERE staff_id = 9 AND 
(staff_id NOT IN (SELECT councelor_id FROM students) AND staff_id NOT IN (SELECT staff_id FROM courses))


/*Add a student to the student table and enroll the student you added to any course*/

INSERT INTO [dbo].[students] VALUES(1,2,'Edin Hobbs','2020') 

INSERT INTO [dbo].[students_courses] ([student_id],[course_id]) VALUES(35,1)



