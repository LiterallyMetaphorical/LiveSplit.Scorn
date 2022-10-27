// Created by Meta, Nikoheart and oneir1c with help from LivingLooneyBin

state("Scorn-Win64-Shipping", "Steam 1.0")
{
	int isLoading       : 0x48E4740, 0x180, 0x240;
    int loadedSubLevel  : 0x48E4740, 0x180, 0x328;
    byte12 cameraPosition : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;

    float pawnPositionX   : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x130, 0x11C;
    byte1 characterState  : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x280, 0x6B0, 0x388;
    // Not sure what this is but it helps us track the ending flash
}

state("Scorn-WinGDK-Shipping", "XboxGP v1.0")
{
	int isLoading         : 0x44AD358, 0x180, 0x240;
    int loadedSubLevel    : 0x44AD358, 0x180, 0x328;
    byte12 cameraPosition : 0x44AD358, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;

    // Find this one again
    float pawnPositionX   : 0x44AD358, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x130, 0x11C;
    byte1 characterState  : 0x44AD358, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x280, 0x6B0, 0x388;
}

state("Scorn-Win64-Shipping", "Steam v1.1.8.0")
{
	int isLoading         : 0x48E69C0, 0x180, 0x240;
    /*                         ^       ^      ^
        GWorld-----------------|       |      |
        UAbstractScornGameInstance-----|      |
        bShowLoading--------------------------|
    */

    int loadedSubLevel    : 0x48E69C0, 0x180, 0x328;
    /*                         ^       ^      ^
        GWorld-----------------|       |      |
        UAbstractScornGameInstance-----|      |
        EScornSubLevel------------------------|
    */

    byte12 cameraPosition : 0x48E69C0, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;
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
    
    float pawnPositionX   : 0x48E69C0, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x130, 0x11C;
    /*                         ^       ^      ^     ^     ^     ^     ^      ^
        GWorld-----------------|       |      |     |     |     |     |      |
        UAbstractScornGameInstance-----|      |     |     |     |     |      |
        TArray<class ULocalPlayer*>-----------|     |     |     |     |      |
        UPlayer (ULocalPlayer)----------------------|     |     |     |      |
        APlayerController---------------------------------|     |     |      |
        APawn---------------------------------------------------|     |      |
        USceneComponent-----------------------------------------------|      |
        FVector[RelativeLocation]--------------------------------------------|
    */

    // we can only take a single byte ouf ot this; use as current.characterState[0]
    byte1 characterState    : 0x48E69C0, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x280, 0x6B0, 0x388;
    /*                         ^       ^      ^     ^     ^     ^     ^      ^        ^
        GWorld-----------------|       |      |     |     |     |     |      |        |
        UAbstractScornGameInstance-----|      |     |     |     |     |      |        |
        TArray<class ULocalPlayer*>-----------|     |     |     |     |      |        |
        UPlayer (ULocalPlayer)----------------------|     |     |     |      |        |
        APlayerController---------------------------------|     |     |      |        |
        ACharacter(APawn)---------------------------------------|     |      |        |
        USkeletalMeshComponent----------------------------------------|      |        |
        UMainCharacterAnimInstance(UAnimInstance)----------------------------|        |
        ECharacterState-------------------------------------------------------------- |
    */
}

init
{
    vars.endGameTimeOffset = new TimeSpan(0,0,9);

	switch (modules.First().ModuleMemorySize) 
    {
        case 81539072: 
            version = "Steam v1.0";
            break;
		case 76517376: 
            version = "XboxGP v1.0";
            break; 
		case 81547264: 
            version = "Steam v1.1.8.0";
            break;

    default:
        print("Unknown version detected");
        return false;
    }
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
    settings.Add("removeIntroTime", true, "Start timer at -27.15s. Enable this for full runs, disable for ILs");
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
	    //Use cases for each version of the game listed in the State method
		// this may not be necessary actually, assuming we get the same pointers/values in every version.
		switch (version) 
	{
		case "Steam v1.0": case "XboxGP v1.0": case "Steam v1.1.8.0":
			break;
	}
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
        if (current.loadedSubLevel == 8 && current.pawnPositionX > 175000 && current.characterState[0] == 11) return true;
    }

    return false;
}

