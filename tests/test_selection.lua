-- Production scanner/filter/UI callbacks; all native/server inputs are doubles.
return function(A,frames,ok,advance)
 local p=A:Profile();A:StopScan("test");A:ClearCandidates()
 p.hcMode="all";p.minLevel=10;p.maxLevel=110;p.activeFilters={};p.excludedClasses={};p.contacts={};GR735DB.filters={}
 local function person(name,level,guild,class)return{name=name,level=level or 28,guild=guild or "",classFile=class or"MAGE",class="Mage",race="Human",zone="Zone"}end
 local function rule(kind,needle,explicit)
  GR735DB.filters={{id="case",kind=kind,needle=needle,title="test",match=explicit}};p.activeFilters={case=true}
 end
 rule("name","x7")
 ok(not A:FilterHit(person("Alex7-plusx1")),"legacy x7 does not hit character-name substring")
 ok(A:FilterHit(person("Ordinary-plusx7")),"legacy x7 hits exact world")
 ok(not A:FilterHit(person("Ordinary-plusx70")),"world x7 not world x70")
 rule("realm","plusx7","explicit")
 ok(not A:FilterHit(person("Alex7-plusx1"))and A:FilterHit(person("A-x7")),"explicit world aliases and identity")
 ok(not A:FilterHit(person("WithoutSuffix")),"bare name uses current plusx1 world")
 rule("name","Alex7","explicit")
 ok(A:FilterHit(person("Alex7-plusx1")),"intentional name substring remains supported")
 GR735DB.filters={};p.activeFilters={}
 local created,id=A:AddNameExclusion("x7")
 ok(created and A:GetFilter(id).kind=="realm"and not p.activeFilters[id],"new x7 becomes world rule, initially OFF")
 A:ToggleFilter(id);ok(not A:FilterHit(person("Alex7-plusx1")),"world rule real toggle retains correct semantics")
 GR735DB.filters={};p.activeFilters={}
 GR735CharDB.ladderCache={realm=A:RealmID(),complete=true,at=A:WallClock(),rows={{name="ХАРД",realm=A:RealmID(),level=28}}}
 ok(A:IsLadderMatch("Хард-plusx1"),"HC bare ladder matches same-world WHO suffix")
 ok(not A:IsLadderMatch("Хард-plusx7"),"HC same base different world not merged")
 p.hcMode="exclude";ok(A:CandidateReason(person("Хард-plusx1"))=="hardcore","single eligibility gate excludes HC")
 p.hcMode="only";ok(not A:CandidateReason(person("Хард-plusx1"))and A:CandidateReason(person("Ordinary"))=="hardcore","HC-only uses same identity gate")
 p.hcMode="all"
 p.contacts[A:Fold("Хард")]=A:WallClock()
 ok(A:RecentContact(person("Хард-plusx1"))and not A:RecentContact(person("Хард-plusx7")),"old bare contact compatible without cross-world collision")
 p.contacts={};p.contacts[A:Fold("Хард-plusx1")]=A:WallClock()
 ok(A:RecentContact(person("Хард")),"qualified saved contact blocks bare alias")
 p.contacts={}
 local data,reported={},0;local requests={}
 SendWho=function(q)requests[#requests+1]=q end
 GetNumWhoResults=function()return #data,reported end
 GetWhoInfo=function(i)local r=data[i];return r.name,r.guild,r.level,r.race,r.class,r.zone,r.classFile end
 local function scan(rows,total)
  A:StopScan("test");advance(50);data=rows;reported=total or #rows;A:StartScan();A:TickScanner();A:OnWhoResult()
 end
 scan({person("Ordinary28-plusx1",28),person("Ordinary32-plusx1",32),person("Guilded",28,"Guild")})
 ok(#A.candidates==2 and A.scan.stats.reasons.guild==1,"WHO retains raw guilded row but excludes view")
 rule("name","Ordinary28","explicit");A:SelectionChanged()
 ok(not A.scan.active and #A.candidates==1 and A.candidates[1].level==32,"filter change stops old scan and immediately rebuilds view")
 p.activeFilters={};A:SelectionChanged()
 ok(#A.candidates==2,"disabled filter restores already received row without network")
 p.excludedClasses.MAGE=true;A:SelectionChanged();ok(#A.candidates==0 and A.scan.stats.reasons.class==2,"class exclusion reuses gate")
 p.excludedClasses={};p.minLevel=30;A:SelectionChanged();ok(#A.candidates==1,"changed level range immediately filters snapshot")
 p.minLevel=10;A:SelectionChanged();ok(#A.candidates==2,"lowered range restores known rows")
 p.contacts[A:Fold("Ordinary28-plusx1")]=A:WallClock();A:RefreshUI()
 ok(#A.candidates==1 and A.scan.stats.reasons.contact==1,"contact attempts disappear from current view")
 p.contacts={};A:RefreshUI();ok(#A.candidates==2,"cleared history restores current view")
 A:StopScan("test");p.minLevel=20;p.maxLevel=40
 scan({person("Low",10),person("Good",28),person("High",110)})
 ok(not A.scan.active and A.scan.partial and #A.candidates==0,"mixed out-of-range reply rejected atomically")
 ok(A.scan.stats.rejectedReplies==1 and A:ScanStatusText():find(A:T("Неполный поиск"),1,true),"mismatched reply visible as incomplete")
 p.minLevel=10;p.maxLevel=110
 local many={};for i=1,95 do many[i]=person("Paged"..i.."-plusx1",28)end
 scan(many,95);A:StopScan("test");A:UpdateCandidates()
 ok(#A.candidates==95 and #A.ui.rows<=30,"95 candidates retained using bounded30-row pool")
 A.ui.nextPage.scripts.OnClick();ok(A.candidatePage==2 and A.ui.rows[1].person.name=="Paged31-plusx1","page two actual button reaches candidate31")
 A.ui.nextPage.scripts.OnClick();A.ui.nextPage.scripts.OnClick()
 ok(A.candidatePage==4 and A.ui.rows[5].person.name=="Paged95-plusx1"and not A.ui.rows[6]:IsShown(),"last page reaches final candidate without stale rows")
 A.ui.previousPage.scripts.OnClick();ok(A.candidatePage==3,"previous page actual button")
 rule("name","Paged","explicit");A:SelectionChanged()
 ok(#A.candidates==0 and A.candidatePage==1 and A.ui.nextPage.disabled,"shrinking view clamps page and buttons")
 GR735DB.filters={};p.activeFilters={}
 p.minLevel=28;p.maxLevel=28
 local capped={};for i=1,50 do capped[i]=person("Cap"..i,28)end
 WHO_TAG_CLASS=nil;scan(capped,60)
 ok(A.scan.partial and A.scan.stats.saturated==1,"unavailable class syntax leaves explicit incomplete coverage")
 A:StopScan("test")
 local files={"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","DEATHKNIGHT","SHAMAN","MAGE","WARLOCK","MONK","DRUID","DEMONHUNTER"}
 WHO_TAG_CLASS="c-";LOCALIZED_CLASS_NAMES_MALE={};for _,file in ipairs(files)do LOCALIZED_CLASS_NAMES_MALE[file]=file end
 scan(capped,60)
 ok(#A.scan.pending==12 and not A.scan.partial,"single-level saturation splits into12native class queries")
 advance(9);A:TickScanner()
 ok(requests[#requests]=='28-28 c-"WARRIOR"',"class query uses provided native tag and name")
 data={person("Warrior28",28,"","WARRIOR")};reported=1;A:OnWhoResult()
 ok(A.scan.recordIndex[A:CandidateKey("Warrior28")]~=nil,"matching class reply captured")
 advance(9);A:TickScanner();data={person("WrongClass",28,"","MAGE")};A:OnWhoResult()
 ok(not A.scan.active and A.scan.partial and not A.scan.recordIndex[A:CandidateKey("WrongClass")],"server ignoring class query stops safely")
 p.minLevel=10;p.maxLevel=110
 scan({person("Limit",28)});A.scan.queryCount=120;A.scan.pending={{low=10,high=110}};advance(9);A:TickScanner()
 ok(not A.scan.active and A.scan.queryCount==120 and A.scan.partial,"120queries remains hard cap")
 scan({person("BeforeTimeout",28)});A.scan.pending={{low=10,high=110}};advance(9);A:TickScanner();advance(46);A:TickScanner()
 ok(not A.scan.active and A:ScanStatusText():find("45",1,true),"timeout status visible and snapshot retained")
 -- secure post-hook detects another addon/manual SendWho; own send not flagged.
 local callback;A.whoHooked=nil
 hooksecurefunc=function(name,fn)ok(name=="SendWho","only native WHO observed");callback=fn end
 SendWho=function(q)requests[#requests+1]=q;if callback then callback(q)end end
 A:StopScan("test");advance(50);A:StartScan();A:TickScanner()
 ok(A.scan.active and A.scan.inFlight,"own SendWho observer does not interrupt")
 SendWho('manual query');ok(not A.scan.active and A.scan.partial,"foreign SendWho stops scan before mixing replies")
 hooksecurefunc=nil;A.whoHooked=nil
 scan({person("Settings",28)})
 p.maxLevel=100;A:TickScanner();ok(not A.scan.active and A.scan.partial,"direct settings change detected before next request")
 local before=#requests;A:ExplainCandidate("Settings")
 ok(#requests==before,"why diagnostic sends no extra WHO")
 -- No silent truncation at snapshot bound: stop and retain all existing rows.
 A:StopScan("test");p.maxLevel=110;advance(50);A:StartScan();A:TickScanner()
 for i=1,5000 do local r=person("Bound"..i);A.scan.records[i]=r;A.scan.recordIndex[A:CandidateKey(r.name)]=i end
 data={person("BeyondBound")};reported=1;A:OnWhoResult()
 ok(not A.scan.active and A.scan.partial and #A.scan.records==5000,"record limit is explicit partial stop")
 ok(#A.candidates==5000 and #A.ui.rows<=30,"all5000 retained with bounded widget pool")
 A.candidatePage=167;A:UpdateCandidates()
 ok(A.ui.rows[20].person.name=="Bound5000"and not A.ui.rows[21]:IsShown(),"last retained player reachable at capacity")
 A:StopScan("test");A:ClearCandidates()
 local hcName="MatrixHC-plusx1"
 GR735CharDB.ladderCache={realm=A:RealmID(),complete=true,rows={{name="MatrixHC",realm=A:RealmID(),level=28}},at=A:WallClock()}
 -- Cross-filter interactions: any rejection wins, no OR between filter families.
 for _,mode in ipairs({"all","exclude","only"})do
  for _,isHC in ipairs({false,true})do for _,guilded in ipairs({false,true})do
   for _,blockedClass in ipairs({false,true})do for _,contacted in ipairs({false,true})do
    for _,level in ipairs({9,28,111})do
     p.hcMode=mode;p.minLevel=10;p.maxLevel=110;p.excludedClasses={};p.contacts={}
     local r=person(isHC and hcName or "MatrixNormal-plusx1",level,guilded and"Guild"or"","MAGE")
     if blockedClass then p.excludedClasses.MAGE=true end
     if contacted then p.contacts[A:Fold(r.name)]=A:WallClock()end
     local expected=not guilded and not blockedClass and not contacted and level==28 and(mode=="all"or(mode=="exclude"and not isHC)or(mode=="only"and isHC))
     ok((A:CandidateReason(r)==nil)==expected,"combined HC/guild/class/contact/level eligibility")
    end
   end end
  end end
 end
 p.hcMode="all";p.excludedClasses={};p.contacts={}
 A:ClearCandidates();ok(A.scan.records==nil and #A.candidates==0,"clear removes current snapshot only")
 print("GR735 selection chain PASS")
end
