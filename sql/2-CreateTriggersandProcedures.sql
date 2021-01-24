-- RN-001
DELIMITER //
CREATE OR REPLACE TRIGGER triggerMaximumTeachingLoad
BEFORE INSERT ON TeachingLoads
FOR EACH ROW
BEGIN
DECLARE groupYear INT;
DECLARE currentCredits INT;
SET groupYear = (SELECT year FROM Groups WHERE groupId = new.groupId);
SET currentCredits = (SELECT SUM(credits)
FROM TeachingLoads JOIN Groups ON (TeachingLoads.groupId = Groups.groupId)
WHERE professorId = new.professorId AND year=groupYear);
IF((currentCredits+new.credits) > 25) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Un profesor no puede tener más de 25 créditos de docencia en un año';
END IF;
END //
DELIMITER ;

-- RN-003
DELIMITER //
CREATE OR REPLACE TRIGGER triggerConsistentDepartment
BEFORE INSERT ON TeachingLoads
FOR EACH ROW
BEGIN
DECLARE professorDepartment INT;
DECLARE subjectDepartment INT;
SET professorDepartment = (SELECT departmentId
FROM Professors
WHERE Professors.professorId = new.professorId);
SET subjectDepartment = (SELECT departmentId
FROM Groups JOIN Subjects ON (Groups.subjectId = Subjects.subjectId)
WHERE Groups.groupId = new.groupId);
IF(professorDepartment != subjectDepartment) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Un profesor no puede dar asignaturas fueras de su departamento';
END IF;
END //
DELIMITER ;

-- RN-005
DELIMITER //
CREATE OR REPLACE TRIGGER triggerValidTutoringAppointment
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
DECLARE startHour TIME;
DECLARE endHour TIME;
DECLARE weekDay INT;
SELECT TutoringHours.startHour, TutoringHours.endHour, dayOfWeek INTO startHour, endHour, weekDay
FROM TutoringHours
WHERE TutoringHours.tutoringHoursId = new.tutoringHoursId;
IF (new.hour < startHour OR new.hour > endHour OR WEEKDAY(new.date)!=weekDay) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Las citas de tutoría deben ser consistentes con el horario';
END IF;
END//
DELIMITER ;

-- RN-006
DELIMITER //
CREATE OR REPLACE TRIGGER
triggerWithHonours
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
IF (new.withHonours = 1 AND new.value < 9.0) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Para obtener matrícula hay que sacar al menos un 9';
END IF;
END//
DELIMITER ;

-- RN-007
DELIMITER //
CREATE OR REPLACE TRIGGER
triggerUniqueGradesSubject
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
DECLARE subject INT; -- La asignatura en la que se inserta la nota
DECLARE groupYear INT; -- El año al que corresponde
DECLARE subjectGrades INT; -- Conteo de notas de la misma asignatura/alumno/año/convocatoria
SELECT subjectId, year INTO subject, groupYear FROM Groups WHERE groupId = new.groupId;
SET subjectGrades = (SELECT COUNT(*)
FROM Grades, Groups
WHERE (Grades.studentId = new.studentId AND -- Mismo estudiante
Grades.gradeCall = new.gradeCall AND -- Misma convocatoria
Grades.groupId = Groups.groupId AND
Groups.year = groupYear AND -- Mismo año
Groups.subjectId = subject)); -- Misma asignatura
IF(subjectGrades > 0) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Un alumno no puede tener varias notas asociadas a la misma
asignatura en la misma convocatoria, el mismo año';
END IF;
END//
DELIMITER ;

-- RN-008
DELIMITER //
CREATE OR REPLACE TRIGGER
triggerValidAge
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN
IF (new.accessMethod='Selectividad' AND (YEAR(CURDATE()) - YEAR(new.birthdate) < 16)) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Para entrar por selectividad hay que tener más de 16 años';
END IF;
END//
DELIMITER ;

-- RN-009
DELIMITER //
CREATE OR REPLACE TRIGGER
triggergGradeStudentGroup
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
DECLARE isInGroup INT;
SET isInGroup = (SELECT COUNT(*)
FROM GroupsStudents
WHERE studentId = new.studentId AND groupId = new.groupId);
IF(isInGroup < 1) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Un alumno no puede tener notas en grupos a los que no pertenece';
END IF;
END//
DELIMITER ;

