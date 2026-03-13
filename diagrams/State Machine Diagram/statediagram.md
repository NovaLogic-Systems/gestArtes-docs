```mermaid
stateDiagram-v2
    direction TB

    %% Request start
    [*] --> Pending_Approval : Request Submitted(Student / Teacher)

    %% Booking validation
    Pending_Approval --> Scheduled : School Management Action(Validates & Approves)
    Pending_Approval --> Cancelled_Timeout : System Event(48h passes without action)
    Pending_Approval --> Cancelled_Rejected : School Management Action(Rejects due to no vacancy)

    %% Post-coaching flow
    Scheduled --> Completion_Confirmation_Pending : Lesson Completed

    %% Single account model: parent and student use the same account
    Completion_Confirmation_Pending --> Confirmed_By_Student_Account_And_Teacher : Student Account + Teacher confirm completion
    Completion_Confirmation_Pending --> Confirmed_By_Student_Account_And_School_Management : Student Account + School Management confirm completion

    %% Final validation required only when School Management is not already in co-confirmation
    Confirmed_By_Student_Account_And_Teacher --> Finalization_Validation_Pending : School Management validates finalization
    Finalization_Validation_Pending --> Finalized
    Confirmed_By_Student_Account_And_School_Management --> Finalized

    %% Automatic accounting update
    Finalized --> Accounting_Table_Updated : System Event(Automatic Entry)

    %% Exception flow during scheduled lesson
    Scheduled --> No_Show : Teacher Action(Reports Absence w/ no notice)
    Scheduled --> Cancelled_Justified : Student Account(Cancels with valid reason)

    No_Show --> Accounting_Table_Updated : School Management Final Audit(Charges 100%)
    Cancelled_Justified --> Accounting_Table_Updated : School Management Final Audit(Evaluates exemption)

    %% Final states
    Cancelled_Timeout --> [*]
    Cancelled_Rejected --> [*]
    Accounting_Table_Updated --> [*]
```
