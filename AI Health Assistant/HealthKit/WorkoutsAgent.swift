import HealthKit

// TODO: Make this conform to the HealthKitAgent protocol. re-design how we pull and store the workouts data.

class WorkoutsAgent: HealthKitAgent {
    func fetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        
    }
    
    func agentName() -> String {
        return "WorkoutsAgent"
    }
    
    private let healthStore = HKHealthStore()
    
    private func getWorkoutActivityTypeName(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .swimming:
            return "Swimming"
        case .hiking:
            return "Hiking"
        case .crossTraining:
            return "Cross Training"
        case .elliptical:
            return "Elliptical"
        case .functionalStrengthTraining:
            return "Functional Strength Training"
        case .golf:
            return "Golf"
        case .mixedCardio:
            return "Mixed Cardio"
        case .paddleSports:
            return "Paddle Sports"
        case .play:
            return "Play"
        case .preparationAndRecovery:
            return "Preparation and Recovery"
        case .skatingSports:
            return "Skating Sports"
        case .snowSports:
            return "Snow Sports"
        case .stairs:
            return "Stairs"
        case .surfingSports:
            return "Surfing Sports"
        case .yoga:
            return "Yoga"
        case .barre:
            return "Barre"
        case .coreTraining:
            return "Core Training"
        case .crossCountrySkiing:
            return "Cross Country Skiing"
        case .downhillSkiing:
            return "Downhill Skiing"
        case .flexibility:
            return "Flexibility"
        case .highIntensityIntervalTraining:
            return "High Intensity Interval Training"
        case .jumpRope:
            return "Jump Rope"
        case .kickboxing:
            return "Kickboxing"
        case .pilates:
            return "Pilates"
        case .snowboarding:
            return "Snowboarding"
        case .soccer:
            return "Soccer"
        case .softball:
            return "Softball"
        case .squash:
            return "Squash"
        case .stairClimbing:
            return "Stair Climbing"
        case .stepTraining:
            return "Step Training"
        case .wheelchairWalkPace:
            return "Wheelchair Walk Pace"
        case .wheelchairRunPace:
            return "Wheelchair Run Pace"
        case .wrestling:
            return "Wrestling"
        default:
            return "Other"
        }
    }
}
