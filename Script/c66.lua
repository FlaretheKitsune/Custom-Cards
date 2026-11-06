--Bonding – Combustion Reaction
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon Fire Dragon
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
	
	--Protection effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)
end
s.listed_names={67} --Fire Dragon

function s.cfilter(c,tp)
	return (c:IsCode(15981690) or c:IsCode(58071123)) and c:IsReleasable() and (c:IsOnField() or c:IsLocation(LOCATION_HAND))
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
		return g:FilterCount(Card.IsCode,nil,15981690)>=1 and g:FilterCount(Card.IsCode,nil,58071123)>=2
	end
	
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	local sg=Group.CreateGroup()
	
	--Select 1 Carboneddon
	local carbon=g:Filter(Card.IsCode,nil,15981690)
	if #carbon>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local c1=carbon:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(c1)
	end
	
	--Select 2 Oxygeddon
	local oxy=g:Filter(Card.IsCode,nil,58071123)
	if #oxy>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local o1=oxy:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(o1)
		local oxy2=oxy:Filter(Card.IsCode,nil,58071123)
		if #oxy2>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local o2=oxy2:Select(tp,1,1,nil):GetFirst()
			sg:AddCard(o2)
		end
	end
	
	Duel.Release(sg,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsCode(67) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
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

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_PYRO))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffect(tp,eg,e,REPLACEMENT_FLAG)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end