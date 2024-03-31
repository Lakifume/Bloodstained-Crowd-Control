﻿using System;
using System.Collections.Generic;
using CrowdControl.Common;
using JetBrains.Annotations;
using ConnectorType = CrowdControl.Common.ConnectorType;

namespace CrowdControl.Games.Packs.Bloodstained;

public class Bloodstained : SimpleTCPPack
{
    public override string Host => "127.0.0.1";

    public override ushort Port => 33940;

    public override ISimpleTCPPack.MessageFormat MessageFormat => ISimpleTCPPack.MessageFormat.CrowdControlLegacy;

    public Bloodstained(UserRecord player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game { get; } = new("Bloodstained: Ritual of the Night", "Bloodstained", "PC", ConnectorType.SimpleTCPServerConnector);

    public override EffectList Effects => new List<Effect>
    {
		new("Poison Player",        "PoisonPlayer")        {Description = "Unlike the old school poison this one actually drains your health",                                               Category = "Main", Price =   50},
		new("Curse Player",         "CursePlayer")         {Description = "Their run is probably cursed enough as is, but a little extra never hurt anyone",                                 Category = "Main", Price =   50},
		new("Petrify Player",       "PetrifyPlayer")       {Description = "Remind the player why they should never get stoned",                                                              Category = "Main", Price =   50},
		new("Slow Player Down",     "SlowPlayerDown")      {Description = "Who are you calling slow ?",                                                                                      Category = "Main", Price =   50},
		new("Use Waystone",         "UseWaystone")         {Description = "Send the player back to Johannes for a health check-up. Still has no effect during boss fights",                  Category = "Main", Price =  500},
		new("Empty Health",         "EmptyHealth")         {Description = "Set player HP to 1",                                                                                              Category = "Main", Price =  500},
		new("Empty Magic",          "EmptyMagic")          {Description = "Set player MP to 1",                                                                                              Category = "Main", Price =  250},
		new("Refill Health",        "RefillHealth")        {Description = "Refill player HP to full",                                                                                        Category = "Main", Price =  250},
		new("Refill Magic",         "RefillMagic")         {Description = "Refill player MP to full",                                                                                        Category = "Main", Price =  125},
		new("Shuffle Colors",       "ShuffleColors")       {Description = "Randomize Miriam's colors",                                                                                       Category = "Main", Price =   50},
		new("Fake Flawless Win",    "FakeFlawlessWin")     {Description = "Congratulations",                                                                                                 Category = "Main", Price =   50},
		new("Play Death Quote",     "PlayDeathQuote")      {Description = "Randomly play one of the quotes normally heard when getting a Game Over on certain bosses",                       Category = "Main", Price =   50},
		new("Flip Player",          "FlipPlayer")          {Description = "Turn the player around, also inverting their controls",                                                           Category = "Main", Price =  150, Duration = 30},
		new("Shuffle Controls",     "ShuffleControls")     {Description = "Randomize all non-directional player controls. Does not affect keyboard inputs",                                  Category = "Main", Price =  250, Duration = 30},
		new("Use Witch Time",       "UseWitchTime")        {Description = "Trigger an ancient technique once used by the Umbra",                                                             Category = "Main", Price =  250, Duration = 15},
		new("Turbo Enemies",        "TurboEnemies")        {Description = "They move so fast !",                                                                                             Category = "Main", Price =  250, Duration = 30},
		new("Uncontrollable Speed", "UncontrollableSpeed") {Description = "The more speed the better… right ?",                                                                              Category = "Main", Price =  200, Duration = 30},
		new("Critical Mode",        "CriticalMode")        {Description = "Every player attack is a guaranteed crit, however defense will be set to 0",                                      Category = "Main", Price =  150, Duration = 30},
		new("Gold Rush",            "GoldRush")            {Description = "Call upon the player's thirst for gold, converting damage dealt to money at the cost of draining their currency", Category = "Main", Price =  250, Duration = 60},
		new("Use Rosario",          "UseRosario")          {Description = "Kill every enemy on the current screen. If it's a boss it will only inflict damage",                              Category = "Main", Price =  200},
		new("Summon Ambush",        "SummonAmbush")        {Description = "Ambush the player by surrounding them with a random enemy",                                                       Category = "Main", Price =  150},
		new("Rewind Time",          "RewindTime")          {Description = "Warp the player back to the last room they've traversed. Does not work during boss fights",                       Category = "Main", Price =  250},
		new("Summon Rave",          "SummonRave")          {Description = "It's party time at the demon castle !",                                                                           Category = "Main", Price =  100, Duration = 30},
		new("Summon Darkness",      "SummonDarkness")      {Description = "Follow the light at the end of the tunnel",                                                                       Category = "Main", Price =  100, Duration = 20},
		new("Trigger Earthquake",   "TriggerEarthquake")   {Description = "Shakin' and vibin'",                                                                                              Category = "Main", Price =  100, Duration = 10},
		new("Force Invert",         "ForceInvert")         {Description = "Force the player to remain in second castle",                                                                     Category = "Main", Price =  200, Duration = 20},
		new("No Skill Shards",      "NoSkillShards")       {Description = "Turn off all white shards. Epic gamers can use their own skillz",                                                 Category = "Main", Price =  200, Duration = 30},
		new("Weapons Only",         "WeaponsOnly")         {Description = "Unequip the player's current shards, forcing them to use weapons instead",                                        Category = "Main", Price =  100, Duration = 60},
		new("Shards Only",          "ShardsOnly")          {Description = "Unequip the player's current weapon, forcing them to use shards instead",                                         Category = "Main", Price =  100, Duration = 30},
		new("Force Equipment",      "ForceEquipment")      {Description = "Force a random set of equipment based on what the player has in their inventory",                                 Category = "Main", Price =  100, Duration = 60},
		new("Heaven or Hell",       "HeavenOrHell")        {Description = "May make the player invincible… or may put them in one-hit KO mode",                                              Category = "Main", Price =  250, Duration = 60},
		new("Return Books",         "ReturnBooks")         {Description = "This is a library, not a bookshop",                                                                               Category = "Main", Price =  500},
		new("Call The Library",     "CallTheLibrary")      {Description = "Report Miriam to Orlok Dracule so that he can meet with her soon to talk about the tomes she did not return",     Category = "Main", Price = 1000}
    };
}