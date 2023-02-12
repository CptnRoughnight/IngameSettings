extends Control

################################################################################# EXPORTS

@export_node_path("WorldEnvironment") var worldEnvironmentPath
@export var HighResEnvResource : String
@export var LowResEnvResource : String
@export_node_path("Camera3D") var mainCameraPath
@export_node_path("DirectionalLight3D") var mainDirectionalLightPath



################################################################################# NODES

@onready var tabbar = $MarginContainer/VBoxContainer2/VBoxContainer/SettingsCategory
@onready var buttonBox = %ButtonBox


# VIDEO SETTINGS
@onready var VideoSettingsPanel = %VideoSettingsPanel
@onready var LblAspect = %LblAspect
@onready var OBtnAspect = %OBtnAspect

@onready var LblResolution = %LblResolution
@onready var OBtnResolution = %OBtnResolution

@onready var CbFullscreen = %CbFullscreen

@onready var fpsValue = %FPSValue

@onready var CbVSync = %CbVSync

# AUDIO SETTINGS
@onready var AudioSettingsPanel = %AudioSettingsPanel
@onready var HSMasterVolume = %HSMasterVolume as HSlider

# NETWORK SETTINGS
@onready var NetworkSettingsPanel = %NetworkSettingsPanel
@onready var LEPort = %LEPort

# QUALITY SETTINGS
@onready var QualitySettingsPanel = %QualitySettingsPanel

@onready var OBtnQualityPreset = %ObtnQualityPreset

@onready var CbAmbientOcclusion = %CbAmbientOcclusion
@onready var CbIndirectLighting = %CbIndirectLighting
@onready var CbGlobalIllumination = %CbGlobalIllumination
@onready var LEViewDistance = %LEViewDistance
@onready var CbShadows = %CbShadows
@onready var LEShadowDistance = %LEShadowDistance
@onready var OBtnMsaa = %OBtnMsaa



################################################################################# ENUMS
enum SettingsCategory
{
	VIDEO=0,
	AUDIO=1,
	NETWORK=2,
	PHYSICS=3
}

const AspectRatios = ["RATIO4_3","RATIO16_9"]
enum AspectRatiosENUM
{
	RATIO4_3=0,
	RATIO16_9=1
}


########################################################################################

############################################################################ VIDEO MODES

var Resolutions4_3 = ["160x120","256x192","320x240","384x288","400x300","512x384",
					"640x480","800x600","960x720","1024x768","1152x864","1280x960",
					"1440x1080","1600x1200","1856x1392","1920x1440","2048x1536",
					"2560x1920","2800x2100","3200x2400","4096x3072"]

var Resolutions16_9 = ["240x136","480x272","640x360","848x480","960x540","1024x600",
					"1136x640","1152x648","1280x720","1366x768","1600x900","1920x1080",
					"2048x1152","2560x1440","3200x1800","4096x2304","4480x2520","5120x2880"]

var vRes4_3 = [ Vector2i(160,120),Vector2i(256,192),Vector2i(320,240),Vector2i(384,288),
				Vector2i(400,300),Vector2i(512,384),Vector2i(640,480),Vector2i(800,600),
				Vector2i(960,720),Vector2i(1024,768),Vector2i(1152,864),Vector2i(1280,960),
				Vector2i(1440,1080),Vector2i(1600,1200),Vector2i(1856,1392),Vector2i(1920,1440),
				Vector2i(2048,1536),Vector2i(2560,1920),Vector2i(2800,2100),Vector2i(3200,2400),
				Vector2i(4096,3072)]

var vRes16_9 = [ Vector2i(240,136),Vector2i(480,272),Vector2i(640,360),Vector2i(848,480),Vector2i(960,540),
				Vector2i(1024,600),Vector2i(1136,640),Vector2i(1152,648),Vector2i(1280,720),Vector2i(1366,768),
				Vector2i(1600,900),Vector2i(1920,1080),Vector2i(2048,1152),Vector2i(2560,1440),Vector2i(3200,1800),
				Vector2i(4096,2304),Vector2i(4480,2520),Vector2i(5120,2880)]


var selectedModeIndex = 0
var selectedAspectIndex = 0
var selectedfullscreen = false
var selectedVSync = true
var selectedFPS = 60



########################################################################################

################################################################################ SIGNALS

signal ResolutionChanged(newRes:Vector2i)
signal FullscreenChagned(fullscreen:bool)
signal VSyncChanged(vsync:bool)
signal FPSChanged(fps:int)

signal WorldEnvironmentChanged

signal SettingsChanged

signal AudioMasterVolumeChanged(newVal:int)

signal NetworkPortChanged(newPort : int)

########################################################################################

var hasSettingChanged : bool = false
var isCustomEnvironment : bool = false

var currentCategoryActive = SettingsCategory.VIDEO

# VIDEO SETTINGS
var currentViewport

# AUDIO SETTINGS
var masterVolume : int = 50

# NETWORK SETTINGS
var networkPort : int = 1337

# exports - vars
var worldEnvironment : WorldEnvironment
var customWorldEnvironment : Environment

