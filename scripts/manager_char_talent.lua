-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function addTalent(nodeChar, sRecord, tData)
	local rAdd = CharBuildDropManager.helperBuildAddStructure(nodeChar, "reference_talent", sRecord, tData);
	CharTalentManager.helperAddTalentMain(rAdd);
end

function helperAddTalentMain(rAdd)
	CharBuildDropManager.addFeature(rAdd);
end
function checkTalentSkipAdd(rAdd)
	-- Skip if talent already exists, and is not repeatable
	if DB.getValue(rAdd.nodeSource, "repeatable", 0) ~= 1 then
		if CharManager.hasTalent(rAdd.nodeChar, rAdd.sSourceName) then
			return true;
		end
	end

	return false;
end

function hasTalent(nodeChar, s)
	return ActorManagerSMP.hasPCTalent(nodeChar, s);
end