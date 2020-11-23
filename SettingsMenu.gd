extends CanvasLayer

signal resolution_changed

onready var items = $MarginContainer/HBoxContainer/HBoxContainer3/ScrollContainer/VBoxContainer

export var Active : bool = false
export var showFPS : bool = false

# General Menu

# Video Menu
var video_menu_items = {
	"Resolution" : 0,
	"Fullscreen" : 1,
	"VSync" : 2,
	"Stretch Mode" : 3,
	"Stretch Aspect" : 4,
}

var stretch_mode = {
	"Disabled" : 0,
	"2D" : 1,
	"Viewport" : 2
}

var stretch_aspect = {
	"Ignore" : 0,
	"Keep" : 1,
	"Keep Width" : 2,
	"Keep Height" : 3,
	"Expand" : 4
}

export var resolution = [
	Vector2(320,240),
	Vector2(640,480),
	Vector2(800,600),
	Vector2(1024,768),
	Vector2(1280,1024),
	Vector2(1600,1200),
	Vector2(1920,1080)
]

# current setup

var _cur_fullscreen
var _cur_stretchmode
var _cur_stretchaspect
var _cur_resolution

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_F10:
			Active = false if Active else true
			if Active:
				$MarginContainer.visible=true
				if showFPS:
					set_process(true)				
			else:
				$MarginContainer.visible=false
				if !showFPS:
					set_process(false)

		
func _showFPS() -> void:
	showFPS = true
	$FPS.visible = true
	set_process(true)

func _hideFPS() -> void:
	showFPS = false
	$FPS.visible = false
	set_process(false)
	
func toggleFPS() -> void:
	showFPS = false if showFPS else true
	if showFPS:
		_showFPS()
	else:
		_hideFPS()
		
func _ready():
	if (!showFPS):
		$FPS.visible = false
		set_process(false)
	else:
		$FPS.visible = true
		set_process(true)
		 
	_cur_fullscreen = OS.window_fullscreen
	_cur_stretchaspect = 0
	_cur_stretchmode = 0
	
	$MarginContainer.visible=false
	for i in range(0,100):
		var op = OptionButton.new()
		op.text = "Test"+str(i)
		op.connect("button_down",self,"_on_general_button_down",[op])
		items.add_child(op)

func _process(_delta):
	print("hey")
	$FPS.text = "FPS : " + str(Engine.get_frames_per_second())
	
func _on_General_pressed() -> void:
	clearItems()
	
func _on_Video_pressed() -> void:
	clearItems()
	for i in video_menu_items:
		if i=="Resolution":
			var b = OptionButton.new()
			b.text = i
			b.connect("item_selected",self,"_on_resolution_changed")
			for res in resolution:
				b.add_item(str(res))
			items.add_child(b)
		elif i=="Fullscreen":
			var b = CheckButton.new()
			b.text = i
			b.pressed = OS.window_fullscreen
			b.connect("toggled",self,"_on_fullscreen_toggled");
			items.add_child(b)
		elif i=="VSync":
			var b = CheckButton.new()
			b.text = i
			b.pressed = OS.vsync_enabled
			b.connect("toggled",self,"_on_vsync_toggled");
			items.add_child(b)
		elif i=="Stretch Mode" :
			var b = OptionButton.new()
			b.text = i
			b.connect("item_selected",self,"_on_stretch_mode_changed")
			for res in stretch_mode:
				b.add_item(str(res))
			items.add_child(b)
		elif i=="Stretch Aspect" :
			var b = OptionButton.new()
			b.text = i
			b.connect("item_selected",self,"_on_stretch_aspect_changed")
			for res in stretch_aspect:
				b.add_item(str(res))
			items.add_child(b)
			
func clearItems() -> void:
	for n in items.get_children():
		n.queue_free()

func _on_general_button_down(n : Node) -> void:
	print("What the Fuck" + str(n));

func _on_video_button_down(value) -> void:
	print("Video " + str(value));

func _on_resolution_changed(index) -> void:
	if (OS.window_fullscreen):
		get_tree().set_screen_stretch(2,0,resolution[index])
	else:	
		OS.set_window_size(resolution[index])
		get_tree().set_screen_stretch(2,0,resolution[index])
		get_tree().get_root().get_viewport().set_size_override(true,resolution[index],Vector2(0,0))

	emit_signal("resolution_changed",[resolution[index]])

func _on_fullscreen_toggled(pressed) -> void:
	OS.window_fullscreen = pressed

func _on_vsync_toggled(pressed) -> void:
	OS.vsync_enabled = pressed
	
func _on_stretch_mode_changed(index) -> void:
	_cur_stretchmode = index
	get_tree().set_screen_stretch(index,_cur_stretchaspect,resolution[index])

func _on_stretch_aspect_changed(index) -> void:
	_cur_stretchaspect = index
	get_tree().set_screen_stretch(_cur_stretchmode,index,resolution[index])
	



# helper funcs
#func _get_nearest_resolution() -> int :
#	var diffx=9999
#	var diffy=9999
#	for res in resolution:
#		if ()
	

# User Overrides
func set_Resolution_List(resList) -> void:
	resolution = resList
