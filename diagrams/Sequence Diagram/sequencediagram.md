## SD-01: User Authentication

```mermaid
sequenceDiagram
    actor User
    participant Platform as Platform
    participant AuthController as AuthController
    participant JwtService as JwtService

    User->>Platform: open login page
    activate Platform
    Platform-->>User: render login form
    User->>Platform: login(email, password)
    Platform->>AuthController: login(email, password)
    activate AuthController
    AuthController->>AuthController: findUserByEmail(email)
    AuthController->>AuthController: bcrypt.compare(password, PasswordHash)
    AuthController->>JwtService: issueAuthTokens({ user, role, ip, userAgent })
    JwtService-->>AuthController: { accessToken, refreshToken, refreshTokenExpiresAt }
    AuthController-->>Platform: { user, role, accessToken, tokenType, expiresIn }
    Platform-->>User: redirect to dashboard
    deactivate AuthController
    deactivate Platform
```

---

## SD-02: Coaching Session Booking Request

```mermaid
sequenceDiagram
    actor Student
    participant Platform as Platform
    participant CoachingController as CoachingController
    participant CoachingService as CoachingService
    participant CoachingUseCases as CoachingUseCases
    participant NotificationController as NotificationController

    Student->>Platform: select modality and schedule
    Platform->>CoachingController: getAvailableSlots(weekStart, modalityId, teacherId)
    CoachingController->>CoachingService: getAvailableSlots({ weekStart, startDate, endDate, teacherId, modalityId, authenticatedUserId })
    CoachingService-->>CoachingController: { slots }
    CoachingController-->>Platform: { slots }
    Platform-->>Student: display available slots

    Student->>Platform: createBooking(payload)
    Platform->>CoachingController: createBooking(payload)
    activate CoachingController
    CoachingController->>CoachingUseCases: createBookingRequest.execute({ req, studentUserId, payload })
    CoachingUseCases-->>CoachingController: { session }
    CoachingController-->>Platform: { session }
    deactivate CoachingController
    Platform-->>Student: Session created (Pending Approval)

    Student->>Platform: booking request sent
    Platform->>NotificationController: broadcastNotification()
    NotificationController-->>Student: Notification sent to Management
```

---

## SD-03: Post-Coaching Double Validation

```mermaid
sequenceDiagram
    actor Teacher
    actor Student
    actor Admin
    participant Platform as Platform
    participant CoachingController as CoachingController
    participant CoachingService as CoachingService
    participant TeacherController as TeacherController
    participant AdminController as AdminController
    participant AdminService as AdminService
    participant PricingService as PricingService

    Note over CoachingController: Session Status: Scheduled

    alt Teacher confirms completion
        Teacher->>Platform: confirmCompletion(sessionId)
        Platform->>TeacherController: confirmCompletion(sessionId)
        Note over TeacherController: creates SessionValidation (TeacherConfirmation),<br/>Session → Finalization_Validation_Pending
        TeacherController-->>Platform: { validationId, sessionId }
        Platform-->>Teacher: Completion confirmed
    else Student confirms completion
        Student->>Platform: confirmCompletion(sessionId)
        Platform->>CoachingController: confirmCompletion(sessionId)
        CoachingController->>CoachingService: confirmCompletion(sessionId, studentUserId)
        Note over CoachingService: creates SessionValidation (StudentConfirmation),<br/>Session → Finalization_Validation_Pending
        CoachingService-->>CoachingController: { validationId, sessionId, step, validatedAt }
        CoachingController-->>Platform: { validationId, sessionId }
        Platform-->>Student: Completion confirmed
    end

    Admin->>Platform: finalizeSessionValidation(sessionId)
    Platform->>AdminController: finalizeSessionValidation(sessionId)
    AdminController->>AdminService: finalizeSessionValidation({ sessionId, adminUserId })
    Note over AdminService: creates SessionValidation (AdminFinalValidation),<br/>Session → Finalized
    AdminService->>PricingService: generateFinancialEntryOnFinalization(sessionId, adminUserId, tx)
    PricingService-->>AdminService: { EntryID } (FinancialEntry type=session_revenue)
    AdminService-->>AdminController: { sessionId, validationId, finalizedAt, financialEntryId }
    AdminController-->>Platform: { sessionId, validationId, finalizedAt, financialEntryId }
    Platform-->>Admin: Validation finalized
```

