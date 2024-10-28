---@class ZOMarket_util
local market_util = {build = 3}


--[[
market_util.add_offers_safely(target, offers): integer -- amount of added offers
market_util.add_offer_safely(target, offer_data): boolean
market_util.add_offers(target, offers)
]]


market_util.validation_rules = {
	---@param offer TechnologyModifier
	["give-item"] = function(offer)
		return (prototypes.item[offer.item] ~= nil)
	end,
	---@param offer TechnologyModifier
	["unlock-recipe"] = function(offer)
		return (prototypes.recipe[offer.item] ~= nil)
	end,
	---@param offer TechnologyModifier
	["gun-speed"] = function(offer)
		return (prototypes.ammo_category[offer.ammo_category] ~= nil)
	end,
	---@param offer TechnologyModifier
	["ammo-damage"] = function(offer)
		return (prototypes.ammo_category[offer.ammo_category] ~= nil)
	end,
	---@param offer TechnologyModifier
	["turret-attack"] = function(offer)
		return (prototypes.entity[offer.turret_id] ~= nil)
	end
}


---@param target LuaEntity
---@param offers Offer[]
---@return integer # amount of added offers
function market_util.add_offers_safely(target, offers)
	local validation_rules = market_util.validation_rules
	local item_prototypes = prototypes.item
	local add_market_item = target.add_market_item
	local added_amount = 0
	for _, offer_data in pairs(offers) do
		local prices = offer_data.price
		for _, price_data in pairs(prices) do
			if item_prototypes[price_data.name] == nil then
				goto skip
			end
		end

		local offer = offer_data.offer
		local rule = validation_rules[offer.type]
		if rule and rule(offer) ~= true then
			goto skip
		end

		added_amount = added_amount + 1
		add_market_item(offer_data)
		:: skip ::
	end

	return added_amount
end


---@param target LuaEntity
---@param offer_data Offer
---@return boolean # is added
function market_util.add_offer_safely(target, offer_data)
	local item_prototypes = prototypes.item
	local prices = offer_data.price
	for j=1, #prices do
		local price_data = prices[j]
		if item_prototypes[price_data.name] == nil then
			return false
		end
	end

	local offer = offer_data.offer
	local rule = market_util.validation_rules[offer.type]
	if rule and rule(offer) ~= true then
		return false
	end

	target.add_market_item(offer_data)
	return true
end


---Please, use add_offers_safely(target, offers) instead
---@param target LuaEntity
---@param offers Offer[]
function market_util.add_offers(target, offers)
	local add_market_item = target.add_market_item
	for _, offer_data in pairs(offers) do
		add_market_item(offer_data)
	end
end


return market_util
