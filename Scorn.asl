// Created by Meta and Nikoheart
// Also shoutouts to Looney for helping Meta's dumbass figure out fuckin if statements lmao

state("Scorn-Win64-Shipping")
{
	int loading   : 0x46ACEC0; 
	int loadedAct : 0x046C0400, 0x0, 0x298;
	//int finalCS : 0x44A3B8C;
    float playerXpos  : 0x047B2E98, 0x8, 0x110, 0x1A0, 0x10, 0x250;
}

init
{
	vars.setStartTime = false;
}

startup
{
    vars.TimeOffset = -27.15;
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	// Asks user to change to game time if LiveSplit is currently set to Real Time.
	{        
		var timingMessage = MessageBox.Show (
		"This game uses Time without Loads (Game Time) as the main timing method.\n"+
		"LiveSplit is currently set to show Real Time (RTA).\n"+
		"Would you like to set the timing method to Game Time?",
		"LiveSplit | Scorn",
		MessageBoxButtons.YesNo,MessageBoxIcon.Question
		);
        
		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
}

onStart
{
    vars.setStartTime = true;
    timer.IsGameTimePaused = true;
}

start
{   
    //pointer goes null and then to 0 during load
    if (current.playerXpos == null || old.playerXpos != 0) 
    {
    return false;
    }
    // then picks up proper position of like -24871.98633 which gets rounded to -24871.99 in livesplit
    return old.playerXpos == 0 && current.playerXpos < -23000; 
}

gameTime
{
	if(vars.setStartTime)
	{
		vars.setStartTime = false;
		return TimeSpan.FromSeconds(vars.TimeOffset);
	}
}

isLoading
{
	return current.loading != 0;
}

split
{
    return old.loadedAct > 0 && current.loadedAct == old.loadedAct + 1;
}

/* this split method also splits at the white flash at the end of the game
split 
{ 	
	return old.loadedAct > 0 && current.loadedAct == old.loadedAct + 1 ||
    current.loadedAct == 8 && old.playerXpos > 170000 && current.playerXpos == 0;
}
*/

update
{
//DEBUG CODE
print(current.playerXpos.ToString());
print(current.loadedAct.ToString());
} 
