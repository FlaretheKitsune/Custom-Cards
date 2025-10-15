--Alpha-Cyber Chimera Wyvern
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 "Cyber" Tuner + 1+ non-Tuner Machine monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x93),1,1,Synchro.NonTuner(Card.IsRace,RACE_MACHINE),1,99)
	
	--Gains 100 ATK for each banished "Alpha-Cyber" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) 
		return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_REMOVED,0,nil,0x2323)*100
	end)
	c:RegisterEffect(e1)
	
	--Quick Effect: Banish 1 "Cyber" monster from GY, then destroy 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end