CREATE TABLE Role (
  RoleID      int IDENTITY NOT NULL, 
  RoleName    varchar(50) NOT NULL UNIQUE, 
  Description varchar(255) NULL, 
  PRIMARY KEY (RoleID));
CREATE TABLE [User] (
  UserID       int IDENTITY NOT NULL, 
  FirstName    varchar(150) NOT NULL, 
  LastName     varchar(150) NULL, 
  PhoneNumber  varchar(20) NULL, 
  Email        varchar(100) NOT NULL UNIQUE, 
  Photo        varchar(255) NULL, 
  RoleID       int NOT NULL, 
  PasswordHash varchar(255) NOT NULL, 
  AuthUID      varchar(255) NOT NULL UNIQUE, 
  CreatedAt    datetime NOT NULL, 
  UpdatedAt    datetime NULL, 
  IsActive     bit NOT NULL, 
  DeletedAt    datetime NULL, 
  PRIMARY KEY (UserID));
CREATE TABLE StudentAccount (
  StudentAccountID int IDENTITY NOT NULL, 
  UserID           int NOT NULL UNIQUE, 
  BirthDate        date NOT NULL, 
  PRIMARY KEY (StudentAccountID));
CREATE TABLE Studio (
  StudioID   int IDENTITY NOT NULL, 
  StudioName varchar(50) NOT NULL UNIQUE, 
  Capacity   int NOT NULL, 
  PRIMARY KEY (StudioID));
CREATE TABLE InventoryItem (
  InventoryItemID int IDENTITY NOT NULL, 
  OwnerID         int NOT NULL, 
  ItemName        varchar(100) NOT NULL, 
  CategoryID      int NOT NULL, 
  SymbolicFee     decimal(10, 2) NOT NULL, 
  Description     varchar(255) NULL, 
  PhotoURL        varchar(255) NULL, 
  IsSchoolOwned   bit NOT NULL, 
  PRIMARY KEY (InventoryItemID));
CREATE TABLE CoachingSession (
  SessionID             int IDENTITY NOT NULL, 
  StudioID              int NOT NULL, 
  StartTime             datetime NOT NULL, 
  EndTime               datetime NOT NULL, 
  StatusID              int NOT NULL, 
  FinalPrice            decimal(10, 2) NULL, 
  ValidationRequestedAt datetime NULL, 
  CancellationReason    varchar(255) NULL, 
  RequestedByUserID     int NOT NULL, 
  ModalityID            int NOT NULL, 
  MaxParticipants       int NULL, 
  IsExternal            bit NOT NULL, 
  IsOutsideStdHours     bit NOT NULL, 
  PRIMARY KEY (SessionID));
CREATE TABLE SessionTeacher (
  SessionID        int NOT NULL, 
  TeacherID        int NOT NULL, 
  AssignmentRoleID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  TeacherID));
CREATE TABLE SessionStudent (
  SessionID          int NOT NULL, 
  StudentAccountID   int NOT NULL, 
  EnrolledAt         datetime NOT NULL, 
  AttendanceStatusID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  StudentAccountID));
CREATE TABLE Modality (
  ModalityID   int IDENTITY NOT NULL, 
  ModalityName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (ModalityID));
CREATE TABLE StudioModality (
  StudioID   int NOT NULL, 
  ModalityID int NOT NULL, 
  PRIMARY KEY (StudioID, 
  ModalityID));
CREATE TABLE TeacherAvailability (
  AvailabilityID int IDENTITY NOT NULL, 
  TeacherID      int NOT NULL, 
  DayOfWeek      int NOT NULL, 
  StartTime      time(7) NOT NULL, 
  EndTime        time(7) NOT NULL, 
  PRIMARY KEY (AvailabilityID));
CREATE TABLE InventoryTransaction (
  TransactionID    int IDENTITY NOT NULL, 
  InventoryItemID  int NOT NULL, 
  RenterID         int NOT NULL, 
  StartDate        datetime NOT NULL, 
  EndDate          datetime NULL, 
  PaymentMethodID  int NOT NULL, 
  IsCompleted      bit NOT NULL, 
  ConditionChecked bit NOT NULL, 
  ReturnVerified   bit NOT NULL, 
  PRIMARY KEY (TransactionID));
