-- Earthbound support card
local s,id=GetID()
local CARD_EARTHBOUND_GLYPH=44710391

s.listed_names={CARD_EARTHBOUND_GLYPH}
s.listed_series={SET_EARTHBOUND_IMMORTAL}

function s.initial_effect(c)
	-- When activated: You can activate "Earthbound Geoglyph" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- During your Draw Phase: Special Summon an "Earthbound Immortal"
	-- from your hand or GY instead of conducting your normal draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.drawcon)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)

	-- During your End Phase: Pay 500 LP or destroy this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.lpcon)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)

	-- Once per turn during your Main Phase: Shuffle 1 card from your hand into the Deck, then draw 2
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end

function s.geofilter(c,tp)
	local ae=c:GetActivateEffect()
	return c:IsCode(CARD_EARTHBOUND_GLYPH)
		and ae and ae:IsActivatable(tp,true,true)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.GetMatchingGroup(s.geofilter,tp,LOCATION_DECK,0,nil,tp)
	if #g==0 or not Duel.SelectYesNo(tp,94) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc and Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
		-- While Geoglyph is in the Field Zone, cards in either Field Zone cannot be targeted
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end

function s.immfilter(c,e,tp)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.immfilter,tp,
			LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not Duel.SelectYesNo(tp,94) then return end

	local g=Duel.GetMatchingGroup(s.immfilter,tp,
		LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if not tc then return end

	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.SpecialSummonComplete()

		-- Replace this Draw Phase's normal draw with 0 cards
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		Duel.RegisterEffect(e1,tp)
	else
		Duel.SpecialSummonComplete()
	end
end

function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,94) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end

function s.deckfilter(c)
	return c:IsAbleToDeck()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if ct>0 then
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end