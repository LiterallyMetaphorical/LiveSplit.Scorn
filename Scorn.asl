// Created by Meta, Nikoheart and oneir1c with help from LivingLooneyBin

state("Scorn-Win64-Shipping", "Steam 1.0")
{
	int isLoading       : 0x48E4740, 0x180, 0x240;
    int loadedSubLevel  : 0x48E4740, 0x180, 0x328;
    byte12 cameraPosition : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;

    float pawnPositionX   : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x130, 0x11C;
    byte1 characterState  : 0x48E4740, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x280, 0x6B0, 0x388;
}

state("Scorn-WinGDK-Shipping", "XboxGP v1.1")
{
	int isLoading         : 0x44AF658, 0x180, 0x240;
    int loadedSubLevel    : 0x44AF658, 0x180, 0x328;
    byte12 cameraPosition : 0x44AF658, 0x180, 0x38, 0x0, 0x30, 0x2B8, 0x228, 0x11C;

    float pawnPositionX   : 0x44AF658, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x130, 0x11C;
    byte1 characterState  : 0x44AF658, 0x180, 0x38, 0x0, 0x30, 0x2A0, 0x280, 0x6B0, 0x388;
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
    /*                         ^           ^      ^     ^     ^     ^     ^      ^        ^
        GWorld-----------------|           |      |     |     |     |     |      |        |
        UAbstractScornGameInstance---------|      |     |     |     |     |      |        |
        TArray<class ULocalPlayer*>---------------|     |     |     |     |      |        |
        UPlayer (ULocalPlayer)--------------------------|     |     |     |      |        |
        APlayerController-------------------------------------|     |     |      |        |
        ACharacter(APawn)-------------------------------------------|     |      |        |
        USkeletalMeshComponent--------------------------------------------|      |        |
        UMainCharacterAnimInstance(UAnimInstance)--------------------------------|        |
        ECharacterState-------------------------------------------------------------------|
    */
}

init
{
	switch (modules.First().ModuleMemorySize) 
    {
        case 81539072: 
            version = "Steam v1.0";
            break;
		case 76525568: 
            version = "XboxGP v1.1";
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

    // IL auto start
    settings.Add("ILMode", false, "IL Mode: Initiate timing as soon as level begins");

    // Character state default -- ECharacterState_MAX
    vars.charState = 0x14;
}

update
{
    // update the current Character State safely; the mesh reference may not be available
    old.charState = vars.charState;
    try { vars.charState = 0x14; vars.charState = current.characterState[0]; }
    catch (Microsoft.CSharp.RuntimeBinder.RuntimeBinderException) {}
    current.charState = vars.charState;

    // log charState change
    if (current.charState != old.charState) print("[SCORN ASL] charState: " + old.charState + " -> " + current.charState);
}


start
{
    if (!vars.isRunStarted) {

        // begin run with IL Mode; as soon as the character is initialized
        if (settings["ILMode"] && current.charState == 0 && old.charState == 20) {
            vars.isRunStarted = true;
            return true;
        }

        // begin run in standard config; when leaving the first world event
        if (current.charState == 0 && old.charState == 11) {
            vars.isRunStarted = true;
            return true;
        }
    }

    return false;
}

onReset
{
    vars.isRunStarted = false;
    timer.IsGameTimePaused = true;
}

isLoading
{
    if (current.isLoading != old.isLoading) print("[SCORN ASL] isLoading " + old.isLoading.ToString() + " -> " + current.isLoading.ToString());
	return current.isLoading != 0;
}

split 
{
    if (vars.isRunStarted) {

        // Normal splitting
        if (current.loadedSubLevel > old.loadedSubLevel) {
            print("[SCORN ASL] loadedSubLevel " + old.loadedSubLevel.ToString() + " -> " + current.loadedSubLevel.ToString());
            return true;
        }

        // Custom last split; end run as soon as player loses control
        if (current.loadedSubLevel == 8 && current.pawnPositionX > 175000 && current.characterState[0] == 11) return true;
    }

    return false;
}