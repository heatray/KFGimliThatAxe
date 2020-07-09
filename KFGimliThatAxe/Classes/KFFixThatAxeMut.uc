//===============================================
// Repair "Gimli That Axe!" Achievement Mutator
// Created by Heatray
// https://s.team/p/kff-tvmg
//===============================================

class KFFixThatAxeMut extends Mutator;

var KFSteamWebApi Api;
var ROBufferedTCPLink Link;
var int retryCount;

simulated function ModifyPlayer(Pawn Other)
{
	retryCount = 0;
	SetTimer(1, false);
}

simulated function Timer()
{
	// Log("Fix That Axe: Retry " $ retryCount);

	foreach DynamicActors(class'ROBufferedTCPLink', Link)
	{
		// Check JSON Errors
		if (InStr(Link.InputBuffer, "\"success\":false") != -1)
		{
			Destroy();
			Log("Fix That Axe: JSON Error");
			return;
		}
		if (InStr(Link.InputBuffer, "\"apiname\":\"NotAWarhammer\",\"achieved\":0") != -1)
		{
			Destroy();
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

	foreach DynamicActors(class'KFSteamWebApi', Api)
	{
		// Check JSON
		if (InStr(Api.playerStats, "\"success\": true") != -1)
		{
			Destroy();
			Log("Fix That Axe: JSON Success");
			return;
		}
	}

	// 5 sec Repeat
	if (retryCount++ >= 24)
	{
		Destroy();
		Log("Fix That Axe: Retries Limit");
		return;
	}
	else
	{
		SetTimer(5, true);
		return;
	}
}

DefaultProperties
{
	GroupName="KF-Achievements"
	FriendlyName="Fix That Axe"
	Description="Fix Gimli That Axe! Achievement; by Heatray"

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bAddToServerPackages=true
}
