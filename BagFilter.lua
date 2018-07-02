if not IsAddOnLoaded('ElvUI') then return; end

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags');

local U = select(2, ...);
local L = {};

local function SetSlotFilter(self, bagID, slotID)
    local f = B:GetContainerFrame(bagID > NUM_BAG_SLOTS or bagID == BANK_CONTAINER);
    if not (f and f.FilterHolder) then return; end

    if f.FilterHolder.active and self.Bags[bagID] and self.Bags[bagID][slotID] then
        local link = GetContainerItemLink(bagID, slotID);
        if not link or f.FilterHolder[f.FilterHolder.active].filter(select(6, GetItemInfo(link))) then
            self.Bags[bagID][slotID].searchOverlay:Hide();
        elseif f.FilterHolder[f.FilterHolder.active].ttText ~= L.All and f.FilterHolder[f.FilterHolder.active].ttText ~= L.Equipment and -- Equipmentset start
               f.FilterHolder[f.FilterHolder.active].ttText ~= L.Usable and f.FilterHolder[f.FilterHolder.active].ttText ~= L.Quest and
               f.FilterHolder[f.FilterHolder.active].ttText ~= L.TradeGood and f.FilterHolder[f.FilterHolder.active].ttText ~= L.Misc and
               f.FilterHolder[f.FilterHolder.active].filter(f.FilterHolder[f.FilterHolder.active].ttText, link) then
            self.Bags[bagID][slotID].searchOverlay:Hide(); -- Equipmentset end
        else
            self.Bags[bagID][slotID].searchOverlay:Show();
        end
    end
end

local function SetFilter(self)
    local f = B:GetContainerFrame(self.isBank);
    if not (f and f.FilterHolder) then return; end

    for i = 1, U.numFilters do
        if i ~= self:GetID() then
            f.FilterHolder[i]:SetChecked(nil);
        end
    end
    f.FilterHolder.active = self:GetID();
        
	for i, bagID in ipairs(f.BagIDs) do
        if f.Bags[bagID] then
   			for slotID = 1, f.Bags[bagID].numSlots do
                SetSlotFilter(f, bagID, slotID);
            end
        end
    end
end

local function ResetFilter(self)
    local f = B:GetContainerFrame(self.isBank);
    if not (f and f.FilterHolder) then return; end

    if f.FilterHolder.active then
        f.FilterHolder[f.FilterHolder.active]:SetChecked(nil);
        f.FilterHolder.active = nil;
        
        for i, bagID in ipairs(f.BagIDs) do
            if f.Bags[bagID] then
                for slotID = 1, f.Bags[bagID].numSlots do
                    if f.Bags[bagID][slotID] then
                        f.Bags[bagID][slotID].searchOverlay:Hide();
                    end
                end
            end
        end
    end
end
    
local function AddFilterButtons(f, isBank)
	local buttonSize = isBank and B.db.bankSize or B.db.bagSize;
	local buttonSpacing = E.PixelMode and 2 or 4;
    local lastContainerButton;
    
    for i, filter in ipairs(U.Filters) do
        if not f.FilterHolder[i] then
            local name, icon, func = unpack(filter);

            f.FilterHolder[i] = CreateFrame('CheckButton', nil, f.FilterHolder, 'ItemButtonTemplate');
            f.FilterHolder[i]:SetTemplate('Default', true);
            f.FilterHolder[i]:StyleButton();
            f.FilterHolder[i]:SetNormalTexture('');
            f.FilterHolder[i]:SetPushedTexture('');
            f.FilterHolder[i].ttText = name;
            f.FilterHolder[i].filter = func;
            f.FilterHolder[i].isBank = isBank;
            f.FilterHolder[i]:SetScript('OnEnter', B.Tooltip_Show);
            f.FilterHolder[i]:SetScript('OnLeave', B.Tooltip_Hide);
            f.FilterHolder[i]:SetScript('OnClick', SetFilter);
            f.FilterHolder[i]:SetScript('OnHide', ResetFilter);
            f.FilterHolder[i]:SetID(i);
            
            local tex = f.FilterHolder[i]:CreateTexture(nil, 'OVERLAY');
			tex:SetTexture(0.9, 0.8, 0.1, 0.3);
			tex:SetInside();
			f.FilterHolder[i]:SetCheckedTexture(tex);
            
            f.FilterHolder[i].icon:SetTexture(icon);
            f.FilterHolder[i].icon:SetInside();
            f.FilterHolder[i].icon:SetTexCoord(unpack(E.TexCoords));
        end
        
        f.FilterHolder:Size(((buttonSize + buttonSpacing) * i) + buttonSpacing, buttonSize + (buttonSpacing * 2));
          
        f.FilterHolder[i]:Size(buttonSize);
        f.FilterHolder[i]:ClearAllPoints();
        if i == 1 then
            f.FilterHolder[i]:SetPoint('BOTTOMLEFT', f.FilterHolder, 'BOTTOMLEFT', buttonSpacing, buttonSpacing)
        else
            f.FilterHolder[i]:SetPoint('LEFT', lastContainerButton, 'RIGHT', buttonSpacing, 0);
        end
        
        lastContainerButton = f.FilterHolder[i];
    end