-- RN-010
DELIMITER //
CREATE OR REPLACE TRIGGER
triggerGradesChangeDifference
BEFORE UPDATE ON Grades
FOR EACH ROW
BEGIN
DECLARE difference DECIMAL(4,2);
DECLARE student ROW TYPE OF Students;
SET difference = new.value - old.value;
IF(difference > 4) THEN
SELECT * INTO student FROM Students WHERE studentId = new.studentId;
SET @error_message = CONCAT('Al alumno ', student.firstName, ' ', student.surname,
' se le ha intentado subir una nota en ', difference, ' puntos');
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END IF;
END//
DELIMITER ;

-- RN-019
DELIMITER //
CREATE OR REPLACE TRIGGER triggerGroupsStudentsSubject
AFTER INSERT ON groupsstudents
FOR EACH ROW
BEGIN
DECLARE subjectGroup INT;
DECLARE groupsTot INT;
DECLARE activityGroup TEXT;
DECLARE yearGroup TEXT;
SELECT groups.subjectId, groups.activity, groups.year INTO subjectGroup, activityGroup, yearGroup FROM groups
WHERE groups.groupId = new.groupId;
SELECT COUNT(*) INTO groupsTot FROM groups NATURAL JOIN groupsstudents
where studentId= new.studentId AND subjectId = subjectGroup AND activity = activityGroup AND YEAR = yearGroup
GROUP BY subjectId;
IF (groupsTot > 1) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'El alumno ya tiene asignado un grupo de ese tipo, en esa asignatura';
END IF;
END//
DELIMITER ;


-- RN-20
DELIMITER //
CREATE OR REPLACE TRIGGER triggerTheoryTeacher
BEFORE INSERT ON TeachingLoads
FOR EACH ROW
BEGIN
DECLARE theProfessorId INT;
DECLARE theGroupT ROW TYPE OF Groups;
DECLARE theSubjectId INT;
DECLARE hayLabs INT;
DECLARE theYear INT;
SELECT * INTO theGroupT FROM Groups WHERE groupId = new.groupId;
SET theSubjectId = theGroupT.subjectId;
SET theProfessorId = (SELECT DISTINCT professorId FROM TeachingLoads
WHERE professorId = new.professorId);
SET theYear = theGroupT.year;
-- If this group is theory, there must be a lab assigned
IF (theGroupT.activity = 'Teoria') THEN
SET hayLabs = (SELECT COUNT(*) FROM TeachingLoads, Groups
WHERE (TeachingLoads.groupId = Groups.groupId
AND Groups.subjectId = TheSubjectId
AND TeachingLoads.professorId = theProfessorId
AND Groups.year = theYear));
IF (hayLabs < 1) THEN
SIGNAL SQLSTATE '45000' SET message_text = 'El profesor debe tener ya asignado un grupo de laboratorio';
END IF;
END IF;
END //
DELIMITER ;

-- RN-21
DELIMITER //
CREATE OR REPLACE TRIGGER triggerGroupsClassRooms
BEFORE INSERT ON groups
FOR EACH ROW
BEGIN
DECLARE activityRooms text;
SELECT activity INTO  activityRooms from classrooms
WHERE classrooms.classroomId = new.classroomId;
IF (activityRooms <> new.activity) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'El tipo de aula no corresponde';
END IF;
END//
DELIMITER ;


-- RN-22
DELIMITER //
CREATE OR REPLACE TRIGGER triggerAppointmentsDate
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
DECLARE appointmentsTot INT;
SELECT  COUNT(*) INTO appointmentsTot from appointments NATURAL JOIN tutoringhours
WHERE studentId = new.studentId
AND DATE-CURDATE() > 0;
IF (appointmentsTot> 0) THEN
SIGNAL SQLSTATE '45000' SET message_text =
'Tiene ya una cita concertada pendiente';
END IF;
END
//
DELIMITER ;


-- RF-001
DELIMITER //
CREATE OR REPLACE PROCEDURE
createGrade(groupId INT, studentId INT, gradeCall INT, withHonours BOOLEAN, value DECIMAL(4,2))
BEGIN
INSERT INTO Grades (groupId, studentId, gradeCall, withHonours, value) VALUES (groupId, studentId, gradeCall, withHonours, value);
END //
DELIMITER ;

