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

	-- Copy a face-up monster's ATK, name, and effects; weaken and negate that monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.copytg)
	e4:SetOperation(s.copyop)
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

function s.monsterfilter(c)
	return c:IsFaceup()
end

function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and s.monsterfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.monsterfilter,tp,
			LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.monsterfilter,tp,
		LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

	local atk=tc:GetAttack()
	local code=tc:GetOriginalCode()

	-- This card gains ATK equal to the targeted monster's ATK
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)

		-- This card's name becomes the targeted monster's original name
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(code)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)

		-- This card copies the targeted monster's effects until the End Phase
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end

	-- The targeted monster loses 500 ATK/DEF and has its effects negated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-500)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(-500)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e5)

	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	e6:SetValue(RESET_TURN_SET)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e6)

	-- Inflict 500 damage to your opponent
	Duel.Damage(1-tp,500,REASON_EFFECT)
end