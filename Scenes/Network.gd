extends Node

signal mv_up
signal mv_down
signal mv_left
signal mv_right

const HOST: String = "192.168.1.142"
const PORT: int = 1234
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://client.gd")
var _client: Client = Client.new()

func _ready() -> void:
	_client.connect("connected", self, "_handle_client_connected")
	_client.connect("disconnected", self, "_handle_client_disconnected")
	_client.connect("error", self, "_handle_client_error")
	_client.connect("data", self, "_handle_client_data")
	
	_client.connect("mv_up", self, "net_up")
	_client.connect("mv_down", self, "net_down")
	_client.connect("mv_left", self, "net_left")
	_client.connect("mv_right", self, "net_right")
	
	add_child(_client)
	_client.connect_to_host(HOST, PORT)

func _connect_after_timeout(timeout: float) -> void:
	yield(get_tree().create_timer(timeout), "timeout") # Delay for timeout
	_client.connect_to_host(HOST, PORT)

func _handle_client_connected() -> void:
	print("Client connected to server.")

func _handle_client_data(data: PoolByteArray) -> void:
	print("Client data: ", data.get_string_from_utf8())
	var message: PoolByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
	_client.send(message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func net_up():
	emit_signal("mv_up")

func net_down():
	emit_signal("mv_down")

func net_left():
	emit_signal("mv_left")

func net_right():
	emit_signal("mv_right")
