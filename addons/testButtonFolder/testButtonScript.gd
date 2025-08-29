# MyEditorPlugin.gd
@tool
extends EditorPlugin

var my_button: Button

func _enter_tree():
	my_button = Button.new()
	my_button.text = "Кноп"
	my_button.pressed.connect(_on_my_button_pressed)
	
	# Этот метод гарантированно работает, но размещает кнопку в конце.
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, my_button)

func _exit_tree():
	if is_instance_valid(my_button):
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, my_button)
		my_button.queue_free()

func _on_my_button_pressed():
	print("Нажата моя кнопка!")
