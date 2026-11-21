# Zip history

Every package sent, newest first. Filenames carry their contents so an old
download is identifiable without opening it.

Naming: `sdg_app_zipNN_what-changed.zip`

---

## zip 30 — `sdg_app_zip30_all-282-complete.zip`
**19 Nov 2026**

**All 282 registered problems now open a working screen. All 17 goals are
finished.** 44 new tools: land and forest, justice, partnerships — and three
that zip 29 missed.

### Correction to zip 29

zip 29 said goals 12, 13 and 14 were finished. Three screens in goals 12 and
13 had not been built: my checklist script skipped titles containing an
apostrophe. They are in this zip:

- **My home's water and power footprint** (goal 12) — litres a person a day
  against the 55 / 135 litre planning norms, and the three cuts worth making
  for the appliances actually in the house
- **Today's heat risk for outdoor work** (goal 13) — opens the same live
  screen as goal 8, rather than a second copy of it
- **My household's carbon footprint** (goal 13) — power, LPG, petrol and
  diesel into tonnes a year, the biggest share first, with the cut for each

The project's own generator had the count right all along (it reported 238
built, not 241); it was my separate listing that missed them. From here the
count that matters is the one `tools/gen_issues.py` prints.

### Goal 15 — land and forest (13)

Crop raided by animals (with the forest-department letter, and the new
crop-insurance cover from Kharif 2026), animal deaths, livestock vaccine
calendar, tree felling, land record check, land unit converter,
encroachment letter, fertiliser dose in bags, pesticide waiting days, organic
certification, illegal felling or poaching, forest fire, farm pond sizing.

**The land converter carries no bigha, katha or marla.** Those differ by
state and by district; a wrong preset would quietly corrupt a land deal. You
enter the size the patwari gives you.

**The fertiliser screen turns the soil card's kilos of nutrient into bags**
of DAP or SSP, urea and potash, and takes the nitrogen in DAP off the urea.

### Goal 16 — justice (14)

FIR refused (the three free steps, with the letter to the SP), arrested
relative, bail, which court, cheque bounce (with the 30-day clock), legal
notice, Lok Adalat, online fraud first hour, lost phone, bribe, missing
person, voter ID forms, the grievance ladder, free legal aid.

**Section numbers follow the 2024 codes.** The BNSS replaced the CrPC on
1 July 2024; the FIR screen gives both numbers, since officers still say the
old ones aloud.

### Goal 17 — partnerships (14)

Volunteer, blood donation check, organ pledge, check a charity, crowdfunding
for treatment, start a group, gram sabha item, village plan proposal, social
audit, CSR funds, register an NGO, translate the app, share a tool, where
every fact comes from.

**Translations and corrections use the existing correction form** — same
Firestore collection, same rules, same admin screen. No new place for
strangers to write to, so nothing new to moderate.

**"Where every fact comes from" counts the shipped records live** — how many
there are in each file and how many have been checked — straight from the
app's own data.

### Checked before sending

- `tools/validate.py`: 194 Dart files, all checks passed
- Registry: 282 total, 282 built, 0 coming
- No goal's `issues.dart` has an unbuilt entry left
- Every new screen is reachable from its goal's menu
- No two types share a name anywhere in `lib/`

---

## zip 29 — `sdg_app_zip29_goals-12-to-14-complete.zip`
**19 Nov 2026**

**Goals 1 to 14 are finished** — 238 of 282 working. 36 new tools: buying
and waste, climate, and the sea.

### Goal 12 — what you buy and throw away (12)

Defective product letter, order not delivered or refund stuck, charged above
MRP, misleading advertisement, gold hallmark, fake medicine, use-by or
best-before, unit price, warranty tracker, which bin, compost, old phone or
battery.

**The consumer screens work out which commission and whether there is a
fee** from the price paid — the District Commission to ₹50 lakh, no fee to
₹5 lakh — then write the letter to the seller.

**The bins follow the 2026 rules.** The Solid Waste Management Rules 2026,
in force from 1 April 2026, split household waste four ways: wet, dry,
sanitary and special care. The search covers 29 everyday items.

**The medicine screen never says a medicine is genuine.** It helps firm up a
suspicion — the QR code, now required on vaccines, antibiotics, cancer and
narcotic medicines too — and opens by saying not to stop a prescribed
medicine without asking the doctor.

**The warranty list stays on the phone** and flags anything ending within 30
days, so a fault gets registered while repair is still free.

### Goal 13 — climate (11)

Rain and storm risk for 3 days, lightning, cyclone stages, house damaged by
flood or storm, crop insurance enrolment and premium, sowing week, drought,
livestock in heat or flood, cool roof, native trees by region, stubble.

**The forecast now carries rain in millimetres and the strongest gust.**
Two fields added to the weather reading, so the rain screen can use the
Meteorological Department's own rainfall bands (heavy is over 64.5 mm in a
day) and the sowing screen can tell "light rain coming" from "heavy rain
coming". Older cached readings without them are treated as unknown, never as
dry.

**The sowing screen goes by the soil as well as the sky**: squeeze a handful
— crumbles, holds a ball, or drips — and it says sow, wait for rain, wait for
it to drain, or do not sow before heavy rain.

**The house-damage screen opens with "photographs before the clean-up"**,
because the survey only sees what is left when the surveyor arrives.

### Goal 14 — the sea (13)

Sea state today, boat safety kit, border crossed or boat seized, boat
registration, net mesh check, protected species released, accident
insurance, ban-season support, KCC for fishers, catch log, ice needed, fish
pond, beach clean-up.

**The sea-state screen never says it is safe to go.** It reads wave height
from Open-Meteo's marine model and today's gusts, and only says when the
numbers reach the level at which fishers are normally told to stay in — and
it puts the IMD and INCOIS warnings first.

**The ice screen uses the FAO's own tables** — about 0.34 kg of ice to chill
each kg of fish from 30°C, plus what melts each hour by how the boxes are
kept — and never goes below the FAO's 1:1 working rule for boxes in the
tropics.

**The accident insurance screen carries the claim clock** from NFDB's own
procedure: notice within 90 days, papers within 180, and what a family does
when someone is missing at sea.

### Checked before sending

- `tools/validate.py`: 182 Dart files, all checks passed
- Registry: 282 total, 238 built, 44 coming
- Every new screen is reachable from its goal's menu

---

## zip 28 — `sdg_app_zip28_goals-9-to-11-complete.zip`
**19 Nov 2026**

**Goals 1 to 11 are finished** — 202 of 282 working. 38 new tools: running a
small business, unequal treatment, and housing and towns.

### Goal 9 — enterprise (14)

MSME class, GST threshold, FSSAI licence, street-vendor certificate,
buyer paying late (45-day rule with the three-times-bank-rate interest
worked out), loan EMI, loan refused, PM Vishwakarma, pricing, break-even,
daily cash book, bill maker, selling on GeM, taking UPI payments.

**The pricing screen will not let your own labour stay at zero.** The
commonest reason a small business runs for years and saves nothing is that
the owner's time was never counted; the screen asks for it, says why, and
adds rent and power as a share of each item.

**The cash book stays on the phone.** Nothing is sent anywhere and it is
tied to no account. It keeps up to 120 days, and clearing it asks first.
Three months of clean entries is the paper a bank most often asks for.

**The UPI screen leads with the frauds**, not the features: no PIN is ever
needed to receive money, a payment message on someone else's phone proves
nothing, and the QR sticker gets pasted over. Then 1930 and the cyber portal.

### Goal 10 — inequality (12)

UDID card, disability pension and free aids (ADIP income bands), caste
certificate appeal letter, atrocity relief by stage, refused entry or
service, manual scavenging, senior citizens' maintenance tribunal, senior
concessions, transgender ID, moving for work, voting from home, reservation
share check.

**The atrocity screen ties each payment to its stage.** The first quarter
is due when the FIR is registered and about half on the charge sheet — the
part most often left unclaimed because nobody volunteers it. Minimum relief
for five common offences is shown, with a line saying the schedule has
forty more.

**The senior concessions screen opens with what you will not get.** The
railway fare concession was withdrawn in March 2020 and has not come back;
an old man who travels to the station expecting half fare has been failed
by a cheerful list.

