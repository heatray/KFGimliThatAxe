//===============================================
// Repair "Gimli That Axe!" Achievement Mutator
// Created by Heatray
// https://s.team/p/kff-tvmg
//===============================================

class KFFixThatAxeMut extends Mutator;

var int retryCount;

simulated function PostBeginPlay()
{
	Log("Fix That Axe: Init");
	retryCount = 0;
	SetTimer(0.1, false);
}

simulated function Timer()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		FixWebAPI();
	}
}

simulated function FixWebAPI()
{
	local KFSteamWebApi Api;
	local ROBufferedTCPLink Link;

	foreach DynamicActors(class'KFSteamWebApi', Api)
	{
		retryCount++;
		// Log("Fix That Axe: FixWebAPI Retry " $ retryCount);

		Link = Api.myLink;
		if (Link != none)
		{
			// Check JSON Errors
			if (InStr(Link.InputBuffer, "\"success\":false") != -1)
			{
				Log("Fix That Axe: JSON Error");
				return;
			}
			if (InStr(Link.InputBuffer, "\"apiname\":\"NotAWarhammer\",\"achieved\":0") != -1)
			{
				Log("Fix That Axe: Not A Warhammer isn't achieved");
				return;
			}

			// Transform JSON
			if (InStr(Link.InputBuffer, "\"apiname\":\"NotAWarhammer\",\"achieved\":1") != -1)
			{
				Link.InputBuffer = Repl(Link.InputBuffer, "\"success\":true", "\"success\": true");
				Link.InputBuffer = Repl(Link.InputBuffer, "\"apiname\":\"NotAWarhammer\"", "\"apiname\": \"NotAWarhammer\"");
				Link.InputBuffer = Repl(Link.InputBuffer, "\"achieved\":1", "\"achieved\": 1");
				Link.InputBuffer = Link.InputBuffer $ Link.CRLF;
				// Log("Fix That Axe: JSON Transformed");
			}
		}
		else
		{
			Log("Fix That Axe: Success");
			return;
		}
	}

	// 5 sec Repeat
	if (retryCount >= 24)
	{
		Log("Fix That Axe: Retries Limit");
	}
	else
	{
		SetTimer(5, false);
	}
}

DefaultProperties
{
	GroupName="KF-Achievements"
	FriendlyName="Fix That Axe"
	Description="Repair \"Gimli That Axe!\" Achievement; by Heatray"

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bAddToServerPackages=true
}