CREATE TABLE PaymentMethod (
  PaymentMethodID int IDENTITY NOT NULL, 
  MethodName      varchar(50) NOT NULL UNIQUE, 
  IsActive        bit NOT NULL, 
  PRIMARY KEY (PaymentMethodID));
CREATE TABLE NotificationType (
  TypeID   int IDENTITY NOT NULL, 
  TypeName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (TypeID));
CREATE TABLE Notification (
  NotificationID int IDENTITY NOT NULL, 
  UserID         int NOT NULL, 
  Message        varchar(255) NULL, 
  TypeID         int NOT NULL, 
  IsRead         bit NOT NULL, 
  CreatedAt      datetime NOT NULL, 
  Title          varchar(255) NOT NULL, 
  SessionID      int NULL, 
  CONSTRAINT NotificationID 
    PRIMARY KEY (NotificationID));
CREATE TABLE LostAndFoundItem (
  LostItemID         int IDENTITY NOT NULL, 
  Description        varchar(255) NULL, 
  FoundDate          datetime NOT NULL, 
  ClaimedStatus      bit NOT NULL, 
  PhotoURL           varchar(255) NULL, 
  Title              varchar(255) NOT NULL, 
  RegisteredByUserID int NOT NULL, 
  PRIMARY KEY (LostItemID));
CREATE TABLE MarketplaceItem (
  MarketplaceItemID int IDENTITY NOT NULL, 
  SellerID          int NOT NULL, 
  Title             varchar(100) NOT NULL, 
  Description       varchar(255) NULL, 
  Price             decimal(10, 2) NOT NULL, 
  ConditionID       int NOT NULL, 
  StatusID          int NOT NULL, 
  PRIMARY KEY (MarketplaceItemID));
CREATE TABLE MarketplaceItemCondition (
  ConditionID   int IDENTITY NOT NULL, 
  ConditionName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (ConditionID));
CREATE TABLE MarketplaceItemStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
CREATE TABLE MarketplaceTransaction (
  TransactionID     int IDENTITY NOT NULL, 
  MarketplaceItemID int NOT NULL, 
  BuyerID           int NOT NULL, 
  TransactionDate   datetime NOT NULL, 
  PaymentMethodID   int NOT NULL, 
  PRIMARY KEY (TransactionID));
CREATE TABLE SessionStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
CREATE TABLE ItemCategory (
  CategoryID   int IDENTITY NOT NULL, 
  CategoryName varchar(50) NOT NULL UNIQUE, 
  Description  varchar(255) NULL, 
  IsActive     bit NOT NULL, 
  PRIMARY KEY (CategoryID));
CREATE TABLE TeacherAbsence (
  AbsenceID int IDENTITY NOT NULL, 
  TeacherID int NOT NULL, 
  StartDate datetime NOT NULL, 
  EndDate   datetime NOT NULL, 
  Reason    varchar(255) NULL, 
  PRIMARY KEY (AbsenceID));
CREATE TABLE CoachingJoinRequest (
  JoinRequestID    int IDENTITY NOT NULL, 
  SessionID        int NOT NULL, 
  StudentAccountID int NOT NULL, 
  RequestedAt      datetime NOT NULL, 
  StatusID         int NOT NULL, 
  ReviewedByUserID int NULL, 
  ReviewedAt       datetime NULL, 
  PRIMARY KEY (JoinRequestID));
CREATE TABLE SessionValidation (
  ValidationID      int IDENTITY NOT NULL, 
  SessionID         int NOT NULL, 
  ValidatedByUserID int NOT NULL, 
  ValidatedAt       datetime NOT NULL, 
  ValidationStepID  int NOT NULL, 
  PRIMARY KEY (ValidationID));
