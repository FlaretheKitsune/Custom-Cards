local s, id = GetID()
function s.initial_effect(c)
	-- Enable Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c, true, true, 79979666, 84327329) -- Elemental HERO Bubbleman + Elemental HERO Clayman

	-- Special Summon Condition
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	-- Cannot be targeted by opponent's card effects while you control another "HERO" monster
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.indcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	-- Draw Cards
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)

	-- Attack while in Defense Position using DEF for damage calculation
	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DEFENSE_ATTACK)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end

function s.spfilter(c, code)
	return c:IsCode(code) and c:IsAbleToDeckAsCost()
end

function s.spcon(e, c)
	if c == nil then return true end
	local tp = c:GetControler()
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
		   Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil, 79979666) and
		   Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil, 84327329)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
	local g1 = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, 1, nil, 79979666)
	local g2 = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, 1, nil, 84327329)
	g1:Merge(g2)
	Duel.SendtoDeck(g1, nil, 2, REASON_COST)
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsSetCard, 0x8), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, e:GetHandler())
end

function s.drcon(e)
	return Duel.IsTurnPlayer(e:GetHandlerPlayer())
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
	local ct = Duel.GetMatchingGroupCount(Auxiliary.FaceupFilter(Card.IsSetCard, 0x8), tp, LOCATION_MZONE, 0, nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(math.min(2, ct))
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, math.min(2, ct))
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
	local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
	local ct = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
	if ct > 0 then
		Duel.Draw(p, ct, REASON_EFFECT)
	end
end
