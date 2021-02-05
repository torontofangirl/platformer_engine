//forgiveness mechanics!
/*
Coyote time
Input buffering - store an input for a set length of time
until it becomes valid, then execute it (use input buffering wherever you can)
All actions should have early input forgiveness and late input forgiveness

Hitbox pinching - when you are moving, base collisions off a pinched version
of the hitbox
Then, push the player up out of the wall using the normal hitbox
Can also use hitbox pinching when jumping;
- pinch it when you go up so you can go inside the wall up
- normal hitbox when falling so you can land easily
*/

hsp = 0
vsp = 0

j_height = 48
time_to_apex = 18
j_damping = 0.8
//solve for grv dynamically
grv = (2 * j_height) / power(time_to_apex, 2)
j_velocity = -abs(grv) * time_to_apex
stopping_grv = grv + 0.45

accel_time = 6 //in frames
deccel_time = 3
walksp = 3

dashsp = 10
dash_accel_time = 5
dash_deccel_time = 18

///@func move_n_collide()
move_n_collide = function(){
	if (place_meeting(x + hsp, y, obj_wall)){
		while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp)
		hsp = 0
	}
	x += hsp
	if (place_meeting(x, y + vsp, obj_wall)){
		while (!place_meeting(x, y + sign(vsp), obj_wall)) y += sign(vsp)
		vsp = 0
	}
	y += vsp
}

///@func change_hsp(hdir, accel, deccel)
change_hsp = function(_hdir, _accel_spd, _deccel_spd){
	if (KEY_RIGHT ^ KEY_LEFT){
		hsp = approach(hsp, _hdir * walksp, _accel_spd)
	}
	else hsp = approach(hsp, 0, _deccel_spd)
}

/// @func apply_dash(speed, direction)
apply_dash = function(_spd, _dir){
	hsp = approach(hsp, lengthdir_x(_spd, _dir), abs(lengthdir_x(_spd, _dir)) / dash_accel_time)
	vsp = approach(vsp, lengthdir_y(_spd, _dir), abs(lengthdir_y(_spd, _dir)) / dash_accel_time)
}

///@func on_ground()
on_ground = function(){
	return place_meeting(x, y + 1, obj_wall)
}

///@func can_jump()
can_jump = function(){
	return on_ground() && KEY_JUMP_PRESSED
}

state = new StateMachine("idle")
state.add("idle", {
	enter: function(){
		hsp = 0
		vsp = 0
		
		image_index = 0
	},
	step: function(){
		if (KEY_DASH) state_switch("dash")
		
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0) state_switch("walk")
		
		if (KEY_JUMP && can_jump()) state_switch("rising")
		
		vsp += grv
	}
})
state.add("walk", {
	enter: function(){
		image_index = 0
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir == 0 && hsp == 0){
			state_switch("idle")
		}
		
		if (_hdir != 0) image_xscale = _hdir
		
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		if (KEY_JUMP && can_jump()) state_switch("rising")
		
		vsp += grv
	}
})
state.add("rising", {
	enter: function(){
		vsp += j_velocity
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0) image_xscale = _hdir
		
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		//if rising and not pressing jump
		if (!KEY_JUMP){
			vsp += stopping_grv
		} 
		else{
			vsp += grv
		}
		
		if (vsp >= 0) state_switch("falling")
	}
})
state.add("falling", {
	enter: function(){
		image_index = 0
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0) image_xscale = _hdir
		
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		vsp += grv
		
		if (on_ground()){
			if (_hdir == 0) state_switch("idle")
			else state_switch("walk")
		}
	}
})
