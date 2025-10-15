--Alpha-Cyber Distress Signal
--Scripted by YourName
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end

function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x2323) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x2323) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.synfilter(c,mg)
	return c:IsSetCard(0x2323) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mg)
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsType,1,nil,TYPE_TUNER) and sg:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE,0,nil,e,tp)
		local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_GRAVE,0,nil,e,tp)
		return #g1>0 and #g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	
	--Select and Special Summon 1 Tuner
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g1==0 then return end
	
	--Select and Special Summon 1 non-Tuner
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g2==0 then return end
	
	g1:Merge(g2)
	local tc1=g1:GetFirst()
	local tc2=g1:GetNext()
	
	--Special Summon both monsters
	if Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP) 
		and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
		
		Duel.SpecialSummonComplete()
		local mg=Group.FromCards(tc1,tc2)
		
		--Check for possible Synchro Summon
		local synchro_g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,mg)
		if #synchro_g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=synchro_g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
		end
	else
		Duel.SpecialSummonComplete()
	end
end