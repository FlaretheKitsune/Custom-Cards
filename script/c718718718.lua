--[[
Mokey Mokey Lazy Cataclysm
LIGHT / Fairy / Fusion / Level 9
ATK 0 / DEF 2500
Materials: "Mokey Mokey the Forbidden One" + 3 "Mokey Mokey" monsters
Effect:
If this card is Fusion Summoned: Destroy all monsters your opponent controls with ATK higher than this card. Once per turn (Quick Effect): You can banish 1 "Mokey Mokey" monster from your GY; this card gains 1000 ATK for each "Mokey Mokey" card in your GY until the end of this turn.
--]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	
	-- Fusion Material
	local f1=aux.FilterBoolFunction(Card.IsCode,72072072) -- "Mokey Mokey the Forbidden One"
	local f2=aux.FilterBoolFunction(Card.IsSetCard,0x184) -- "Mokey Mokey" archetype
	Fusion.AddProcMix(c,true,true,f1,f2,f2,f2)
	
	-- Must be properly summoned before reviving
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	
	-- Destroy opponent's higher ATK monsters on summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	
	-- Quick Effect: Banish 1 "Mokey Mokey" from GY to gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk+1)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local atk=c:GetAttack()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end

function s.cfilter(c)
	return (c:IsCode(12482652) or c:IsSetCard(0x184)) and c:IsAbleToRemoveAsCost()
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=Duel.GetMatchingGroupCount(function(c) 
			return c:IsCode(12482652) or c:IsSetCard(0x184) 
		end,tp,LOCATION_GRAVE,0,nil)
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*1000)
		c:RegisterEffect(e1)
	end
end
