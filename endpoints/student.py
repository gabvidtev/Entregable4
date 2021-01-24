from silence.decorators import endpoint

@endpoint(
    route="/students",
    method="GET",
    sql="SELECT * FROM Students",
)
def get_students():
    pass

@endpoint(
    route="/students/$studentId",
    method="GET",
    sql="SELECT * FROM Students WHERE studentId = $studentId",
)
def get_by_id():
    pass

@endpoint(
    route="/students",
    method="POST",
    sql="INSERT INTO Students(accessMethod,dni,firstName,\
    surname,birthDate,email) VALUES ($accessMethod,$dni,$firstName,\
    $surname,$birthDate,$email)",
)

def add(accessMethod,dni,firstName,surname,birthDate,email):
    pass

@endpoint(
    route="/students/$studentId",
    method="DELETE",
    sql="DELETE FROM Students WHERE studentId = $studentId",
)
def delete():
    pass

@endpoint(
    route="/students/$studentId",
    method="PUT",
    sql="UPDATE Students SET accessMethod = $accessMethod,dni = $dni,firstName = $firstName,\
    surname = $surname,birthDate = $birthDate,email = $email\
    WHERE studentId = $studentId",
)
def update(accessMethod,dni,firstName,surname,birthDate,email):
    pass