---

## SD-04: Session Cancellation with Justification

```mermaid
sequenceDiagram
    actor Student
    participant Platform as Platform
    participant CoachingController as CoachingController
    participant CoachingService as CoachingService
    participant NotificationController as NotificationController

    Note over CoachingController: Session Status: Scheduled
    Student->>Platform: cancelBooking(sessionId, justification)
    Platform->>CoachingController: cancelBooking(sessionId, justification)
    activate CoachingController
    CoachingController->>CoachingService: cancelBooking(sessionId, studentUserId, justification)
    CoachingService-->>CoachingController: { session }
    CoachingController-->>Platform: { session }
    deactivate CoachingController
    Platform-->>Student: Booking cancelled

    Platform->>NotificationController: broadcastNotification()
    NotificationController-->>Student: Notification sent to Management
```

---

## SD-05: No-Show Recording

```mermaid
sequenceDiagram
    actor Teacher
    participant Platform as Platform
    participant TeacherController as TeacherController
    participant PricingService as PricingService
    participant NotificationController as NotificationController

    Note over TeacherController: Session Status: Scheduled – student absent
    Teacher->>Platform: registerNoShow(sessionId, studentAccountId, remarks)
    Platform->>TeacherController: registerNoShow(sessionId, studentAccountId, remarks)
    Note over TeacherController: SessionStudent.AttendanceStatus → NO_SHOW,<br/>Session → No_Show, SessionValidation (NoShowRecorded)
    TeacherController->>PricingService: applyNoShowPenalty(sessionId, teacherUserId)
    PricingService-->>TeacherController: { FinancialEntry (no_show_fee, full price) }
    TeacherController-->>Platform: { sessionId, studentAccountId, status: 'no_show_registered' }
    Platform-->>Teacher: No-show recorded

    Note over TeacherController: createAdminNotifications() + student notification (in-DB)
    NotificationController-->>Teacher: Management & student notified
```

---

## SD-06: Student Join Request to Existing Session

```mermaid
sequenceDiagram
    actor Student
    actor Teacher
    actor Admin
    participant Platform as Platform
    participant JoinRequestController as JoinRequestController
    participant CoachingController as CoachingController
    participant NotificationController as NotificationController

    Student->>Platform: createJoinRequest(sessionId)
    Platform->>JoinRequestController: createJoinRequest(sessionId)
    JoinRequestController->>JoinRequestController: createJoinRequest(sessionId)
    JoinRequestController-->>Platform: { joinRequest }
    Platform-->>Student: Join request submitted

    Teacher->>Platform: getTeacherPending()
    Platform->>JoinRequestController: getTeacherPending()
    JoinRequestController-->>Platform: { joinRequests }
    Platform-->>Teacher: Display pending join requests

    Teacher->>Platform: teacherApprove(joinRequestId)
    Platform->>JoinRequestController: teacherApprove(joinRequestId)
    JoinRequestController->>JoinRequestController: teacherApprove(joinRequestId)
    JoinRequestController-->>Platform: { joinRequest }
    Platform-->>Teacher: Request approved by teacher

    Admin->>Platform: getAdminPending()
    Platform->>JoinRequestController: getAdminPending()
    JoinRequestController-->>Platform: { joinRequests }
    Platform-->>Admin: Display pending join requests

    Admin->>Platform: adminApprove(joinRequestId)
    Platform->>JoinRequestController: adminApprove(joinRequestId)
    JoinRequestController->>JoinRequestController: adminApprove(joinRequestId)
    JoinRequestController-->>Platform: { joinRequest }
    Platform-->>Admin: Request approved by admin

    Platform->>NotificationController: broadcastNotification()
    NotificationController-->>Student: Notification sent to Student
```

---

## SD-07: Teacher Availability Setup

