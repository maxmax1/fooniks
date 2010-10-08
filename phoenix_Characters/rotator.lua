-- EDIT ME
 
local rotSpeed = 1 -- How much degrees you want the camera to turn per frame
 
-- DON'T EDIT ME ANYMOAR
local angle = 0
local elem
local zOff
local dist
local active = false
 
function getPointFromDistanceRotation(x, y, dist, angle) --credits to robhol from wiki snippets
    local a = math.rad(90 - angle)
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end
 
function attachrotatingcamera(bool,element,Zoffset,distance)
   if bool then
      active=true
      elem,zOff,dist=element,Zoffset,distance --make values global
      addEventHandler("onClientRender",getRootElement(),createRotRamera)
   else
      removeEventHandler("onClientRender",getRootElement(),createRotRamera)
      setCameraTarget(getLocalPlayer(),getLocalPlayer())
      active=false
   end
end
 
function createRotRamera()
   local x,y,z=getElementPosition(elem)
   local camx,camy=getPointFromDistanceRotation(x, y, dist, angle)
   setCameraMatrix(camx,camy,z+zOff,x,y,z)
   angle=(angle+rotSpeed)%360
end

addEvent( "rotateAroundPlayer", true );
addEventHandler( "rotateAroundPlayer", getRootElement( ), function ( rot, ply, zoff, dist ) attachrotatingcamera( rot, ply, zoff, dist ) end );