**The transgender ID screen gives no step-by-step process, on purpose.** The
2019 Act was amended in 2026, the amendment is in force from May and is
being challenged in the Supreme Court, and the rules are still settling.
The screen says what is settled — cards issued before the amendment stay
valid, discrimination is still barred — and routes to the district office
(in writing) and the free legal aid authority.

### Goal 11 — towns and housing (12)

Rent agreement checklist, deposit demand letter, eviction threat, property
tax comparison, mutation after a death, overcharged fare, noise or smoke,
unsafe building, housing society dispute, flood go-bag, earthquake risk by
house type, road accident.

**Nobody may be put out of a house except by an order** — the eviction
screen says this first, then splits five ways: threatened, locked out,
power cut off, served notice, rent raised. Every branch says keep paying
the rent.

**The fare screen holds no rate.** It asks for the minimum fare and the
per-kilometre rate from the official fare card and works out what you
should have paid, including the night surcharge from the card.

**Mutation insists on every heir.** The commonest mistake is letting the
record go into one son's name; daughters are equal heirs, married or not.

**The road accident screen persists nothing** and opens with 112 or 108,
then the Good Samaritan protections under section 134A, the ₹25,000
Rah-Veer reward and cashless treatment up to ₹1.5 lakh for 7 days.

### Checked before sending

- `tools/validate.py`: 172 Dart files, all checks passed
- Registry: 282 total, 202 built, 80 coming

---

## zip 27 — `sdg_app_zip27_goals-6-to-8-complete.zip`
**17 Nov 2026**

**Goals 1 to 8 are finished** — 164 of 282 working. 42 new tools: water and
sanitation, energy, and work.

### Goal 6 — water and sanitation (14)

Chlorine dose, water testing, flood water, tap connection, handpump, water
bill, tanker, toilet grant, toilet pit, drains near a water source,
rainwater, dripping tap, daily water need, tank cleaning.

Three of these are built against the obvious design, for reasons worth
knowing:

**The chlorine screen carries no dose.** Tablets sold in India run from
3.5 mg to several grams and treat anywhere from one litre to a tank, so a
number printed in an app would be wrong for most packets somebody is
actually holding — and wrong in the direction that matters, because too
little chlorine looks exactly like enough. The screen asks what the packet
says and does the arithmetic for the pot, bucket, drum or tank in front of
them. It also refuses to compute bleaching powder at all, because its
strength falls as it sits open and spoon-measuring it at home is not
reliable; that one routes to the panchayat worker or to boiling.

**The toilet-pit screen opens with the don't, not the how.** People die
every year climbing into pits and septic tanks, from the gas rather than
from drowning, within a minute — and most of the dead are the ones who went
in after to help. So the first thing on the screen is that nobody goes in,
that employing someone to do it is a crime, and that if someone falls in you
put a rope down from outside and call 112. Then the twin-pit switch, which
is the case where no one need be called at all.

**The tap-connection screen turns the standard into a sentence.** Jal Jeevan
Mission's service level is 55 litres per person per day, so the screen takes
your household size, works out what that comes to, and builds the complaint
around the figure. "We do not get enough water" achieves nothing; "there are
eight of us, the standard is 55 litres each, and we get this much" is a
complaint that has to be answered.

### Goal 7 — energy (14)

Appliance costs, meter testing, star ratings, LED swap, new connection,
power cuts, inverter sizing, rooftop solar, PM-KUSUM, Ujjwala, LPG subsidy,
gas leak, electric shock, house wiring.

**No tariff anywhere in this goal.** Rates differ by state, slab and
category and change yearly, so every calculator asks for the rate printed
on your own bill. A figure the reader supplies cannot go stale.

**The gas-leak screen is about sequence, not information.** Everyone knows
not to light a match. Far fewer know that switching a light *off* makes the
same spark, and that reaching for the switch is the reflex on walking into a
dark room that smells of gas. That is the first line on the screen, before
anything else.

**PM Surya Ghar** computes the actual subsidy — ₹30,000 a kW for the first
two, ₹18,000 for the third, capped at ₹78,000 — and suggests a size from
your consumption using the scheme's own table. The warning that matters
most: a system installed by a vendor not on the portal's list gets no
subsidy, and nothing can be done about it afterwards.

**The LPG subsidy screen carries no per-cylinder figure.** The amount and
the number of subsidised refills are set by government order, have changed
more than once, and the sources quoting them contradict each other — which
is exactly when a number in an app does harm. Instead it teaches the
household to read its own subsidy credit in the gas company's app, which is
always current and always theirs.

**The wiring screen names the one device that prevents most deaths**: an
RCCB. A fuse and an MCB protect the house wiring; an RCCB protects the
person, and it is the thing houses do not have.

### Goal 8 — decent work (14)

Wages not paid, minimum wage, overtime, PF, gratuity, dismissal, injury at
work, ESI, child labour, bonded labour, working in heat, going abroad, skill
training, building worker card.

**Four calculators where the law is unusually clear and the worker
unusually unlikely to know it.** Overtime at twice the ordinary rate.
Gratuity at fifteen days' wages a year after five years, on a 26-day month.
Retrenchment compensation at fifteen days per completed year. The daily
minimum-wage shortfall turned into a yearly figure. The wages screen also
builds the complaint letter, and names the point that turns contractor
cases: where a contractor does not pay, the principal employer is liable, so
name both.

**The heat screen reads your live forecast.** It is the only screen in the
app that turns the weather for your own place into a decision — today's
feels-like temperature, the risk band, and when to stop. Then the heat-stroke
signs and what to do before the ambulance.

**Bonded labour** leads with the thing that keeps people in it: the debt is
extinguished by law on release. It does not have to be repaid, and no land
or goods have to be given against it. Then the release certificate, which
the whole rehabilitation amount turns on, and the ₹30,000 immediate
assistance each district holds a fund for.

**Going abroad** is built around the one check that would prevent most of
the harm — looking the agent's registration number up on the eMigrate
portal, which takes two minutes and which the families who sell land to pay
an agent have almost always skipped. Plus the trap: a visit visa is not a
work visa, whatever the agent says about changing it there.

**The building worker card** is, for the effort involved, the
highest-return thing in this app. Every state's welfare board holds a large
cess-funded pot that goes unspent because workers are not registered, and
the card carries accident cover, treatment, maternity, children's
scholarships, tools, a housing loan and a pension after sixty.

### Three more checks in `tools/validate.py`

Each of these caught a real defect in this zip's own code, and each is
negative-tested.

- **Widget argument names.** `CopyBlock(title: ...)` when it takes only
  `text` and `note` is a compile error, and nothing else in the checker sees
  it: the import resolves, the symbol exists, the parentheses balance. It
  cost one round trip before this rule existed. The rule parses every
  project class's constructor and checks call sites against it, ignoring
  nested calls and quoted strings.
- **Unused private declarations.** The analyzer reports these and they
  accumulate. Getting this rule to be useful took two passes: first it
  reported twelve names that were used inside string interpolation, because
  blanking the literals hid them; then it reported seven more because the
  function pattern was matching *usage* lines as declarations. It now finds
  exactly one real case per run.
- **The Devanagari typo rule was narrowed.** It was flagging `VA।` — a unit
  before a Hindi full stop — as a latin letter inside a Devanagari word. The
  danda is punctuation and now ends a word the way a full stop does. Checked
  that it still catches a real `मृत्यu`.

Also added `tools/wire.py`, which attaches built screens to registered
issues and asserts on every miss. Doing that edit by hand twelve more times
is how a goal ships with half its screens unreachable.

---

## zip 26 — `sdg_app_zip26_goals-2-to-5-complete.zip`
**17 Nov 2026**

**Goals 1 to 5 are finished.** 33 new tools, every registered problem in
those five goals now opening a working screen, 122 of 282 across the app.
These are the five goals that came from your Render web apps, so parity is
complete and well past it.

### Goal 2 — food (8 tools)

**Ration in another state.** Portability works nationwide and "this card
does not work here" is simply untrue. Covers the split-family case too: some
members drawing here, the rest in the village, which is per-member and which
dealers often say is impossible. The one thing that genuinely blocks it is
Aadhaar not linked for the member collecting, so that is the checklist's
first item.

