extends Node

var file: File
var thread: Thread
var mutex: Mutex
var semaphore: Semaphore
var resource: String
var exit_thread: bool = false

# Extra info passed along loading request
var props: Dictionary = {}

func _ready() -> void:
	EventBus.connect("game_scene_loaded", self, "_on_game_scene_loaded")

	# Doesn't work on HTML5
	if Settings.html_mode:
		return

	file = File.new()
	thread = Thread.new()
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread.start(self, "thread_func")

func load_scene(path, instruction)->void:
	mutex.lock()
	if !file_check(path):
		print("File does not exist: " + path)
		return
	mutex.unlock()

	mutex.lock()
	props[path] = instruction
	resource = path
	mutex.unlock()

	semaphore.post()

func file_check(path: String) -> bool:
	var result = false
	mutex.lock()
	result = file.file_exists(path)
	mutex.unlock()

	return result

func thread_func(_o = null) -> void:
	# Trap the function
	while true:
		# Start the work when semaphote.post()
		semaphore.wait()

		mutex.lock()

		# Protect with Mutex
		var should_exit = exit_thread

		if should_exit:
			break

		mutex.unlock()

		# Didn't feel like to do separate lock
		mutex.lock()

		var scene = load(resource)
		call_deferred("emit_signal", "scene_loaded", {resource=scene, instructions = props[resource]})
		mutex.unlock()

# even autoloaded script needs to do this or bricks on quiting
func _exit_tree() -> void:
	if !Settings.html_mode:
		mutex.lock()
		#this is checked in thread
		exit_thread = true
		mutex.unlock()

		# give last resume to the function to see it neads to break
		semaphore.post()

		# sync the threads
		thread.wait_to_finish()
