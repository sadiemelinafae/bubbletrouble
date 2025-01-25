extends Node

@export var me: Enemy;

@export var particle_effects: Array[GPUParticles3D]

@export var death_particles: GPUParticles3D;

var _time_since_death: float = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	me.on_hit.connect(_on_hit);

func _on_hit() -> void:
	if me.state != Enemy.State.DEAD:
		if me.hit_points == 0:
			_time_since_death = 0;
			_start_death();

func _start_death() -> void:
	# Actually start death
	me.state = Enemy.State.DEAD;
	me.on_die.emit();
	
	# Stop moving
	me.move_stop();
	
	for effect in particle_effects:
		effect.emitting = false;
	
	# Allow other enemies and players to move through us
	# We will still collide with the floor though!
	me.set_collision_layer_value(1, false);
	
	death_particles.emitting = true;
	
	while _time_since_death < 0.4:
		await get_tree().process_frame;
	
	death_particles.emitting = false;
	
	# hide mesh
	me.model.visible = false;

func _process(delta: float) -> void:
	if GameState.shouldRunPhysics():
		death_particles.process_mode = Node.PROCESS_MODE_ALWAYS;
	else:
		death_particles.process_mode = Node.PROCESS_MODE_DISABLED;
		return;
	
	_time_since_death += delta;
