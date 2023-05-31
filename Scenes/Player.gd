extends KinematicBody2D

var speed = 200
onready var Net = $"/root/World/Network"

var vel : Vector2 = Vector2()

func _ready():
	Net.connect("mv_up",    self, "up") 
	Net.connect("mv_down",  self, "down") 
	Net.connect("mv_left",  self, "left") 
	Net.connect("mv_right", self, "right")
	


func up():
	position.y += 1

func down():
	position.y -= 1

func left():
	position.x -= 1

func right():
	position.x += 1

