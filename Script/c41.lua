--Alpha-Cyber Calling
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x93) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Check for Synchro Summon
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.synchroop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.synchroop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanSpecialSummon(tp) then return end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_SYNCHRO)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x93),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_SYNCHRO)
		if #sg>0 then
			Duel.SynchroSummon(tp,sg:GetFirst())
		end
	end
	e:Reset()
end