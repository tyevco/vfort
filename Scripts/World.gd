extends Spatial

export (PackedScene) var Wall

var finalizeWall: bool = false;
var mouse_left_down: bool = false;
var firstPointSelected: bool = false;
var mouseDownStartPosition: Vector3 = Vector3.ZERO;
var mouseDownCurrentPosition: Vector3 = Vector3.ZERO;
var placedWall = null;


func _input( event ):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false

func _physics_process(_delta):
	if (mouse_left_down):
		var camera = $CameraGimbal/InnerGimbal/Camera
		var ray_length = 100 # some large number
		var mouse_pos = get_viewport().get_mouse_position()
		$RayCast.transform.origin = camera.project_ray_origin(mouse_pos)
		$RayCast.cast_to = camera.project_ray_normal(mouse_pos) * ray_length
		$RayCast.force_update_transform()
		$RayCast.force_raycast_update()
		var collisionPoint = $RayCast.get_collision_point()
		if (collisionPoint != null):
			if (firstPointSelected):
				mouseDownCurrentPosition = collisionPoint;
				$Current.global_transform.origin = mouseDownCurrentPosition
				$Current.visible = true;
				if (placedWall == null):
					placedWall = Wall.instance();
					placedWall.transform.origin = lerp($Start.global_transform.origin, $Current.global_transform.origin, 0.5);
					var relativeNormal = $RayCast.get_collision_normal() + placedWall.transform.origin;
					placedWall.look_at(relativeNormal, Vector3.UP)

					add_child(placedWall)
				else:
					placedWall.transform.origin = lerp($Start.global_transform.origin, $Current.global_transform.origin, .5)
					var distance = mouseDownStartPosition.distance_to(mouseDownCurrentPosition);
					print(distance)
					placedWall.scale.z = distance / 2;
					placedWall.look_at(mouseDownCurrentPosition, Vector3.UP)
					
			else:
				mouseDownStartPosition = collisionPoint;
				$Start.global_transform.origin = mouseDownStartPosition
				firstPointSelected = true;
				$Start.visible = true;
	else:
		$Start.visible = false;
		$Current.visible = false;
		if (firstPointSelected):
			firstPointSelected = false;
			finalizeWall = true;
		placedWall = null;

