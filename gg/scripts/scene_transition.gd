extends Node
class_name SceneTransition

# Global SceneTransition script / manager static methods

static func change_scene_with_loading(
	tree: SceneTree,
	target_scene_path: String,
	target_spawn_pos: Vector2,
	use_custom_spawn: bool,
	walk_dir: Vector2 = Vector2.RIGHT,
	walk_dist: float = 36.0
) -> void:
	if GameState.is_transitioning:
		return
	
	GameState.is_transitioning = true
	GameState.target_spawn_pos = target_spawn_pos
	GameState.use_custom_spawn = use_custom_spawn
	GameState.spawn_walk_dir = walk_dir
	GameState.spawn_walk_dist = walk_dist

	# Instantiate the loading screen scene
	var loading_scene = preload("res://scenes/loading_screen.tscn").instantiate()
	tree.root.add_child(loading_scene)
	
	# Wait for fade-in
	await loading_scene.fade_in().finished

	# Change scene using threaded loader
	ResourceLoader.load_threaded_request(target_scene_path)
	
	var load_status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	var progress_array = []
	
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		load_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress_array)
		if progress_array.size() > 0:
			loading_scene.progress_bar.value = progress_array[0] * 100.0
		# Wait a short duration to yield the main thread so the UI updates
		await tree.create_timer(0.05).timeout

	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
		tree.change_scene_to_packed(new_scene)
	else:
		print("Failed to load scene: ", target_scene_path)
		tree.change_scene_to_file(target_scene_path) # Fallback

	loading_scene.progress_bar.value = 100.0
	await tree.create_timer(0.1).timeout # Brief pause at 100%

	# Wait 2 frames for node initialization
	await tree.process_frame
	await tree.process_frame

	# Setup player position and perform auto-step away forward
	var player = tree.get_first_node_in_group("player")
	if player:
		if use_custom_spawn:
			player.global_position = target_spawn_pos
		
		if player.has_method("perform_auto_walk") and walk_dist > 0.0:
			player.perform_auto_walk(walk_dir, walk_dist)

	# Hold loading screen briefly for visual smoothness
	await tree.create_timer(0.3).timeout

	# Wait for fade-out
	await loading_scene.fade_out().finished
	loading_scene.queue_free()
	
	# Transition complete — small grace timer before enabling new transitions
	await tree.create_timer(0.2).timeout
	GameState.is_transitioning = false
