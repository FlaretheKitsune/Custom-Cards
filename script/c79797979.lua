--Mokey Mokey Metamorphosis
local s,id=GetID()
function s.initial_effect(c)
	--Always treated as "Polymerization"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK)
	e0:SetValue(24094653) -- "Polymerization"
	c:RegisterEffect(e0)

	--Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY effect: Add 1 Mokey Mokey monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={24094653,27288416} -- Polymerization, Mokey Mokey
s.listed_series={0xb2} -- Mokey Mokey archetype (example, update if yours is 184)

--Fusion Summon
function s.fusfilter(c,e,tp,mg,f,chkf)
	return c:IsSetCard(0xb2) and c:IsType(TYPE_FUSION) and c:IsLevelBelow(12) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetFusionMaterial(tp)
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,3,nil,27288416) then
			mg:Merge(Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil))
		end
		return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg=Duel.GetFusionMaterial(tp)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,3,nil,27288416) then
		mg:Merge(Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil))
	end
	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
		tc:SetMaterial(mat)
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

--GY Search effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
function s.thfilter(c)
	return c:IsSetCard(0xb2) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
