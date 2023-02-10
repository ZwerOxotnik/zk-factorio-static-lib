---@class ZKMarket
local market_util = {}


market_util.validation_rules = {
	---@param offer TechnologyModifier
	["give-item"] = function(offer)
		return (game.item_prototypes[offer.item] ~= nil)
	end,
	---@param offer TechnologyModifier
	["unlock-recipe"] = function(offer)
		return (game.recipe_prototypes[offer.item] ~= nil)
	end
}


---@param target LuaEntity
---@param offers Offer[]
---@return integer # amount of added offers
market_util.add_offers_safely = function(target, offers)
	local validation_rules = market_util.validation_rules
	local item_prototypes = game.item_prototypes
	local add_market_item = target.add_market_item
	local added_amount = 0
	for i = 1, #offers do
		local offer_data = offers[i]
		local prices = offer_data.price
		for j=1, #prices do
			local price_data = prices[j]
			if item_prototypes[price_data[1] or price_data.name] == nil then
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
market_util.add_offer_safely = function(target, offer_data)
	local item_prototypes = game.item_prototypes
	local prices = offer_data.price
	for j=1, #prices do
		local price_data = prices[j]
		if item_prototypes[price_data[1] or price_data.name] == nil then
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
market_util.add_offers = function(target, offers)
	local add_market_item = target.add_market_item
	for i = 1, #offers do
		local offer_data = offers[i]
		add_market_item(offer_data)
	end
end


return market_util
