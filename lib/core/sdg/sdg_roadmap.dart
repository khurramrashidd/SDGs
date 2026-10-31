/// What each unbuilt goal will contain.
///
/// These are shown on the locked tiles so the app states its plan rather
/// than just saying "coming soon". Each one follows the same rule the built
/// modules follow: find the thing that is genuinely missing in India, and
/// avoid rebuilding what the government already does better.
library;

const Map<int, List<String>> kSdgRoadmap = {
  10: [
    'Caste, disability and minority certificates: what each unlocks and how to apply',
    'Reservation in education and jobs explained without jargon',
    'Filing a discrimination complaint, and which commission handles it',
    'Accessibility rights for persons with disabilities, and the UDID card',
  ],
  11: [
    'Property tax, mutation and the documents that prevent a land dispute',
    'PM Awas Yojana: urban and rural eligibility, and tracking an application',
    'Municipal complaints that actually get resolved: how to escalate',
    'Local disaster preparedness — flood, heat wave, earthquake',
  ],
  12: [
    'Reading a food label: what the numbers and claims really mean',
    'Repair before replace — electronics, clothes, and where to find a repairer',
    'Safe e-waste disposal and the authorised collection points',
    'Spotting greenwashing in everyday products',
  ],
  13: [
    'Heat wave survival: the signs of heat stroke and what to do first',
    'Local flood and cyclone warnings, and what each alert level means',
    'Crop advisories and weather-based insurance claims for farmers',
    'Household actions that genuinely cut emissions, ranked by effect',
  ],
  14: [
    'Coastal livelihoods: fishing seasons, bans and compensation schemes',
    'Plastic in the sea — where it actually comes from and what stops it',
    'Reporting an oil spill, dead fish or illegal coastal construction',
    'Protected marine areas and what is permitted in them',
  ],
  15: [
    'Forest Rights Act: how a claim is filed and what it grants',
    'Identifying common trees and what grows well locally',
    'Reporting illegal felling, poaching or a human-wildlife conflict',
    'Soil health card, and how to read the recommendations on it',
  ],
  17: [
    'Transparency: what this app stores, what it costs to run, and who maintains it',
    'Open the content library so any organisation can reuse the data',
    'Directory of verified NGOs and government programmes by goal',
    'How to contribute a correction, a translation or a local dataset',
  ],
};
