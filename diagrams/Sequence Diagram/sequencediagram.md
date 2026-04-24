## SD-01: User Authentication

```mermaid
sequenceDiagram
    actor User
    participant Platform
    participant AuthService

    User->>Platform: openLoginPage()
    activate Platform
    Platform-->>User: renderLoginForm()
    User->>Platform: submitCredentials(email, password)
    Platform->>AuthService: authenticate(email, password)
    activate AuthService
    alt Valid credentials
        AuthService-->>Platform: authenticationSuccess(userId, authUid)
        Platform-->>User: redirectToDashboard()
    else Invalid credentials
        AuthService-->>Platform: authenticationFailed()
        Platform-->>User: showLoginError()
    end
    deactivate AuthService
    deactivate Platform
```

---

## SD-02: Coaching Session Booking Request

```mermaid
sequenceDiagram
    actor Applicant as Student / Teacher
    participant Platform
    participant Studio
    participant TeacherAvailability
    participant CoachingSession
    actor Management
    participant Notification

    Applicant->>Platform: requestCoachingSession()
    Platform->>Studio: Check studio availability
    Studio-->>Platform: Studio available
    Platform->>TeacherAvailability: isAvailable(startAt, endAt)
    TeacherAvailability-->>Platform: Teacher available
    Platform->>CoachingSession: requestApproval()
    Platform->>Notification: Notify Management – pending approval
    Notification-->>Management: New booking request
    alt Management approves within 48h
        Management->>Platform: approveByManagement()
        Platform->>CoachingSession: approve()
        Platform->>Notification: Notify Applicant – session confirmed
        Notification-->>Applicant: Booking confirmed
    else Management rejects
        Management->>Platform: rejectRequest(reason)
        Platform->>CoachingSession: reject()
        Platform->>Notification: Notify Applicant – rejected or alternative slot proposed
        Notification-->>Applicant: Booking rejected / alternative slot
    else 48h deadline expires without action
        Platform->>CoachingSession: reject()
        Platform->>Notification: Notify Applicant – booking expired
        Notification-->>Applicant: Booking cancelled (timeout)
    end
```

---

## SD-03: Post-Coaching Double Validation

```mermaid
sequenceDiagram
    actor Teacher
    actor Student as StudentAccount
    actor Management
    participant Platform
    participant CoachingSession
    participant SessionValidation
    participant FinancialEntry
    participant Notification

    Note over CoachingSession: Status: SCHEDULED
    alt Teacher confirms completion
        Teacher->>Platform: confirmCompletion()
        Platform->>SessionValidation: record()
    else StudentAccount confirms completion
        Student->>Platform: confirmCompletion()
        Platform->>SessionValidation: record()
    end
    Platform->>CoachingSession: confirmCompletion()
    Platform->>Notification: Request final validation from Management
    Notification-->>Management: Session ready for finalisation
    Management->>Platform: approveByManagement()
    Platform->>SessionValidation: record()
    Platform->>CoachingSession: approve()
    Platform->>FinancialEntry: generateFromSession()
    Note over FinancialEntry: Accounting table updated automatically
```

---

## SD-04: Session Cancellation with Justification

```mermaid
sequenceDiagram
    actor Student as StudentAccount
    actor Management
    participant Platform
    participant CoachingSession
    participant SessionStudent
    participant FinancialEntry
    participant Notification

    Note over CoachingSession: Status: SCHEDULED
    Student->>Platform: cancelWithJustification(reason)
    Platform->>CoachingSession: cancelWithReason(reason)
    Platform->>SessionStudent: markAttendance(CANCELLED_WITH_REASON)
    Platform->>Notification: Notify Management – cancellation with reason
    Notification-->>Management: Session cancelled with justification
    Management->>Platform: Evaluate justification
    alt Exemption granted
        Platform->>FinancialEntry: Create entry (type: JUSTIFIED_CANCELLATION_REVIEW, amount: 0)
        Platform->>Notification: Notify Student – no charge applied
        Notification-->>Student: Cancellation accepted, no charge
    else No exemption – charge applies
        Platform->>FinancialEntry: Create entry (type: COACHING_CHARGE, full price)
        Platform->>Notification: Notify Student – charge applied
        Notification-->>Student: Cancellation fee charged
    end
    Note over FinancialEntry: Accounting table updated
```

---

## SD-05: No-Show Recording