var mainCamera : Camera3D
var directionalLight : DirectionalLight3D

func _ready():
	InitVideoSettings()
	buttonBox.visible = false
	
	if !worldEnvironmentPath.is_empty():
		worldEnvironment = get_node(worldEnvironmentPath)
		
	if !mainCameraPath.is_empty():
		mainCamera = get_node(mainCameraPath)
		
	if !mainDirectionalLightPath.is_empty():
		directionalLight = get_node(mainDirectionalLightPath)
	
	HSMasterVolume.value = masterVolume
	LEPort.text = str(networkPort)

func UpdateSettingsTab():
	match currentCategoryActive:
		"VIDEO":
			VideoSettingsPanel.visible = true
			AudioSettingsPanel.visible = false
			NetworkSettingsPanel.visible = false
			QualitySettingsPanel.visible = false
		"AUDIO":
			VideoSettingsPanel.visible = false
			AudioSettingsPanel.visible = true
			NetworkSettingsPanel.visible = false
			QualitySettingsPanel.visible = false
		"NETWORK":
			VideoSettingsPanel.visible = false
			AudioSettingsPanel.visible = false
			NetworkSettingsPanel.visible = true
			QualitySettingsPanel.visible = false
		"PHYSICS":
			VideoSettingsPanel.visible = false
			AudioSettingsPanel.visible = false
			NetworkSettingsPanel.visible = false
			QualitySettingsPanel.visible = true