```mermaid
sequenceDiagram
    actor Teacher
    actor Admin
    participant Platform as Platform
    participant AvailabilityController as AvailabilityController
    participant TeacherController as TeacherController
    participant NotificationController as NotificationController

    Note over Platform: New academic year begins
    Teacher->>Platform: submitTeacherAvailability(slots)
    Platform->>AvailabilityController: submitTeacherAvailability(slots)
    activate AvailabilityController
    AvailabilityController->>AvailabilityController: submitTeacherAvailability(teacherUserId, slots)
    AvailabilityController-->>Platform: { availability }
    deactivate AvailabilityController
    Platform-->>Teacher: Availability submitted (Pending Review)

    Admin->>Platform: listAdminPendingAvailability()
    Platform->>AvailabilityController: listAdminPendingAvailability()
    AvailabilityController-->>Platform: { availabilities }
    Platform-->>Admin: Display pending availabilities

    alt Admin approves
        Admin->>Platform: approveAvailability(availabilityId)
        Platform->>AvailabilityController: approveAvailability(availabilityId)
        AvailabilityController->>AvailabilityController: approveAvailability(availabilityId)
        AvailabilityController-->>Platform: { availability }
        Platform-->>Admin: Availability approved
    else Admin rejects
        Admin->>Platform: rejectAvailability(availabilityId, reason)
        Platform->>AvailabilityController: rejectAvailability(availabilityId, reason)
        AvailabilityController->>AvailabilityController: rejectAvailability(availabilityId, reason)
        AvailabilityController-->>Platform: { availability }
        Platform-->>Admin: Availability rejected
    end

    Platform->>NotificationController: broadcastNotification()
    NotificationController-->>Teacher: Notification sent to Teacher
```

---

## SD-08: School Inventory Rental

```mermaid
sequenceDiagram
    actor Student
    actor Admin
    participant Platform as Platform
    participant InventoryController as InventoryController
    participant AdminInventoryController as AdminInventoryController
    participant InventoryService as InventoryService
    participant CreateRentalUseCase as CreateRentalUseCase
    participant ApproveRentalUseCase as ApproveRentalUseCase
    participant VerifyReturnUseCase as VerifyReturnUseCase

    Student->>Platform: browseInventory()
    Platform->>InventoryController: getItems(query)
    InventoryController->>InventoryService: listItems(query)
    InventoryService-->>InventoryController: { items }
    InventoryController-->>Platform: { items }
    Platform-->>Student: Display catalog

    Student->>Platform: requestRental(itemId, rentalPeriod, paymentMethodId)
    Platform->>InventoryController: createRental(payload)
    InventoryController->>CreateRentalUseCase: execute({ req, renterId, payload })
    CreateRentalUseCase-->>InventoryController: { rental, checkoutSummary }
    InventoryController-->>Platform: { rental, checkoutSummary }
    Platform-->>Student: Rental created (Awaiting Approval)

    Admin->>Platform: listAdminRentals()
    Platform->>AdminInventoryController: getRentals()
    AdminInventoryController->>InventoryService: listAllRentals()
    InventoryService-->>AdminInventoryController: { rentals }
    AdminInventoryController-->>Platform: { rentals }
    Platform-->>Admin: Display rentals queue

    Admin->>Platform: approveRental(rentalId, decision)
    Platform->>AdminInventoryController: approveRental(rentalId)
    AdminInventoryController->>ApproveRentalUseCase: execute({ rentalId, payload })
    ApproveRentalUseCase-->>AdminInventoryController: { rental }
    AdminInventoryController-->>Platform: { rental }
    Platform-->>Admin: Rental approved

    Student->>Platform: checkRentalStatus()
    Platform->>InventoryController: getRentals()
    InventoryController->>InventoryService: listRentalsByRenterId(renterId)
    InventoryService-->>InventoryController: { rentals }
    InventoryController-->>Platform: { rentals }
    Platform-->>Student: Display rental status

    Admin->>Platform: verifyReturn(rentalId, conditionStatus, conditionNotes)
    Platform->>AdminInventoryController: verifyReturn(rentalId, payload)
    AdminInventoryController->>VerifyReturnUseCase: execute({ rentalId, payload })
    VerifyReturnUseCase-->>AdminInventoryController: { rental }
    AdminInventoryController-->>Platform: { rental }
    Platform-->>Admin: Return verified
```

