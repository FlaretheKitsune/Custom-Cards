-- Earthbound Immortal
local s,id=GetID()
s.listed_series={SET_EARTHBOUND_IMMORTAL}

function s.initial_effect(c)
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

	-- While you control a WATER monster, your opponent cannot activate monster effects in the GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)

	-- If this card's ATK is higher than its original ATK: Inflict 2600 damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(0,1)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
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

function s.waterfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.waterfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.aclimit(e,re,tp)
	return tp~=e:GetHandlerPlayer()
		and re:IsActiveType(TYPE_MONSTER)
		and re:GetActivateLocation()==LOCATION_GRAVE
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetFlagEffect(id)==0 and c:GetAttack()>c:GetBaseAttack()
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2600)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
		and c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		Duel.Damage(1-tp,2600,REASON_EFFECT)
	end
end