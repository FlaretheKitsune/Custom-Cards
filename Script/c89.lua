-- Elemental Tyrant of the Abyss - Leviathan
local s,id=GetID()

function s.initial_effect(c)
	-- Banish 2 WATER and/or Sea Serpent monsters from your hand and/or GY;
	-- Special Summon this card from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Opposing monsters lose ATK equal to their original ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- If destroyed by battle or card effect: Special Summon up to 2 WATER monsters
	-- except this card from your GY in face-up Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

function s.banishfilter(c)
	return c:IsMonster()
		and (c:IsAttribute(ATTRIBUTE_WATER) or c:IsRace(RACE_SEASERPENT))
		and c:IsAbleToRemoveAsCost()
end

function s.costcheck(sg,e,tp,mg)
	return #sg==2
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.banishfilter,tp,
		LOCATION_HAND+LOCATION_GRAVE,0,c)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #g>=2
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.costcheck,0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.costcheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.atkval(e,c)
	return -c:GetBaseAttack()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.gyfilter(c,e,tp)
	return c~=e:GetHandler()
		and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ct=math.min(2,#g,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_GRAVE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<=0 then return end
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,math.min(ct,#g),nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end