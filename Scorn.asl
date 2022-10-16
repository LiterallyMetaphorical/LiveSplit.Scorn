// Created by Meta and Nikoheart

state("Scorn-Win64-Shipping")
{
	int loading   : 0x46ACEC0; 
    int loadedAct : 0x046C0400, 0x0, 0x298;
}

startup
  {
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
    // This is part of a "cycle fix", makes sure the timer always starts at 0.00
    timer.IsGameTimePaused = true;
}

isLoading
{
	return current.loading != 0;
}

split 
{ 	
    return   
	    (current.loadedAct == 2) && (old.loadedAct == 1 ) ||  
        (current.loadedAct == 3) && (old.loadedAct == 2 ) || 
        (current.loadedAct == 4) && (old.loadedAct == 3 ) || 
        (current.loadedAct == 5) && (old.loadedAct == 4 ) || 
        (current.loadedAct == 7) && (old.loadedAct == 5 ) || 
	    (current.loadedAct == 8) && (old.loadedAct == 7 );
}	

update
{
//DEBUG CODE
//print(current.testLoading.ToString());
//print(current.loadedAct.ToString());
} 