**Not on the ration list at all.** Five reasons, each with its own route —
and the part that matters more, what a family eats while the application is
pending: the anganwadi needs no ration card, nor does the midday meal, and a
food officer can issue a temporary slip.

**What the anganwadi owes you**, in figures: 500 kcal and 12–15 g protein a
day for a child 6 months to 3 years as take-home ration, the same for 3 to 6
but as a morning snack plus a hot cooked meal, 800 kcal and 20–25 g for a
severely underweight child, 600 kcal and 18–20 g for a pregnant or nursing
mother. A mother who knows that number is in a different position from one
told "this is what came this month". Source: Ministry of Women and Child
Development.

**Midday meal problems.** 100 g of grain and 450 kcal for primary, 150 g and
700 kcal for upper primary. Five kinds of problem routed separately, with
children being seated apart handled as what it is — against the scheme's
rules and against the law on untouchability, and not something to wait out
inside the school. The thing that makes these complaints work is a list of
dates, so the screen says so plainly.

**Storing grain at home.** Safe moisture and keeping time per grain, the
old no-meter tests (a grain should snap, not squash), and the don'ts —
chiefly never store it damp, which undoes everything else. It deliberately
gives no pesticide advice at all and sends you to the Krishi Vigyan Kendra,
because seed grain and eating grain are handled differently and that is not
a decision for an app.

**Kitchen garden.** What to sow this month, by month and by zone — plains,
hills, southern or coastal — because one national list would be wrong for
most readers. Five crops a month, not twenty.

**Selling a crop.** This one carries **no prices, deliberately.** MSP moves
every season and a farmer quoting last year's figure at a mandi loses the
argument and the credibility. What it does instead: the arithmetic, the four
selling routes with the honest note that MSP only bites where the government
actually procures, and the point that a single line reading "expenses" on
the slip is where money goes missing.

**Kisan Credit Card.** Built around one fact: a moneylender at "five rupees
a hundred a month" is 60% a year, and a KCC repaid on time is 4%. It puts
your figure through both. Collateral-free to ₹2 lakh since 1 January 2025,
subvention to ₹5 lakh, five-year validity. The part most people do not know
is first: tenant farmers, oral lessees and sharecroppers are eligible even
with no land in their name.

### Goal 3 — health (8 tools)

The four emergency screens are the most carefully built things in the app.
Each opens with the ambulance number, says in its first line that it does
not tell you what the illness is, and keeps nothing on the phone.

**Snakebite.** Here the don'ts carry the whole value, so they get their own
red block: no tourniquet (the guideline says plainly it can cost the limb
and that releasing it can send the venom up at once), no cutting, no
suction — mouth suction is strongly prohibited — no washing or rubbing, no
herbs, no ice, no cautery, no electric shock, no black stone, and no time
spent at a healer, which is the hour in which people die. What to do:
immobilise like a fracture without pressure, strip off rings and tight
clothing before the swelling makes them tourniquets, recovery position,
nothing by mouth, carry them, and phone ahead to confirm antivenom. The one
bandage exception the guideline allows is stated as the exception it is.

**Dog or animal bite.** Fifteen minutes of soap and running water first,
because it does more than anything else and is the step most often skipped.
Then the three exposure categories, and the vaccine days for both routes —
intradermal 0, 3, 7, 28; intramuscular 0, 3, 7, 14, 28 — with the point that
day 0 is the first dose, not the bite, and a missed day does not restart the
course. For Category III it tells you to ask for the immunoglobulin **by
name**, because that is what people get sent home without. And the list of
what must never go on the wound: chilli, mustard oil, lime, salt, turmeric,
soil, herbs, chalk, betel leaves.

**Fever, when it is an emergency.** By age, because the youngest band is the
one families misjudge: under two months any fever at all means go now, and
so does the body turning unusually cold. For 2 months to 5 years, the four
IMNCI danger signs decide it regardless of how high the fever is. Past seven
days at any age it needs a test, not another tablet from the medical shop.

**Pregnancy.** Pick the last period and it works out the due date and all
four check-up dates, highlighting the one that is due. Then the danger signs
grouped by the facility each needs, because "go to a hospital" is useless
advice when the sub-centre is nearer and cannot help. Includes the 9th of
every month free check-up, and that a delivery and a caesarean at a
government hospital are free.

**Ayushman Bharat.** The ₹5 lakh cover, what it includes, and the 70-plus
extension that ignores income entirely — including the part nobody knows: if
the family already has a card, the senior gets their own additional ₹5 lakh
and the younger members' cover is not touched. Card-making is free and can
be done at the hospital during an admission, so "there is no card" is not a
reason to walk away from treatment.

**Asked for money under a free scheme.** The more important of the pair.
PM-JAY is cashless: "buy the medicine outside", "get the test done outside",
"the bed charge is separate" are none of them legitimate. A delivery is free
including a caesarean, transport and the newborn's first year. Then the
complaint ladder from the hospital's Ayushman Mitra through 14555 to
CPGRAMS, and a folder checklist — including what to write down when no
receipt was given, which is itself a second complaint.

**TB.** The thing almost nobody knows is first: on top of free tests and
free medicines, the government pays the patient **₹1,000 a month for the
whole treatment**, raised from ₹500 in October 2024. Six symptoms any one of
which should send someone for a test. And the don'ts, led by not stopping
when you feel better, which is what makes the disease drug-resistant.

**Blood sugar.** Pick which test it was — fasting, after food, or HbA1c —
because applying the fasting cut-off to an after-food reading is how people
frighten themselves for nothing. All three bands shown, the right one
highlighted, and a firm line that one reading does not diagnose and nobody
should start, stop or borrow medicine on it.

### Goal 4 — education (9 tools)

**Scholarship money not received.** Five stages, and the step that catches
most students named for what it is: the institute has to verify the
application on the portal, and a student who has heard nothing for months is
usually waiting on a clerk who has not opened it. Go in person, ask who the
nodal officer is, get it done while you stand there. Also the renewal
window, which is the quiet one — miss it and in many schemes the year is
simply gone.

**Education loan.** The EMI, and the number nobody works out: what the
interest adds up to over the whole term. Then PM-Vidyalaxmi's 3% subvention
on loans to ₹10 lakh for family income to ₹8 lakh, the collateral-free
guarantee to ₹7.5 lakh, and the older CSIS scheme for income to ₹4.5 lakh.
Eight questions to put to the bank in writing, including whether insurance
is being quietly added to the amount you borrow.

**RTE 25% free seat.** Age against the entry class, the neighbourhood rule,
the once-a-year window, and that the lottery means applying early is no
advantage but missing the window costs the year.

**School refused admission or asked for a donation.** Seven things schools
do routinely that the Act prohibits, each with its section: capitation fee
and screening under 13, no refusal for want of age proof under 14, admission
at any time under 15, age-appropriate class under 4, no holding back or
expulsion before class 8 under 16, no physical punishment under 17. The
section number is the point — a parent who can name it gets a different
answer at the same counter. First step in every case: ask for the refusal in
writing, which is where most of these end.

**Free books, uniform, cycle, hostel** — separating what is an entitlement
everywhere from what is a state scheme with a window, because the first
needs no application and the second does. With the line that applies to all
of them: whatever comes free to a school is in a register, and asking to see
it is your right.

**Lost marksheet.** DigiLocker first, because for many boards the document
is already there and legally valid, so no duplicate is needed at all. Then
the duplicate route for each of four document types, and the two things to
do the day you get it back.

**Dropped out.** Open schooling has no upper age limit and plenty of people
pass class 10 in their thirties. Subjects already passed carry over for five
years, so only the missing ones need taking. Under 14, it says the RTE Act
applies and the school cannot refuse. And for anyone who has to earn: the
apprenticeship route pays a stipend while open schooling runs alongside it,
which is the least-mentioned road there is.

**After class 10.** A shortlist, never a single recommendation, with two
things nobody says: a stream can be changed, and the bank, railway, police
and civil service exams do not look at it at all; and the stream the village
thinks is "biggest" and the one that suits you are not the same thing.

**After class 12.** Exams grouped by direction rather than by name, because
a student who does not know the names cannot look them up. **Months only, no
dates** — exam calendars shift every year and a wrong date means a missed
form, the one mistake that cannot be undone. Plus the fee waivers most
students never claim.

