--Alpha-Cyber Circuit Burst
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.rmfilter(c)
	return c:IsSetCard(0x2323) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
		return #g>0 and Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,#g,nil)
	e:SetLabel(#rg)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=dg:Select(tp,1,#rg,nil)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end