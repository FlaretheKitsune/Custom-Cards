-- Elemental Tyrant of Inferno - Magma Colossus
local s,id=GetID()

function s.initial_effect(c)
	-- Special Summon this card from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- This card's original ATK is the number of FIRE monsters in your GY x 1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- At the start of the Damage Step, if this card battles an opponent's monster:
	-- You can destroy both battling monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetTarget(s.btdestg)
	e3:SetOperation(s.btdesop)
	c:RegisterEffect(e3)

	-- If destroyed by battle or card effect:
	-- Destroy all Spell/Trap cards on the field, then banish 2 FIRE and/or Fiend monsters
	-- from your GY; if both steps succeed, Special Summon this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

function s.spcostfilter(c,sc)
	return c~=sc
		and c:IsMonster()
		and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_FIEND))
		and c:IsAbleToRemoveAsCost()
end

function s.costcheck(sg,e,tp,mg)
	return #sg==2
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,
		LOCATION_HAND+LOCATION_GRAVE,0,nil,c)
	if chk==0 then
		return #g>=2
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.costcheck,0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.costcheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.atkval(e,c)
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,
		c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)
	return ct*1000
end

function s.btdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then
		return bc and bc:IsControler(1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(c,bc),2,tp,0)
end

function s.btdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and c:IsRelateToBattle() and bc:IsRelateToBattle() then
		Duel.Destroy(Group.FromCards(c,bc),REASON_EFFECT)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.stfilter(c)
	return c:IsSpellTrap()
end

function s.gravefilter(c)
	return c:IsMonster()
		and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_FIEND))
		and c:IsAbleToRemove()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.stfilter,tp,
				LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_GRAVE,0,2,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local g=Duel.GetMatchingGroup(s.stfilter,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.stfilter,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 or Duel.Destroy(g,REASON_EFFECT)==0 then return end

	local rg=Duel.GetMatchingGroup(s.gravefilter,tp,LOCATION_GRAVE,0,nil)
	if #rg<2 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=rg:Select(tp,2,2,nil)
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=2 then return end

	if c:IsRelateToEffect(e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end