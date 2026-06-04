```mermaid
classDiagram
    direction LR

   
    class Role {
        +RoleID: Int
        +RoleName: String
        +Description?: String
    }

    class User {
        +UserID: Int
        +AuthUID: String
        +FirstName: String
        +LastName?: String
        +Email: String
        +PhoneNumber?: String
        +Photo?: String
        +PasswordHash: String
        +IsActive: Boolean
        +CreatedAt: DateTime
        +UpdatedAt?: DateTime
        +DeletedAt?: DateTime
        +login()
        +refresh()
        +logout()
        +logoutAll()
        +me()
        +updateProfile()
        +changePassword()
        +switchRole()
    }

    class UserRole {
        +UserID: Int
        +RoleID: Int
    }

    class RefreshToken {
        +TokenID: Int
        +UserID: Int
        +Token: String
        +ExpiresAt: DateTime
        +CreatedAt: DateTime
        +RevokedAt?: DateTime
    }

 
    class StudentAccount {
        +StudentAccountID: Int
        +UserID: Int
        +BirthDate: Date
        +GuardianName?: String
        +GuardianPhone?: String
        +IsModalityLocked: Boolean
        +getProfile()
        +getDashboard()
        +getUpcomingSchedule()
        +getSessionHistory()
    }


    class Studio {
        +StudioID: Int
        +StudioName: String
        +Capacity: Int
    }

    class StudioBlock {
        +StudioBlockID: Int
        +StudioID: Int
        +StartsAt: DateTime
        +EndsAt: DateTime
        +Reason?: String
        +BlockType: String
        +CreatedByUserID: Int
        +CreatedAt: DateTime
        +IsActive: Boolean
    }

    class StudioStatusOverride {
        +StudioStatusOverrideID: Int
        +StudioID: Int
        +Status: String
        +Reason?: String
        +StartsAt: DateTime
        +EndsAt?: DateTime
        +SetByUserID: Int
        +CreatedAt: DateTime
        +UpdatedAt?: DateTime
        +IsActive: Boolean
    }

    class StudioModality {
        +StudioID: Int
        +ModalityID: Int
    }


    class Modality {
        +ModalityID: Int
        +ModalityName: String
    }

    class TeacherModality {
        +TeacherID: Int
        +ModalityID: Int
    }

    class TeacherAssignmentRole {
        +AssignmentRoleID: Int
        +RoleName: String
    }

    
    class CoachingSession {
        +SessionID: Int
        +StudioID: Int
        +StartTime: DateTime
        +EndTime: DateTime
        +StatusID: Int
        +ModalityID: Int
        +FinalPrice?: Decimal
        +RequestedByUserID: Int
        +PricingRateID: Int
        +MaxParticipants?: Int
        +IsExternal: Boolean
        +IsOutsideStdHours: Boolean
        +CreatedAt: DateTime
        +ValidationRequestedAt?: DateTime
        +ReviewedByUserID?: Int
        +ReviewedAt?: DateTime
        +ReviewNotes?: String
        +CancellationReason?: String
        +getAvailableSlots()
        +createSession()
        +createBooking()
        +confirmCompletion()
        +cancelBooking()
        +registerNoShow()
    }

    class SessionStatus {
        +StatusID: Int
        +StatusName: String
    }

    class SessionPricingRate {
        +PricingRateID: Int
        +RateName: String
        +HourlyRate: Decimal
        +Description?: String
    }

    class SessionStudent {
        +SessionID: Int
        +StudentAccountID: Int
        +EnrolledAt: DateTime
        +AttendanceStatusID: Int
    }

    class AttendanceStatus {
        +AttendanceStatusID: Int
        +StatusName: String
    }

    class SessionTeacher {
        +SessionID: Int
        +TeacherID: Int
        +AssignmentRoleID: Int
    }

   
    class CoachingJoinRequest {
        +JoinRequestID: Int
        +SessionID: Int
        +StudentAccountID: Int
        +RequestedAt: DateTime
        +StatusID: Int
        +ReviewedByUserID?: Int
        +ReviewedAt?: DateTime
        +createJoinRequest()
        +getTeacherPending()
        +teacherApprove()
        +teacherReject()
        +getAdminPending()
        +adminApprove()
        +adminReject()
        +getStudentRequests()
        +cancelJoinRequest()
    }

    class CoachingJoinRequestStatus {
        +StatusID: Int
        +StatusName: String
    }

   
    class SessionValidation {
        +ValidationID: Int
        +SessionID: Int
        +ValidatedByUserID: Int
        +ValidatedAt: DateTime
        +ValidationStepID: Int
    }

    class ValidationStep {
        +StepID: Int
        +StepName: String
    }

    
    class TeacherAvailability {
        +AvailabilityID: Int
        +TeacherID: Int
        +RequestedAt: DateTime
        +StatusID: Int
        +Notes?: String
        +ReviewedByUserID?: Int
        +ReviewedAt?: DateTime
        +ReviewNotes?: String
        +submitTeacherAvailability()
        +listTeacherAvailability()
        +listAdminPendingAvailability()
        +approveAvailability()
        +rejectAvailability()
        +createTeacherException()
        +cancelTeacherAvailability()
    }

    class TeacherAvailabilityStatus {
        +StatusID: Int
        +StatusName: String
    }

    class TeacherAvailabilityRecurring {
        +AvailabilityID: Int
        +DayOfWeek: Int
        +StartTime: Time
        +EndTime: Time
        +AcademicYearID: Int
        +IsActive: Boolean
    }

    class TeacherAvailabilityPunctual {
        +AvailabilityID: Int
        +StartDateTime: DateTime
        +EndDateTime: DateTime
    }

    
    class TeacherAbsence {
        +AbsenceID: Int
        +TeacherID: Int
        +StartDate: DateTime
        +EndDate: DateTime
        +Reason?: String
        +StatusID: Int
        +RequestedAt: DateTime
        +ReviewedByUserID?: Int
        +ReviewedAt?: DateTime
        +ReviewNotes?: String
    }

    class TeacherAbsenceStatus {
        +StatusID: Int
        +StatusName: String
    }

    
    class Notification {
        +NotificationID: Int
        +UserID: Int
        +Title: String
        +Message?: String
        +TypeID: Int
        +SessionID?: Int
        +IsRead: Boolean
        +CreatedAt: DateTime
        +create()
        +sendNotification()
        +broadcastNotification()
        +getAllByUser()
        +getById()
        +markAsRead()
        +remove()
    }

    class NotificationType {
        +TypeID: Int
        +TypeName: String
    }

    
    class ItemCategory {
        +CategoryID: Int
        +CategoryName: String
        +Description?: String
        +IsActive: Boolean
    }

    class InventoryItem {
        +InventoryItemID: Int
        +ItemName: String
        +CategoryID: Int
        +SymbolicFee: Decimal
        +Description?: String
        +PhotoURL?: String
        +TotalQuantity: Int
        +IsSchoolOwned: Boolean
    }

    class InventoryTransaction {
        +TransactionID: Int
        +InventoryItemID: Int
        +RenterID: Int
        +StartDate: DateTime
        +EndDate?: DateTime
        +PaymentMethodID: Int
        +IsCompleted: Boolean
        +ConditionChecked: Boolean
        +ReturnVerified: Boolean
        +ReturnConditionStatus?: String
        +ReturnConditionNotes?: String
        +ReturnVerifiedAt?: DateTime
        +ApprovalStatus?: String
        +ApprovedAt?: DateTime
        +ApprovalNotes?: String
        +createRental()
        +getRentals()
        +approveRental()
        +verifyReturn()
        +rejectReturn()
    }

    class PaymentMethod {
        +PaymentMethodID: Int
        +MethodName: String
        +IsActive: Boolean
    }

   
    class MarketplaceItem {
        +MarketplaceItemID: Int
        +SellerID: Int
        +CategoryID?: Int
        +Title: String
        +Description?: String
        +Price: Decimal
        +ConditionID: Int
        +StatusID: Int
        +PhotoURL?: String
        +Location?: String
        +RejectionReason?: String
        +CreatedAt: DateTime
        +IsActive: Boolean
        +createListing()
        +getListings()
        +getListingById()
        +getMyListings()
        +updateListing()
        +deleteListing()
    }

    class MarketplaceItemCondition {
        +ConditionID: Int
        +ConditionName: String
    }

    class MarketplaceItemStatus {
        +StatusID: Int
        +StatusName: String
    }

    class MarketplaceTransaction {
        +TransactionID: Int
        +MarketplaceItemID: Int
        +BuyerID: Int
        +TransactionDate: DateTime
        +PaymentMethodID: Int
    }

    
    class FinancialEntry {
        +EntryID: Int
        +SessionID: Int
        +Amount: Decimal
        +EntryTypeID: Int
        +CreatedAt: DateTime
        +IsExported: Boolean
        +ExportedByUserID?: Int
        +FinancialSummaryID: Int
    }

    class FinancialEntryType {
        +EntryTypeID: Int
        +TypeName: String
    }

    class FinancialSummary {
        +FinancialSummaryID: Int
        +AcademicYearID: Int
        +PeriodStart: Date
        +PeriodEnd: Date
        +GeneratedAt: DateTime
        +GeneratedByUserID: Int
        +TotalAmount: Decimal
        +IsExported: Boolean
    }

    
    class AcademicYear {
        +AcademicYearID: Int
        +Label: String
        +StartsOn: Date
        +EndsOn: Date
        +IsActive: Boolean
    }

    class SchoolEvent {
        +EventID: Int
        +Title: String
        +Description?: String
        +StartsAt: DateTime
        +EndsAt: DateTime
        +AudienceScopeID: Int
        +AcademicYearID: Int
        +CreatedByUserID: Int
        +StatusID: Int
        +IsActive: Boolean
    }

    class SchoolEventStatus {
        +StatusID: Int
        +StatusName: String
    }

    class AudienceScope {
        +AudienceScopeID: Int
        +ScopeName: String
    }

    class SchoolSchedule {
        +ScheduleEntryID: Int
        +StartsAt: DateTime
        +EndsAt: DateTime
        +Notes?: String
        +StudioID?: Int
        +AcademicYearID: Int
        +StatusID: Int
        +IsActive: Boolean
    }

    class SchoolScheduleStatus {
        +StatusID: Int
        +StatusName: String
    }

    
    class LostAndFoundItem {
        +LostItemID: Int
        +Title: String
        +Description?: String
        +Location?: String
        +FoundDate: DateTime
        +ClaimedStatus: Boolean
        +PhotoURL?: String
        +IsArchived: Boolean
        +AdminNotes?: String
        +ArchivedAt?: DateTime
        +RegisteredByUserID: Int
        +create()
        +listPublicItems()
        +claimItem()
        +archiveItem()
    }

   
    class AuditLog {
        +AuditLogID: Int
        +AuditTimestamp: DateTime
        +UserID?: Int
        +UserName?: String
        +UserRole?: String
        +Action: String
        +Module: String
        +TargetType?: String
        +TargetID?: String
        +Result: String
        +Detail?: String
    }

    class CoachingRequest {
        +RequestID: Int
        +StudentUserID: Int
        +TeacherUserID: Int
        +RequestedByUserID: Int
        +ModalityID: Int
        +StudioID?: Int
        +ConfirmedSessionID?: Int
        +GroupProposalID?: Int
        +PreferredStartTime: DateTime
        +PreferredEndTime?: DateTime
        +CurrentStartTime: DateTime
        +CurrentEndTime?: DateTime
        +SuggestedStartTime?: DateTime
        +SuggestedEndTime?: DateTime
        +Status: String
        +RequestNotes?: String
        +TeacherResponseNotes?: String
        +StudentResponseNotes?: String
        +AdminResponseNotes?: String
        +RequestedAt: DateTime
        +UpdatedAt?: DateTime
        +ResolvedAt?: DateTime
        +createCoachingRequest()
        +listModalities()
        +listTeachersByModality()
        +getTeacherWeeklyAvailability()
        +listRequestsForStudent()
        +listRequestsForTeacher()
        +listRequestsForAdmin()
        +getRequestById()
        +reviewRequestAsTeacher()
        +respondToTeacherSuggestion()
        +reviewRequestAsAdmin()
        +getCompatibleStudiosForRequest()
    }

    class CoachingRequestAction {
        +RequestActionID: Int
        +RequestID: Int
        +ActorUserID: Int
        +ActionType: String
        +PreviousStatus?: String
        +NextStatus?: String
        +Message?: String
        +ProposedStartTime?: DateTime
        +ProposedEndTime?: DateTime
        +CreatedAt: DateTime
    }

    class GroupCoachingProposal {
        +ProposalID: Int
        +TeacherUserID: Int
        +ModalityID: Int
        +StudioID?: Int
        +ConfirmedSessionID?: Int
        +StartTime: DateTime
        +EndTime: DateTime
        +Status: String
        +Notes?: String
        +AdminResponseNotes?: String
        +RequestedAt: DateTime
        +UpdatedAt?: DateTime
        +ResolvedAt?: DateTime
        +searchStudents()
        +createProposal()
        +listTeacherProposals()
        +listAdminProposals()
        +getCompatibleStudios()
        +reviewProposal()
    }

    class GroupCoachingParticipant {
        +ParticipantID: Int
        +ProposalID: Int
        +StudentUserID: Int
        +SourceRequestID?: Int
        +AddedAt: DateTime
    }

    class StudentAllowedModality {
        +StudentAccountID: Int
        +ModalityID: Int
    }

    class Timetable {
        +TimetableID: Int
        +Label: String
        +IsActive: Boolean
        +CreatedBy?: Int
        +CreatedAt: DateTime
        +listTimetables()
        +getTimetable()
        +createTimetable()
        +updateTimetable()
        +deleteTimetable()
    }

    class TimetableSlot {
        +SlotID: Int
        +TimetableID: Int
        +DayOfWeek: Int
        +StartMinutes: Int
        +EndMinutes: Int
        +Title: String
        +TeacherUserID?: Int
        +StudioID?: Int
        +ModalityID?: Int
        +Color?: String
        +Notes?: String
        +createSlot()
        +updateSlot()
        +deleteSlot()
    }

    

    
    User "0..*" -- "0..*" Role : has roles
    User "1" *-- "0..1" StudentAccount : student account
    User "1" --> "0..*" RefreshToken : refresh tokens

   
    Studio "1" <-- "0..*" CoachingSession : hosted in
    Modality "1" <-- "0..*" CoachingSession : modality
    SessionStatus "1" <-- "0..*" CoachingSession : status
    SessionPricingRate "1" <-- "0..*" CoachingSession : pricing rate
    User "1" <-- "0..*" CoachingSession : requested by
    User "0..*" <-- "0..*" CoachingSession : reviewed by

   
    CoachingSession "1" *-- "1..*" SessionTeacher : teachers
    User "1" <-- "0..*" SessionTeacher : teacher
    TeacherAssignmentRole "1" <-- "0..*" SessionTeacher : assignment role

    
    CoachingSession "1" *-- "0..*" SessionStudent : students
    StudentAccount "1" <-- "0..*" SessionStudent : student
    AttendanceStatus "1" <-- "0..*" SessionStudent : attendance

   
    CoachingSession "1" *-- "0..*" CoachingJoinRequest : join requests
    StudentAccount "1" <-- "0..*" CoachingJoinRequest : student
    CoachingJoinRequestStatus "1" <-- "0..*" CoachingJoinRequest : status
    User "0..*" <-- "0..*" CoachingJoinRequest : reviewed by

    
    CoachingSession "1" *-- "0..*" SessionValidation : validations
    ValidationStep "1" <-- "0..*" SessionValidation : step
    User "1" <-- "0..*" SessionValidation : validated by

   
    Studio "0..*" -- "0..*" Modality : supports via
    StudioModality "1" --> "1" Studio : studio
    StudioModality "1" --> "1" Modality : modality
    Studio "1" <-- "0..*" StudioBlock : blocks
    Studio "1" <-- "0..*" StudioStatusOverride : overrides
    User "1" <-- "0..*" StudioBlock : created by
    User "1" <-- "0..*" StudioStatusOverride : set by

 
    User "1" <-- "0..*" TeacherAvailability : teacher
    TeacherAvailabilityStatus "1" <-- "0..*" TeacherAvailability : status
    User "0..*" <-- "0..*" TeacherAvailability : reviewed by
    TeacherAvailability <|-- TeacherAvailabilityRecurring
    TeacherAvailability <|-- TeacherAvailabilityPunctual
    AcademicYear "1" <-- "0..*" TeacherAvailabilityRecurring : academic year
    TeacherModality "1" --> "1" User : teacher
    TeacherModality "1" --> "1" Modality : modality

    
    User "1" <-- "0..*" TeacherAbsence : teacher
    TeacherAbsenceStatus "1" <-- "0..*" TeacherAbsence : status
    User "0..*" <-- "0..*" TeacherAbsence : reviewed by

   
    User "1" <-- "0..*" Notification : receives
    NotificationType "1" <-- "0..*" Notification : type
    CoachingSession "0..1" <-- "0..*" Notification : related to

  
    ItemCategory "1" <-- "0..*" InventoryItem : category
    InventoryItem "1" *-- "0..*" InventoryTransaction : transactions
    User "1" <-- "0..*" InventoryTransaction : renter
    PaymentMethod "1" <-- "0..*" InventoryTransaction : payment

    
    ItemCategory "0..1" <-- "0..*" MarketplaceItem : category
    MarketplaceItemCondition "1" <-- "0..*" MarketplaceItem : condition
    MarketplaceItemStatus "1" <-- "0..*" MarketplaceItem : status
    User "1" <-- "0..*" MarketplaceItem : seller
    MarketplaceItem "1" <-- "0..*" MarketplaceTransaction : item
    User "1" <-- "0..*" MarketplaceTransaction : buyer
    PaymentMethod "1" <-- "0..*" MarketplaceTransaction : payment

   
    CoachingSession "1" <-- "0..*" FinancialEntry : generated from
    FinancialEntryType "1" <-- "0..*" FinancialEntry : type
    FinancialSummary "1" o-- "0..*" FinancialEntry : aggregates
    User "1" <-- "0..*" FinancialEntry : exported by
    User "1" <-- "0..*" FinancialSummary : generated by
    AcademicYear "1" <-- "0..*" FinancialSummary : academic year

    
    AcademicYear "1" *-- "0..*" SchoolEvent : events
    AcademicYear "1" *-- "0..*" SchoolSchedule : schedules
    AcademicYear "1" *-- "0..*" TeacherAvailabilityRecurring : availabilities
    SchoolEvent "1" --> "1" SchoolEventStatus : status
    SchoolEvent "1" --> "1" AudienceScope : audience
    User "1" <-- "0..*" SchoolEvent : created by
    SchoolSchedule "1" --> "1" SchoolScheduleStatus : status
    Studio "0..1" <-- "0..*" SchoolSchedule : studio

    
    User "1" <-- "0..*" LostAndFoundItem : registered by

    
    User "0..1" <-- "0..*" AuditLog : performed by

    
    User "1" <-- "0..*" CoachingRequest : student / teacher / requested by
    Modality "1" <-- "0..*" CoachingRequest : modality
    Studio "0..1" <-- "0..*" CoachingRequest : studio
    CoachingSession "0..1" <-- "0..*" CoachingRequest : confirmed session
    CoachingRequest "1" *-- "0..*" CoachingRequestAction : actions
    User "1" <-- "0..*" CoachingRequestAction : actor
    GroupCoachingProposal "0..1" <-- "0..*" CoachingRequest : group proposal

    
    User "1" <-- "0..*" GroupCoachingProposal : teacher
    Modality "1" <-- "0..*" GroupCoachingProposal : modality
    Studio "0..1" <-- "0..*" GroupCoachingProposal : studio
    CoachingSession "0..1" <-- "0..*" GroupCoachingProposal : confirmed session
    GroupCoachingProposal "1" *-- "0..*" GroupCoachingParticipant : participants
    User "1" <-- "0..*" GroupCoachingParticipant : student
    CoachingRequest "0..1" <-- "0..*" GroupCoachingParticipant : source request

    
    StudentAccount "1" *-- "0..*" StudentAllowedModality : allowed modalities
    Modality "1" <-- "0..*" StudentAllowedModality : modality

    
    Timetable "1" *-- "0..*" TimetableSlot : slots
    User "0..1" <-- "0..*" Timetable : created by
    User "0..1" <-- "0..*" TimetableSlot : teacher
    Studio "0..1" <-- "0..*" TimetableSlot : studio
    Modality "0..1" <-- "0..*" TimetableSlot : modality
```