### Goal 5 — women (8 tools)

**Workplace harassment.** Which committee hears it, which is what stops most
complaints before they start: a woman in a four-person shop assumes there is
nowhere to go, when the district's Local Committee covers exactly her. The
time limits are stated because they decide whether a complaint is heard at
all — three months, extendable by three with a recorded reason, inquiry
within ninety days. And what the employer may not do, including settling it
for money and calling that the outcome.

**Maternity leave.** 26 weeks for the first two children, 12 for a third,
up to 8 before delivery, full pay, no dismissal. Below ten employees it says
plainly that the law does not apply, and names the two things that still
do — Matru Vandana and a free government delivery — rather than leaving her
with nothing.

**Domestic violence: a protection order.** Built differently from every
other screen in the app. **It saves nothing** — no ticks, no answers,
nothing written to the phone — because on a shared phone a saved tick can be
read by the person she is afraid of, and it says so on itself. It opens with
112 and 181 and tells her to memorise them rather than store them. It makes
clear domestic violence is not only being beaten, and that the Act covers a
mother, sister or daughter too. All five reliefs can go in one application —
asking for only one is a common loss. No court fee, filed by her or anyone
on her behalf, Protection Officer and One Stop Centre named, free lawyer on
15100. It never suggests confronting anyone. And on gathering papers before
leaving: if collecting them raises the risk, leave them — papers can be made
again, and 181 and 112 work without any of them.

**Dowry demand.** The demand alone is the offence, before anything is given.
Section 4 and section 3 penalties, non-bailable, non-compoundable, and the
burden of proof on the accused. Harassment over dowry is routed to the
protection-order screen because that relief comes faster. Plus the point
that what was given to her at the marriage is her own property.

**Daughter's share in property.** Two questions first, because conflating
them is the root of the confident wrong answers: ancestral or self-acquired,
and which personal law. For Hindu families it states the 2005 amendment and
the 2020 Supreme Court ruling that the right does not depend on the father
being alive on 9 September 2005, and that marriage changes nothing.
Agricultural land is handled honestly — same rule in principle, but state
tenancy laws bear on it, so it refuses to give one answer. Muslim, Christian
and Parsi law each get their own answer rather than being folded in. And the
warning that matters: sign nothing unread.

**Marriage under 18.** 18 and 21, with the 2021 Bill to raise the girl's age
to 21 stated as **introduced and not passed**, so it remains 18. 1098 first,
and that it takes anonymous reports. Different steps for the girl herself, a
family member, a neighbour, and a marriage already performed — the last of
which can still be annulled, within two years of majority, with maintenance
asked for in the same petition. It says explicitly not to confront the
family, because that makes the marriage happen sooner and in secret.

**Equal pay.** The daily gap turned into a monthly and yearly figure, since
₹30 a day is ₹9,000 a year. The old Equal Remuneration Act now sits in the
Code on Wages, in force since 21 November 2025. The job title does not
matter; what is actually done does. And a daily note in her own hand costs
nothing and is the strongest thing she can build.

**Self-help group.** Six steps from ten women to a bank linkage, what
arrives when, and the don'ts that are really about how groups break: the
register living in one house, the account in one name, paying someone to
arrange it, and the loan all going into one member's business.

### Also in this zip

**Two new shared widgets.** `ToolSteps` for ordered steps that are not meant
to be ticked, and `ToolDonts` for the red block of things not to do. The
reason they exist: `ToolChecklist` saves your ticks to the phone, which is
right for papers gathered over weeks and wrong for an emergency — nobody
ticks boxes during a snakebite — and wrong for anything about a woman's
safety.

**3,286 lines of dead code deleted.** The nine old `*_home_page.dart` files
for goals 2 to 9 and 16 have been unreachable since zip 22, when the mini-app
frame took over routing and the goal menus started reading from
`issues.dart`. I verified no live file references anything they declare
before deleting them, and the validator passes. This also closes the "move
SDG 6, 7 and 9 onto the shared `GuideListPage`" item: those goals' registry
entries already point at the shared screen, and the private copies inside
those dead files were the only thing left to remove. If you want any of them
back, they are in zip 25.

### Still on your side

The doctor and lawyer review packet is a separate document, not in this zip.
It lists all 21 clinical and legal claims with their sources and what breaks
if each is wrong, and names the three in each set most worth their time.

Still waiting on `flutter --version` before I add real GPS.

---

## zip 25 — `sdg_app_zip25_goal-1-complete.zip`
**17 Nov 2026**

**Goal 1 is finished.** All 15 of its registered problems now open a working
screen, not a page of text. It is the first goal to get there, and it is the
shape I am building the other sixteen to.

Six new tools, all hand-coded:

**Pension check — old age, widow, disability.** Takes an age, which of the
three situations apply, and whether the household is on the BPL list, and
names the pension that fits with the exact central share: ₹200 for old age
at 60–79, ₹300 for widow at 40–79 and disability at 18–79, ₹500 for all
three at 80 and above. It says plainly that only one of the three is ever
paid to one person, that the state adds its own share on top, and that the
state's share is usually the larger part — so the figure to ask the block
office for is the total of each, before choosing. Document checklist
included, with the point most families get wrong: the bank account must be
the pensioner's own, not a son's.
Source: Ministry of Rural Development.

**e-Shram: should I register.** Four questions — age, whether the job is a
permanent one, whether PF or ESIC is deducted, whether they file income tax
— and it says yes or names the bar they fail. The screen opens by saying
what the card is not: it pays nothing by itself. Anyone who has been told
"the card gives two lakh rupees" has been told something false, and finding
that out at a counter is how people stop trusting every scheme after it. It
points at PMJJBY and PMSBY instead, which do pay and cost ₹436 and ₹20.

**PM-KISAN instalment stopped.** The generic DBT screen cannot name the two
failures particular to this scheme, so this one does: e-KYC, which is the
commonest single reason, and land records still in a father's or
grandfather's name because the mutation was never done — which stops the
payment even though the family has farmed the land for forty years. Routes
differ by what the farmer can see (nothing ever came / it stopped /
neighbours were paid / the page says ineligible), and the first step in all
four is reading the status page and writing down its exact words. Includes
the exclusion heads, because an exclusion wrongly applied to a whole khata
is correctable and people assume it is final. Helpline 155261.

**The application was rejected.** The one useful act is the one nobody is
offered: the reason, in writing. Most rejections are a missing document, a
name spelt two ways, or an income typed wrong — all fixable in a day, and
all unfindable without the reason. If the counter will not write it, a
₹10 RTI gets it in thirty days, and the app already has an RTI letter
builder under goal 16. Then the ladder, a rung at a time, with the point
that skipping rungs is what slows it down. Ends at free legal aid — DLSA,
helpline 15100 — and a folder checklist, because a complaint with a date and
a name gets answered and one without does not.

**An Aadhaar problem.** The Aadhaar counter is where people are overcharged
most, for one reason: nobody knows the fee. UIDAI publishes it, so the
screen states it before the trip — ₹75 for a demographic update, ₹125 for
biometric, free for a new enrolment, free for a document update done online,
free for a child's mandatory biometric update in its window. Six routes by
what is actually wrong, and two of them need no centre visit at all. Also:
a lost card is not a lost Aadhaar, the e-Aadhaar download is the same
document legally and costs nothing, and nobody should be paying a shop for a
plastic "smart card" that UIDAI does not issue. Overcharging goes to 1947.
Source: UIDAI's published charge sheet, read this month — with the figures
carried as data and an on-screen note that the free windows have end dates,
so the slip at the counter is the final word.

**A birth or death certificate, late.** Pick the date and it names the gate
the law puts you behind: within 21 days it registers free; to 30 days the
registrar does it on a late fee, with nobody's permission needed — say so if
told otherwise; from 30 days to a year it takes the District Registrar's
written permission, which is still not a court; past a year it takes a
magistrate's order, which does happen, thousands of times, and takes two or
three months. Separate document checklists for a birth and a death, and the
one nobody thinks to bring: the school admission record, often the strongest
paper a family holds.

