-- Alpha-Cyber Accelerator
-- Level 4 / LIGHT / Machine / Effect
-- 1800 ATK / 1000 DEF
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon a Tuner when Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Banish from GY to change Levels
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end

-- Special Summon a Tuner
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2323) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Banish to change Levels
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x93) and c:HasLevel() and not c:IsLevel(0)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	
	local op=0
	if g:IsExists(Card.IsLevel,1,nil,1) then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	end
	
	local val=op==0 and 1 or -1
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end