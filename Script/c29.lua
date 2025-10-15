-- Alpha-Cyber Synchronizer
-- Level 2 / LIGHT / Machine / Tuner / Effect
-- 800 ATK / 600 DEF
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if you control an "Alpha Cyber" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Excavate and Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.extg)
	e2:SetOperation(s.exop)
	c:RegisterEffect(e2)
end

-- Special Summon condition: Control an "Alpha Cyber" monster
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2323) -- Assuming 0x1093 is the set code for "Alpha-Cyber"
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

-- Excavate and Special Summon effect
function s.exfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2323) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToDeck,nil)==3
		return result
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	
	-- Excavate 3 cards
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.DisableShuffleCheck()
	
	-- Check for summonable monsters
	local sg=g:Filter(s.exfilter,nil,e,tp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	local sumcount=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	
	if #sg>0 and ft>0 and (sumcount==0 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,math.min(ft,#sg),nil):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			g:RemoveCard(sc)
		end
		Duel.SpecialSummonComplete()
	end
	
	-- Return remaining cards to deck
	if #g>0 then
		Duel.SortDecktop(tp,tp,#g)
		for i=1,#g do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),1)
		end
	end
end