```mermaid
sequenceDiagram
    actor Teacher
    actor Management
    actor Student as StudentAccount
    participant Platform
    participant CoachingSession
    participant SessionStudent
    participant FinancialEntry
    participant Notification

    Note over CoachingSession: Status: SCHEDULED – student absent, no prior notice
    Teacher->>Platform: recordNoShow()
    Platform->>SessionStudent: markAttendance(NO_SHOW)
    Platform->>CoachingSession: recordNoShow()
    Platform->>Notification: Notify Management – no-show recorded
    Notification-->>Management: No-show requires final audit
    Management->>Platform: Apply 100% penalty (final audit)
    Platform->>CoachingSession: calculateFinalPrice() → 100%
    Platform->>FinancialEntry: Create entry (type: NO_SHOW_PENALTY, amount: full price)
    Platform->>Notification: Notify Student – 100% charge applied
    Notification-->>Student: No-show penalty charged
    Note over FinancialEntry: Accounting table updated
```

---

## SD-06: Student Join Request to Existing Session

```mermaid
sequenceDiagram
    actor Student as StudentAccount
    actor Teacher
    actor Management
    participant Platform
    participant CoachingSession
    participant CoachingJoinRequest
    participant SessionStudent
    participant Notification

    Student->>Platform: submitJoinRequest()
    Platform->>CoachingSession: Check available capacity (maxParticipants vs enrolled)
    alt Capacity available
        CoachingSession-->>Platform: Capacity available
        Platform->>CoachingJoinRequest: requestJoin()
        Platform->>Notification: Notify Teacher – join request pending
        Notification-->>Teacher: Student requests to join your session
        Teacher->>Platform: approveByTeacher()
        Platform->>CoachingJoinRequest: approveByTeacher()
        Platform->>Notification: Notify Management – teacher approved, awaiting final validation
        Notification-->>Management: Join request pending your approval
        alt Management approves
            Management->>Platform: approveByManagement()
            Platform->>CoachingJoinRequest: approveByManagement()
            Platform->>SessionStudent: enrollStudent(student)
            Platform->>Notification: Notify Student – session membership confirmed
            Notification-->>Student: You have been added to the session
        else Management rejects
            Management->>Platform: rejectRequest()
            Platform->>CoachingJoinRequest: reject()
            Platform->>Notification: Notify Student – request rejected
            Notification-->>Student: Join request was rejected
        end
    else Capacity full
        CoachingSession-->>Platform: Capacity full
        Platform->>CoachingJoinRequest: reject()
        Platform->>Notification: Notify Student – session full
        Notification-->>Student: Join request rejected due to capacity
    end
```

---

## SD-07: Teacher Availability Setup

```mermaid
sequenceDiagram
    actor Teacher
    actor Management
    actor Student as StudentAccount
    participant Platform
    participant TeacherAvailability
    participant TeacherAvailabilityRecurring
    participant Notification

    Note over Platform: New academic year begins
    Teacher->>Platform: submitAvailability()
    loop For each availability slot
        Platform->>TeacherAvailabilityRecurring: storeSlot(dayOfWeek, startTime, endTime)
    end
    TeacherAvailabilityRecurring-->>Platform: All slots saved
    Platform->>Notification: Notify Management – availability submitted
    Notification-->>Management: Teacher availability ready for review
    Management->>Platform: Audit and validate global availability map
    alt Conflicts found
        Platform->>TeacherAvailability: reject()
        Platform->>Notification: Notify Teacher – conflicting slots need revision
        Notification-->>Teacher: Please update the conflicting availability
        Teacher->>Platform: submitAvailability()
        loop For each revised slot
            Platform->>TeacherAvailabilityRecurring: storeSlot(dayOfWeek, startTime, endTime)
        end
    else Coverage gaps found
        Platform->>TeacherAvailability: reject()
        Platform->>Notification: Notify Teacher – coverage gaps need filling
        Notification-->>Teacher: Please add the missing coverage
        Teacher->>Platform: submitAvailability()
        loop For each added slot
            Platform->>TeacherAvailabilityRecurring: storeSlot(dayOfWeek, startTime, endTime)
        end
    else Availability validated
        Management->>Platform: approveByManagement()
        Platform->>TeacherAvailability: approve()
        Teacher->>Platform: confirmPublication()
        Platform->>Platform: publishAvailability()
        Platform->>Notification: Publish available slots to students
        Notification-->>Student: New coaching slots are available
    end
```

---

## SD-08: School Inventory Rental

