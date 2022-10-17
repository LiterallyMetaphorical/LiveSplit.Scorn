// Created by Meta and Nikoheart

state("Scorn-Win64-Shipping")
{
	int loading   : 0x46ACEC0; 
	int loadedAct : 0x046C0400, 0x0, 0x298;
	int finalCS : 0x44A3B8C;
	int playerControl : 0x044A3510, 0x8D8, 0x8;
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
	return old.playerControl == 5 && current.playerControl == 2 & current.loading != 0;
}

isLoading
{
	return current.loading != 0;
}

gameTime
{
	if(vars.setStartTime)
	{
		vars.setStartTime = false;
		return TimeSpan.FromSeconds(vars.TimeOffset);
	}
}

split 
{ 	
	return current.loadedAct == old.loadedAct + 1;
}

update
{
//DEBUG CODE
print(current.testLoading.ToString());
//print(current.loadedAct.ToString());
} 
