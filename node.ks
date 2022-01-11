// === The math behind this ===
// g0 is standard gravity constant.

// The ideal rocket equation:
//  dVel = (isp * g0) * ln(initialMass / finalMass)
// Calculates the velocity change based on engine isp and fuel used (initialMass / finalMass).
// Solved for finalMass:
//  finalMass = initialMass / e ^ (dVel / (isp * g0))

// Equation for fuel usage over time, given the fuel usage rate:
//  finalMass = initialMass - (fuelRate * dTime)
// Gives the final mass of the vehicle after dTime amount of fueldRate fuel usage, based on initial wet weight of vehicle.
// Useful to solve for burn time:
//  dTime = (initialMass - finalMass) / fuelRate

// Equation for calculating thrust:
//  thrust = g0 * isp * fuelRate
// Useful to solve for fuelRate:
//  fuelRate = thrust / (isp * g0)

// #region Libs
function telem {
  parameter str.
  parameter ln.
  
  print str:padright(terminal:width - str:length) at (0, terminal:height - ln).
}
// #endregion

function nodeBurnTime {
    parameter node.

    local isp is 0.
    list engines in engs.
    for eng in engs {
        if eng:ignition and not eng:flameout {
            set isp to isp + (eng:isp * (eng:availablethrust / ship:availablethrust)).
        }
    }
    if isp = 0 {
        return -1.
    }
    local finalMass is ship:mass / constant:e ^ (node:deltav:mag / (isp * constant:g0)).
    local fuelRate is ship:availablethrust / (isp * constant:g0).

    return (ship:mass - finalMass) / fuelRate.
}

clearScreen.
print "Node v1.0".
print " ".

sas off.

if allNodes:length = 0 {
    print "Err: No maneuver node!".
    set EXIT to 1/0.
}
set thrt to 0.
lock throttle to thrt.
set burnTime to nodeBurnTime(nextNode).
if burnTime = -1 {
    print "Err: Burn time infinite! Do you have any active, fueled engines?".
    set EXIT to 1/0.
}
print "Est. burn time: " + round(burnTime, 1) + " secs.".
lock steering to nextNode:deltav.
lock dirErr to (nextNode:deltav:normalized * ship:facing:vector:normalized) - 1.  
until abs(dirErr) <= 0.0001 {
    telem("Error : " + round(dirErr, 1), 1).
}

print "Warping to N- " + round((burnTime / 2) - 3, 1) + "...".
warpTo(time:seconds + (nextNode:eta - (burnTime / 2) - 3)).
wait until nextNode:eta <= burnTime / 2.

print "Initiating burn.".
lock velErr to (nextNode:deltav:normalized * ship:velocity:orbit:normalized) - 1.
set thrt to 1.
until nextNode:deltav:mag < 0.1 or abs(velErr) > 0.01 {
    telem("Error : " + round(velErr, 1), 1).
}

set thrt to 0.
print "Burn complete.".

sas on.