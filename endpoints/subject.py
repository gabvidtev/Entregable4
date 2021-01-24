from silence.decorators import endpoint

@endpoint(
    route="/subjects",
    method="GET",
    sql="SELECT * FROM Subjects",
)
def get_subjects():
    pass

@endpoint(
    route="/subjects/$subjectId",
    method="GET",
    sql="SELECT * FROM Subjects WHERE subjectId = $subjectId",
)
def get_by_id():
    pass

@endpoint(
    route="/degrees/$degreeId/subjects",
    method="GET",
    sql="SELECT * FROM Subjects WHERE degreeId = $degreeId",
)
def get_by_id():
    pass

@endpoint(
    route="/subjects",
    method="POST",
    sql="INSERT INTO Subjects(name,acronym,credits,course,type,degreeId,\
    departmentId) VALUES ($name,$acronym,$credits,$course,$type,$degreeId,\
    $departmentId)",
)

def add(name,acronym,credits,course,type,degreeId,departmentId):
    pass

@endpoint(
    route="/subjects/$subjectId",
    method="DELETE",
    sql="DELETE FROM Subjects WHERE subjectId = $subjectId",
)
def delete():
    pass

@endpoint(
    route="/subjects/$subjectId",
    method="PUT",
    sql="UPDATE Subjects SET name = $name, acronym = $acronym,\
    credits = $credits, course = $course, type = $type, degreeId = $degreeId, departmentId = $departmentId\
    WHERE subjectId = $subjectId",
)
def update(name,acronym,credits,course,type,degreeId,departmentId):
    pass