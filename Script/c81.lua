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

	-- Your "Earthbound Immortal" monsters can attack in Defense Position using their DEF
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_FIELD)
e4:SetCode(EFFECT_DEFENSE_ATTACK)
e4:SetValue(1)
e4:SetRange(LOCATION_MZONE)
e4:SetTargetRange(LOCATION_MZONE,0)
e4:SetTarget(s.deftg)
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

function s.deftg(e,c)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end

c12345678=Card(81)