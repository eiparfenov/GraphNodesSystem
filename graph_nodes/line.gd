extends CSGPolygon3D
class_name Line3D

@onready var path_3d: Path3D = $Path3D


func set_points(point1: Vector3, point2: Vector3):
	path_3d.curve.points_count = 2
	path_3d.curve.set_point_position(0, point1)
	path_3d.curve.set_point_position(1, point2)
