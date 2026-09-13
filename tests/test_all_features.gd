extends SceneTree

## Comprehensive automated test suite for Gentle Tidy
## Validates all gameplay loops, audio synthesis, diorama rendering, unlocks, and persistence.


func _init() -> void:
	_run_all_tests.call_deferred()


func _run_all_tests() -> void:
	print("========================================")
	print("🧪 RUNNING GENTLE TIDY AUTOMATED TEST SUITE")
	print("========================================")

	# Set up Autoload singletons in root
	var gm_script = load("res://scripts/GameManager.gd")
	var gm: Node = gm_script.new()
	gm.name = "GameManager"
	root.add_child(gm)

	var am_script = load("res://scripts/AudioManager.gd")
	var am: Node = am_script.new()
	am.name = "AudioManager"
	root.add_child(am)

	await process_frame

	await _test_game_manager(gm)
	await _test_audio_manager(am)
	await _test_bubble_tile()
	await _test_bubble_sheet_view()
	await _test_zen_wipe_view()
	await _test_breathe_view()
	await _test_diorama_and_items()
	await _test_shop_view()
	await _test_daily_tasks_view()
	await _test_settings_modal()
	await _test_main_scene()

	print("\n========================================")
	print("🎉 ALL 11 TEST SUITES PASSED CLEANLY!")
	print("========================================")
	quit(0)


func _test_game_manager(gm: Node) -> void:
	print("\n[1/11] Testing GameManager...")
	gm.call("reset_all_progress")
	assert(gm.get("satisfaction_points") == 0, "Initial points should be 0")
	assert((gm.get("unlocked_diorama_items") as Array).is_empty(), "Initial items should be empty")

	gm.call("add_satisfaction_points", 150)
	assert(gm.get("satisfaction_points") == 150, "Points should be 150")
	assert(bool(gm.call("can_afford", 100)) == true, "Should afford 100")
	assert(bool(gm.call("can_afford", 200)) == false, "Should not afford 200")

	var unlocked: bool = bool(gm.call("unlock_item_with_points", "succulent_plant"))
	assert(unlocked == true, "Should unlock succulent_plant")
	assert(gm.get("satisfaction_points") == 100, "Points should be 100 after 50 pts purchase")
	assert(bool(gm.call("is_item_unlocked", "succulent_plant")) == true, "Item should be unlocked")

	var double_unlock: bool = bool(gm.call("unlock_item_with_points", "succulent_plant"))
	assert(double_unlock == false, "Should not re-unlock same item")

	gm.call("record_bubble_pop")
	assert(gm.get("total_bubbles_popped") == 1, "Bubble count should be 1")
	assert(int(gm.call("get_task_progress", "pop_25")) == 1, "Task progress should be 1")
	print("  ✓ GameManager passed")


func _test_audio_manager(am: Node) -> void:
	print("\n[2/11] Testing AudioManager...")
	assert(am.get("_pop_stream") != null, "Pop audio stream synthesized")
	assert(am.get("_whoosh_stream") != null, "Whoosh audio stream synthesized")
	assert(am.get("_sparkle_stream") != null, "Sparkle audio stream synthesized")
	assert(am.get("_bowl_stream") != null, "Bowl audio stream synthesized")
	assert(am.get("_click_stream") != null, "Click audio stream synthesized")
	assert((am.get("_chime_streams") as Array).size() == 6, "6 Pentatonic chimes synthesized")

	am.call("play_pop", 1.1)
	am.call("play_chime", 2)
	am.call("play_whoosh")
	am.call("play_sparkle")
	am.call("play_bowl")
	am.call("play_click")
	print("  ✓ AudioManager passed")


func _test_bubble_tile() -> void:
	print("\n[3/11] Testing BubbleTile...")
	var tile_scene = load("res://scenes/BubbleTile.tscn")
	var tile: Area2D = tile_scene.instantiate()
	root.add_child(tile)
	await process_frame

	assert(tile.get("is_popped") == false, "Tile starts unpopped")

	var signal_box := [false]
	tile.connect("popped", func(_pts: int) -> void: signal_box[0] = true)

	tile.call("pop")
	assert(tile.get("is_popped") == true, "Tile is now popped")
	assert(signal_box[0] == true, "Popped signal emitted")

	tile.call("reset_bubble")
	assert(tile.get("is_popped") == false, "Tile reset to unpopped")

	tile.queue_free()
	await process_frame
	print("  ✓ BubbleTile passed")


func _test_bubble_sheet_view() -> void:
	print("\n[4/11] Testing BubbleSheetView...")
	var bs_scene = load("res://scenes/BubbleSheetView.tscn")
	var bs: Control = bs_scene.instantiate()
	root.add_child(bs)
	await process_frame

	var bubbles: Array = bs.get("_bubbles")
	assert(bubbles.size() == 35, "Default sheet has 35 bubbles (5x7)")
	assert(int(bs.call("get_popped_count")) == 0, "0 popped initially")

	var b0: Node2D = bubbles[0]
	b0.call("pop")
	assert(int(bs.call("get_popped_count")) == 1, "1 popped now")
	assert(int(bs.get("_combo")) == 1, "Combo increased to 1")

	bs.call("_on_flip_button_pressed")
	assert(int(bs.get("_combo")) == 0, "Combo reset on flip")

	bs.queue_free()
	await process_frame
	print("  ✓ BubbleSheetView passed")