```mermaid
sequenceDiagram
    actor InterestedParty as Student / Parent
    actor SchoolOwner as School (Item Owner)
    participant Platform
    participant InventoryItem
    participant InventoryTransaction
    participant Notification

    InterestedParty->>Platform: browseSchoolInventory()
    Platform->>InventoryItem: publish()
    InventoryItem-->>Platform: Available items
    Platform-->>InterestedParty: Display catalog
    InterestedParty->>Platform: requestRental(itemId, rentalPeriod)
    Platform->>Notification: Notify school owner of rental interest
    Notification-->>SchoolOwner: Rental interest received
    SchoolOwner->>Platform: reviewConditionAndReturnDate()

    alt Rental approved
        SchoolOwner->>Platform: confirmTerms(symbolicFee, rentalPeriod)
        InterestedParty->>Platform: processInventoryRental(itemId, rentalPeriod)
        Platform->>InventoryItem: startRental()
        Platform->>InventoryTransaction: startRental()
        Platform->>InventoryTransaction: completeRental()
        Platform->>Notification: confirmRentalToBothParties()
        Notification-->>InterestedParty: Rental confirmed
        Notification-->>SchoolOwner: Rental confirmed
    else Rental rejected
        SchoolOwner->>Platform: rejectRequest(reason)
        Platform->>Notification: notifyRentalRejection()
        Notification-->>InterestedParty: Rental request rejected
    end

    Note over InventoryTransaction: On return – returnVerified: true, isCompleted: true
```

---

## SD-09: Community Marketplace Transaction

```mermaid
sequenceDiagram
    actor Buyer
    actor Seller as Item Owner (Teacher / Student)
    participant Platform
    participant MarketplaceItem
    participant MarketplaceTransaction
    participant Notification

    Buyer->>Platform: browseMarketplace()
    Platform->>MarketplaceItem: publish()
    MarketplaceItem-->>Platform: Available listings
    Platform-->>Buyer: Display items
    Buyer->>Platform: requestInterest(itemId)
    Platform->>Notification: Notify Seller of buyer interest
    Notification-->>Seller: Someone is interested in your item
    Seller->>Platform: confirmTerms()

    alt Agreement reached
        Platform->>MarketplaceItem: reserve()
        Buyer->>Platform: processMarketplaceTransaction(itemId)
        Platform->>MarketplaceTransaction: complete()
        Platform->>MarketplaceItem: close()
        Platform->>Notification: notifyTransactionCompletion()
        Notification-->>Buyer: Transaction completed
        Notification-->>Seller: Transaction completed
    else Agreement rejected
        Seller->>Platform: rejectRequest(reason)
        Platform->>Notification: notifyBuyerRejection()
        Notification-->>Buyer: Offer rejected
    end
```

---

## SD-10: Financial Summary Generation and Export

```mermaid
sequenceDiagram
    actor Management
    participant Platform
    participant FinancialEntry
    participant FinancialSummary

    Management->>Platform: generateFinancialSummary(periodStart, periodEnd)
    Platform->>FinancialEntry: collectEntries(periodStart, periodEnd)
    FinancialEntry-->>Platform: Entry list (COACHING_CHARGE, NO_SHOW_PENALTY, INVENTORY_RENTAL_FEE, etc.)
    Platform->>FinancialSummary: generate()
    FinancialSummary-->>Platform: Summary created
    Platform-->>Management: Display summary table
    Management->>Platform: Export summary to accounting
    Platform->>FinancialSummary: exportToAccounting()
    Platform-->>Management: Export file ready (Excel / CSV)
```

---

## SD-11: Lost and Found – Manage and View

```mermaid
sequenceDiagram
    actor SM as School Management
    actor Student as Student / Guardian
    participant Platform
    participant LostAndFoundItem

    Note over SM, Platform: School Management registers a found item
    SM->>Platform: Add found item (title, description, photo, findDate)
    Platform->>LostAndFoundItem: publish()
    LostAndFoundItem-->>Platform: Item stored
    Platform-->>SM: Item published on Lost & Found page

    Note over Student, Platform: Student browses lost and found page
    Student->>Platform: View lost and found list
    Platform->>LostAndFoundItem: Fetch all active entries
    LostAndFoundItem-->>Platform: Return item list
    Platform-->>Student: Display found items

    Note over SM, Platform: School Management marks an item as claimed
    SM->>Platform: Mark found item as claimed (LostFoundID)
    Platform->>LostAndFoundItem: markClaimed()
    LostAndFoundItem-->>Platform: Entry updated
    Platform-->>SM: Item updated in Lost & Found page
```
