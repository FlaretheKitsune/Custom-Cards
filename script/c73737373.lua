--Mokey Mokey Rebellion
local s,id=GetID()
function s.initial_effect(c)
	--Return summoned monsters and burn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x184}

--Condition: You control a Mokey Mokey Fusion
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x184) and c:IsType(TYPE_FUSION)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--Target summoned monsters
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #eg>0 end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,#eg,0,0)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x184)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end

--Return and burn
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x184)
			if ct>0 then
				Duel.Damage(1-tp,ct*500,REASON_EFFECT)
			end
		end
	end
end
