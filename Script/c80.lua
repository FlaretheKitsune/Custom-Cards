-- Earthbound Immortal
local s,id=GetID()
s.listed_series={SET_EARTHBOUND_IMMORTAL}

function s.initial_effect(c)
	-- Only 1 copy of this card can be on the field
	c:SetUniqueOnField(1,0,id)

	-- Destroy this card if there is no face-up Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.sdop)
	c:RegisterEffect(e1)

	-- Opponent's monsters cannot target this card for attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- This card can attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)

	-- If this card is Normal Summoned: Discard 1 to 3 cards, then gain 500 ATK for each discarded
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(s.attg)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)
end

function s.fieldfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FIELD)
end

function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and not Duel.IsExistingMatchingCard(
		s.fieldfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil
	) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.DiscardHand(tp,aux.TRUE,1,3,REASON_EFFECT+REASON_DISCARD)
	if ct>0 then
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end