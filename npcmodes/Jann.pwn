#include <a_npc>

public OnNPCModeInit()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
}	

public OnRecordingPlaybackEnd()
{
    StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
}