#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

printf "Loading variables into our context...\n"
source "${SCRIPT_DIR}/../set_variables.sh"

# Generate a list of 200 partner names following the structure RouteFromX
declare -a TEMPLATE_NAMES=(
        "RouteFromEngineer" "RouteFromGovernment" "RouteFromManager" "RouteFromClient" "RouteFromVendor" "RouteFromSupplier" "RouteFromCustomer" 
        "RouteFromPartner" "RouteFromDistributor" "RouteFromRetailer" "RouteFromWholesaler" "RouteFromAgent" "RouteFromBroker" "RouteFromConsultant" 
        "RouteFromContractor" "RouteFromInvestor" "RouteFromStakeholder" "RouteFromAuditor" "RouteFromInspector" "RouteFromAdvisor" "RouteFromDirector" 
        "RouteFromExecutive" "RouteFromAdministrator" "RouteFromCoordinator" "RouteFromSupervisor" "RouteFromTechnician" "RouteFromSpecialist" 
        "RouteFromAnalyst" "RouteFromStrategist" "RouteFromPlanner" "RouteFromArchitect" "RouteFromDesigner" "RouteFromDeveloper" "RouteFromProgrammer" 
        "RouteFromTester" "RouteFromTrainer" "RouteFromInstructor" "RouteFromProfessor" "RouteFromScientist" "RouteFromResearcher" "RouteFromDoctor" 
        "RouteFromNurse" "RouteFromPharmacist" "RouteFromTherapist" "RouteFromLawyer" "RouteFromJudge" "RouteFromOfficer" "RouteFromDetective" 
        "RouteFromSoldier" "RouteFromPilot" "RouteFromDriver" "RouteFromCourier" "RouteFromMessenger" "RouteFromOperator" "RouteFromMachinist" 
        "RouteFromAssembler" "RouteFromFabricator" "RouteFromWelder" "RouteFromElectrician" "RouteFromPlumber" "RouteFromCarpenter" "RouteFromPainter" 
        "RouteFromMechanic" "RouteFromTechnologist" "RouteFromScientist" "RouteFromBiologist" "RouteFromChemist" "RouteFromPhysicist" "RouteFromEconomist" 
        "RouteFromAccountant" "RouteFromBookkeeper" "RouteFromTreasurer" "RouteFromBanker" "RouteFromFinancier" "RouteFromTrader" "RouteFromMerchant" 
        "RouteFromMarketer" "RouteFromAdvertiser" "RouteFromPromoter" "RouteFromPublisher" "RouteFromEditor" "RouteFromWriter" "RouteFromJournalist" 
        "RouteFromReporter" "RouteFromPhotographer" "RouteFromArtist" "RouteFromMusician" "RouteFromActor" "RouteFromProducer" "RouteFromDirector" 
        "RouteFromCameraman" "RouteFromAnimator" "RouteFromIllustrator" "RouteFromDesigner" "RouteFromStylist" "RouteFromTailor" "RouteFromChef" 
        "RouteFromBaker" "RouteFromButcher" "RouteFromFarmer" "RouteFromGardener" "RouteFromFisherman" "RouteFromHunter" "RouteFromMiner" "RouteFromLogger" 
        "RouteFromRancher" "RouteFromBreeder" "RouteFromTrainer" "RouteFromHandler" "RouteFromZookeeper" "RouteFromVeterinarian" "RouteFromCaretaker" 
        "RouteFromCleaner" "RouteFromJanitor" "RouteFromCustodian" "RouteFromSecurity" "RouteFromGuard" "RouteFromPatrol" "RouteFromWatchman" 
        "RouteFromFirefighter" "RouteFromParamedic" "RouteFromRescuer" "RouteFromVolunteer" "RouteFromActivist" "RouteFromOrganizer" "RouteFromLeader" 
        "RouteFromMember" "RouteFromParticipant" "RouteFromSupporter" "RouteFromFollower" "RouteFromSubscriber" "RouteFromUser" "RouteFromViewer" 
        "RouteFromListener" "RouteFromReader" "RouteFromLearner" "RouteFromStudent" "RouteFromApprentice" "RouteFromIntern" "RouteFromTrainee" 
        "RouteFromCandidate" "RouteFromApplicant" "RouteFromNominee" "RouteFromWinner" "RouteFromChampion" "RouteFromCompetitor" "RouteFromPlayer" 
        "RouteFromAthlete" "RouteFromCoach" "RouteFromReferee" "RouteFromUmpire" "RouteFromJudge" "RouteFromOfficial" "RouteFromOrganizer" 
        "RouteFromSponsor" "RouteFromDonor" "RouteFromBenefactor" "RouteFromPhilanthropist" "RouteFromVolunteer" "RouteFromAdvocate" "RouteFromAmbassador" 
        "RouteFromEnvoy" "RouteFromDiplomat" "RouteFromConsul" "RouteFromEmissary" "RouteFromMessenger" "RouteFromCourier" "RouteFromTransporter" 
        "RouteFromDriver" "RouteFromPilot" "RouteFromCaptain" "RouteFromSailor" "RouteFromFisherman" "RouteFromHunter" "RouteFromExplorer" "RouteFromGuide"
)

# Loop through TEMPLATE_NAMES array and use each name as is
for TEMPLATE_NAME in "${TEMPLATE_NAMES[@]}"; do
        curl -k -u ${USER}:${PWD} -X POST "https://${SERVER}:${PORT}/api/v2.0/routes" -H "accept: */*" -H "Content-Type: application/json" \
        -d "{\"name\": \"${TEMPLATE_NAME}\", \"description\": \"Random text for ${TEMPLATE_NAME}\", \"type\": \"TEMPLATE\", \"conditionType\":\"MATCH_ALL\"}"
done
