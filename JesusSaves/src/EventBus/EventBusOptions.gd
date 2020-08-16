extends Node

# Options Screens
signal show_screen(value)
signal toggle_options(value)

# Video Signals
signal video_toggle_fullscreen(value)
signal video_toggle_borderless(value)
signal video_scale_up()
signal video_scale_down()

# Sound Signals
signal sound_change_master(value)
signal sound_change_music(value)
signal sound_change_sfx(value)

# Control Signals
signal control_add_action(key, value)
signal control_remove_action(key, value)
