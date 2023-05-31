extends Node

signal connected
signal data
signal disconnected
signal error
signal mv_up
signal mv_down
signal mv_left
signal mv_right

var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()

func _ready() -> void:
	#connect("move",$Player , "move")
	_status = _stream.get_status()

func _process(delta: float) -> void:
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				print("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				print("Connecting to host.")
			_stream.STATUS_CONNECTED:
				print("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			print("available bytes: ", available_bytes)
			var purple: Array = _stream.get_partial_data(available_bytes)
			
			# Check for read error.
			if purple[0] != OK:
				print("Error getting data from stream: ", purple[0])
				emit_signal("error")
			else:
				print("test: ", purple[1])
				if purple[1][0] == 119:
					print("UP")
					emit_signal("mv_up")
				if purple[1][0] == 115:
					print("DOWN")
					emit_signal("mv_down")
				if purple[1][0] == 97:
					print("LEFT")
					emit_signal("mv_left")
				if purple[1][0] == 100:
					print("RIGHT")
					emit_signal("mv_right")

func connect_to_host(host: String, port: int) -> void:
	print("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		print("Error connecting to host.")
		emit_signal("error")

func send(data: PoolByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.")
		return false
	var error: int = _stream.put_data(data)
	if error != OK:
		print("Error writing to stream: ", error)
		return false
	return true