CREATE TABLE FinancialEntry (
  EntryID            int IDENTITY NOT NULL, 
  SessionID          int NOT NULL, 
  Amount             decimal(10, 2) NOT NULL, 
  EntryTypeID        int NOT NULL, 
  CreatedAt          datetime NOT NULL, 
  IsExported         bit NOT NULL, 
  ExportedByUserID   int NOT NULL, 
  FinancialSummaryID int NOT NULL, 
  PRIMARY KEY (EntryID));
CREATE TABLE FinancialEntryType (
  EntryTypeID int IDENTITY NOT NULL, 
  TypeName    varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (EntryTypeID));
CREATE TABLE ValidationStep (
  StepID   int IDENTITY NOT NULL, 
  StepName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StepID));
CREATE TABLE AttendanceStatus (
  AttendanceStatusID int IDENTITY NOT NULL, 
  StatusName         varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AttendanceStatusID));
CREATE TABLE TeacherModality (
  TeacherID  int NOT NULL, 
  ModalityID int NOT NULL, 
  PRIMARY KEY (TeacherID, 
  ModalityID));
CREATE TABLE FinancialSummary (
  FinancialSummaryID int IDENTITY NOT NULL, 
  PeriodStart        date NOT NULL, 
  PeriodEnd          date NOT NULL, 
  GeneratedAt        datetime NOT NULL, 
  TotalAmount        decimal(10, 2) NOT NULL, 
  GeneratedByUserID  int NOT NULL, 
  IsExported         bit NOT NULL, 
  AcademicYearID     int NULL, 
  PRIMARY KEY (FinancialSummaryID));
