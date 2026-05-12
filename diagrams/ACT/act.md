```mermaid
flowchart TD
    %% Estilos UML
    classDef action fill:#e1f5fe,stroke:#01579b,stroke-width:2px,rx:10px,ry:10px;
    classDef decision fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef bar fill:#000,stroke:#000,stroke-width:6px,color:#fff;
    classDef startend fill:#000,stroke:#000,color:#fff;

    Start((Start)):::startend --> A1[Teacher.createSessionInitiative() — Session=PENDING_APPROVAL]:::action

    %% Fork: approval path vs timeout
    A1 --> Fork1[          ]:::bar

    Fork1 --> A2[Admin.reviewSession() / Validate]:::action
    Fork1 --> A3[Timer: 48h auto-expire PENDING_APPROVAL]:::action

    %% Join
    A2 --> Join1[          ]:::bar
    A3 --> Join1

    %% Gateway 1: Validação inicial
    Join1 --> D1{Approved within 48h?}:::decision

    D1 -- No / Timeout --> A4[Session cancelled (PENDING → CANCELLED)]:::action
    A4 --> End1((End)):::startend

    D1 -- Yes --> A5[Student.createBooking(sessionId) — SessionStudent created]:::action
    A5 --> A6[Wait for Coaching Scheduled Time]:::action

    %% Gateway 2: Lesson outcome (mirror backend methods)
    A6 --> D2{Lesson Outcome}:::decision

    D2 -- Attended --> A11[Student.confirmCompletion() — calls coachingService.confirmCompletion()]:::action
    A11 --> A13[Create SessionValidation — set Session.status = FINALIZATION_VALIDATION_PENDING]:::action

    D2 -- Cancelled with reason --> A9[Requester calls coachingService.cancelBooking(justification)]:::action
    A9 --> A10[System records CANCELLED_JUSTIFIED status]:::action
    A10 --> A13

    D2 -- No-Show (no notice) --> A7[System detects absence / no confirmation]:::action
    A7 --> A8[finance.applyNoShowPenalty() — FinancialEntry: NOSHOWPENALTY (full price)]:::action

    %% Final management / accounting
    A13 --> A14[Final Management Validation (admin) & close session]:::action
    A8 --> A14

    A14 --> End2((End)):::startend
```