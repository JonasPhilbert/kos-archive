// TODO: Clamp pitch to never go below horizon, even for really high orbital targets.
parameter targetApoapsis is 100000.

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

function calcTgtVel {
  if ship:altitude > 50000 {
    return 9001.
  } else {
    return 3.61966e-7 * ship:altitude ^ 2 + 0.015553 * ship:altitude + 200.
  }
}

function calcTgtPitch {
  local result is 90 + (-0.0359278 * altitude ^ 0.730423).
  if (result <= 0) {
    return 0.
  } else {
    return result.
  }
}

clearScreen.
print "Ascent v1.1".
print "  Note: Assuming first stage is engines and second stage is supports.".
print " ".

sas off.

stagePrint("main engines").
wait 1.
stagePrint("tower supports").

set thrt to 1.
lock throttle to thrt.
lock tgtVel to calcTgtVel().
lock velErr to tgtVel - ship:velocity:surface:mag.
lock dVelTgt to velErr * 1. // (velErr * const) higher constants means small velocity err prompts higher target velocity change.

lock tgtPitch to calcTgtPitch().
lock steering to heading(90, tgtPitch).

when ship:availablethrust <= 0 then {
  print "No available thrust. Staging.".
  stage.
  preserve.
}

until apoapsis > targetApoapsis {
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

set thrt to 0.
print "Orbital ascent complete.".

sas on.