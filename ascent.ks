// #region Libs
set dVel to V(0, 0, 0).
set _lastVel to ship:velocity:surface.
set _lastTime to time:seconds.
when true then { // Trigger on TRUE, which results in trigger on every physics tick.
  local dt is time:seconds - _lastTime.
  if dt > 0 {
    set dVel to (ship:velocity:surface - _lastVel) / dt.
  }
  set _lastTime to time:seconds.
  set _lastVel to ship:velocity:surface.
  return true. // Persists the trigger.
}

function telem {
  parameter str.
  parameter ln.
  
  print str:padright(terminal:width - str:length) at (0, terminal:height - ln).
}

function stagePrint {
  parameter name.

  print "Staging " + name + ".".
  stage.
}
// #endregion

set thrt to 0.
function adjThrt {
  parameter val.

  set thrt to thrt + val.
  if thrt > 1 {
    set thrt to 1.
  } else if thrt < 0 {
    set thrt to 0.
  }
}

clearScreen.
print "Ascent v1".
print "  Note: Assuming first stage is engines and second stage is supports.".
print " ".

sas off.

stagePrint("main engines").
wait 1.
stagePrint("tower supports").

set thrt to 1.
lock throttle to thrt.
lock tgtVel to 200 + (0.000001 * altitude ^ 2).
lock velErr to tgtVel - ship:velocity:surface:mag.
lock dVelTgt to velErr * 1. // (velErr * const) higher constants means small velocity err prompts higher target velocity change.

lock tgtPitch to 90 + (-0.0359278 * altitude ^ 0.730423).
lock steering to heading(90, tgtPitch).

until apoapsis > 100000 {
  set dVelErr to dVelTgt - dVel:mag.
  adjThrt(dVelErr / 100).

  telem("Delta vel.      : " + round(dVel:mag, 1), 1).
  telem("Delta vel. tgt. : " + round(dVelTgt, 1), 2).
  telem("Delta vel. err. : " + round(dVelErr, 1), 3).

  telem("Velocity        : " + round(ship:velocity:surface:mag, 1), 4).
  telem("Velocity tgt.   : " + round(tgtVel, 1), 5).
  telem("Velocity err.   : " + round(velErr, 1), 6).

  telem("Pitch tgt.      : " + round(tgtPitch, 1), 7).
}

print "Orbital ascent complete.".

sas on.