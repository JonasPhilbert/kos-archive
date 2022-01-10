set dVel to V(0, 0, 0).
set lastVel to ship:velocity:surface.
set lastTime to time:seconds.
when true then { // Trigger on TRUE, which results in trigger on every physics tick.
  local dt is time:seconds - lastTime.
  if dt > 0 {
    set dVel to (ship:velocity:surface - lastVel) / dt.
  }
  set lastTime to time:seconds.
  set lastVel to ship:velocity:surface.
  return true. // Persists the trigger.
}

clearscreen.
print "Ascent v0.1".
print " ".

from {local count is 3.} until count = 0 step {set count to count - 1.} do {
  print "..." + count.
  wait 1.
}

stage. // Main engines.
wait 1.
stage. // Supports.

set thrt to 1.
lock throttle to thrt.
lock tgtVel to 200 + (0.000001 * altitude ^ 2).
lock velErr to tgtVel - ship:velocity:surface:mag.

lock tgtPitch to 90 + (-0.0359278 * altitude ^ 0.730423).
lock steering to heading(90, tgtPitch).

until apoapsis > 100000 {
  set dVelErr to velErr - dVel:mag. // Use absolute vel. as basis of error calc, as we want our dVel. to be the diff of our current dVel. and our taget absolute vel.
  adjThrt(dVelErr / 100).
  // if (dVelErr > 0) {
  //   adjThrt(0.01).
  // } else if (dVelErr < 0) {
  //   adjThrt(-0.01).
  // }

  print "Delta vel.      : " + round(dVel:mag, 1) + "        " at (0, 15).
  print "Delta vel. tgt. : " + round(velErr, 1) + "        " at (0, 16).
  print "Delta vel. err. : " + round(dVelErr, 1) + "        " at (0, 17).

  print "Velocity       : " + round(ship:velocity:surface:mag, 1) + "        " at (0, 18).
  print "Velocity tgt.  : " + round(tgtVel, 1) + "        " at (0, 19).
  print "Velocity err.  : " + round(velErr, 1) + "        " at (0, 20).

  print "Pitch          : " + round(ship:direction:pitch, 1) + "        " at (0, 21).
  print "Pitch tgt.     : " + round(tgtPitch, 1) + "        " at (0, 22).
  print "Pitch err.     : " + round(tgtPitch - ship:direction:pitch, 1) + "        " at (0, 23).
}

function adjThrt {
  parameter val.

  set thrt to thrt + val.
  if thrt > 1 {
    set thrt to 1.
  } else if thrt < 0 {
    set thrt to 0.
  }
}