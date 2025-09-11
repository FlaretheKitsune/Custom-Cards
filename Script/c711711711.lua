--Mokey Mokey Happy
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),1,2)
	c:EnableReviveLimit()
	--Attach Mokey Mokey from hand or field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--3+ materials: Mokey Mokey monsters cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon3)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x184))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--4+ materials: You take no damage from battles involving this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetCondition(s.indcon4)
	c:RegisterEffect(e3)
	--5+ materials: Special Summon Mokey Mokey
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.indcon5)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x184}

--filters for attaching
function s.mtfilter_field(c)
	return c:IsFaceup() and c:IsSetCard(0x184) and not c:IsType(TYPE_TOKEN)
end
function s.mtfilter_hand(c)
	return c:IsSetCard(0x184) and not c:IsType(TYPE_TOKEN)
end

--Attach effect
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.mtfilter_field,tp,LOCATION_MZONE,0,1,e:GetHandler())
			or Duel.IsExistingMatchingCard(s.mtfilter_hand,tp,LOCATION_HAND,0,1,nil)
	end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.mtfilter_field,tp,LOCATION_MZONE,0,c)
	local g2=Duel.GetMatchingGroup(s.mtfilter_hand,tp,LOCATION_HAND,0,nil)
	local g=g1:Clone()
	g:Merge(g2)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			Duel.Overlay(c,tc)
		end
	end
end

--3+ materials condition
function s.indcon3(e)
	return e:GetHandler():GetOverlayCount()>=3
end
--4+ materials condition
function s.indcon4(e)
	return e:GetHandler():GetOverlayCount()>=4
end
--5+ materials condition
function s.indcon5(e)
	return e:GetHandler():GetOverlayCount()>=5
end

--Cost for Special Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
--Special Summon target
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x184) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
--Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
