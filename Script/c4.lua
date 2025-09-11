--[[
Underworld Necropolis
Field Spell Card

Effect:
Fiend monsters that are Special Summoned from the GY have their ATK doubled.
If this card would be destroyed, you can destroy 1 Fiend monster in your Deck instead.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	-- Double ATK of Fiend monsters Special Summoned from GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	
	-- Destruction replacement effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end

-- ATK Doubling Effect
function s.atkfilter(c,tp)
	return c:IsRace(RACE_FIEND) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsLocation(LOCATION_MZONE)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkfilter,1,nil,tp)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.atkfilter,nil,tp)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- Destruction Replacement Effect
function s.repfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_DECK,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			e:SetLabelObject(g:GetFirst())
			g:GetFirst():CreateEffectRelation(e)
			return true
		end
	end
	return false
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
	end
end
