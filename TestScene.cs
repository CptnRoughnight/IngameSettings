using Godot;
using System;

public partial class TestScene : Node3D
{
	private Label fpsLabel;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		fpsLabel = GetNode<Label>("CanvasLayer/Label");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		fpsLabel.Text = "FPS : " + Engine.GetFramesPerSecond().ToString();
	}

	public void _on_ingame_settings_resolution_changed(Vector2I newResolution)
	{
		GD.Print(newResolution.ToString());
	}

	public void _on_ingame_settings_fullscreen_chagned(bool fullscreen)
	{
		GD.Print("Fullscreen " + fullscreen.ToString());
	}

	public void _on_ingame_settings_fps_changed(int newFPS)
	{
		GD.Print("FPS changed " + newFPS.ToString());	
	}

	public void _on_ingame_settings_v_sync_changed(bool vsync)
	{
		GD.Print("Vsync " + vsync.ToString());
	}

	public void _on_ingame_settings_settings_changed()
	{
		OS.SetRestartOnExit(true);
		GetTree().Quit();
	}
}