---

## SD-09: Community Marketplace Listings and Moderation

```mermaid
sequenceDiagram
    actor Seller as Student (Seller)
    actor Buyer as Student (Buyer)
    actor Admin
    participant Platform as Platform
    participant MarketplaceController as MarketplaceController
    participant AdminMarketplaceController as AdminMarketplaceController
    participant ApproveListingUseCase as ApproveListingUseCase
    participant RejectListingUseCase as RejectListingUseCase

    Seller->>Platform: createListing(title, description, price, category, condition, photo)
    Platform->>MarketplaceController: createListing(payload)
    MarketplaceController-->>Platform: { listing }
    Platform-->>Seller: Listing submitted (Pending Review)

    Admin->>Platform: openMarketplaceModeration()
    Platform->>AdminMarketplaceController: getListings(status=pending)
    AdminMarketplaceController-->>Platform: { listings }
    Platform-->>Admin: Display pending listings

    alt Admin approves listing
        Admin->>Platform: approveListing(listingId)
        Platform->>AdminMarketplaceController: approveListing(listingId)
        AdminMarketplaceController->>ApproveListingUseCase: execute({ listingId })
        ApproveListingUseCase-->>AdminMarketplaceController: { listing }
        AdminMarketplaceController-->>Platform: { listing }
        Platform-->>Admin: Listing approved
    else Admin rejects listing
        Admin->>Platform: rejectListing(listingId, reason)
        Platform->>AdminMarketplaceController: rejectListing(listingId, reason)
        AdminMarketplaceController->>RejectListingUseCase: execute({ listingId, reason })
        RejectListingUseCase-->>AdminMarketplaceController: { listing }
        AdminMarketplaceController-->>Platform: { listing }
        Platform-->>Admin: Listing rejected
    end

    Buyer->>Platform: browseMarketplace(filters)
    Platform->>MarketplaceController: getListings(query)
    MarketplaceController-->>Platform: { listings }
    Platform-->>Buyer: Display listings

    Buyer->>Platform: openListingDetail(listingId)
    Platform->>MarketplaceController: getListingById(listingId)
    MarketplaceController-->>Platform: { listing (with seller contact) }
    Platform-->>Buyer: Display detail (Email / WhatsApp)

    Note over Buyer,Seller: Negotiation and payment happen externally (out of platform)

    Seller->>Platform: manageMyListings()
    Platform->>MarketplaceController: getMyListings()
    MarketplaceController-->>Platform: { listings }
    Platform-->>Seller: Display my listings

    alt Update listing
        Seller->>Platform: updateListing(listingId, updateData)
        Platform->>MarketplaceController: updateListing(listingId, updateData)
        MarketplaceController-->>Platform: { listing }
        Platform-->>Seller: Listing updated
    else Delete listing
        Seller->>Platform: deleteListing(listingId)
        Platform->>MarketplaceController: deleteListing(listingId)
        MarketplaceController-->>Platform: { ok }
        Platform-->>Seller: Listing deleted
    end
```

---

## SD-10: Financial Summary Generation and Export

```mermaid
sequenceDiagram
    actor Admin
    participant Platform as Platform
    participant FinanceController as FinanceController
    participant FinanceService as FinanceService

    Admin->>Platform: generateFinancialSummary(periodStart, periodEnd)
    Platform->>FinanceController: listTransactions(periodStart, periodEnd)
    FinanceController->>FinanceService: listTransactions({ periodStart, periodEnd })
    FinanceService-->>FinanceController: { transactions }
    FinanceController-->>Platform: { transactions }
    Platform-->>Admin: Display summary table

    Admin->>Platform: getFinancialSummary(periodStart, periodEnd)
    Platform->>FinanceController: getSummary(periodStart, periodEnd)
    FinanceController->>FinanceService: getSummary({ periodStart, periodEnd })
    FinanceService-->>FinanceController: { summary }
    FinanceController-->>Platform: { summary }
    Platform-->>Admin: Display summary

    Admin->>Platform: exportTransactions(periodStart, periodEnd)
    Platform->>FinanceController: exportTransactions(periodStart, periodEnd)
    FinanceController->>FinanceService: exportTransactions({ periodStart, periodEnd })
    FinanceService-->>FinanceController: { csv, count }
    FinanceController-->>Platform: { csv }
    Platform-->>Admin: Download CSV
```

