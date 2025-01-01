-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- NOTE: Non-land vehicles are also immune to "prone" by default
VEHICLE_TYPE_LAND = "land";
tStandardVehicleConditionImmunities = { "blinded", "charmed", "deafened", "frightened", "intoxicated", "paralyzed", "petrified", "poisoned", "stunned", "unconscious" };
tStandardVehicleDamageImmunities = { "poison", "psychic" };

function onInit()
	initActorHealth();
end

--
--	HEALTH
-- 

function initActorHealth()
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_UNCONSCIOUS, ColorManager.getUIColor("health_dyingordead"));

	ActorHealthManager.getWoundPercent = getWoundPercent;
end

-- NOTE: Always default to using CT node as primary to make sure 
--		that all bars and statuses are synchronized in combat tracker
--		(Cross-link network updates between PC and CT fields can occur in either order, 
--		depending on where the scripts or end user updates.)
-- NOTE 2: We can not use default effect checking in this function; 
-- 		as it will cause endless loop with conditionals that check health
function getWoundPercent(v)
	local rActor = ActorManager.resolveActor(v);

	local nMaxHits = 0;
	local nWounds = 0;
    local nConstitution = 0;
    local nConstitutionBonus = 0;
    local nSoulDeparture = 0;
    local nRoundsDying = 0;

	local nodeCT = ActorManager.getCTNode(rActor);
	if nodeCT then
		nMaxHits = math.max(DB.getValue(nodeCT, "hits", 0), 0);
		nWounds = math.max(DB.getValue(nodeCT, "wounds", 0), 0);
	elseif ActorManager.isPC(rActor) then
		local nodePC = ActorManager.getCreatureNode(rActor);
		if nodePC then
			nMaxHits = math.max(DB.getValue(nodePC, "hits.total", 0), 0);
            nConstitution = DB.getValue(nodePC, "stats.constitution", 0);
            nConstitutionBonus = DB.getValue(nodePC, "stats.constitution.total", 0);
            nSouldDeparture = DB.getValue(nodePC, "hits.souldeparture", 0);
            nRoundsDying = DB.getValue(nodePC, "hits.roundsdying", 0);
			nWounds = math.max(DB.getValue(nodePC, "hits.wounds", 0), 0);
		end
	end
	
	local nPercentWounded = 0;
    local nDyingHitsThreshhold = nMaxHits + nConstitution;
    
	if nMaxHits > 0 then
		nPercentWounded = nWounds / nMaxHits;
	end
	
	local sStatus;
	if nPercentWounded >= 1 then
        if nWounds >= nDyingHitsThreshhold then
            if nRoundsDying >= (12 + nConstitutionBonus + nSoulDeparture) then
                sStatus = ActorHealthManager.STATUS_DEAD;
            else
                sStatus = ActorHealthManager.STATUS_DYING;
            end
        else
            sStatus = ActorHealthManager.STATUS_UNCONSCIOUS;
        end
	else
		sStatus = ActorHealthManager.getDefaultStatusFromWoundPercent(nPercentWounded);
	end
	
	return nPercentWounded, sStatus;
end

function getPCSheetWoundColor(nodePC)
	local nMaxHits = 0;
	local nWounds = 0;
	if nodePC then
		nMaxHits = math.max(DB.getValue(nodePC, "hits.total", 0), 0);
		nWounds = math.max(DB.getValue(nodePC, "hits.wounds", 0), 0);
	end

	local nPercentWounded = 0;
	if nMaxHits > 0 then
		nPercentWounded = nWounds / nMaxHits;
	end
	
	local sColor = ColorManager.getHealthColor(nPercentWounded, false);
	return sColor;
end

function hasTalent(rActor, s)
	if ActorManager.isPC(rActor) then
		return ActorManagerSMP.hasPCTalent(ActorManager.getCreatureNode(rActor), s);
	elseif ActorManager.isRecordType(rActor, "npc") then
		return false; --ActorManagerSMP.hasNPCTalent(ActorManager.getCreatureNode(rActor), s);
	end
	return false;
end

function hasPCTalent(nodeActor, s)
	return (ActorManagerSMP.getListRecordByName(nodeActor, "talentlist", s) ~= nil);
end

function getListRecordByName(nodeActor, sList, s)
	if not nodeActor or ((sList or "") == "") or ((s or "") == "") then
		return nil;
	end
	local sLower = StringManager.simplify(s);
	for _,v in ipairs(DB.getChildList(nodeActor, sList)) do
		if StringManager.simplify(DB.getValue(v, "name", "")) == sLower then
			return v;
		end
	end
	return nil;
end