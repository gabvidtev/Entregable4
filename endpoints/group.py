from silence.decorators import endpoint


@endpoint(
    route="/groups",
    method="GET",
    sql="SELECT * FROM Groups",
)
def get_all_group():
    pass

@endpoint(
    route="/groups/$groupId",
    method="GET",
    sql="SELECT * FROM Groups WHERE groupId = $groupId",
)
def get_by_id():
    pass

@endpoint(
    route="/classrooms/$classroomId/groups",
    method="GET",
    sql="SELECT * FROM Groups WHERE classroomId = $classroomId",
)
def get_by_id():
    pass

@endpoint(
    route="/groups",
    method="POST",
    sql="INSERT INTO Groups(name, activity, year,subjectId, classroomId) VALUES ($name, $activity, $year,\
    $subjectId, $classroomId)",
)

def add(name, activity, year,subjectId, classroomId):
    pass

@endpoint(
    route="/groups/$groupId",
    method="DELETE",
    sql="DELETE FROM Groups WHERE groupId = $groupId",
)
def delete():
    pass

@endpoint(
    route="/groups/$groupId",
    method="PUT",
    sql="UPDATE Groups SET name = $name, activity = $activity, year = $year,\
    subjectId = $subjectId, classroomId = $classroomId\
    WHERE groupId = $groupId",
)
def update(name, activity, year, subjectId, classroomId):
    pass