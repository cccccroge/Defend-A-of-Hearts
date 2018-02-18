extends Node

onready var stream_player_1 = get_node("Stream_player_1")
onready var stream_player_2 = get_node("Stream_player_2")
onready var tween = get_node("Tween")


func _ready():
	stream_player_1.set_volume(0.6)
	stream_player_2.set_volume(0.6)


func play(song_path):
	stream_player_1.set_volume(0.6)
	stream_player_2.set_volume(0.6)
	var audio_stream = load(song_path)
	if !stream_player_1.is_playing():
		stream_player_1.set_stream(audio_stream)
		#stream_player_1.set_volume(0.6)
		stream_player_1.play()
	else:
		stream_player_2.set_stream(audio_stream)
		#stream_player_2.set_volume(0.6)
		stream_player_2.play()


func fade_out(sec):
	if stream_player_1.is_playing():
		tween.interpolate_property(stream_player_1, "stream/volume_db", stream_player_1.get_volume(),
		-80, sec, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		tween.interpolate_property(stream_player_2, "stream/volume_db", stream_player_2.get_volume(),
		-80, sec, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Tween_tween_complete( object, key ):
	object.stop()