---

## SD-11: Lost and Found – Manage and View

```mermaid
sequenceDiagram
    actor Admin
    actor Student
    participant Platform as Platform
    participant LostFoundController as LostFoundController
    participant LostFoundService as LostFoundService

    Note over Admin: School Management registers a found item
    Admin->>Platform: addFoundItem(itemData)
    Platform->>LostFoundController: createFoundItem(itemData)
    LostFoundController->>LostFoundService: createItem(itemData, userId, role)
    LostFoundService-->>LostFoundController: { item }
    LostFoundController-->>Platform: { item }
    Platform-->>Admin: Item published

    Student->>Platform: viewLostAndFound()
    Platform->>LostFoundController: listPublicItems()
    LostFoundController->>LostFoundService: listPublicItems()
    LostFoundService-->>LostFoundController: { items }
    LostFoundController-->>Platform: { items }
    Platform-->>Student: Display found items

    Admin->>Platform: claimItem(itemId, adminNotes)
    Platform->>LostFoundController: claimItem(itemId, adminNotes)
    LostFoundController->>LostFoundService: claimItem(itemId, adminNotes, role)
    LostFoundService-->>LostFoundController: { item }
    LostFoundController-->>Platform: { item }
    Platform-->>Admin: Item marked as claimed

    Admin->>Platform: archiveItem(itemId, adminNotes)
    Platform->>LostFoundController: archiveItem(itemId, adminNotes)
    LostFoundController->>LostFoundService: archiveItem(itemId, adminNotes, role)
    LostFoundService-->>LostFoundController: { item }
    LostFoundController-->>Platform: { item }
    Platform-->>Admin: Item archived
```

---

## SD-12: Admin User Management

```mermaid
sequenceDiagram
    actor Admin
    participant Platform as Platform
    participant AdminController as AdminController
    participant AdminUserUseCases as AdminUserUseCases

    Admin->>Platform: listUsers()
    Platform->>AdminController: listUsers()
    AdminController->>AdminController: listUsers()
    AdminController-->>Platform: { users }
    Platform-->>Admin: Display user list

    Admin->>Platform: createUser(userData)
    Platform->>AdminController: createUser(userData)
    AdminController->>AdminUserUseCases: createUser.execute({ payload })
    AdminUserUseCases-->>AdminController: { user }
    AdminController-->>Platform: { user }
    Platform-->>Admin: User created

    Admin->>Platform: updateUser(userId, updateData)
    Platform->>AdminController: updateUser(userId, updateData)
    AdminController->>AdminController: updateUser(userId, updateData)
    AdminController-->>Platform: { user }
    Platform-->>Admin: User updated

    Admin->>Platform: updateUserRoles(userId, roles)
    Platform->>AdminController: updateUserRoles(userId, roles)
    AdminController->>AdminController: updateUserRoles(userId, roles)
    AdminController-->>Platform: { user }
    Platform-->>Admin: Roles updated

    Admin->>Platform: deleteUser(userId)
    Platform->>AdminController: deleteUser(userId)
    AdminController->>AdminController: deleteUser(userId)
    AdminController-->>Platform: { user }
    Platform-->>Admin: User deleted (soft delete)
```

---

## SD-13: Teacher Admission Request Review

