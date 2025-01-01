-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- CHARACTER SHEET DROPS
--

function addInfoDB(nodeChar, sClass, sRecord)
	-- Validate parameters
	if not nodeChar then
		return false;
	end
	
	if sClass == "reference_race" then
		CharSpeciesManager.addSpecies(nodeChar, sRecord);
	elseif sClass == "reference_racialtrait" then
		CharSpeciesManager.addSpeciesTrait(nodeChar, sRecord);

	elseif sClass == "reference_profession" then
		CharProfessionManager.addProfession(nodeChar, sRecord);

	elseif sClass == "reference_culture" then
		CharCultureManager.addCulture(nodeChar, sRecord);

	elseif sClass == "reference_talent" then
		CharTalentManager.addFeat(nodeChar, sRecord);

	elseif sClass == "reference_skill" then
		CharBuildDropManager.addSkillRecord(nodeChar, sRecord);

	else
		return false;
	end
	
	return true;
end

function addSkillRecord(nodeChar, sRecord)
    --TODO Add Skill to Character in the right Skill Category
end

function helperBuildAddStructure(nodeChar, sClass, sRecord, tData)
	if not nodeChar or ((sClass or "") == "") or ((sRecord or "") == "") then
		return nil;
	end

	local rAdd = { };
	rAdd.nodeSource = DB.findNode(sRecord);
	if not rAdd.nodeSource then
		return nil;
	end

	rAdd.sSourceClass = sClass;
	rAdd.sSourceName = StringManager.trim(DB.getValue(rAdd.nodeSource, "name", ""));

	rAdd.nodeChar = nodeChar;
	rAdd.sCharName = StringManager.trim(DB.getValue(nodeChar, "name", ""));

	rAdd.sSourceType = StringManager.simplify(rAdd.sSourceName);
	if rAdd.sSourceType == "" then
		rAdd.sSourceType = DB.getName(rAdd.nodeSource);
	end

	return rAdd;


end

function addFeature(rAdd)
	if not rAdd then
		return;
	end

	if CharBuildDropManager.checkFeatureSkipAdd(rAdd) then
		return;
	end

	CharBuildDropManager.addFeatureStandard(rAdd);

	if not CharBuildDropManager.checkFeatureSpecialHandling(rAdd) then
		CharBuildDropManager.checkFeatureDescription(rAdd);
	end

	CharBuildDropManager.checkFeatureActions(rAdd);
end
function checkFeatureSkipAdd(rAdd)
	if not rAdd then
		return true;
	end

    if rAdd.sSourceClass == "reference_racialtrait" then
		return CharSpeciesManager.checkSpeciesTraitSkipAdd(rAdd);
	elseif rAdd.sSourceClass == "reference_talent" then
		return CharTalentManager.checkTalentSkipAdd(rAdd);
	end

	return false;
end