On that last screen I have deliberately not named which magistrate. The 2023
amendment to the Act names a District Magistrate, an SDM, or an Executive
Magistrate the DM authorises; the Gujarat High Court has upheld exactly
that, and the Bombay High Court has held that only a Judicial Magistrate
First Class may order it. It is unsettled. So the screen says a magistrate's
order is needed and tells the reader to ask the registrar the plain question
— "which office do cases older than a year go to here?" — rather than state
one and be wrong in half the country. This is one for your lawyer to look at
when the legal review happens.

### A third new check in `tools/validate.py`

- **Icon names.** `Icons.badge_outline` instead of `Icons.badge_outlined` is
  a compile error, and it is one that cannot be caught by reading: the names
  are long and the suffixes inconsistent. `tools/icon_names.txt` now ships
  with the project — all 8,825 IconData names from Flutter's own
  `material/icons.dart` — and every `Icons.x` in the app is checked against
  it. All 213 icons the app uses are valid. Negative-tested on a planted
  typo. The command to refresh the list when Flutter moves is in the
  check's own comment.
- **Unnecessary interpolation braces.** `${name}` where `$name` would do is
  an analyzer info, and `unnecessary_brace_in_string_interps` is switched on
  through `package:flutter_lints`. Two of mine were caught by this and fixed
  before packaging. It knows to leave alone the ones doing real work, like
  `'${field}Hi'`.

---

## zip 24 — `sdg_app_zip24_compile-fixes.zip`
**17 Nov 2026**

A correctness-only package. Nothing new was added; zip 23 did not compile,
and this is the fix. Every zip 22 and zip 23 change is carried forward.

Your `flutter analyze` reported 405 issues in 11 distinct classes. All 405
are gone, and three of them were mine to have caught before sending:

**1. `registry.dart` would not compile** (1 error + 17 more from it).
`kGoals` was declared `const`, but a goal whose issue has a working screen
holds a closure, and a closure is never a compile-time constant. It is now
`final`, with a comment saying why, so the next hand-edit does not undo it.

**2. Five generated `issues.dart` files were cut in half mid-sentence**
(10 unterminated strings, and 133 nonsense errors downstream of them —
"illegal character", "undefined name `पुलिस`", and so on). My generator
keeps lines under 80 columns by breaking them at a space. For one kind of
line it broke at *any* space, including a space inside a quoted Hindi
title — which leaves a string literal hanging open, and the analyzer then
reports the rest of the file as gibberish. The generator now works out
which spaces are outside the quotes and breaks only at those; where there
is no safe break, the line simply goes out long. A long line in a
generated file is untidy. A line broken in the wrong place does not build.

Affected and now correct: SDG 16 "Police, FIR and legal aid", SDG 2 (four
food-safety screens), SDG 3 (health helplines, free care, cheaper
medicines, leftover medicines), SDG 7 energy guides, SDG 8 work rights,
SDG 6 water guides.

**3. Two imports I left behind** in `mgnrega_tool.dart` and
`papers_tools.dart`, after moving those screens off `SelectionTile`.

**4. 206 `const` suggestions.** An issue with no screen built yet holds
nothing but text and an icon, so it can be a compile-time constant: 199 of
the 282 are now `const Issue(`. The other 83 hold a closure and cannot be.
The seven checklists in the new tools are `const` too.

### Two new checks in `tools/validate.py`

Both of these bugs were mine to catch locally, and the checker did not.
It does now.

- **Unterminated string literals.** Scans every Dart file for a one-quote
  string left open at the end of a line, understanding escapes, raw
  strings, triple-quoted strings and `${...}` interpolation that itself
  contains quotes. Negative-tested: it finds a planted broken literal and
  reports the right line, and it passes all 144 real files, including the
  three that nest quotes inside interpolation.
- **The reason it missed the two unused imports.** The routine that works
  out what a file declares used `\s` for the space between a type and the
  name it declares. `\s` matches a newline, so the pattern ran straight
  past the end of the line and matched any `Name(` anywhere in the file —
  picking up `Text(`, `Icon(` and `SizedBox(` from inside build methods.
  Those appear in nearly every Flutter file, so every import looked used.
  It now matches only spaces and tabs. Re-run against the broken files, it
  finds exactly the two imports your analyzer found, and nothing else
  across 144 files.

---

## zip 23 — `sdg_app_zip23_tools-goals-1-to-4.zip`
**16 Nov 2026**

Seventeen new hand-built tools across goals 1 to 4. **83 of 282 problems
now work**, up from 66.

**SDG 1 — No Poverty (8 new)**
- Ration card: which card you hold and what it is worth each month
  (35 kg a household for Antyodaya, 5 kg a head for priority).
- MGNREGA: writes the written demand for work, then runs the three
  clocks — work within 15 days, the allowance owed when it is late
  (a quarter of the wage rate for the first 30 days, half after), and
  what you are owed once the work starts.
- Rs 2 lakh cover for Rs 436: who can take PMJJBY and PMSBY, and the point
  that matters more — a cover the family does not know about is never
  claimed.
- Money not arriving: works backwards from the symptom to the broken step
  (scheme record, Aadhaar seeded with NPCI, dormant account, or the old
  account the money is actually going into).
- After a death in the family: the order to do things in, and the papers.
- Family papers: the checklist, ticked off at leisure, kept on the phone.
- The real interest behind a moneylender's rate, including why instalments
  roughly double it.
- Household budget: income, fixed costs, what is actually left.

**SDG 2 — Zero Hunger (5 new)**
- Ration shop complaint: works out your entitlement first, then writes a
  complaint that names it, with the helpline and the escalation route.
- A child's arm check (MUAC): red, yellow or green, with swollen feet
  overriding a good reading.
- Feeding a baby, 0 to 24 months: how often, how thick, what to get in.
- How much to cook for a function, so less is thrown away.
- How much ration your card should get (shared with SDG 1).

**SDG 3 — Good Health (2 new)**
- Diarrhoea in a child: ORS volumes by age from WHO Plan A, the danger
  signs that mean go now, and the two beliefs that do the most harm. No
  medicine doses — zinc comes from the health worker.
- Blood pressure: which published band a reading falls in, and why one
  reading is not a diagnosis.

**SDG 4 — Quality Education (2 new)**
- Marks, percentage and CGPA, with the multiplier asked for rather than
  assumed.
- Study plan: the hours per chapter actually available, with a tenth of
  the days already taken off for life.

**Shared**
- New `tool_kit.dart`: number and text fields, one big answer, workings,
  a copyable draft, a source note, and a checklist that remembers itself.
- Validator: a new rule catches a latin letter inside a Devanagari word
  (it found a real typo in this zip), and top-level getters no longer
  look like unused imports.

**No new packages, no Android edits.**

---

## zip 22 — `sdg_app_zip22_mini-apps-and-issues.zip`
**16 Nov 2026**

Every goal becomes its own small app, and the whole app is organised around
problems rather than screens. **282 problems registered, 66 working today.**

- **Each goal is now a mini-app.** Its own colour bar, a hamburger menu of
  its problems, a right-hand panel, and a footer with four tabs: Home,
  Problems, Saved, Help. On a phone both side panels slide in; on a tablet
  or a browser they stay open beside the content.
- **Header shows your place, the weather, the day, the date and a live
  clock.** Tap it to change the place.
- **Weather is used, not just shown.** A heat warning appears on goals 3, 8
  and 13; a rain warning on goals 2, 11, 13 and 15. Weather comes from
  Open-Meteo (free, no key). The last reading is kept, so the header still
  works offline.
- **Your place**: guessed from the network (no permission, no new package),
  or searched and picked by you. Once you pick one, nothing overwrites it.
- **One search box on the home screen**, across all 282 problems, in English
  and Hindi. A result opens inside its goal, not on a bare screen.
- **Saved and recent tools**, kept on this phone only, wipeable from
  Settings in one tap.
- **Notices can be pinned to one goal** from Admin, and show in that goal's
  panel instead of interrupting everyone.
- **Every problem is listed, built or not.** The 216 not yet built are shown
  greyed with what they will do, so the map is honest rather than hidden.
- **One route for all 17 goals** (`/sdg/:goal`), read from the issue
  registry. A new problem is one entry in one file.
