extends Control

@onready var spin_box: SpinBox = %SpinBox
@onready var h_scroll_bar: HScrollBar = %HScrollBar

func _on_h_scroll_bar_value_changed(value : float) -> void:
	spin_box.value = h_scroll_bar.value
	if %autoApply.button_pressed:
		G.Sensivity = h_scroll_bar.value
	pass # Replace with function body.


func _on_spin_box_value_changed(value : float) -> void:
	h_scroll_bar.value = spin_box.value
	if %autoApply.button_pressed:
		G.Sensivity = spin_box.value
	pass # Replace with function body.


func _on_apply_sensitivity_button_down() -> void:
	h_scroll_bar.value = spin_box.value
	G.Sensivity = h_scroll_bar.value
	pass # Replace with function body.


func _on_auto_apply_pressed() -> void:
	if %autoApply.button_pressed:
		%applySensitivity.hide()
	else:
		%applySensitivity.show()

	pass # Replace with function body.


@onready var exclusive_fullscreen: CheckBox = $Screen/ExclusiveFullscreen
@onready var window_fullscreen: CheckBox = $Screen/WindowFullscreen
@onready var windowed: CheckBox = $Screen/Windowed


func _on_exclusive_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_window_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_windowed_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

var vsync : bool = true

func _on_vsync_pressed() -> void:
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	vsync = !vsync


func _on_spin_fps_value_changed(value: int) -> void:
	Engine.max_fps = value



@onready var volumeMaster := AudioServer.get_bus_index("Master")
@onready var spin_volume: SpinBox = %SpinVolume
@onready var h_scroll_volume: HScrollBar = %HScrollVolume

func _volume_value_changed(value: float) -> void:
	h_scroll_volume.value = value
	spin_volume.value = value
	AudioServer.set_bus_volume_db(volumeMaster,value)


func _on_test_sound_pressed() -> void:
	%AudioStreamPlayer.play()


func _on_exit_pressed() -> void:
	get_tree().quit()