-- RF-002
DELIMITER //
CREATE OR REPLACE PROCEDURE
procedureGetAppointments(professorId INT, dayOfWeek INT)
BEGIN
SELECT * FROM
TutoringHours JOIN Appointments ON (TutoringHours.tutoringHoursId = Appointments.tutoringHoursId)
JOIN Students ON (Appointments.studentId = Students.studentId)
WHERE TutoringHours.professorId=professorId AND TutoringHours.dayOfWeek=dayOfWeek;
END //
DELIMITER ;

-- RF-003
DELIMITER //
CREATE OR REPLACE PROCEDURE
procedureCreateTeachingLoad(professorId INT, groupId INT, credits INT)
BEGIN
INSERT INTO TeachingLoads(professorId, groupId, credits) VALUES (professorId, groupId, credits);
END //
DELIMITER ;

-- RF-004
CREATE OR REPLACE VIEW ProfessorsTeachingLoads AS
SELECT Professors.professorId, firstName, surname, year, SUM(credits) AS credits
FROM Professors
JOIN TeachingLoads ON (Professors.professorId = TeachingLoads.professorId)
JOIN Groups on (TeachingLoads.groupId = Groups.groupId)
GROUP BY Professors.professorId, year;

-- RF-005
DELIMITER //
CREATE OR REPLACE FUNCTION
functionProfessorHighestLoad(subjectId INT, year INT) RETURNS INT
BEGIN
RETURN (SELECT TeachingLoads.professorId
FROM TeachingLoads
JOIN Groups ON (TeachingLoads.groupId = Groups.groupId)
JOIN Subjects ON (Groups.subjectId = Subjects.subjectId)
WHERE Subjects.subjectId = subjectId AND Groups.year = year
GROUP BY TeachingLoads.professorId
ORDER BY SUM(TeachingLoads.credits) DESC
LIMIT 1);
END //
DELIMITER ;

-- RF-006
DELIMITER //
CREATE OR REPLACE PROCEDURE
procedureDeleteGrades(studentDni CHAR(9))
BEGIN
DECLARE id INT;
SET id = (SELECT studentId FROM Students WHERE dni=studentDni);
DELETE FROM Grades WHERE studentId=id;
END //
DELIMITER ;

-- RF-007
CREATE OR REPLACE VIEW ViewStudentsList AS
SELECT firstName, surname, Subjects.name AS subject, Groups.name AS groupName
FROM Students
LEFT JOIN GroupsStudents ON (Students.studentId = GroupsStudents.studentId)
LEFT JOIN Groups ON (GroupsStudents.groupId = Groups.groupId)
LEFT JOIN Subjects ON (Groups.subjectId = Subjects.subjectId)
ORDER BY firstName;

-- RF-008
CREATE OR REPLACE VIEW ViewOldStudents AS
SELECT * FROM Students WHERE accessMethod = 'Mayor';

-- RF-009
CREATE OR REPLACE VIEW ViewSubjectsSoft2018 AS
SELECT name, acronym, credits, type
FROM Subjects
WHERE degreeId=1 AND (SELECT COUNT(*)
FROM Groups
WHERE year = 2018 AND Groups.SubjectId = Subjects.subjectId)>0
ORDER BY acronym;

-- RF-011
DELIMITER //
CREATE OR REPLACE FUNCTION
functionAvgGrade(studentId INT) RETURNS DOUBLE
BEGIN
RETURN (	SELECT AVG(value)
FROM Grades
WHERE GRADES.studentId=studentId);
END //
DELIMITER ;



-- RF-036
CREATE OR REPLACE VIEW ViewGroupStudents AS
SELECT YEAR, NAME, activity, firstname, surname FROM groups
NATURAL JOIN groupsstudents NATURAL JOIN students
ORDER BY 1,2, 3;

-- RF-037
CREATE OR REPLACE VIEW ViewGroupProfessors AS
SELECT YEAR, NAME, activity, professorId, firstname, surname FROM groups
NATURAL JOIN teachingloads
NATURAL JOIN professors
ORDER BY 1,2, 3;

-- RF-038
CREATE OR REPLACE VIEW ViewOfficeProfessors AS
SELECT officeId, COUNT(*) FROM professors NATURAL JOIN offices GROUP
BY officeId
HAVING COUNT(*)>1;

-- RF-039
CREATE OR REPLACE VIEW ViewAppointments AS
SELECT professorId, DATE, HOUR, studentId from appointments NATURAL JOIN tutoringhours
WHERE DATE-CURDATE() >0
ORDER BY 1,2,3,4;

