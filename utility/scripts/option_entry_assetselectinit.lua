-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getDisplayValue()
	return UtilityManager.getAssetBaseFileName(asset.getValue());
end
function getOptionValue()
	return OptionsManager.getOption("INITIND");
end
function onSetOptionValue(s)
	local tData = TokenManager.getTokenActiveOptions();
	asset.setValue(tData.sAsset);
	if tData.bUnder then
		placement.setStringValue("under");
	else
		placement.setStringValue("");
	end
end

function onOptionPressed()
	if self.isReadOnly() then
		return;
	end
	Interface.openWindow("initind_select", "");
end
function handleDrop(draginfo)
	if not StringManager.contains({ "image", "portrait", "token" }, draginfo.getType()) then
		return;
	end
	local tData = TokenManager.getTokenActiveOptions();
	tData.sAsset = draginfo.getTokenData();
	TokenManager.setTokenActiveOptions(tData);
end
