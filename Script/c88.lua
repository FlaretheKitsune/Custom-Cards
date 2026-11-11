
-- Elemental Tyrant of Tempests - Chimera Aeralis
local s,id=GetID()
local SET_TYRANT=0x666
local CARD_MYSTICAL_SPACE_TYPHOON=5318639

s.listed_series={SET_TYRANT}
s.listed_names={CARD_MYSTICAL_SPACE_TYPHOON}

function s.initial_effect(c)

	-- Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Quick Effect: Respond to a Quick-Play Spell activation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)

end

-- Monsters that can be destroyed
function s.desfilter(c)
	return c:IsMonster()
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

-- At least 1 WIND monster must be selected
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
		and (Duel.GetMZoneCount(tp)>0
		or sg:IsExists(Card.IsInMainMZone,1,nil,tp))
end

-- Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)

	local c=e:GetHandler()
	local loc=Duel.IsPlayerAffectedByEffect(tp,88581108)
		and LOCATION_MZONE or 0

	local g=Duel.GetMatchingGroup(s.desfilter,tp,
		LOCATION_MZONE+LOCATION_HAND,loc,c)

	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and #g>=2
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,
		LOCATION_MZONE+LOCATION_HAND)

end

-- Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)

	local c=e:GetHandler()

	local loc=Duel.IsPlayerAffectedByEffect(tp,88581108)
		and LOCATION_MZONE or 0

	local g=Duel.GetMatchingGroup(s.desfilter,tp,
		LOCATION_MZONE+LOCATION_HAND,loc,c)

	if #g<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
		return
	end

	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,
		s.rescon,1,tp,HINTMSG_DESTROY)

	if not dg or #dg~=2 then return end

	local bothwind=dg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)==2

	if Duel.Destroy(dg,REASON_EFFECT)==2 then

		if not c:IsRelateToEffect(e) then return end

		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end

		-- If both destroyed monsters were WIND:
		-- Add up to 2 Mystical Space Typhoon
		if bothwind then

			local mg=Duel.GetMatchingGroup(s.mstfilter,tp,
				LOCATION_DECK+LOCATION_GRAVE,0,nil)

			if #mg>0 then

				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

				local sg=mg:Select(tp,1,math.min(2,#mg),nil)

				if #sg>0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				end

			end
		end
	end
end

-- Mystical Space Typhoon filter
function s.mstfilter(c)
	return c:IsCode(CARD_MYSTICAL_SPACE_TYPHOON)
		and c:IsAbleToHand()
end

-- Check Quick-Play Spell activation
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)

	return not Duel.IsDamageStep()
		and re
		and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler():IsType(TYPE_QUICKPLAY)

end

-- Cards that can be shuffled into the Deck
function s.tdfilter(c)
	return c:IsAbleToDeck()
end

-- Target up to 2 opponent cards
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chkc then
		return chkc:IsControler(1-tp)
			and chkc:IsLocation(LOCATION_ONFIELD)
			and s.tdfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(s.tdfilter,tp,
			0,LOCATION_ONFIELD,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g=Duel.SelectTarget(tp,s.tdfilter,tp,
		0,LOCATION_ONFIELD,1,2,nil)

	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,
		1-tp,LOCATION_ONFIELD)

end

-- Shuffle targeted cards into the Deck
function s.tdop(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)

	if not g then return end

	g=g:Filter(Card.IsRelateToEffect,nil,e)
	g=g:Filter(Card.IsAbleToDeck,nil)

	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end

end
