-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _bInitialized = false;
function onInit()
	self.initValue();
	super.onInit();
	_bInitialized = true;
end

local _tLastOption,_tCurrentOption;
function initValue()
	_tLastOption = TokenManager.getTokenActiveOptions();
	_tCurrentOption = UtilityManager.copyDeep(_tLastOption);
	sub_buttons.subwindow.placement.setStringValue(_tCurrentOption.bUnder and "under" or "");
end

function onActivate(sAsset)
	if not _bInitialized then
		return;
	end
	_tCurrentOption.sAsset = sAsset;
	TokenManager.setTokenActiveOptions(_tCurrentOption);
end
function onPlacementChange()
	if not _bInitialized then
		return;
	end
	_tCurrentOption.bUnder = (sub_buttons.subwindow.placement.getStringValue() == "under");
	TokenManager.setTokenActiveOptions(_tCurrentOption);
end

function handleClear()
	TokenManager.setTokenActiveOptions();
end
function handleOK()
	close();
end
function handleCancel()
	TokenManager.setTokenActiveOptions(_tLastOption);
	close();
end
