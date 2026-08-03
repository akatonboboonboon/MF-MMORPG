class_name FsATuning
extends Resource

const AUTHORITY_FS_PROVISIONAL := &"fs_provisional"

@export var authority_label: StringName = AUTHORITY_FS_PROVISIONAL

@export_group("Player")
@export_range(1, 10000, 1) var player_integrity_max: int
@export var player_start_position: Vector2
@export var player_start_aim: Vector2

@export_group("Light Attack")
@export_range(0.0, 5.0, 0.01) var light_windup_seconds: float
@export_range(0.001, 5.0, 0.01) var light_active_seconds: float
@export_range(0.0, 5.0, 0.01) var light_recovery_seconds: float
@export_range(0, 10000, 1) var light_body_damage: int
@export_range(0, 10000, 1) var light_part_damage: int
@export_range(1.0, 2000.0, 1.0) var light_reach: float
@export_range(1.0, 179.0, 1.0) var light_half_angle_degrees: float

@export_group("Heavy Attack")
@export_range(0.0, 5.0, 0.01) var heavy_windup_seconds: float
@export_range(0.001, 5.0, 0.01) var heavy_active_seconds: float
@export_range(0.0, 5.0, 0.01) var heavy_recovery_seconds: float
@export_range(0, 10000, 1) var heavy_body_damage: int
@export_range(0, 10000, 1) var heavy_part_damage: int
@export_range(1.0, 2000.0, 1.0) var heavy_reach: float
@export_range(1.0, 179.0, 1.0) var heavy_half_angle_degrees: float

@export_group("Boss And Part")
@export_range(1, 100000, 1) var boss_hp_max: int
@export_range(1, 100000, 1) var part_hp_max: int
@export_range(0.0, 1.0, 0.01) var part_hit_body_damage_ratio: float
@export var boss_position: Vector2
@export var part_offset: Vector2
@export_range(1.0, 1000.0, 1.0) var boss_target_radius: float
@export_range(1.0, 1000.0, 1.0) var part_target_radius: float

@export_group("Enemy Line Telegraph")
@export_range(0.0, 10.0, 0.01) var enemy_initial_cooldown_seconds: float
@export_range(0.001, 10.0, 0.01) var line_telegraph_seconds: float
@export_range(0.001, 5.0, 0.01) var line_active_seconds: float
@export_range(0.0, 10.0, 0.01) var line_recovery_seconds: float
@export_range(0.0, 10.0, 0.01) var line_cooldown_seconds: float
@export_range(0, 10000, 1) var line_integrity_damage: int
@export_range(0.0, 10000.0, 0.1) var line_deformation: float
@export_range(1.0, 3000.0, 1.0) var line_range: float
@export_range(1.0, 1000.0, 1.0) var line_half_width: float

@export_group("Enemy Sector Telegraph")
@export_range(0.001, 10.0, 0.01) var sector_telegraph_seconds: float
@export_range(0.001, 5.0, 0.01) var sector_active_seconds: float
@export_range(0.0, 10.0, 0.01) var sector_recovery_seconds: float
@export_range(0.0, 10.0, 0.01) var sector_cooldown_seconds: float
@export_range(0, 10000, 1) var sector_integrity_damage: int
@export_range(0.0, 10000.0, 0.1) var sector_deformation: float
@export_range(1.0, 3000.0, 1.0) var sector_range: float
@export_range(1.0, 179.0, 1.0) var sector_half_angle_degrees: float

@export_group("Harvest And Result")
@export var harvest_offset_a: Vector2
@export var harvest_offset_b: Vector2
@export var harvest_offset_c: Vector2
@export_range(1.0, 1000.0, 1.0) var harvest_interaction_range: float
@export_range(0.0, 10.0, 0.01) var result_delay_seconds: float
@export var reward_id: StringName
@export_range(0, 10000, 1) var reward_per_harvest_point: int


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if authority_label != AUTHORITY_FS_PROVISIONAL:
		errors.append("authority_label must remain fs_provisional")
	if player_integrity_max <= 0:
		errors.append("player_integrity_max must be positive")
	if boss_hp_max <= 0 or part_hp_max <= 0:
		errors.append("boss and part HP must be positive")
	if not _valid_timing(light_windup_seconds, light_active_seconds, light_recovery_seconds):
		errors.append("light action timing is invalid")
	if not _valid_timing(heavy_windup_seconds, heavy_active_seconds, heavy_recovery_seconds):
		errors.append("heavy action timing is invalid")
	if not _valid_timing(line_telegraph_seconds, line_active_seconds, line_recovery_seconds):
		errors.append("line attack timing is invalid")
	if not _valid_timing(sector_telegraph_seconds, sector_active_seconds, sector_recovery_seconds):
		errors.append("sector attack timing is invalid")
	if part_hit_body_damage_ratio < 0.0 or part_hit_body_damage_ratio > 1.0:
		errors.append("part_hit_body_damage_ratio must be within 0..1")
	if player_start_aim.length_squared() <= 0.0001:
		errors.append("player_start_aim must be non-zero")
	if reward_id.is_empty() or reward_per_harvest_point <= 0:
		errors.append("harvest reward must be positive and identified")
	return errors


func harvest_offsets() -> Array[Vector2]:
	return [harvest_offset_a, harvest_offset_b, harvest_offset_c]


func _valid_timing(windup: float, active: float, recovery: float) -> bool:
	return (
		is_finite(windup)
		and is_finite(active)
		and is_finite(recovery)
		and windup >= 0.0
		and active > 0.0
		and recovery >= 0.0
	)