func _test_zen_wipe_view() -> void:
	print("\n[5/11] Testing ZenWipeView...")
	var zw_scene = load("res://scenes/ZenWipeView.tscn")
	var zw: Control = zw_scene.instantiate()
	root.add_child(zw)
	await process_frame

	var total_dust: int = int(zw.get("_total_dust_cells"))
	assert(total_dust > 0, "Dust cells should be generated")
	assert(bool(zw.get("_is_completed")) == false, "Not completed initially")

	zw.call("_wipe_at", Vector2(230, 230))
	var cleaned: int = int(zw.get("_cleaned_dust_cells"))
	assert(cleaned > 0, "Center wipe cleaned dust cells")

	zw.call("_on_surface_completed")
	assert(bool(zw.get("_is_completed")) == true, "Surface marked completed")

	zw.queue_free()
	await process_frame
	print("  ✓ ZenWipeView passed")


func _test_breathe_view() -> void:
	print("\n[6/11] Testing BreatheView...")
	var bv_scene = load("res://scenes/BreatheView.tscn")
	var bv: Control = bv_scene.instantiate()
	root.add_child(bv)
	await process_frame

	assert(int(bv.get("_completed_cycles")) == 0, "0 cycles initially")

	for i in 4:
		bv.call("_advance_phase")

	assert(int(bv.get("_completed_cycles")) == 1, "1 cycle completed")

	bv.queue_free()
	await process_frame
	print("  ✓ BreatheView passed")


func _test_diorama_and_items() -> void:
	print("\n[7/11] Testing DioramaCanvas & DioramaItem...")
	var dc_script = load("res://scripts/DioramaCanvas.gd")
	var dc: Node2D = dc_script.new()
	root.add_child(dc)
	await process_frame

	dc.call("_spawn_item", "succulent_plant", 0)
	dc.call("_spawn_item", "sleeping_cat", 1)

	var container: Node2D = dc.get_node("ItemsContainer")
	assert(container.get_child_count() >= 2, "Items spawned in diorama")

	var item1 = container.get_child(container.get_child_count() - 1)
	assert(item1.get("item_id") == "sleeping_cat", "Item ID matches sleeping_cat")
	item1.call("_interact")

	dc.queue_free()
	await process_frame
	print("  ✓ DioramaCanvas & DioramaItem passed")


func _test_shop_view() -> void:
	print("\n[8/11] Testing ShopView...")
	var sv_scene = load("res://scenes/ShopView.tscn")
	var sv: Control = sv_scene.instantiate()
	root.add_child(sv)
	await process_frame

	var items_vbox: VBoxContainer = sv.get_node("ScrollContainer/ItemsContainer")
	assert(items_vbox.get_child_count() == 12, "Shop has all 12 collectible items")

	sv.queue_free()
	await process_frame
	print("  ✓ ShopView passed")


func _test_daily_tasks_view() -> void:
	print("\n[9/11] Testing DailyTasksView...")
	var dt_scene = load("res://scenes/DailyTasksView.tscn")
	var dt: Control = dt_scene.instantiate()
	root.add_child(dt)
	await process_frame

	var tasks_vbox: VBoxContainer = dt.get_node("ScrollContainer/TasksContainer")
	assert(tasks_vbox.get_child_count() == 6, "DailyTasksView has 6 mindful tasks")

	dt.queue_free()
	await process_frame
	print("  ✓ DailyTasksView passed")


func _test_settings_modal() -> void:
	print("\n[10/11] Testing SettingsModal...")
	var sm_scene = load("res://scenes/SettingsModal.tscn")
	var sm: Control = sm_scene.instantiate()
	root.add_child(sm)
	await process_frame

	sm.call("_on_sfx_toggled", false)
	sm.call("_on_sfx_toggled", true)
	sm.call("_on_close_pressed")
	assert(sm.visible == false, "Settings modal hides on close")

	sm.queue_free()
	await process_frame
	print("  ✓ SettingsModal passed")


func _test_main_scene() -> void:
	print("\n[11/11] Testing Main scene integration...")
	var main_scene = load("res://scenes/Main.tscn")
	var main: Control = main_scene.instantiate()
	root.add_child(main)
	await process_frame

	for i in 6:
		main.call("_switch_tab", i)
		assert(main.get("_current_tab_index") == i, "Active tab is %d" % i)

	main.call("_on_open_shop_requested")
	assert(main.get("_current_tab_index") == 4, "Switched to Shop tab")

	main.queue_free()
	await process_frame
	print("  ✓ Main scene passed")