```mermaid
sequenceDiagram
    actor Teacher
    actor Admin
    actor Student
    participant Platform as Platform
    participant TeacherController as TeacherController
    participant JoinRequestController as JoinRequestController
    participant AdminController as AdminController

    Student->>Platform: createJoinRequest(sessionId)
    Platform->>JoinRequestController: createJoinRequest(sessionId)
    JoinRequestController-->>Platform: { joinRequest }
    Platform-->>Student: Request submitted

    Teacher->>Platform: getAdmissionRequests()
    Platform->>TeacherController: getAdmissionRequests()
    TeacherController-->>Platform: { admissionRequests }
    Platform-->>Teacher: Display admission requests

    Teacher->>Platform: reviewAdmissionRequest(joinRequestId, decision)
    Platform->>TeacherController: reviewAdmissionRequest(joinRequestId, decision)
    TeacherController->>TeacherController: reviewAdmissionRequest(joinRequestId, decision)
    TeacherController-->>Platform: { admissionRequest }
    Platform-->>Teacher: Request reviewed

    Admin->>Platform: getAdminPending()
    Platform->>JoinRequestController: getAdminPending()
    JoinRequestController-->>Platform: { joinRequests }
    Platform-->>Admin: Display pending join requests

    Admin->>Platform: adminApprove(joinRequestId)
    Platform->>JoinRequestController: adminApprove(joinRequestId)
    JoinRequestController->>JoinRequestController: adminApprove(joinRequestId)
    JoinRequestController-->>Platform: { joinRequest }
    Platform-->>Admin: Request approved
```

---

## SD-14: Notification Management

```mermaid
sequenceDiagram
    actor User
    participant Platform as Platform
    participant NotificationController as NotificationController
    participant NotificationService as NotificationService

    User->>Platform: getNotifications()
    Platform->>NotificationController: getAll()
    NotificationController->>NotificationService: getAllByUser(userId)
    NotificationService-->>NotificationController: { notifications }
    NotificationController-->>Platform: { notifications }
    Platform-->>User: Display notifications

    User->>Platform: markAsRead(notificationId)
    Platform->>NotificationController: markAsRead(notificationId)
    NotificationController->>NotificationService: markAsRead(notificationId, userId)
    NotificationService-->>NotificationController: { success }
    NotificationController-->>Platform: { success: true }
    Platform-->>User: Notification marked as read

    User->>Platform: removeNotification(notificationId)
    Platform->>NotificationController: remove(notificationId)
    NotificationController->>NotificationService: remove(notificationId, userId)
    NotificationService-->>NotificationController: { success }
    NotificationController-->>Platform: { success: true }
    Platform-->>User: Notification removed
```

---

## SD-15: Student Dashboard and Schedule

```mermaid
sequenceDiagram
    actor Student
    participant Platform as Platform
    participant StudentController as StudentController
    participant CoachingController as CoachingController

    Student->>Platform: getDashboard()
    Platform->>StudentController: getDashboard()
    StudentController-->>Platform: { dashboard }
    Platform-->>Student: Display dashboard

    Student->>Platform: getUpcomingSchedule()
    Platform->>StudentController: getUpcomingSchedule()
    StudentController->>StudentController: getUpcomingSchedule(studentUserId)
    StudentController-->>Platform: { schedule }
    Platform-->>Student: Display upcoming schedule

    Student->>Platform: getSessionHistory()
    Platform->>CoachingController: getSessionHistory()
    CoachingController->>CoachingService: getSessionHistory(studentUserId)
    CoachingService-->>CoachingController: { sessions }
    CoachingController-->>Platform: { sessions }
    Platform-->>Student: Display session history
```

---

## SD-16: Teacher Dashboard and Today Schedule

```mermaid
sequenceDiagram
    actor Teacher
    participant Platform as Platform
    participant TeacherController as TeacherController

    Teacher->>Platform: getDashboard()
    Platform->>TeacherController: getDashboard()
    TeacherController-->>Platform: { dashboard }
    Platform-->>Teacher: Display dashboard

    Teacher->>Platform: getTodaySchedule()
    Platform->>TeacherController: getTodaySchedule()
    TeacherController->>TeacherController: getTodaySchedule(teacherUserId)
    TeacherController-->>Platform: { schedule }
    Platform-->>Teacher: Display today's schedule

    Teacher->>Platform: getActiveSessions()
    Platform->>TeacherController: getActiveSessions()
    TeacherController-->>Platform: { sessions }
    Platform-->>Teacher: Display active sessions
```

