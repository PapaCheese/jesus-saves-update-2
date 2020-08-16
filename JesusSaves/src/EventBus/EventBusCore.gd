extends Node

# GUI Events
signal gui_toggle_main_menu(value)
signal gui_toggle_options_menu(value)
signal gui_toggle_options_main(value)
signal gui_toggle_options_i18n(value)
signal gui_toggle_options_controls(value)

# Game Events
signal game_new_game()
signal game_pause()
signal game_paused()
signal game_resume()
signal game_resumed()
signal game_restart()
signal game_exit()

signal game_show_locales(value)

signal game_scene_is_loaded()
signal game_select_scene(scene)
signal game_change_scene()
signal game_scene_loaded()
signal game_main_menu(value)
#signal game_new_game()
signal game_continue()
#signal game_resume()
#signal game_restart()
signal game_restart_scene()
signal game_options(value)
#signal game_paused(value)
signal game_controls()
signal game_languages()
#signal game_exit()
signal game_refocus()
signal game_window_resized()
signal game_reload_i18n()
signal game_select_locale(locale)
signal new_scroll_container_button()

# Settings Events
signal settings_change_setting(key, value)
signal settings()
signal settings_create_input_binding(input_event)

#signal ChangeScene()
#signal MainMenu()
#signal NewGame()
#signal Continue()
#signal Resume()
#signal Restart()
#signal Options()
#signal Controls()
#signal Languages()
#signal Paused()
#signal Exit()
#signal Refocus()

# General Events
signal toggle_main_menu()
signal quit_game()
signal pause_game()
signal resume_game()
signal save_game(state, slot)
signal load_game(slot)

# Player Events
signal player_respawn()
signal player_change_facing(direction)
signal player_animation(animation)
signal player_gain_skill(skill_number)
signal player_select_skill(skill_number)
signal player_gain_spell_damage(points)
signal player_gain_points(points)
signal player_loot_energy()
signal player_get_weapon(weapon)
signal player_damaged(damage)
signal player_attack()

# Enemy Events
signal enemy_damaged(body, damage)
