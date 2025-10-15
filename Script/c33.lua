-- Alpha-Cyber Charged Dragon
-- Level 5 / LIGHT / Machine / Effect
-- 2100 ATK / 1600 DEF
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	
	-- Special Summon Tuner from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- Special Summon condition: Opponent controls a monster, you control none
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

-- Special Summon Tuner from Deck
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2323) and c:IsType(TYPE_TUNER) and c:IsLevelBelow(2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		if #tc>0 then
			-- Cannot be used as Synchro Material, except for a Machine monster
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(function(e,c) 
				if not c then return false end
				return not c:IsRace(RACE_MACHINE)
			end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:GetFirst():RegisterEffect(e1)
		end
	end
end