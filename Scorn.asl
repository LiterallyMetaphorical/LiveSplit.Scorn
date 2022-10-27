// Created by Meta, Nikoheart and oneir1c with help from LivingLooneyBin

state("Scorn-Win64-Shipping")
{
	int isLoading       : 0x48E4740, 0x180, 0x240;
    /*                         ^       ^      ^
        GWorld-----------------|       |      |
        UAbstractScornGameInstance-----|      |
        bShowLoading--------------------------|
    */

    int loadedSubLevel  : 0x48E4740, 0x180, 0x328;
    /*                         ^       ^      ^
        GWorld-----------------|       |      |
        UAbstractScornGameInstance-----|      |
        EScornSubLevel------------------------|
    */

    byte12 cameraPosition : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;
    /*                         ^       ^      ^     ^     ^     ^     ^      ^
        GWorld-----------------|       |      |     |     |     |     |      |
        UAbstractScornGameInstance-----|      |     |     |     |     |      |
        TArray<class ULocalPlayer*>-----------|     |     |     |     |      |
        UPlayer (ULocalPlayer)----------------------|     |     |     |      |
        APlayerController---------------------------------|     |     |      |
        APlayerCameraManager------------------------------------|     |      |
        USceneComponent-----------------------------------------------|      |
        FVector[RelativeLocation]--------------------------------------------|
    */

    float playerXpos  : 0x047B2E98, 0x8, 0x110, 0x1A0, 0x10, 0x250;
    // Not sure what this is but it helps us track the ending flash
}

init
{
    vars.endGameTimeOffset = new TimeSpan(0,0,9);
}

startup
{
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        // Asks user to change to game time if LiveSplit is currently set to Real Time.
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

    // Run start flags
    vars.isRunStarted = false;
    vars.runJustStarted = false;

    // Timing offset and flag
    settings.Add("removeIntroTime", false, "Add a negative time offset when starting the run to remove the waking period during Act 1");
    vars.startTimeOffsetFlag = false;
    vars.startTimeOffset = -27.15;

    /* camera position; use if necessary
    vars.cameraX = 0.0f;
    vars.cameraY = 0.0f;
    vars.cameraZ = 0.0f;
    */
}


onStart
{
    timer.IsGameTimePaused = true;
}

update
{
    // add more stuff here
    return;
}


start
{
    // Run starts when leaving the first loadscreen
    if (!vars.isRunStarted && current.isLoading == 0 && old.isLoading == 1) {
        vars.isRunStarted = true;
        vars.runJustStarted = true;
        
        // custom timing
        if (settings["removeIntroTime"]) vars.startTimeOffsetFlag = true;
        return true;
    }

    return false;
}

onReset
{
    vars.isRunStarted = false;
    timer.IsGameTimePaused = true;
}

gameTime
{
    if(settings["removeIntroTime"] && vars.startTimeOffsetFlag) 
    {
        vars.startTimeOffsetFlag = false;
        return TimeSpan.FromSeconds(vars.startTimeOffset);
    }

        else if(current.loadedSubLevel == 8 && old.playerXpos > 170000 && current.playerXpos == 0)
    {
        return ((TimeSpan)timer.CurrentTime.GameTime).Subtract(vars.endGameTimeOffset);
    }
}

isLoading
{
    if (current.isLoading != old.isLoading) print("[SCORN ASL] isLoading " + current.isLoading.ToString());
	return current.isLoading != 0;
}

split 
{
    if (vars.isRunStarted) {

        // Normal splitting
        if (current.loadedSubLevel == old.loadedSubLevel + 1) {
            print("[SCORN ASL] loadedSubLevel " + current.loadedSubLevel.ToString());

            // Avoid redundant first split
            if (vars.runJustStarted) {
                vars.runJustStarted = false;
                return false;
            }
            
            return true;
        }

        // Custom last split
        if (current.loadedSubLevel == 8 && old.playerXpos > 170000 && current.playerXpos == 0) return true;
    }

    return false;
}
