extends Area2D

signal enemy_killed

var direction = Vector2()
var screensize 
var follow = false
var distance
var speed = 0
var swarm = false
var enemySpeedMin = 50
var enemySpeedMax = 75
var enemyTimerMin = 5
var enemyTimerMax = 25

onready var player = get_node("/root/main/player")

func _ready():
    # Initiate Randomization
    randomize()
    # Init variables
    # get Screensize 
    screensize = screensize = get_viewport_rect().size
    # set speed between Min & Max values
    speed = rand_range(enemySpeedMin ,enemySpeedMax)
    # init AI variables 
    follow = false
    swarm = 0
    # setup Tween to shrink enemy when killed
    $effect.interpolate_property(self, "scale", self.get_scale(),Vector2(.3,.3),0.3,Tween.TRANS_QUAD,Tween.EASE_OUT)
    # set Enemy live time between Min & Max values
    $enemyTimer.wait_time = (rand_range(enemyTimerMin ,enemyTimerMax))
    # Start Enemy Life Timer
    $enemyTimer.start()

func _process(delta):   
    # AI rules
    # get direction / distance of player
    direction = player.position - self.position
    # Determine whether to flip enemy image to face player
    if direction.x > 0:
        # Set Enemy facing right
        self.get_node("enemy").set_flip_h(1)
    else:
        # Set Enemy facing left
        self.get_node("enemy").set_flip_h(0)
    # calculate distance from player
    distance = sqrt(direction.x * direction.x + direction.y * direction.y)
    #print(dist) # uncomment this to see distance from player
    # If distance less than 200 then start Enemy following player
    if distance < 200:
        follow = true
    else:
        follow = false
    # Move Enemy towards player if follow is true or swarm is true
    if follow == true or swarm > 100:   
        # increment swarm while enemy following
        swarm += 1
        #print(swarm) # uncomment this to check swarm 
        position += direction.normalized() * speed * delta
        position.x = clamp(position.x, 0, screensize.x)
        position.y = clamp(position.y, 0 , screensize.y)

func _on_enemy_area_enter( area ):
    #print(area.get_name()) # uncomment this to print name of area entering enemy collision2d
    if area.get_name()=="player":
        # limit collision to single time
        call_deferred("set_monitoring", false)
        # check if Tween active and if not activate it
        if not $effect.is_active():
            $effect.start()
        # emit a signal when enemy killed
        emit_signal("enemy_killed")

func _on_effect_tween_completed( object, key ):
    # remove enemy from memory after Tween finishes (enemy shrinks when killed)
    queue_free()

func _on_enemytimer_timeout():
    # if enemy time to live runs out activate Tween (enemy shrinks)
    if not $effect.is_active():
        $effect.start()

func _on_VisibilityNotifier2D_screen_exited():
    # if enemy goes outside of screen (shouldn't happen) then remove from memory
    queue_free()