---

## SD-17: Admin Dashboard and Operational Summary

```mermaid
sequenceDiagram
    actor Admin
    participant Platform as Platform
    participant AdminController as AdminController

    Admin->>Platform: getDashboard()
    Platform->>AdminController: getDashboard()
    AdminController->>AdminController: getDashboard()
    AdminController-->>Platform: { dashboard }
    Platform-->>Admin: Display dashboard

    Admin->>Platform: getOperationalSummary()
    Platform->>AdminController: getOperationalSummary()
    AdminController->>AdminController: getOperationalSummary()
    AdminController-->>Platform: { operationalSummary }
    Platform-->>Admin: Display operational summary

    Admin->>Platform: getStudioOccupancy()
    Platform->>AdminController: getStudioOccupancy()
    AdminController->>AdminController: getStudioOccupancy()
    AdminController-->>Platform: { studioOccupancy }
    Platform-->>Admin: Display studio occupancy
```

---

## SD-18: Auth Token Refresh

```mermaid
sequenceDiagram
    actor User
    participant Platform as Platform
    participant AuthController as AuthController
    participant JwtService as JwtService

    User->>Platform: openApp()
    activate Platform
    Platform->>AuthController: refresh()
    activate AuthController
    AuthController->>JwtService: rotateRefreshToken(refreshToken, { ip, userAgent, role })
    JwtService-->>AuthController: { user, role, accessToken, refreshToken, refreshTokenExpiresAt }
    AuthController-->>Platform: { user, role, accessToken, tokenType, expiresIn }
    deactivate AuthController
    Platform-->>User: App authenticated
    deactivate Platform
```

---

## SD-19: Role Switch

```mermaid
sequenceDiagram
    actor User
    participant Platform as Platform
    participant AuthController as AuthController

    User->>Platform: switchRole(newRole)
    Platform->>AuthController: switchRole(newRole)
    AuthController->>AuthController: switchRole(userId, newRole)
    AuthController-->>Platform: { user }
    Platform-->>User: View switched to new role
```

---

## SD-20: Admin Session Approval (Legacy)

```mermaid
sequenceDiagram
    actor Admin
    participant Platform as Platform
    participant AdminController as AdminController
    participant AdminSessionUseCases as AdminSessionUseCases

    Admin->>Platform: listPendingApproval()
    Platform->>AdminController: listPendingApproval()
    AdminController-->>Platform: { sessions }
    Platform-->>Admin: Display pending sessions

    Admin->>Platform: approveSession(sessionId)
    Platform->>AdminController: approveSession(sessionId)
    AdminController->>AdminSessionUseCases: approveSession.execute({ adminUserId, payload: { sessionId } })
    AdminSessionUseCases-->>AdminController: { sessionId, statusId, userIdsToNotify }
    AdminController-->>Platform: { sessionId, statusId }
    Platform-->>Admin: Session approved (→ Scheduled)

    Admin->>Platform: rejectSession(sessionId, reason)
    Platform->>AdminController: rejectSession(sessionId, reason)
    AdminController->>AdminSessionUseCases: rejectSession.execute({ adminUserId, payload: { sessionId, reviewNotes } })
    AdminSessionUseCases-->>AdminController: { sessionId, userIdsToNotify }
    AdminController-->>Platform: { sessionId }
    Platform-->>Admin: Session rejected (→ Cancelled_Rejected)
```

---

## SD-21: Coaching Request with Schedule Negotiation

