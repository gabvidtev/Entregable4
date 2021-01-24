from silence.decorators import endpoint

@endpoint(
    route="/degrees",
    method="GET",
    sql="SELECT * FROM Degrees",
)
def get_all_degree():
    pass

@endpoint(
    route="/degrees/$degreeId",
    method="GET",
    sql="SELECT * FROM Degrees WHERE degreeId = $degreeId",
)
def get_by_id():
    pass

@endpoint(
    route="/degrees",
    method="POST",
    sql="INSERT INTO Degrees(name, years) VALUES ($name, $years)",
)

def add(name, years):
    pass

@endpoint(
    route="/degrees/$degreeId",
    method="DELETE",
    sql="DELETE FROM Degrees WHERE degreeId = $degreeId",
)
def delete():
    pass

@endpoint(
    route="/degrees/$degreeId",
    method="PUT",
    sql="UPDATE Degrees SET name = $name, years = $years WHERE degreeId = $degreeId",
)
def update(name, years):
    pass

