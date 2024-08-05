class_name DebugVector
extends Control


class Vector:
	var from: Vector3  # The vector to draw
	var to: Vector3  # The vector to draw
	var scale  # Scale factor
	var width  # Line width
	var color  # Draw color

	func _init(_from, _to, _scale, _width, _color):
		from = _from
		to = _to
		scale = _scale
		width = _width
		color = _color

	func draw(node: Control, camera):
		var start = camera.unproject_position(from)
		var end = camera.unproject_position(to * scale)
		node.draw_line(start, end, color, width)

		# node.draw_polygon(end, start.direction_to(end), width * 2, color)


var vectors = []  # Array to hold all registered values.


func _process(delta):
	if not visible:
		return
	# update()
	self.queue_redraw()


func _draw():
	var camera = get_viewport().get_camera_3d()
	for vector in vectors:
		vector.draw(self, camera)


func add_vector(from, to, v_scale, width, color):
	vectors.append(Vector.new(from, to, v_scale, width, color))