```mermaid
sequenceDiagram
    actor Student
    actor Teacher
    actor Admin
    participant Platform as Platform
    participant CoachingController as CoachingController
    participant CoachingRequestService as CoachingRequestService

    Student->>Platform: createRequest(modalityId, teacherId, preferredStartTime)
    Platform->>CoachingController: createRequest(payload)
    CoachingController->>CoachingRequestService: createCoachingRequest({ studentUserId, payload })
    CoachingRequestService-->>CoachingController: { request (Status: PENDING_TEACHER_REVIEW) }
    CoachingController-->>Platform: { request }
    Platform-->>Teacher: Notify teacher (new coaching request)

    Teacher->>Platform: reviewRequestAsTeacher(requestId, decision)
    Platform->>CoachingController: reviewRequestAsTeacher(requestId)
    CoachingController->>CoachingRequestService: reviewRequestAsTeacher({ requestId, teacherUserId, payload })
    alt Teacher approves directly
        CoachingRequestService-->>CoachingController: { request (PENDING_ADMIN_APPROVAL) }
    else Teacher suggests new time
        CoachingRequestService-->>CoachingController: { request (PENDING_STUDENT_CONFIRMATION) }
        CoachingController-->>Platform: notify student (new time suggested)
        Student->>Platform: respondToTeacherSuggestion(requestId, accept|reject)
        Platform->>CoachingController: respondToTeacherSuggestion(requestId)
        CoachingController->>CoachingRequestService: respondToTeacherSuggestion({ requestId, studentUserId, payload })
        CoachingRequestService-->>CoachingController: { request (PENDING_ADMIN_APPROVAL | cancelled) }
    end

    Admin->>Platform: reviewRequestAsAdmin(requestId, decision, studioId)
    Platform->>CoachingController: reviewRequestAsAdmin(requestId)
    CoachingController->>CoachingRequestService: reviewRequestAsAdmin({ requestId, adminUserId, payload })
    CoachingRequestService-->>CoachingController: { request (APPROVED → ConfirmedSessionID | REJECTED) }
    CoachingController-->>Platform: { request }
    Platform-->>Student: Notify final decision
```

---

## SD-22: Group Coaching Proposal (Teacher-initiated, multi-student)

```mermaid
sequenceDiagram
    actor Teacher
    actor Admin
    participant Platform as Platform
    participant GroupController as GroupCoachingProposalController

    Teacher->>Platform: searchStudents(query)
    Platform->>GroupController: searchStudents(query)
    GroupController-->>Platform: { students }

    Teacher->>Platform: createProposal(modalityId, startTime, endTime, studentUserIds)
    Platform->>GroupController: createProposal(payload)
    GroupController-->>Platform: { proposal (Participants[]) }
    Platform-->>Teacher: Proposal submitted (Pending Admin)

    Admin->>Platform: listAdminProposals()
    Platform->>GroupController: listAdminProposals()
    GroupController-->>Platform: { proposals }

    Admin->>Platform: getCompatibleStudios(proposalId)
    Platform->>GroupController: getCompatibleStudios(proposalId)
    GroupController-->>Platform: { studios }

    Admin->>Platform: reviewProposal(proposalId, decision, studioId)
    Platform->>GroupController: reviewProposal(proposalId)
    GroupController-->>Platform: { proposal (APPROVED → CoachingSession + SessionStudent | REJECTED) }
    Platform-->>Teacher: Notify decision
```

---

## SD-23: Admin Timetable Management (Weekly School Schedule)

```mermaid
sequenceDiagram
    actor Admin
    actor User
    participant Platform as Platform
    participant TimetableController as TimetableController

    Admin->>Platform: createTimetable(label)
    Platform->>TimetableController: createTimetable(payload)
    TimetableController-->>Platform: { timetable }

    Admin->>Platform: createSlot(timetableId, dayOfWeek, startMinutes, endMinutes, teacher/studio/modality)
    Platform->>TimetableController: createSlot(timetableId, payload)
    TimetableController-->>Platform: { slot }

    alt Update slot
        Admin->>Platform: updateSlot(slotId, data)
        Platform->>TimetableController: updateSlot(slotId)
        TimetableController-->>Platform: { slot }
    else Delete slot
        Admin->>Platform: deleteSlot(slotId)
        Platform->>TimetableController: deleteSlot(slotId)
        TimetableController-->>Platform: { ok }
    end

    User->>Platform: openTimetable()
    Platform->>TimetableController: listTimetables() / getTimetable(id)
    TimetableController-->>Platform: { timetables / timetable (active) }
    Platform-->>User: Display weekly schedule
```
