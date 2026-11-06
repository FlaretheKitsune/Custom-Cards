--Bonding – A2O
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon Water Dragon – Tempest Form
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={73} --Water Dragon – Tempest Form

function s.cfilter(c,tp)
	return (c:IsCode(60) or c:IsCode(65)) and c:IsReleasable() and (c:IsOnField() or c:IsLocation(LOCATION_HAND))
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
		return g:FilterCount(Card.IsCode,nil,60)>=2 and g:FilterCount(Card.IsCode,nil,65)>=1
	end
	
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	local sg=Group.CreateGroup()
	
	--Select 2 Oxygeddon X
	local oxy=g:Filter(Card.IsCode,nil,60)
	if #oxy>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local o1=oxy:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(o1)
		local oxy2=oxy:Filter(Card.IsCode,nil,60)
		if #oxy2>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local o2=oxy2:Select(tp,1,1,nil):GetFirst()
			sg:AddCard(o2)
		end
	end
	
	--Select 1 Hydrogeddon X
	local hydro=g:Filter(Card.IsCode,nil,65)
	if #hydro>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local h1=hydro:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(h1)
	end
	
	Duel.Release(sg,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsCode(73) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end