- Validator: issue ids unique and matching their goal, groups must exist,
  helplines digits-only, no per-goal routes, heat warning stays limited to
  the goals it bears on, and a guess may never overwrite a chosen place.
- The 9 old `*_home_page.dart` files are no longer used. They are left in
  place and harmless; the mini-app replaces them.

**No new packages, no Android edits.** Everything from zip 21 is carried.

---

## zip 21 — `sdg_app_zip21_lint-fixes.zip`
**3 Nov 2026**

- Cleared the 17 analyzer infos from zip 20: `const` in the About page,
  `library;` after the doc comments of two tool files, one `const` in
  SDG 12. No behaviour change.
- CHANGELOG: the work sent as zips 20–24 on 2 Nov is now one entry, zip 20,
  matching your repo. Where STATUS.md says "(zip 21)" to "(zip 24)", read
  "zip 20".
- LOCAL_CHANGES: step added — make sure the zip did not create a nested
  `sdg_app\sdg_app` folder.

---

## zip 20 — `sdg_app_zip20_all-17-goals.zip`
**2 Nov 2026**

Sent in five parts the same day and repackaged as one zip. Needs the two
Android edits in LOCAL_CHANGES.md #7 and
`firebase deploy --only firestore:rules,firestore:indexes`.

### Part 5 — goals 12, 14, 15, 17
**2 Nov 2026**

**All 17 goals are now built.** Deploy rules again (new `corrections`):
`firebase deploy --only firestore:rules`

