--Alpha-Cyber Augmentation Sphere
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Cannot attack except with Alpha-Cyber Synchros
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) 
		return not c:IsSetCard(0x2323) or not c:IsType(TYPE_SYNCHRO)
	end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end

function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x93) and c:IsType(TYPE_MONSTER) and c:IsReleasableByEffect()
end

function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(0x2323) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and (c:GetLevel()==lv-1 or c:GetLevel()==lv+1)
end

function s.synfilter(c,mg)
	return c:IsSetCard(0x2323) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_MACHINE)
		and c:IsSynchroSummonable(nil,mg)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e,tp)
		if #g==0 then return false end
		for tc in aux.Next(g) do
			local lv=tc:GetLevel()
			if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,lv,e,tp) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g1==0 then return end
	local tc1=g1:GetFirst()
	local lv=tc1:GetLevel()
	
	if Duel.Release(tc1,REASON_EFFECT)==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if #g2==0 then return end
	local tc2=g2:GetFirst()
	
	if Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)>0 then
		local mg=Group.FromCards(tc1,tc2)
		Duel.AdjustAll()
		
		--Check for possible Synchro Summon
		local synchro_g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,mg)
		if #synchro_g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=synchro_g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
		end
	end
end