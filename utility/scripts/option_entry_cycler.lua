-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onPreInitialize(sKey, tCustom)
	if tCustom then
		cycler.initialize(tCustom.labels, tCustom.values, tCustom.baselabel);
		self.setDefault(tCustom.baseval);
	end
end

local _sDefault = "";
function getDefault()
	return _sDefault;
end
function setDefault(s)
	_sDefault = s or "";
end

function setReadOnly(bValue)
	super.setReadOnly(bValue);

	cycler.setReadOnly(bValue);
	left.setVisible(not bValue);
	right.setVisible(not bValue);
end

function getDisplayValue()
	return cycler.getValue();
end
function getOptionValue()
	local sValue = cycler.getStringValue();
	if sValue == "" then
		sValue = self.getDefault();
	end
	return sValue;
end
function onSetOptionValue(s)
	if s == self.getDefault() then
		s = "";
	end
	cycler.setStringValue(s);
end
