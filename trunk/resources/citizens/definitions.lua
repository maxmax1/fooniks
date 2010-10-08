-- DEBUG = true

_root = getRootElement()

if ( getLocalPlayer ) then
	_local = getLocalPlayer()
else
	_local = getResourceRootElement ( getThisResource() )
end

function enum ( args, prefix )
	for i, v in ipairs ( args ) do
		if ( prefix ) then _G[v] = prefix..i
		else _G[v] = i end
	end
end

UPDATE_DELAY = 200
SYNC_DIST = 100
SYNC_MIN_DIST = 30
PANIC_TIME = 15000
PANIC_DIST = 40
Z_OFFSET = 1

CITIZENS_PEDS = {}
CITIZENS_PRELOADER = {}
CITIZENS_UNLOADER = {}

AREA_ACTIVE = {}

AREA_PRELOAD = false -- This defines if it should preload the areas around active ones

enum ({
	"PED_CREATED",
	"PED_NODE",
	"PED_PANIC"
}, "c" )