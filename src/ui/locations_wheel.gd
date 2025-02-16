@tool
extends Node3D
class_name LocationsWheel

const Y_COEFF1 = -0.01
const Y_COEFF2 = 0.21

const MAX_HEART_SPACE = 0.7

@export var play_spindown: bool = false:
	set(value):
		if value:
			initial_spindown(1.5, 0)
			play_spindown = false

@export var play_advance_location: bool = false:
	set(value):
		if value:
			advance_location()
			play_advance_location = false

@export_range(0, 6) var focused_location: float:
	set(value):
		focused_location = value
		update_labels.call_deferred()
				

@export var location_hearts: HeartHolder

@onready var labels_node: Node3D = %Labels
@onready var default_pos: Vector3 = position

var heart_space: float = 0.5
var animating = false

func _process(_delta: float) -> void:
	if animating:
		update_labels()

func update_labels():
	var labels = labels_node.get_children()
	for i in range(labels.size()):
		var label = labels[i]
		label.position.y = calculate_y_pos(i - focused_location)
		label.update_wheel_visuals()

func calculate_y_pos(dist_from_center: float) -> float:
	var x = abs(dist_from_center)
	if dist_from_center > 0:
		x += heart_space
	return -sign(dist_from_center) * (Y_COEFF1 * x * x + Y_COEFF2 * x) # https://www.desmos.com/calculator/yk5petpy6j

func set_location(location: int):
	focused_location = location

# ---------- FADE ----------

func fade_in(time: float):
	for label: LocationLabel in labels_node.get_children():
		label.fade_in(time)

func fade_out(time: float):
	for label: LocationLabel in labels_node.get_children():
		label.fade_out(time)

# ---------- SPECIFIC ANIMATIONS ----------

func teleport_to_default_pos():
	position = default_pos

func spindown_spawn(x_pos: float, y_pos: float):
	position.x = x_pos
	position.y = y_pos

	heart_space = 0.0
	focused_location = 0
	animating = true

func initial_spindown(x_pos: float, y_pos: float):
	position.x = x_pos
	position.y = y_pos

	var tween = create_tween()
	tween.tween_property(self, "focused_location", 6, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	await get_tree().create_timer(1).timeout

	animating = false

func advance_location(regress: bool = false):
	var tween_time = 0.7
	animating = true

	await get_tree().create_timer(0.2).timeout

	location_hearts.fade_out(0.4)
	await get_tree().create_timer(0.2).timeout

	var heart_space_tween_close = create_tween()
	heart_space_tween_close.tween_property(self, "heart_space", 0, tween_time).set_trans(Tween.TRANS_CUBIC)
	await heart_space_tween_close.finished

	var location_tween = create_tween()
	var idx = focused_location - 1 if not regress else focused_location + 1
	location_tween.tween_property(self, "focused_location", idx, tween_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	Global.sfx_player.play("Wheel_Tick")
	await location_tween.finished

	var heart_space_tween_open = create_tween()
	heart_space_tween_open.tween_property(self, "heart_space", MAX_HEART_SPACE, tween_time).set_trans(Tween.TRANS_CUBIC)
	await heart_space_tween_open.finished

	animating = false
