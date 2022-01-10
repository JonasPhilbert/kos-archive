// #region Velocity change per tick calculation
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
// #endregion

// global _telems is list().
// function telem {
//   parameter label.
//   parameter resolver.

//   local entry is lexicon().
//   entry:add("label", label).
//   entry:add("resolver", resolver).
//   _telems:add(entry).
// }
// when true then {
//   for entry in _telems {
//     local resoultion is entry["resolver"]().
//     local str is entry["label"]:padright(terminal:width - resoultion:tostring:length - 1) + resoultion.
//     print str at(0, terminal:height - _telems:indexof(entry)).
//   }
//   return true.
// }

clearScreen.
print "Ascent v1".
print "Note: Assuming first stage is engines and second stage is supports.".
print " ".
print "Staging in: ".

from {local count is 3.} until count = 0 step {set count to count - 1.} do {
  print count at (12, 4).
  wait 1.
}

clearScreen.
stagePrint("main engines").
wait 1.
stagePrint("tower supports").

set thrt to 1.
lock throttle to thrt.
lock tgtVel to 200 + (0.000001 * altitude ^ 2).
lock velErr to tgtVel - ship:velocity:surface:mag.
lock dVelTgt to velErr * 2.

lock tgtPitch to 90 + (-0.0359278 * altitude ^ 0.730423).
lock steering to heading(90, tgtPitch).

// telem("foo", {return altitude.}).
// telem("bar", {return tgtPitch.}).

until apoapsis > 100000 {
  set dVelErr to dVelTgt - dVel:mag. // Use absolute vel. as basis of error calc, as we want our dVel. to be the diff of our current dVel. and our taget absolute vel.
  adjThrt(dVelErr / 100).

  print "Delta vel.      : " + round(dVel:mag, 1) + "        " at (0, 15).
  print "Delta vel. tgt. : " + round(dVelTgt, 1) + "       " at (0, 16).
  print "Delta vel. err. : " + round(dVelErr, 1) + "        " at (0, 17).

  print "Velocity        : " + round(ship:velocity:surface:mag, 1) + "        " at (0, 18).
  print "Velocity tgt.   : " + round(tgtVel, 1) + "        " at (0, 19).
  print "Velocity err.   : " + round(velErr, 1) + "        " at (0, 20).

  print "Pitch tgt.      : " + round(tgtPitch, 1) + "        " at (0, 22).
}

sas on.
print "Orbital ascent complete.".

// Functions

function adjThrt {
  parameter val.

  set thrt to thrt + val.
  if thrt > 1 {
    set thrt to 1.
  } else if thrt < 0 {
    set thrt to 0.
  }
}

function stagePrint {
  parameter name.

  print "Staging " + name + ".".
  stage.
}