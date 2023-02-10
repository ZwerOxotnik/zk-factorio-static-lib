---@class ZKMarket
local market = {}


market.validation_rules = {
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
market.add_offers_safely = function(target, offers)
	local validation_rules = market.validation_rules
	local item_prototypes = game.item_prototypes
	local add_market_item = target.add_market_item
	local added_amount = 0
	for i = 1, #offers do
		local offer_data = offers[i]
		local prices = offer_data.price
		for j=1, #prices do
			local price = prices[j]
			if item_prototypes[price.name] == nil then
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


---Please, use add_offers_safely(target, offers) instead
---@param target LuaEntity
---@param offers Offer[]
market.add_offers = function(target, offers)
	local add_market_item = target.add_market_item
	for i = 1, #offers do
		local offer_data = offers[i]
		add_market_item(offer_data)
	end
end


return market
