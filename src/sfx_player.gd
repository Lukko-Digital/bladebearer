extends Node
class_name SfxPlayer

# Music volumes in decibels
const music_off_db: float = -80.0
const music_on_db: float = -22

@export var music_players: Array[AudioStreamPlayer]

func _ready() -> void:
	Global.sfx_player = self
	
	for player in music_players:
		player.volume_db = music_off_db

	start_music()
	pick_music(false,false,true,0.5,-30)

	transition_volume_db("Nature_Ambience", -80, 0)

## [audio_player_name] must exactly match the name of a child
## [AudioStreamPlayer] or [AudioStreamPlayer3D] node.
func play(audio_player_name: String):
	get_node(audio_player_name).stop()
	get_node(audio_player_name).play()

func stop(audio_player_name: String):
	get_node(audio_player_name).stop()

func play_timed(audio_player_name: String, delay: float):
	await get_tree().create_timer(delay).timeout
	get_node(audio_player_name).stop()
	get_node(audio_player_name).play()

func transition_volume_db(audio_player_name: String, target_db: float, tween_duration: float = 1):
	if !get_node(audio_player_name): return
	var audio_player: AudioStreamPlayer = get_node(audio_player_name)
	var volume_db_tween = create_tween()
	volume_db_tween.tween_property(audio_player, "volume_db", target_db, tween_duration)
	print(audio_player, target_db)

func pick_music(calm: bool, fight: bool, bass: bool, dur: float = 5, on_vol: float = music_on_db):

	var calm_vol: float = on_vol if calm else music_off_db
	var fight_vol: float = on_vol if fight else music_off_db
	var bass_vol: float = on_vol if bass else music_off_db
	
	transition_volume_db("Music_Calm", calm_vol, dur)
	transition_volume_db("Music_Fight", fight_vol, dur)
	transition_volume_db("Music_BassOnly", bass_vol, dur)

func start_music():
	for music_player in music_players:
		music_player.play()