CREATE TABLE AcademicYear (
  AcademicYearID int IDENTITY NOT NULL, 
  Label          varchar(50) NOT NULL UNIQUE, 
  StartsOn       date NOT NULL, 
  EndsOn         date NOT NULL, 
  IsActive       bit NOT NULL, 
  PRIMARY KEY (AcademicYearID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'label: -- ex: ''2025/2026''', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'AcademicYear';
CREATE TABLE SchoolEvent (
  EventID         int IDENTITY NOT NULL, 
  Title           varchar(100) NOT NULL, 
  Description     varchar(255) NULL, 
  StartsAt        datetime NOT NULL, 
  EndsAt          datetime NOT NULL, 
  AudienceScopeID int NOT NULL, 
  AcademicYearID  int NOT NULL, 
  CreatedByUserID int NOT NULL, 
  StatusID        int NOT NULL, 
  IsActive        bit NOT NULL, 
  PRIMARY KEY (EventID));
CREATE TABLE SchoolEventStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'ex: ''DRAFT'', ''PUBLISHED'', ''CANCELLED''', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolEventStatus';
CREATE TABLE AudienceScope (
  AudienceScopeID int IDENTITY NOT NULL, 
  ScopeName       varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AudienceScopeID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'ex: ''ALL'', ''STUDENTS'', ''TEACHERS''', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'AudienceScope';
CREATE TABLE SchoolSchedule (
  ScheduleEntryID int IDENTITY NOT NULL, 
  StartsAt        datetime NOT NULL, 
  EndsAt          datetime NOT NULL, 
  Notes           varchar(255) NULL, 
  StudioID        int NULL, 
  AcademicYearID  int NOT NULL, 
  StatusID        int NOT NULL, 
  IsActive        bit NOT NULL, 
  PRIMARY KEY (ScheduleEntryID));
CREATE TABLE SchoolScheduleStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'-- ex: ''DRAFT'', ''PUBLISHED'', ''ARCHIVED''', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolScheduleStatus';
CREATE TABLE TeacherAssignmentRole (
  AssignmentRoleID int IDENTITY NOT NULL, 
  RoleName         varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AssignmentRoleID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'ex: ''PRIMARY'', ''ASSISTANT''', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAssignmentRole';
ALTER TABLE [User] ADD CONSTRAINT FKUser68364 FOREIGN KEY (RoleID) REFERENCES Role (RoleID);
ALTER TABLE InventoryItem ADD CONSTRAINT FKInventoryI379196 FOREIGN KEY (OwnerID) REFERENCES [User] (UserID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe374919 FOREIGN KEY (StudioID) REFERENCES Studio (StudioID);
ALTER TABLE SessionTeacher ADD CONSTRAINT FKSessionTea930744 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE SessionTeacher ADD CONSTRAINT FKSessionTea26891 FOREIGN KEY (TeacherID) REFERENCES [User] (UserID);
ALTER TABLE SessionStudent ADD CONSTRAINT FKSessionStu499991 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE SessionStudent ADD CONSTRAINT FKSessionStu268529 FOREIGN KEY (StudentAccountID) REFERENCES StudentAccount (StudentAccountID);
ALTER TABLE StudioModality ADD CONSTRAINT FKStudioModa985589 FOREIGN KEY (StudioID) REFERENCES Studio (StudioID);
ALTER TABLE StudioModality ADD CONSTRAINT FKStudioModa892485 FOREIGN KEY (ModalityID) REFERENCES Modality (ModalityID);
ALTER TABLE TeacherAvailability ADD CONSTRAINT FKTeacherAva280645 FOREIGN KEY (TeacherID) REFERENCES [User] (UserID);
ALTER TABLE InventoryTransaction ADD CONSTRAINT FKInventoryT392770 FOREIGN KEY (InventoryItemID) REFERENCES InventoryItem (InventoryItemID);
ALTER TABLE InventoryTransaction ADD CONSTRAINT FKInventoryT279068 FOREIGN KEY (RenterID) REFERENCES [User] (UserID);
ALTER TABLE InventoryTransaction ADD CONSTRAINT FKInventoryT529044 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod (PaymentMethodID);
ALTER TABLE Notification ADD CONSTRAINT FKNotificati840594 FOREIGN KEY (UserID) REFERENCES [User] (UserID);
ALTER TABLE Notification ADD CONSTRAINT FKNotificati559307 FOREIGN KEY (TypeID) REFERENCES NotificationType (TypeID);
ALTER TABLE StudentAccount ADD CONSTRAINT FKStudentAcc231273 FOREIGN KEY (UserID) REFERENCES [User] (UserID);
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac521076 FOREIGN KEY (SellerID) REFERENCES [User] (UserID);
ALTER TABLE MarketplaceTransaction ADD CONSTRAINT FKMarketplac626084 FOREIGN KEY (BuyerID) REFERENCES [User] (UserID);
ALTER TABLE MarketplaceTransaction ADD CONSTRAINT FKMarketplac794520 FOREIGN KEY (MarketplaceItemID) REFERENCES MarketplaceItem (MarketplaceItemID);
ALTER TABLE MarketplaceTransaction ADD CONSTRAINT FKMarketplac488711 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod (PaymentMethodID);
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac133556 FOREIGN KEY (ConditionID) REFERENCES MarketplaceItemCondition (ConditionID);
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac786798 FOREIGN KEY (StatusID) REFERENCES MarketplaceItemStatus (StatusID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe66160 FOREIGN KEY (StatusID) REFERENCES SessionStatus (StatusID);
ALTER TABLE InventoryItem ADD CONSTRAINT FKInventoryI464627 FOREIGN KEY (CategoryID) REFERENCES ItemCategory (CategoryID);
ALTER TABLE TeacherAbsence ADD CONSTRAINT FKTeacherAbs60475 FOREIGN KEY (TeacherID) REFERENCES [User] (UserID);
ALTER TABLE CoachingJoinRequest ADD CONSTRAINT FKCoachingJo941654 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE CoachingJoinRequest ADD CONSTRAINT FKCoachingJo710192 FOREIGN KEY (StudentAccountID) REFERENCES StudentAccount (StudentAccountID);
ALTER TABLE CoachingJoinRequest ADD CONSTRAINT FKCoachingJo712145 FOREIGN KEY (StatusID) REFERENCES SessionStatus (StatusID);
ALTER TABLE CoachingJoinRequest ADD CONSTRAINT FKCoachingJo315859 FOREIGN KEY (ReviewedByUserID) REFERENCES [User] (UserID);
ALTER TABLE SessionValidation ADD CONSTRAINT FKSessionVal768396 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE SessionValidation ADD CONSTRAINT FKSessionVal845416 FOREIGN KEY (ValidatedByUserID) REFERENCES [User] (UserID);
ALTER TABLE SessionValidation ADD CONSTRAINT FKSessionVal556128 FOREIGN KEY (ValidationStepID) REFERENCES ValidationStep (StepID);
ALTER TABLE FinancialEntry ADD CONSTRAINT FKFinancialE156070 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE FinancialEntry ADD CONSTRAINT FKFinancialE684094 FOREIGN KEY (EntryTypeID) REFERENCES FinancialEntryType (EntryTypeID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe91769 FOREIGN KEY (RequestedByUserID) REFERENCES [User] (UserID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe718595 FOREIGN KEY (ModalityID) REFERENCES Modality (ModalityID);
ALTER TABLE SessionStudent ADD CONSTRAINT FKSessionStu927481 FOREIGN KEY (AttendanceStatusID) REFERENCES AttendanceStatus (AttendanceStatusID);
ALTER TABLE LostAndFoundItem ADD CONSTRAINT FKLostAndFou221547 FOREIGN KEY (RegisteredByUserID) REFERENCES [User] (UserID);
ALTER TABLE Notification ADD CONSTRAINT FKNotificati961434 FOREIGN KEY (SessionID) REFERENCES CoachingSession (SessionID);
ALTER TABLE TeacherModality ADD CONSTRAINT FKTeacherMod35746 FOREIGN KEY (TeacherID) REFERENCES [User] (UserID);
ALTER TABLE TeacherModality ADD CONSTRAINT FKTeacherMod909825 FOREIGN KEY (ModalityID) REFERENCES Modality (ModalityID);
ALTER TABLE FinancialSummary ADD CONSTRAINT FKFinancialS483396 FOREIGN KEY (GeneratedByUserID) REFERENCES [User] (UserID);
ALTER TABLE SchoolEvent ADD CONSTRAINT FKSchoolEven793594 FOREIGN KEY (AcademicYearID) REFERENCES AcademicYear (AcademicYearID);
ALTER TABLE SchoolSchedule ADD CONSTRAINT FKSchoolSche339026 FOREIGN KEY (AcademicYearID) REFERENCES AcademicYear (AcademicYearID);
ALTER TABLE SchoolEvent ADD CONSTRAINT FKSchoolEven325292 FOREIGN KEY (StatusID) REFERENCES SchoolEventStatus (StatusID);
ALTER TABLE SchoolEvent ADD CONSTRAINT FKSchoolEven592714 FOREIGN KEY (AudienceScopeID) REFERENCES AudienceScope (AudienceScopeID);
ALTER TABLE SchoolSchedule ADD CONSTRAINT FKSchoolSche776034 FOREIGN KEY (StatusID) REFERENCES SchoolScheduleStatus (StatusID);
ALTER TABLE SchoolSchedule ADD CONSTRAINT FKSchoolSche688461 FOREIGN KEY (StudioID) REFERENCES Studio (StudioID);
ALTER TABLE SchoolEvent ADD CONSTRAINT FKSchoolEven937570 FOREIGN KEY (CreatedByUserID) REFERENCES [User] (UserID);
ALTER TABLE FinancialEntry ADD CONSTRAINT FKFinancialE401382 FOREIGN KEY (ExportedByUserID) REFERENCES [User] (UserID);
ALTER TABLE SessionTeacher ADD CONSTRAINT FKSessionTea70331 FOREIGN KEY (AssignmentRoleID) REFERENCES TeacherAssignmentRole (AssignmentRoleID);
ALTER TABLE FinancialSummary ADD CONSTRAINT FKFinancialS977589 FOREIGN KEY (AcademicYearID) REFERENCES AcademicYear (AcademicYearID);
ALTER TABLE FinancialEntry ADD CONSTRAINT FKFinancialE900991 FOREIGN KEY (FinancialSummaryID) REFERENCES FinancialSummary (FinancialSummaryID);
