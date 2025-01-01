-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ItemManager.setCustomCharAdd(CharManager.onCharItemAdd);
	ItemManager.setCustomCharRemove(CharManager.onCharItemDelete);

	if Session.IsHost then
		CharInventoryManager.enableInventoryUpdates();
		CharInventoryManager.enableSimpleLocationHandling();
	end
end

function onCharItemAdd(nodeItem)
	DB.setValue(nodeItem, "carried", "number", 1);
end

function onSpeciesLinkPressed(nodeChar)
	local _, sRecord = DB.getValue(nodeChar, "racelink", "", "");
	if CharManager.helperOpenLinkRecord("race", sRecord) then
		return true;
	end
	local sName = DB.getValue(nodeChar, "racename", "");
	CharManager.helperOpenLinkRecordFail("race", sRecord);
	return false;
end

function helperOpenLinkRecord(sRecordType, sRecord)
	if ((sRecord or "") == "") or ((sRecordType or "") == "") then
		return false;
	end
	local nodeRecord = DB.findNode(sRecord);
	if nodeRecord then
		local sDisplayClass = RecordDataManager.getRecordTypeDisplayClass(sRecordType, nodeRecord);
		Interface.openWindow(sDisplayClass, nodeRecord);
		return true;
	end
	return false;
end
