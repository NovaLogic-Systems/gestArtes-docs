CREATE TABLE Role (
  RoleID      int IDENTITY NOT NULL, 
  RoleName    varchar(50) NOT NULL, 
  Description varchar(255) NULL, 
  PRIMARY KEY (RoleID));
CREATE TABLE [User] (
  UserID       int IDENTITY NOT NULL, 
  FirstName    varchar(150) NOT NULL, 
  LastName     varchar(150) NULL, 
  PhoneNumber  varchar(20) NULL, 
  Email        varchar(100) NULL, 
  Photo        varchar(255) NULL, 
  RoleID       int NOT NULL, 
  PasswordHash varchar(255) NOT NULL, 
  AuthUID      varchar(255) NOT NULL, 
  CreatedAt    datetime NOT NULL, 
  UpdatedAt    datetime NULL, 
  IsActive     bit NOT NULL, 
  DeletedAt    datetime NULL, 
  PRIMARY KEY (UserID));
CREATE TABLE StudentAccount (
  StudentAccountID int IDENTITY NOT NULL, 
  UserID           int NOT NULL, 
  BirthDate        date NOT NULL, 
  PRIMARY KEY (StudentAccountID));
CREATE TABLE Studio (
  StudioID   int IDENTITY NOT NULL, 
  StudioName varchar(50) NOT NULL, 
  Capacity   int NOT NULL, 
  PRIMARY KEY (StudioID));
CREATE TABLE InventoryItem (
  InventoryItemID int IDENTITY NOT NULL, 
  OwnerID         int NOT NULL, 
  ItemName        varchar(100) NOT NULL, 
  CategoryID      int NOT NULL, 
  SymbolicFee     decimal(10, 2) NOT NULL, 
  Description     varchar(255) NULL, 
  PRIMARY KEY (InventoryItemID));
CREATE TABLE CoachingSession (
  SessionID             int IDENTITY NOT NULL, 
  StudioID              int NOT NULL, 
  StartTime             datetime NOT NULL, 
  EndTime               datetime NOT NULL, 
  StatusID              int NOT NULL, 
  FinalPrice            decimal(10, 2) NULL, 
  ValidationRequestedAt datetime NULL CHECK(ValidationRequestedAt), 
  CancellationReason    varchar(255) NULL, 
  PRIMARY KEY (SessionID));
CREATE TABLE SessionTeacher (
  SessionID int NOT NULL, 
  TeacherID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  TeacherID));
CREATE TABLE SessionStudent (
  SessionID        int NOT NULL, 
  StudentAccountID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  StudentAccountID));
CREATE TABLE Modality (
  ModalityID   int IDENTITY NOT NULL, 
  ModalityName varchar(50) NOT NULL, 
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
  TransactionID   int IDENTITY NOT NULL, 
  InventoryItemID int NOT NULL, 
  RenterID        int NOT NULL, 
  StartDate       datetime NOT NULL, 
  EndDate         datetime NULL, 
  PaymentMethodID int NOT NULL, 
  IsCompleted     bit NOT NULL, 
  PRIMARY KEY (TransactionID));
CREATE TABLE PaymentMethod (
  PaymentMethodID int IDENTITY NOT NULL, 
  MethodName      varchar(50) NOT NULL, 
  IsActive        bit NOT NULL, 
  PRIMARY KEY (PaymentMethodID));
CREATE TABLE NotificationType (
  TypeID   int IDENTITY NOT NULL, 
  TypeName varchar(50) NOT NULL, 
  PRIMARY KEY (TypeID));
CREATE TABLE Notification (
  NotificationID int IDENTITY NOT NULL, 
  UserID         int NOT NULL, 
  Message        varchar(255) NULL, 
  TypeID         int NOT NULL, 
  IsRead         bit NOT NULL, 
  CreatedAt      datetime NOT NULL, 
  Title          varchar(255) NOT NULL, 
  CONSTRAINT NotificationID 
    PRIMARY KEY (NotificationID));
CREATE TABLE LostAndFoundItem (
  LostItemID    int IDENTITY NOT NULL, 
  Description   varchar(255) NULL, 
  FoundDate     datetime NOT NULL, 
  ClaimedStatus bit NOT NULL, 
  PhotoURL      varchar(255) NULL, 
  Title         varchar(255) NOT NULL, 
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
CREATE TABLE [Condition] (
  ConditionID   int IDENTITY NOT NULL, 
  ConditionName varchar(50) NOT NULL, 
  PRIMARY KEY (ConditionID));
CREATE TABLE Status (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL, 
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
  StatusName varchar(50) NOT NULL, 
  PRIMARY KEY (StatusID));
CREATE TABLE ItemCategory (
  CategoryID   int IDENTITY NOT NULL, 
  CategoryName varchar(50) NOT NULL, 
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
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac949205 FOREIGN KEY (ConditionID) REFERENCES [Condition] (ConditionID);
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac318321 FOREIGN KEY (StatusID) REFERENCES Status (StatusID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe66160 FOREIGN KEY (StatusID) REFERENCES SessionStatus (StatusID);
ALTER TABLE InventoryItem ADD CONSTRAINT FKInventoryI464627 FOREIGN KEY (CategoryID) REFERENCES ItemCategory (CategoryID);
ALTER TABLE TeacherAbsence ADD CONSTRAINT FKTeacherAbs60475 FOREIGN KEY (TeacherID) REFERENCES [User] (UserID);
