
--Liquid Oxygeddon
--WATER / Dinosaur / Level 4
--ATK 1100 / DEF 800

local s,id=GetID()

function s.initial_effect(c)
	--Name becomes Oxygeddon in hand and GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetValue(58071123)
	c:RegisterEffect(e1)

	--Double ATK during Damage Step when battling FIRE or Pyro
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--If this card destroys a FIRE monster by battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)

	--If this card is Tributed: Special Summon up to 2 Dinosaurs
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

--ATK doubling condition
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc
		and (bc:IsAttribute(ATTRIBUTE_FIRE)
		or bc:IsRace(RACE_PYRO))
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end

	local atk=c:GetAttack()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end

--Battle destruction condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc
		and bc:IsAttribute(ATTRIBUTE_FIRE)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(0,800,REASON_EFFECT)
	Duel.Damage(1,800,REASON_EFFECT)
end

--Check that Liquid Oxygeddon was Tributed
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end

--Special Summon filter
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR)
		and (c:IsAttribute(ATTRIBUTE_EARTH)
		or c:IsAttribute(ATTRIBUTE_WIND))
		and c:IsLevelBelow(5)
		and c:IsCanBeSpecialSummoned(
			e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

--Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end

	local ct=math.min(2,ft)

	if Duel.IsPlayerAffectedByEffect(
		tp,CARD_BLUEEYES_SPIRIT) then
		ct=math.min(ct,1)
	end

	if ct<=0 then return end

	if not Duel.IsExistingMatchingCard(
		s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(
		tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)

	if #g>0 then
		Duel.SpecialSummon(
			g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
