--Alpha-Cyber Resurgence
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsSetCard(0x2323) and c:IsMonster() and c:IsAbleToHand()
end

function s.spcheck(sg,e,tp,mg)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=#sg
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2323),tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
		local ct=math.min(2,g:GetCount())
		if ct==0 then return false end
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2323),tp,LOCATION_MZONE,0,1,nil) then
			return true
		else
			return ct>0
		end
	end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(2,g:GetCount())
	local spcheck=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2323),tp,LOCATION_MZONE,0,1,nil)
	local op=0
	if spcheck then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		op=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,ct,nil)
	e:SetLabel(op)
	Duel.SetTargetCard(sg)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
	end
end

function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local op=e:GetLabel()
	if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sg=g:Filter(s.spfilter,nil,e,tp)
		if #sg==0 then return end
		if #sg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=sg:Select(tp,1,1,nil)
		end
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			g:Sub(sg)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	else
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end