- **SDG 12 — Responsible Consumption.** *Check a label* — type fat,
  saturated fat, sugar, salt (per 100 g, or per serving + serving size;
  sodium in mg converted) → low / medium / high, using the NHS
  traffic-light thresholds, clearly labelled as a comparison guide. Guides:
  Right to Repair portal, warranty complaints (1915), e-waste rules,
  banned single-use plastics (corrected against CPCB's own release).
- **SDG 14 — Life Below Water.** *Is the fishing ban on today?* — east
  coast 15 Apr–14 Jun, west coast 1 Jun–31 Jul (61 days, MPEDA), with days
  left or days until it starts, and the state-waters caveat. Guides: Coast
  Guard 1554, INCOIS forecasts and fishing-zone advisories, PMMSY support
  during the ban, reporting oil/dead fish, CRZ violations.
- **SDG 15 — Life on Land.** *Forest rights check* — ST / other forest
  dweller, before 13 Dec 2005, 75 years → individual (Form A), community
  (Form B), community forest resource (Form C), the evidence that counts,
  and the 60-day appeal. Guides: wildlife conflict and compensation (Rs 10
  lakh central guideline for a death), snakebite first aid, Soil Health
  Card and how to read it.
- **SDG 17 — Partnerships.** *Send a correction* — any user can point out a
  wrong number or dead link; it lands in Admin → Moderation → Corrections.
  *What this app keeps* — on the phone, on the server, AI questions, what
  we never do, how sure the information is.
- Home screen: every tile is live.
- Validator: fishing-ban dates, FRA eligibility, label thresholds pinned.

### Part 4 — goals 10, 11, 13
**2 Nov 2026**

Three new goals, each with a working tool. **13 of 17 goals built.**

- **SDG 10 — Reduced Inequalities.** *Which certificate do you need?* —
  purpose, category, income, disability → the exact papers (caste, OBC
  non-creamy layer, EWS with its asset tests, income, domicile, UDID) and
  where to get them. *Where to complain* — caste violence, exclusion,
  reservation denied, disability, religion, women, police abuse → police
  FIR / NCSC / NCST / NCBC / disability commissioner / NCM / NCW / NHRC, in
  order. Guides: disability rights, reservation in plain words.
- **SDG 11 — Sustainable Cities.** *Street complaint writer* — pick the
  problem, type the place, copy a ready complaint, then a 4-step escalation
  ladder (complaint number → commissioner/BDO → state grievance portal →
  RTI). *PM Awas checker* — urban/rural, pucca house, income, build/buy/
  rent → BLC, AHP, interest subsidy (4%, up to Rs 1.80 lakh), rental, or
  PMAY-G, always with the fraud warning. Guides: mutation, tax receipts,
  flood, earthquake, lightning.
- **SDG 13 — Climate Action.** *Heat illness check* — tick signs →
  heat stroke (call 108, cool fast) vs exhaustion vs early signs.
  *Crop loss clock* — PMFBY's 72-hour reporting deadline computed from the
  damage time, and the 14-day post-harvest cover checked; how to report
  (14447). Guides: IMD warning colours, Sachet/Damini/Meghdoot/Mausam apps,
  heat-wave safety for workers and older people.
- Titles and descriptions for goals 10–15 and 17 in all 14 languages.
- New shared widgets: `module_hub.dart` (hub, hero, rows, tool screen,
  answer list) and `core/sdg/advice.dart`.
- Validator: safety lines of the three tools pinned (e.g. confusion or
  collapse always means heat stroke; PMAY result always carries the fraud
  warning).

### Part 3 — food board, study Q&A
**2 Nov 2026**

**Deploy the rules and indexes after copying:**
`firebase deploy --only firestore:rules,firestore:indexes`
Without the rules, posting and claiming are refused; without the indexes, the
Q&A list shows an error for a few minutes while Firebase builds them.

- **SDG 2 — Food board** (the core of your old food-sharing app, built the
  safe way you chose). Post only from a passing "Can this be shared?" check;
  the listing disappears when the food stops being safe (cooked: ≤3 h);
  sign-in to post or claim; the public post has only a locality — phone and
  pickup details show only to the one person who claims; claim is
  first-come via a transaction; poster can reopen a no-show or close; any
  signed-in user can report, 3 reports hide a post.
- **SDG 4 — Study questions**, moderated, no DMs. Nothing appears until an
  admin approves it. No names on posts ("a student", "a helper"). Phone
  numbers, links, emails and @handles refused — in the app and again in the
  rules. Report button on every question and answer.
- **Admin → Moderation**: Q&A approval queue, Q&A reports, reported food
  posts.
- Firestore rules: `foodBoard` (+ private contact, reports), `qa`,
  `qaAnswers`, `qaReports`. Two composite indexes.
- Validator: food board and Q&A safety rules pinned (contact privacy, time
  cap, pending-before-visible, app/rules pattern equality); nullable-return
  functions now recognised.
- Everything from zips 20 and 21 carried.

### Part 2 — reminders, daily log
**2 Nov 2026**

**Needs two one-time edits under `android/` before it builds — LOCAL_CHANGES.md #7.**

- **SDG 3 — Medicine reminders.** Real phone notifications, daily, at the
  time the doctor said. The app never suggests a medicine or dose. Up to 20.
  Survives restarts. Android only; the website says so.
- **SDG 3 — Daily log.** Water, steps (typed in), active minutes; last 7
  days. No calorie or weight targets, on purpose. Phone only, 60 days kept.
- **SDG 3 — Leftover medicines.** Safe disposal, the strong-painkiller
  exception, and why not to pass medicines on (your answer: guide instead
  of donation).
- New packages: `flutter_local_notifications` ^19.4.0 (held below 20 so it
  works on your Flutter), `timezone`.
- Validator: new check — any `...Page`, `...Store`, `...Service` used in a
  file must be declared or imported there. It caught a missing import in
  this very zip before it shipped.
- Everything from zip 20 carried, `.gitignore` included.

### Part 1 — parity with the Render apps
**2 Nov 2026**

Feature parity with your five Render apps. See the parity table in STATUS.md.

- **SDG 3 — My child's vaccines.** Add a child by birth date; every dose
  gets its due date; tick off what is done. Stored on the phone only.
  Never says "late" — a missed dose says "go anyway".
- **SDG 3 — Free and cheaper care.** eSanjeevani (free doctor by video),
  Ayushman Arogya Mandir, PM-JAY Rs 5 lakh cover incl. everyone 70+,
  Jan Aushadhi. Tap-to-dial 14555.
- **SDG 4 — new home screen.** Scholarships stay first. Added: free learning
  by class level (DIKSHA, NCERT, PM eVIDYA, SWAYAM, NIOS, NDL) with subject
  search and language links; practice quiz (six subjects); literacy rates
  for India and neighbours, women and men side by side.
- **SDG 5 — Health and wellbeing.** Matru Vandana cash, free delivery under
  JSSK, anaemia, cancer screening, Tele-MANAS 14416. Plus "Money to start a
  business", opening the SDG 9 loan matcher.
- **New shared widget** `lib/core/widgets/guide_list_page.dart` (with
  tap-to-dial), used by SDG 3 and 5.
- **`fixes/5_EmpowHer/`** — corrected `app.py` for your EmpowHer Render app:
  key read from `GEMINI_API_KEY`, length and rate limits on every AI route.
  Not part of the Flutter app. Revoke the old key first.
- Validator: guide-set rules for the new datasets, learning `levels`,
  vaccination offsets.
- `.gitignore` carried.

---

## .gitignore — rewritten 31 Oct 2026

Sent on its own, and carried in zip 20 onward.

- **Release signing added, which was the serious omission.** `*.jks`,
  `*.keystore` and `key.properties` were not ignored. Committing a keystore
  to a public repo cannot be undone — git keeps history, and anyone holding
  it can sign an app as Ibtidaa Tech that Play Store accepts as an update
  to yours. Losing it is the mirror disaster: no update is possible ever
  again, only a new package name.
- Android `local.properties` and `.gradle/`, iOS and macOS Pods and Xcode
  user data, `node_modules/`, release `.apk`/`.aab` artefacts, editor and
  OS files.
- `pubspec.lock` and `.metadata` stay committed on purpose, with the reason
  in a comment — the lock file is what keeps the `intl` version from
  drifting again.
- `gradle.properties` stays committed too, because it carries the
  `kotlin.incremental=false` line this project needs on Windows.
- Validator now refuses to pass a project whose `.gitignore` has lost the
  keystore, `key.properties` or `.env` rules, or that has started ignoring
  `pubspec.lock`.
- **Fixed a documentation bug:** `LOCAL_CHANGES.md` listed `.gitignore`
  among the files I never ship. It has in fact been in every zip since 28
  October, so a zip would have silently overwritten any edit made to it.

## zip 19 — `sdg_app_zip19_sdg9-enterprise-schemes.zip`
**31 Oct 2026**

- **SDG 9 — Industry & Enterprise**, now live. **10 of 17 goals built.**
- **"Which scheme should I ask about?"** — five questions, routed across
  Mudra, PMEGP, PM SVANidhi and Stand-Up India. The gap here is not
  information, it is navigation: PMEGP pays a 15–35% subsidy but refuses a
  running unit, Mudra takes a running unit but stops at ten lakh, Stand-Up
  India starts above that for SC/ST and women founders only, SVANidhi is
  street vendors alone. Someone can walk past a grant they qualified for
  because nobody told them the word for it.
- The matcher names what you are **not** eligible for, and why. Dropping a
  scheme silently leaves someone who heard of it from a neighbour assuming
  the app missed it — and going to an agent who tells them what they want
  to hear.
- Two flaws found by enumerating all 192 input combinations before writing
  any UI: a street vendor asking for several lakh was being led with a
  ₹50,000 scheme, and 18 combinations matched nothing at all, leaving a
  blank screen where the ordinary MSME term-loan route applies. Both fixed,
  and the validator now guards against the blank result returning.
- **"This is not an approval"** sits on the results screen, with the
  advance-fee fraud named: no agent, consultant or middleman has the power
  to sanction anything, so a fee taken up front for a guaranteed loan is
  charged for something they cannot deliver. The validator rejects the page
  if that warning disappears.
- 14 guides: Udyam registration is free and the ministry states only one
  site is official, the MSME limits revised from 1 April 2025, the four
  schemes in plain terms, Jan Samarth as one window, what a bank actually
  looks at, writing your own project report instead of paying for one, UPI
  at the counter and ONDC.
- **Two figures deliberately left out.** The PMEGP project-cost ceiling:
  the official guidelines PDF says ₹25 lakh while recent sources say ₹50
  lakh, so the card states no number and points to the KVIC portal. And UPI
  merchant charges: zero since January 2020, a 0.4% charge announced for
  October 2026, deferred by NPCI, now under Supreme Court challenge — the
  card says exactly that instead of picking a side.
- Three content sources corrected mid-build, where a card's claim was not
  in the page it linked to.
- Validator gained 3 SDG 9 rules; the guide-dataset check now covers three
  goals through one shared rule.

## zip 18 — `sdg_app_zip18_sdg7-energy-billcheck.zip`
**31 Oct 2026**

- **SDG 7 — Affordable Energy**, now live. **9 of 17 goals built.**
- **"Is my bill right?"** — enter the two readings and the units billed,
  and it does the subtraction. Both numbers are printed on the same bill,
  so a mismatch is the one billing error anyone can prove standing at the
  counter, in any state, with no knowledge of tariffs.
- Findings are split into provable and worth-asking, and shown differently.
  A reading mismatch, a reading that went backwards, and an "estimated"
  bill are decisive. An odd-looking per-unit figure is phrased as a
  question, because fixed charges, arrears and a long billing period all
  explain it innocently.
- No rate check at all below 50 units: a household on 20 units with a ₹120
  fixed charge pays an effective ₹10/unit and nothing is wrong. Flagging
  that would send someone to argue a correct bill and spend the
  credibility they need at that office later.
- Copies a complaint draft with the arithmetic already filled in. Nothing
  typed leaves the device.
- The tool never says the bill is correct and never says you were
  overcharged. It checks arithmetic, not tariff, and the validator now
  rejects any user-facing string that claims either.
- 13 guides, each sourced: no connection without a meter and the 45-day
  grievance limit under the Electricity (Rights of Consumers) Rules 2020,
  the 7/15/30-day connection timelines, automatic compensation, how slabs
  and fixed charges work, the company → forum → ombudsman route, PM Surya
  Ghar subsidy bands and what to settle before paying a vendor, the
  Ujjwala ₹300 transfer and how to check it reached your account, WHO
  figures on cooking smoke, and LPG safety taken from the official PMUY
  consumer guidance.
- **Deliberately not built: a solar payback calculator.** Size and payback
  turn on installed cost per kW, state tariff, net-metering rules and the
  current subsidy, all of which move. On a one-to-two lakh decision a
  confident wrong number is worse than none, so the module explains the
  scheme and sends you to the portal.
- The Ujjwala card gives **no current refill count** on purpose. It has
  been 12, then 9, and was reported in mid-2026 as cut again. The card
  explains the mechanism and tells the reader to check their own bank
  credits, which is the only answer that stays true.
- Validator gained 4 SDG 7 rules and now checks both guide datasets through
  one shared rule rather than a copy per goal.

## zip 17 — `sdg_app_zip17_fix-undefined-hi.zip`
**31 Oct 2026**

Fixes the build break in zips 15 and 16. No new features.

- **Fixed: 3 compile errors.** `_GuideCard` in the SDG 16 and SDG 8 pages
  used `hi` after I removed the field that declared it. Both now derive it
  from the section language inside `build`, where `lang` already was.
- Fixed: unused `auth` local and its import in `home_page.dart` — the
  warning in your analyze output.
- Fixed: 6 of the 14 `prefer_const_constructors` hints in `about_page.dart`.
  The other 8 are left alone on purpose: those widgets take `onTap`
  closures, and a closure is not a constant expression, so adding `const`
  there does not compile. I tried it, caught it before shipping, and added
  a validator rule for it.
- **Validator: 3 real holes closed.**
  - It now rejects a locale name (`hi`, `lang`) used where nothing in the
    class declares it. This is the check that was missing — tested against
    the exact bug, and it reports the same two lines Flutter did.
  - The unused-import check had never fired on anything. It collected `if`
    as a declared symbol of every file, and since `if` appears in all Dart
    code, every import matched something. With that fixed it immediately
    found the real unused import above.
  - `const` holding a closure is now rejected, and the const check now
    looks at private widgets (`const _Foo(`) too, which it never had.

## zip 16 — `sdg_app_zip16_sdg6-clean-water.zip`
**30 Oct 2026**

- **SDG 6 — Clean Water**, now live. **8 of 17 goals built.**
- **"Is my water safe?"** — six questions, and unlike the other checkers it
  tracks two risks separately rather than scoring one. A germ problem and a
  chemical problem need opposite responses, and in India the universal
  advice — boil it — is correct for the first and useless for the second.
- Boiling removes no chemicals. Arsenic is invisible, odourless and
  tasteless, and the harm takes 5-10 years to show, so someone boiling
  faithfully in an affected belt gets no signal that it is not working.
  When the verdict is chemical, the screen says this before anything else.
- Handles the specific trap where water "was tested and was fine": the
  routine village field kit checks nine parameters and arsenic is not one
  of them, so a clear result in an arsenic area may never have looked.
- Iron gets its own calmer verdict. Treating a staining problem in the
  language reserved for arsenic is how people learn to ignore warnings.
- The tool never says your water is safe. It has no way to know, and the
  most positive verdict available says exactly that.
- 14 guides — the free village test and how to ask for it, what each
  treatment method does and does not remove, arsenic and fluoride, source
  and storage protection, the 55 lpcd JJM entitlement, and the complaint
  route from Gram Panchayat to CPGRAMS. Every card carries its government
  source and ships unverified.
- All 14 interface languages carry the new goal title.
- Validator gained 4 SDG 6 rules, including the one that matters: a
  chemical verdict may never contain a step telling the user to boil, and
  the microbial verdict must still contain one.
- Fixed before shipping: answering "yes — iron" fell through to the
  "never been tested" verdict, contradicting what the user had just said.

## zip 15 — `sdg_app_zip15_14-languages-section-switch.zip`
**30 Oct 2026**

- **14 languages in the interface** — English, हिन्दी, বাংলা, मराठी, తెలుగు,
  தமிழ், ગુજરાતી, اردو, ಕನ್ನಡ, ଓଡ଼ିଆ, മലയാളം, ਪੰਜਾਬੀ, অসমীয়া, नेपाली.
  69 strings each, complete parity, every language shown in its own script.
- **Per-section language switch** — a button on every content screen reads
  that one screen in another language and leaves the app language alone.
  19 screens. Not persisted, because "temporary" has to mean temporary.
- Urdu brings right-to-left; Flutter handles the direction from the locale.
- **Admin → Translate content** — add any language to any record, with the
  English original beside the box and progress counts per language and per
  dataset. Goes live without an app release.
- Content records gained an `i18n` map, so a record can carry any number of
  languages without a schema change or a field per language.
- Honest on-screen note when a screen has no text in the chosen language,
  rather than translated buttons implying translated articles.
- Fixed: the localisation delegate returned a real `Future`, which made
  every section language change flash a blank frame. Now synchronous.
- Fixed: the picker read the locale from inside its own override, so it
  reported the section language as the app language.
- Fixed: a method named `set` — Dart reads that as a setter declaration and
  will not parse it.
- Validator gained 7 checks: language key parity, unreachable or
  Flutter-unsupported language codes, the synchronous-delegate requirement,
  corrupted (U+FFFD) text, the bool→language-code accessor change, and
  `set`/`get`/`operator` used as method names.
- **Content stays English and Hindi.** The ~295 content strings are health,
  legal and food-safety claims; machine-translating those into languages
  nobody here reads is the one part of this request I did not do. Reasoning
  in `STATUS.md` and in `translations_page.dart`.

## zip 14 — `sdg_app_zip14_sdg8-work-jobscams.zip`
**30 Oct 2026**

- **SDG 8 — Decent Work**, now live
- **"Is this job real?"** — 10 scored red flags with a verdict. Asking for
  money, promising a government job, or wanting your OTP are decisive on
  their own; weaker signs accumulate.
- Straight through to 1930 and cybercrime.gov.in when it looks like fraud
- 10 work-rights guides: MGNREGA work demand and the dated receipt, the
  15-day rule, unemployment allowance, late-wage compensation, the 5 km
  rule, e-Shram registration, payslips, minimum wage, free skill training
- MGNREGA 1800-111-555 and National Career Service 14434, one tap
- **7 of 17 goals now built**

## zip 13 — `sdg_app_zip13_sdg16-rti-justice.zip`
**30 Oct 2026**

- **SDG 16 — Peace & Justice**, now live on the home grid
- **RTI application builder** — fill in the office, your questions, your
  details, and get a correctly formatted application to copy, post or paste
  into rtionline.gov.in. Nothing typed is uploaded.
- 11 civic guides: RTI timelines and both appeals, FIR and Zero FIR, rights
  on arrest, free legal aid, Lok Adalat, CPGRAMS, corruption reporting
- NALSA 15100 one-tap dial
- Editable from Admin → Edit content
- This CHANGELOG, and descriptive zip filenames from here on

## zip 12 — `sdg_app_zip12_sdg2-food-sharing.zip`
**30 Oct 2026**

- **SDG 2 — Zero Hunger**, completing all five original goals
- "Can this food be shared?" — guided safety check with a real verdict
- 9 FSSAI-sourced food safety rules, 8 household waste tips
- Routes donors to the official FSSAI Save Food Share Food network
- Collection-organisation directory ships empty by design, admin-filled
- The 12 locked tiles now open and show their planned features

## zip 11 — `sdg_app_zip11_sdg3-health.zip`
**30 Oct 2026**

- **SDG 3 — Good Health**
- 16 myth-vs-fact cards, English and Hindi, every one sourced
- One-tap copy for sharing on WhatsApp
- Full national immunisation schedule, birth to 16 years plus pregnancy
- 6 health helplines including Tele-MANAS
- No symptom checker, stated plainly in the app

## zip 10 — `sdg_app_zip10_admin-drawers-about.zip`
**29 Oct 2026**

- Master admin `free.timesenjoy@gmail.com`, enforced in Firestore rules
- Admin roles, promotion, and transferable ownership with a recovery account
- **Content editor** — fix any broken link or record from phone or web
- Left drawer: profile, navigation, admin panel, sign out
- Right panel: theme, language, text size, accent, recent notices
- About page, Terms & Conditions, Privacy Policy
- Fixed: two Firestore rules bugs — reports would have been world-readable,
  and `lower()` is a method not a function

## zip 9 — `sdg_app_zip9_sdg5-empowher.zip`
**29 Oct 2026**

- **SDG 5 — Gender Equality**
- One-tap 181 and 112, 7 national helplines, quick-exit button
- Abuse reporting with three modes, the user chooses what is stored
- Firestore rules: reports are write-only, nobody can read them back
- 9 legal rights in plain English and Hindi
- AI career guidance, business ideas, course finder
- 21 Indian women, described by what they did

## zip 8 — `sdg_app_zip8_fix-sliver-crash.zip`
**29 Oct 2026**

- Fixed the home-screen crash: `AdaptiveGrid` split into box and sliver
  versions, because a `sliver: true` flag that silently switched layout
  protocol was the root cause
- Validator now rejects a non-sliver widget in a `slivers:` list

## zip 7 — `sdg_app_zip7_fix-syntax.zip`
**29 Oct 2026**

- Fixed two syntax errors from the ContentShell edit
- Validator rewritten: balance alone was not enough, it now checks statement
  termination
- Stopped flagging Firebase config files as committed API keys

## zip 6 — `sdg_app_zip6_fix-http-body.zip`
**29 Oct 2026**

- Fixed a compile error: a bulk edit had wrapped an `http.post` body in a
  layout widget
- Added `tools/validate.py`

## zip 5 — `sdg_app_zip5_fix-intl-pin.zip`
**29 Oct 2026**

- Corrected the `intl` version at source, and added `LOCAL_CHANGES.md` so
  machine-side edits stop being clobbered

## zip 4 — `sdg_app_zip4_branding-responsive.zip`
**29 Oct 2026**

- Logo, app icon, favicons, PWA manifest, branded web loading screen
- Responsive layout from 320dp phones to desktop
- Replaced every `RadioListTile` with a version-proof `SelectionTile`

## zip 3 — `sdg_app_zip3_complete.zip`
**28 Oct 2026**

- Complete project with `firebase.json`, `firestore.indexes.json`, `SETUP.md`

## zips 1–2
**28 Oct 2026**

- App shell, theming, i18n, auth, SDG 1 schemes, SDG 4 scholarships,
  admin scaffold, AI proxy
