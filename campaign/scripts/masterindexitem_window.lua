-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local m_sRecordType = "";
local m_bShared = false;

function onInit()
	local node = getDatabaseNode();
	
	if modified then
		local sModule = DB.getModule(node);
		if (sModule or "") ~= "" then
			modified.setVisible(true);
			modified.setTooltipText(sModule);
			if not DB.isReadOnly(node) then
				DB.addHandler(node, "onIntegrityChange", self.onIntegrityChange);
				self.onIntegrityChange(node);
			end
		end
	end

	DB.addHandler(node, "onObserverUpdate", self.onObserverUpdate);
	self.onObserverUpdate(node);
	
	self.onCategoryChange(node);
end
function onClose()
	local node = getDatabaseNode();
	if modified then
		local sModule = DB.getModule(node);
		if (sModule or "") ~= "" then
			if not DB.isReadOnly(node) then
				DB.removeHandler(node, "onIntegrityChange", self.onIntegrityChange);
			end
		end
	end
	DB.removeHandler(node, "onObserverUpdate", self.onObserverUpdate);
end

function setRecordType(sNewRecordType)
	if m_sRecordType == sNewRecordType then
		return;
	end
		
	m_sRecordType = sNewRecordType
	
	local node = getDatabaseNode();
	local sRecordDisplayClass = RecordDataManager.getRecordTypeDisplayClass(m_sRecordType, node);
	link.setValue(sRecordDisplayClass, getDatabasePath());
	
	local sEmptyNameText = RecordDataManager.getRecordTypeDisplayTextEmpty(m_sRecordType);
	name.setEmptyText(sEmptyNameText);
	
	if isidentified and nonid_name then
		if RecordDataManager.isIdentifiable(m_sRecordType, node) then
			nonid_name.setEmptyText(RecordDataManager.getRecordTypeDisplayTextEmptyUnidentified(m_sRecordType));
			self.onIDChanged();
		end
	end
end

function buildMenu()
	resetMenuItems();
	
	if modified and not DB.isIntact(getDatabaseNode()) then
		registerMenuItem(Interface.getString("menu_revert"), "shuffle", 8);
	end
	if m_bShared then
		registerMenuItem(Interface.getString("windowunshare"), "windowunshare", 7);
	else
		registerMenuItem(Interface.getString("windowshare"), "windowshare", 7);
	end
end
function onMenuSelection(selection)
	if selection == 7 then
		self.toggleRecordSharing();
	elseif selection == 8 then
		RecordManager.performRevertByWindow(self);
	end
end

function onIDChanged()
	local bID = RecordDataManager.getIDState(m_sRecordType, getDatabaseNode());
	name.setVisible(bID);
	nonid_name.setVisible(not bID);
end
function onIntegrityChange()
	if modified.update then
		modified.update();
	else
		if not DB.isIntact(getDatabaseNode()) then
			modified.setIcon("record_dirty");
		else
			modified.setIcon("record_intact");
		end
	end
	self.buildMenu();
end
function onObserverUpdate()
	local node = getDatabaseNode();
	if owner then
		owner.setValue(DB.getOwner(node));
	end
	
	local nAccess, aHolderNames = UtilityManager.getNodeAccessLevel(node);
	access.setValue(nAccess);
	if Session.IsHost then
		if nAccess == 2 then
			m_bShared = true;
		elseif nAccess == 1 then
			local sShared = Interface.getString("tooltip_shared") .. " " .. table.concat(aHolderNames, ", ");
			access.setStateTooltipText(1, sShared);
			m_bShared = true;
		else
			m_bShared = false;
		end
		self.buildMenu();
	end
end
function onCategoryChange()
	if category then
		local sCategory = DB.getCategory(getDatabaseNode());
		category.setValue(sCategory);
		category.setTooltipText(sCategory);
	end
end

function toggleRecordSharing()
	if m_bShared then
		self.unshareRecord();
	else
		self.shareRecord();
	end
end
function unshareRecord()
	if not Session.IsHost then
		return;
	end
	
	local node = getDatabaseNode();
	if DB.isPublic(node) then
		DB.setPublic(node, false);
	else
		DB.removeAllHolders(node, true);
	end
end
function shareRecord()
	if not Session.IsHost then
		return;
	end

	DB.setPublic(getDatabaseNode(), true);
end