end

local function AddMenuButton(isBank)
	if E.private.bags.enable ~= true then return; end
	local f = B:GetContainerFrame(isBank);
	
	if not f or f.FilterHolder then return; end
    f.FilterHolder = CreateFrame('Button', nil, f);
	f.FilterHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1);
	f.FilterHolder:SetTemplate('Transparent');
	f.FilterHolder:Hide();
    
    local buttonColor = E.PixelMode and {0.31, 0.31, 0.31} or E.media.bordercolor;
    f.filterButton = CreateFrame('Button', nil, f);
    f.filterButton:Point('RIGHT', f.bagsButton, 'LEFT', -3, 0);
    f.filterButton:Size(55, 10);
    f.filterButton:SetTemplate('Default', true);
    f.filterButton.backdropTexture:SetVertexColor(unpack(buttonColor));
	f.filterButton.backdropTexture.SetVertexColor = E.noop;
    f.filterButton.ttText = L.Filter;
    f.filterButton:SetScript('OnEnter', B.Tooltip_Show);
    f.filterButton:SetScript('OnLeave', B.Tooltip_Hide);
    f.filterButton:SetScript('OnClick', function() 
        f.ContainerHolder:Hide();
        ToggleFrame(f.FilterHolder);
    end);
    
	f.bagsButton:HookScript('OnClick', function()
        f.FilterHolder:Hide();
    end);
    
    -- realign
    if isBank then
        f.sortButton:Point('TOPRIGHT', f, 'TOP', 29, -4);
    else
		f.sortButton:Point('TOP', f, 'TOP', 29, -4);
    end

    AddFilterButtons(f, isBank);
 end

do
    L.Weapon, L.Armor, L.Container, L.Consumable, L.Glyph, L.TradeGood, L.Recipe, L.Gem, L.Misc, L.Quest, L.BattlePets = GetAuctionItemClasses();
	L.Devices, L.Explosives = select(10, GetAuctionItemSubClasses(6));
    L.All = ALL;
    L.Equipment = L.Weapon .. ' & ' .. L.Armor;
    L.Usable = USABLE_ITEMS;
    L.Filter = FILTER;
    
    U.Filters = {
        { L.All, 'Interface/Icons/INV_Misc_EngGizmos_17', 
          function(type, subType) 
              return true;
          end
        },
        { L.Equipment, 'Interface/Icons/INV_Chest_Chain_04', 
          function(type, subType) 
              return type == L.Armor or type == L.Weapon; 
          end
        },
        { L.Usable, 'Interface/Icons/INV_Potion_93', 
          function(type, subType) 
              if type == L.Consumable then
                  return true;
              elseif type == L.TradeGood then
                  if subType == L.Devices or subType == L.Explosives then
                      return true;
                  end
              end 
          end
        },
        { L.Quest, 'Interface/QuestFrame/UI-QuestLog-BookIcon',
          function(type, subType)
              return type == L.Quest;
          end
        },
        { L.TradeGood, 'Interface/Icons/INV_Fabric_Silk_02',
          function(type, subType)
              if type == L.TradeGood then
                  return not(subType == L.Devices or subType == L.Explosives);
              end
              return type == L.Recipe or type == L.Gem;
          end
        },
        { L.Misc, 'Interface/Icons/INV_Misc_Rune_01',
          function(type, subType)
              return type == L.Misc;
          end
        },
    };        
    for y = 1, GetNumEquipmentSets() do -- Equipmentset start
        local name, icon, _ = GetEquipmentSetInfo(y)
        if name then
            table.insert(U.Filters, { name, icon,
                function(sname, link)
                    if sname == name then
                        local match = false
                        local itemArray = GetEquipmentSetItemIDs(name)
                        if itemArray == nil then -- Equipmentset deleted
                            return match
                        end
                        local itemString = string.match(link, "item[%-?%d:]+")
                        if itemString == nil then -- Something wrong with item link (maybe Equipments set has same name as hard coded categories?)
                            return match
                        end
                        local itemId = select(2, strsplit(":", itemString))
                        for i = 1, 19 do
                            if itemArray[i] == tonumber(itemId) then
                                match = true
                                break
                            end
                        end
                        return match                        
                    end
                end
            })
        end
    end -- Equipmentset end
       
    U.numFilters = #U.Filters;
    
    hooksecurefunc(B, 'Layout', function(self, isBank)
        AddMenuButton(isBank);
    end);
    
    hooksecurefunc(B, 'UpdateSlot', SetSlotFilter);
end