func InitVideoSettings():
	# TODO: get the current Resolution and Aspect Ratio
	currentViewport = Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"),
							ProjectSettings.get_setting("display/window/size/viewport_height"))
	# Fullscreen Mode ist 3!
	if (ProjectSettings.get_setting("display/window/size/mode")==3):
		selectedfullscreen = true
		CbFullscreen.button_pressed = true
	else:
		selectedfullscreen = false
		CbFullscreen.button_pressed = false
		
	print(ProjectSettings.get_setting("application/run/max_fps"))
	fpsValue.text = str(ProjectSettings.get_setting("application/run/max_fps"))
	
	if (ProjectSettings.get_setting("display/window/vsync/vsync_mode")!=0):
		CbVSync.button_pressed = true
	else:
		CbVSync.button_pressed = false
		
		
	var foundRes : bool = false

	OBtnAspect.clear()
	OBtnAspect.add_item("4:3")
	OBtnAspect.add_item("16:9")

	for i in range(vRes16_9.size()):
		if vRes16_9[i]==currentViewport:
			foundRes = true
			OBtnAspect.select(1)
			selectedAspectIndex = 1
			UpdateResolutions()
			OBtnResolution.select(i)
			selectedModeIndex = i
			print("found 16x9")

	if foundRes==false:
		for i in range(vRes4_3.size()):
			if vRes16_9[i]==currentViewport:
				OBtnAspect.select(0)
				selectedAspectIndex = 0
				UpdateResolutions()
				OBtnResolution.select(i)
				selectedModeIndex = i
				print("found 4x3")
				
	OBtnMsaa.add_item("disabled")
	OBtnMsaa.add_item("2x")
	OBtnMsaa.add_item("4x")
	OBtnMsaa.add_item("8x")
		#rendering/anti_aliasing/quality/msaa_3d
	OBtnMsaa.select(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d"))


	OBtnQualityPreset.add_item("High")
	OBtnQualityPreset.add_item("Low")
	OBtnQualityPreset.add_item("Custom")
	
	MakeQualityCustomInactive()
	
	
	

func UpdateResolutions():
	OBtnResolution.clear()
	match selectedAspectIndex:
		AspectRatiosENUM.RATIO4_3:
			for i in range(Resolutions4_3.size()):
				OBtnResolution.add_item(Resolutions4_3[i])
		AspectRatiosENUM.RATIO16_9:
			for i in range(Resolutions16_9.size()):
				OBtnResolution.add_item(Resolutions16_9[i])


func _on_settings_category_tab_changed(tab):
	currentCategoryActive = SettingsCategory.keys()[tab]
	print(currentCategoryActive)
	UpdateSettingsTab()



func _on_aspect_options_item_selected(index):
	selectedAspectIndex = index
	UpdateResolutions()


func _on_resolution_options_item_selected(index):
	selectedModeIndex = index
	on_Setting_Changed()



func on_Setting_Changed():
	hasSettingChanged = true
	buttonBox.visible = true


func _on_apply_changes_pressed():
	# get values 
	selectedFPS = int(fpsValue.text)
	selectedfullscreen = CbFullscreen.button_pressed
	selectedVSync = CbVSync.button_pressed
	


	if selectedAspectIndex==0:
		emit_signal("ResolutionChanged",vRes4_3[selectedModeIndex])
	else:
		emit_signal("ResolutionChanged",vRes16_9[selectedModeIndex])

	emit_signal("FullscreenChagned",selectedfullscreen)
	emit_signal("VSyncChanged",selectedVSync)
	emit_signal("FPSChanged",selectedFPS)
	
	applyChanges()
	
	emit_signal("SettingsChanged")
	
	
func applyChanges():
	# Video Settings
	if selectedAspectIndex==0:
		ProjectSettings.set_setting("display/window/size/viewport_width",vRes4_3[selectedModeIndex].x);
		ProjectSettings.set_setting("display/window/size/viewport_height",vRes4_3[selectedModeIndex].y);
	else:
		ProjectSettings.set_setting("display/window/size/viewport_width",vRes16_9[selectedModeIndex].x);
		ProjectSettings.set_setting("display/window/size/viewport_height",vRes16_9[selectedModeIndex].y);
	
	if selectedfullscreen:
		ProjectSettings.set_setting("display/window/size/mode",3)
	else:
		ProjectSettings.set_setting("display/window/size/mode",0)
	
	if selectedVSync:
		ProjectSettings.set_setting("display/window/vsync/vsync_mode",2)	# adaptive
	else:
		ProjectSettings.set_setting("display/window/vsync/vsync_mode",0)	# disabled
		
	ProjectSettings.set_setting("application/run/max_fps",selectedFPS)
	ProjectSettings.save()
	
	
	
func _on_discard_changes_pressed():
	pass # Replace with function body.


func _on_cb_fullscreen_toggled(button_pressed):
	selectedfullscreen=button_pressed
	on_Setting_Changed()


func _on_cb_v_sync_toggled(button_pressed):
	selectedVSync = button_pressed
	on_Setting_Changed()


func _on_fps_value_text_changed(_new_text):
	on_Setting_Changed()


func _on_obtn_quality_preset_item_selected(index):
	#on_Setting_Changed()
	if index == 2:	# custom
		MakeQualityCustomActive()
	else:
		MakeQualityCustomInactive()
		if worldEnvironment!=null:
			if index==0 && HighResEnvResource!=null:
				worldEnvironment.set_environment(load(HighResEnvResource))
				emit_signal("WorldEnvironmentChanged")
			elif index==1 && LowResEnvResource!=null:
				worldEnvironment.set_environment(load(LowResEnvResource))
				emit_signal("WorldEnvironmentChanged")



func MakeQualityCustomActive():
	CbAmbientOcclusion.disabled = false
	CbIndirectLighting.disabled = false
	CbGlobalIllumination.disabled = false
	LEViewDistance.editable = true
	CbShadows.disabled = false
	LEShadowDistance.editable = true
	isCustomEnvironment = true
	
	customWorldEnvironment = worldEnvironment.environment.duplicate()
	worldEnvironment.environment=customWorldEnvironment
	
	# Get the Values
	CbAmbientOcclusion.button_pressed = worldEnvironment.environment.ssao_enabled
	CbIndirectLighting.button_pressed = worldEnvironment.environment.ssil_enabled
	CbGlobalIllumination.button_pressed = worldEnvironment.environment.sdfgi_enabled
	LEViewDistance.text = str(mainCamera.far)
	CbShadows.button_pressed = directionalLight.shadow_enabled
	LEShadowDistance.text = str(directionalLight.directional_shadow_max_distance)
	
	
	
func MakeQualityCustomInactive():
	CbAmbientOcclusion.disabled = true
	CbIndirectLighting.disabled = true
	CbGlobalIllumination.disabled = true
	LEViewDistance.editable = false
	CbShadows.disabled = true
	LEShadowDistance.editable = false
	isCustomEnvironment = false
	

func _on_cb_ambient_occlusion_toggled(button_pressed):
	if !isCustomEnvironment:
		return
		
	worldEnvironment.environment.ssao_enabled = button_pressed



func _on_cb_indirect_lighting_toggled(button_pressed):
	if !isCustomEnvironment:
		return
		
	worldEnvironment.environment.ssil_enabled = button_pressed
	
	

func _on_cb_global_illumination_toggled(button_pressed):
	if !isCustomEnvironment:
		return
		
	worldEnvironment.environment.sdfgi_enabled = button_pressed
	
	

func _on_le_view_distance_text_changed(new_text):
	if !isCustomEnvironment:
		return
		
	if mainCamera==null:
		return
		
	mainCamera.far = int(new_text)
		
	

func _on_cb_shadows_toggled(button_pressed):
	if !isCustomEnvironment:
		return
	if directionalLight==null:
		return
		
	directionalLight.shadow_enabled = button_pressed
	

func _on_le_shadow_distance_text_changed(new_text):
	if !isCustomEnvironment:
		return
	if directionalLight==null:
		return
	
	directionalLight.directional_shadow_max_distance = int(new_text)


func _on_o_btn_msaa_item_selected(index):
	on_Setting_Changed()
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",index)


func _on_hs_master_volume_drag_ended(value_changed):
	emit_signal("AudioMasterVolumeChanged",value_changed)


func setMasterVolume(value):
	HSMasterVolume.value = value
	masterVolume = value


func _on_le_port_text_changed(new_text):
	emit_signal("NetworkPortChanged",int(new_text))
	networkPort = int(new_text)
