CREATE TABLE Role (
  RoleID      int IDENTITY NOT NULL, 
  RoleName    varchar(50) NOT NULL UNIQUE, 
  Description varchar(255) NULL, 
  PRIMARY KEY (RoleID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Lookup dos perfis de acesso: aluno, professor, admin', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'Role';
CREATE TABLE [User] (
  UserID       int IDENTITY NOT NULL, 
  FirstName    varchar(150) NOT NULL, 
  LastName     varchar(150) NULL, 
  PhoneNumber  varchar(20) NULL, 
  Email        varchar(100) NOT NULL UNIQUE, 
  Photo        varchar(255) NULL, 
  PasswordHash varchar(255) NOT NULL, 
  AuthUID      varchar(255) NOT NULL UNIQUE, 
  CreatedAt    datetime NOT NULL, 
  UpdatedAt    datetime NULL, 
  IsActive     bit NOT NULL, 
  DeletedAt    datetime NULL, 
  PRIMARY KEY (UserID), 
  CONSTRAINT CHK_User_Email 
    CHECK (Email LIKE '%@%.%'), 
  CONSTRAINT CHK_User_UpdatedAt 
    CHECK (UpdatedAt IS NULL OR UpdatedAt >= CreatedAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Registo central de todos os utilizadores autenticados com dados de perfil e credenciais', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'User';
CREATE TABLE StudentAccount (
  StudentAccountID int IDENTITY NOT NULL, 
  UserID           int NOT NULL UNIQUE, 
  BirthDate        date NOT NULL, 
  GuardianName     varchar(150) NULL, 
  GuardianPhone    varchar(20) NULL, 
  PRIMARY KEY (StudentAccountID), 
  CONSTRAINT CHK_StudentAccount_BirthDate 
    CHECK (BirthDate < CAST(GETDATE() AS date)));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Extensão do User para alunos — âncora para matrículas e pedidos de aula', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'StudentAccount';
CREATE TABLE Studio (
  StudioID   int IDENTITY NOT NULL, 
  StudioName varchar(50) NOT NULL UNIQUE, 
  Capacity   int NOT NULL, 
  PRIMARY KEY (StudioID), 
  CONSTRAINT CHK_Studio_Capacity 
    CHECK (Capacity > 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estúdios físicos da escola com nome e capacidade', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'Studio';
CREATE TABLE InventoryItem (
  InventoryItemID int IDENTITY NOT NULL, 
  ItemName        varchar(100) NOT NULL, 
  CategoryID      int NOT NULL, 
  SymbolicFee     decimal(10, 2) NOT NULL, 
  Description     varchar(255) NULL, 
  PhotoURL        varchar(255) NULL, 
  TotalQuantity   int DEFAULT 1 NOT NULL, 
  PRIMARY KEY (InventoryItemID), 
  CONSTRAINT InventoryItem_TotalQuantity 
    CHECK (TotalQuantity >= 1), 
  CONSTRAINT CHK_InventoryItem_SymbolicFee 
    CHECK (SymbolicFee >= 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Catálogo de itens para aluguer com taxa simbólica e quantidade total em stock', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'InventoryItem';
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
  CreatedAt             datetime NOT NULL, 
  ReviewedByUserID      int NULL, 
  ReviewedAt            datetime NULL, 
  ReviewNotes           varchar(255) NULL, 
  PricingRateID         int NOT NULL, 
  PRIMARY KEY (SessionID), 
  CONSTRAINT CHK_CoachingSession_ValidationRequestedAt 
    CHECK (ValidationRequestedAt IS NULL OR ValidationRequestedAt >= CreatedAt), 
  CONSTRAINT CHK_CoachingSession_ReviewedAt 
    CHECK (ReviewedAt IS NULL OR ReviewedAt >= CreatedAt), 
  CONSTRAINT CHK_CoachingSession_Times 
    CHECK (EndTime > StartTime), 
  CONSTRAINT CHK_CoachingSession_MaxParticipants 
    CHECK (MaxParticipants IS NULL OR MaxParticipants >= 1), 
  CONSTRAINT CHK_CoachingSession_FinalPrice 
    CHECK (FinalPrice IS NULL OR FinalPrice >= 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'CreatedAt - Quando a sessão foi criada/pedida pelo professor
ValidationRequestedAt - Quando o professor pediu a validação pós-aula à gestão

Registo de cada aula: estúdio, horário, tarifa aplicada, preço final calculado', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'CoachingSession';
CREATE TABLE SessionTeacher (
  SessionID        int NOT NULL, 
  TeacherID        int NOT NULL, 
  AssignmentRoleID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  TeacherID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Professores por sessão com o papel de cada um (PRIMARY/ASSISTANT)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SessionTeacher';
CREATE TABLE SessionStudent (
  SessionID          int NOT NULL, 
  StudentAccountID   int NOT NULL, 
  EnrolledAt         datetime NOT NULL, 
  AttendanceStatusID int NOT NULL, 
  PRIMARY KEY (SessionID, 
  StudentAccountID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Inscrições de alunos numa sessão com estado de presença', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SessionStudent';
CREATE TABLE Modality (
  ModalityID   int IDENTITY NOT NULL, 
  ModalityName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (ModalityID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Modalidades de dança (Balet, Salão, etc.)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'Modality';
CREATE TABLE StudioModality (
  StudioID   int NOT NULL, 
  ModalityID int NOT NULL, 
  PRIMARY KEY (StudioID, 
  ModalityID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Quais modalidades podem ocorrer em cada estúdio', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'StudioModality';
CREATE TABLE TeacherAvailability (
  AvailabilityID   int IDENTITY NOT NULL, 
  TeacherID        int NOT NULL, 
  Notes            varchar(255) NULL, 
  RequestedAt      datetime NOT NULL, 
  StatusID         int NOT NULL, 
  ReviewedByUserID int NULL, 
  ReviewedAt       datetime NULL, 
  ReviewNotes      varchar(255) NULL, 
  PRIMARY KEY (AvailabilityID), 
  CONSTRAINT CHK_TeacherAvailability_ReviewedAt 
    CHECK (ReviewedAt IS NULL OR ReviewedAt >= RequestedAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Pedido de disponibilidade de professor, aprovado pela gestão', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAvailability';
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
  PRIMARY KEY (TransactionID), 
  CONSTRAINT CHK_InventoryTransaction_Dates 
    CHECK (EndDate IS NULL OR EndDate > StartDate));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Registo de cada aluguer: quem, quando, método de pagamento, estado de devolução', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'InventoryTransaction';
CREATE TABLE PaymentMethod (
  PaymentMethodID int IDENTITY NOT NULL, 
  MethodName      varchar(50) NOT NULL UNIQUE, 
  IsActive        bit NOT NULL, 
  PRIMARY KEY (PaymentMethodID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Métodos de pagamento aceites (Dinheiro, Multibanco, MB Way)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'PaymentMethod';
CREATE TABLE NotificationType (
  TypeID   int IDENTITY NOT NULL, 
  TypeName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (TypeID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Tipos de notificação (sessão aprovada, pedido de validação, etc.)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'NotificationType';
CREATE TABLE Notification (
  NotificationID int IDENTITY NOT NULL, 
  UserID         int NOT NULL, 
  Message        varchar(255) NULL, 
  TypeID         int NOT NULL, 
  IsRead         bit NOT NULL, 
  CreatedAt      datetime NOT NULL, 
  Title          varchar(255) NOT NULL, 
  SessionID      int NULL, 
  PRIMARY KEY (NotificationID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Notificações enviadas a utilizadores, associáveis a sessões', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'Notification';
CREATE TABLE LostAndFoundItem (
  LostItemID         int IDENTITY NOT NULL, 
  Title              varchar(255) NOT NULL, 
  Description        varchar(255) NULL, 
  FoundDate          datetime NOT NULL, 
  ClaimedStatus      bit NOT NULL, 
  PhotoURL           varchar(255) NULL, 
  RegisteredByUserID int NOT NULL, 
  AdminNotes         varchar(255) NULL, 
  IsArchived         bit DEFAULT 0 NOT NULL, 
  ArchivedAt         datetime NULL, 
  PRIMARY KEY (LostItemID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Objetos perdidos e achados com estado de reclamação', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'LostAndFoundItem';
CREATE TABLE MarketplaceItem (
  MarketplaceItemID int IDENTITY NOT NULL, 
  SellerID          int NOT NULL, 
  Title             varchar(100) NOT NULL, 
  Description       varchar(255) NULL, 
  Price             decimal(10, 2) NOT NULL, 
  ConditionID       int NOT NULL, 
  StatusID          int NOT NULL, 
  IsActive          bit NOT NULL, 
  CategoryID        int NOT NULL, 
  PhotoURL          varchar(500) NULL, 
  CreatedAt         datetime NULL, 
  Location          varchar(255) NULL, 
  PRIMARY KEY (MarketplaceItemID), 
  CONSTRAINT CHK_MarketplaceItem_Price 
    CHECK (Price >= 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Anúncio de venda entre membros da escola', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'MarketplaceItem';
CREATE TABLE MarketplaceItemCondition (
  ConditionID   int IDENTITY NOT NULL, 
  ConditionName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (ConditionID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Condição do artigo: Novo, Muito bom, Com marcas de uso', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'MarketplaceItemCondition';
CREATE TABLE MarketplaceItemStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estado do anúncio: Disponível, Reservado, Vendido, Cancelado', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'MarketplaceItemStatus';
CREATE TABLE MarketplaceTransaction (
  TransactionID     int IDENTITY NOT NULL, 
  MarketplaceItemID int NOT NULL, 
  BuyerID           int NOT NULL, 
  TransactionDate   datetime NOT NULL, 
  PaymentMethodID   int NOT NULL, 
  PRIMARY KEY (TransactionID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Registo de venda concluída com comprador e método de pagamento', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'MarketplaceTransaction';
CREATE TABLE SessionStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Lookup de estados: awaiting approval, scheduled, in progress, done, cancelled', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SessionStatus';
CREATE TABLE ItemCategory (
  CategoryID   int IDENTITY NOT NULL, 
  CategoryName varchar(50) NOT NULL UNIQUE, 
  Description  varchar(255) NULL, 
  IsActive     bit NOT NULL, 
  PRIMARY KEY (CategoryID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Categorias dos itens (Sapatos, vestido, etc.)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'ItemCategory';
CREATE TABLE TeacherAbsence (
  AbsenceID        int IDENTITY NOT NULL, 
  TeacherID        int NOT NULL, 
  StartDate        datetime NOT NULL, 
  EndDate          datetime NOT NULL, 
  Reason           varchar(255) NULL, 
  StatusID         int NOT NULL, 
  RequestedAt      datetime NOT NULL, 
  ReviewedByUserID int NULL, 
  ReviewedAt       datetime NULL, 
  ReviewNotes      varchar(255) NULL, 
  PRIMARY KEY (AbsenceID), 
  CONSTRAINT CHK_TeacherAbsence_Dates 
    CHECK (EndDate > StartDate), 
  CONSTRAINT CHK_TeacherAbsence_ReviewedAt 
    CHECK (ReviewedAt IS NULL OR ReviewedAt >= RequestedAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Pedido de ausência com datas, motivo e estado de aprovação', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAbsence';
CREATE TABLE CoachingJoinRequest (
  JoinRequestID    int IDENTITY NOT NULL, 
  SessionID        int NOT NULL, 
  StudentAccountID int NOT NULL, 
  RequestedAt      datetime NOT NULL, 
  StatusID         int NOT NULL, 
  ReviewedByUserID int NULL, 
  ReviewedAt       datetime NULL, 
  PRIMARY KEY (JoinRequestID), 
  CONSTRAINT CHK_CoachingJoinRequest_ReviewedAt 
    CHECK (ReviewedAt IS NULL OR ReviewedAt >= RequestedAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Pedido de inscrição de aluno numa sessão existente, sujeito a aprovação', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'CoachingJoinRequest';
CREATE TABLE SessionValidation (
  ValidationID      int IDENTITY NOT NULL, 
  SessionID         int NOT NULL, 
  ValidatedByUserID int NOT NULL, 
  ValidatedAt       datetime NOT NULL, 
  ValidationStepID  int NOT NULL, 
  PRIMARY KEY (ValidationID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Passos do processo de validação pós-aula executados por utilizadores', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SessionValidation';
CREATE TABLE FinancialEntry (
  EntryID            int IDENTITY NOT NULL, 
  SessionID          int NOT NULL, 
  Amount             decimal(10, 2) NOT NULL, 
  EntryTypeID        int NOT NULL, 
  CreatedAt          datetime NOT NULL, 
  IsExported         bit NOT NULL, 
  ExportedByUserID   int NULL, 
  FinancialSummaryID int NOT NULL, 
  PRIMARY KEY (EntryID), 
  CONSTRAINT CHK_FinancialEntry_Amount 
    CHECK (Amount <> 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Lançamento financeiro individual por sessão (débito ou crédito)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'FinancialEntry';
CREATE TABLE FinancialEntryType (
  EntryTypeID int IDENTITY NOT NULL, 
  TypeName    varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (EntryTypeID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Tipo de lançamento: receita de aula, penalização no-show, taxa de aluguer', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'FinancialEntryType';
CREATE TABLE ValidationStep (
  StepID   int IDENTITY NOT NULL, 
  StepName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StepID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Lookup dos passos de validação (ex: professor confirma → gestão valida → contabilizado)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'ValidationStep';
CREATE TABLE AttendanceStatus (
  AttendanceStatusID int IDENTITY NOT NULL, 
  StatusName         varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AttendanceStatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Lookup de presença: attended, cancelled, no-show', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'AttendanceStatus';
CREATE TABLE TeacherModality (
  TeacherID  int NOT NULL, 
  ModalityID int NOT NULL, 
  PRIMARY KEY (TeacherID, 
  ModalityID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Modalidades que cada professor leciona', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherModality';
CREATE TABLE FinancialSummary (
  FinancialSummaryID int IDENTITY NOT NULL, 
  PeriodStart        date NOT NULL, 
  PeriodEnd          date NOT NULL, 
  GeneratedAt        datetime NOT NULL, 
  TotalAmount        decimal(10, 2) NOT NULL, 
  GeneratedByUserID  int NOT NULL, 
  IsExported         bit NOT NULL, 
  AcademicYearID     int NOT NULL, 
  PRIMARY KEY (FinancialSummaryID), 
  CONSTRAINT CHK_FinancialSummary_TotalAmount 
    CHECK (TotalAmount >= 0), 
  CONSTRAINT CHK_FinancialSummary_Period 
    CHECK (PeriodEnd > PeriodStart));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Resumo financeiro por período, ligado ao ano letivo, exportável', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'FinancialSummary';
CREATE TABLE AcademicYear (
  AcademicYearID int IDENTITY NOT NULL, 
  Label          varchar(50) NOT NULL UNIQUE, 
  StartsOn       date NOT NULL, 
  EndsOn         date NOT NULL, 
  IsActive       bit NOT NULL, 
  PRIMARY KEY (AcademicYearID), 
  CONSTRAINT CHK_AcademicYear_Dates 
    CHECK (EndsOn > StartsOn));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Ano letivo (ex: 2025/2026) — só um ativo de cada vez', 
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
  PRIMARY KEY (EventID), 
  CONSTRAINT CHK_SchoolEvent_Times 
    CHECK (EndsAt > StartsAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Eventos escolares (recitais, workshops) com público-alvo e estado', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolEvent';
CREATE TABLE SchoolEventStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estados: DRAFT, PUBLISHED, CANCELLED', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolEventStatus';
CREATE TABLE AudienceScope (
  AudienceScopeID int IDENTITY NOT NULL, 
  ScopeName       varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AudienceScopeID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Público-alvo de eventos: ALL, STUDENTS, TEACHERS', 
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
  PRIMARY KEY (ScheduleEntryID), 
  CONSTRAINT CHK_SchoolSchedule_Times 
    CHECK (EndsAt > StartsAt));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Horário oficial da escola por estúdio e ano letivo', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolSchedule';
CREATE TABLE SchoolScheduleStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estados do horário: DRAFT, PUBLISHED, ARCHIVED', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SchoolScheduleStatus';
CREATE TABLE TeacherAssignmentRole (
  AssignmentRoleID int IDENTITY NOT NULL, 
  RoleName         varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (AssignmentRoleID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Papel do professor na sessão: PRIMARY, ASSISTANT', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAssignmentRole';
CREATE TABLE CoachingJoinRequestStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estados do pedido de inscrição: awaiting approval, approved, not approved', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'CoachingJoinRequestStatus';
CREATE TABLE UserRole (
  UserID int NOT NULL, 
  RoleID int NOT NULL, 
  PRIMARY KEY (UserID, 
  RoleID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Associação N:N entre utilizadores e papéis (um prof pode ser admin em simultaneo)', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'UserRole';
CREATE TABLE TeacherAbsenceStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estados da ausência: pendente, aprovado, rejeitado', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAbsenceStatus';
CREATE TABLE TeacherAvailabilityStatus (
  StatusID   int IDENTITY NOT NULL, 
  StatusName varchar(50) NOT NULL UNIQUE, 
  PRIMARY KEY (StatusID));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Estados: PENDING, APPROVED, REJECTED', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAvailabilityStatus';
CREATE TABLE TeacherAvailabilityRecurring (
  AvailabilityID int NOT NULL, 
  DayOfWeek      int NOT NULL, 
  StartTime      time(7) NOT NULL, 
  EndTime        time(7) NOT NULL, 
  AcademicYearID int NOT NULL, 
  IsActive       bit NOT NULL, 
  PRIMARY KEY (AvailabilityID), 
  CONSTRAINT CHK_TeacherAvailabilityRecurring_Times 
    CHECK (EndTime > StartTime), 
  CONSTRAINT CHK_TeacherAvailabilityRecurring_DayOfWeek 
    CHECK (DayOfWeek BETWEEN 1 AND 7));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Detalhe recorrente: dia da semana + intervalo horário semanal', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAvailabilityRecurring';
CREATE TABLE TeacherAvailabilityPunctual (
  AvailabilityID int NOT NULL, 
  StartDateTime  datetime NOT NULL, 
  EndDateTime    datetime NOT NULL, 
  PRIMARY KEY (AvailabilityID), 
  CONSTRAINT CHK_TeacherAvailabilityPunctual_Times 
    CHECK (EndDateTime > StartDateTime));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Detalhe pontual: data/hora específica', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'TeacherAvailabilityPunctual';
CREATE TABLE SessionPricingRate (
  PricingRateID int IDENTITY NOT NULL, 
  RateName      varchar(50) NOT NULL UNIQUE, 
  HourlyRate    decimal(10, 2) NOT NULL, 
  Description   varchar(255) NULL, 
  PRIMARY KEY (PricingRateID), 
  CONSTRAINT CHK_SessionPricingRate_HourlyRate 
    CHECK (HourlyRate > 0));
EXEC sp_addextendedproperty 
  @NAME = N'MS_Description', @VALUE = N'Tarifas horárias: STANDARD=36€/h, SUNDAY_HOLIDAY=43,50€/h', 
  @LEVEL0TYPE = N'Schema', @LEVEL0NAME = N'dbo', 
  @LEVEL1TYPE = N'Table', @LEVEL1NAME = N'SessionPricingRate';
CREATE TABLE Sessions (
  sid       varchar(255) NOT NULL, 
  [session] varchar(max) NOT NULL, 
  expires   datetime NOT NULL, 
  PRIMARY KEY (sid));
CREATE INDEX IX_User_IsActive 
  ON [User] (IsActive);
CREATE INDEX IX_InventoryItem_CategoryID 
  ON InventoryItem (CategoryID);
CREATE INDEX IX_CoachingSession_StartTime_EndTime 
  ON CoachingSession (StartTime, EndTime);
CREATE INDEX IX_CoachingSession_StatusID 
  ON CoachingSession (StatusID);
CREATE INDEX IX_CoachingSession_StudioID 
  ON CoachingSession (StudioID);
CREATE INDEX IX_CoachingSession_RequestedByUserID 
  ON CoachingSession (RequestedByUserID);
CREATE INDEX IX_CoachingSession_ModalityID 
  ON CoachingSession (ModalityID);
CREATE INDEX IX_SessionTeacher_TeacherID 
  ON SessionTeacher (TeacherID);
CREATE INDEX IX_SessionStudent_StudentAccountID 
  ON SessionStudent (StudentAccountID);
CREATE INDEX IX_TeacherAvailability_TeacherID 
  ON TeacherAvailability (TeacherID);
CREATE INDEX IX_TeacherAvailability_StatusID 
  ON TeacherAvailability (StatusID);
CREATE INDEX IX_InventoryTransaction_RenterID 
  ON InventoryTransaction (RenterID);
CREATE INDEX IX_InventoryTransaction_InventoryItemID 
  ON InventoryTransaction (InventoryItemID);
CREATE INDEX IX_InventoryTransaction_IsCompleted 
  ON InventoryTransaction (IsCompleted);
CREATE INDEX IX_Notification_UserID 
  ON Notification (UserID);
CREATE INDEX IX_Notification_UserID_IsRead 
  ON Notification (UserID, IsRead);
CREATE INDEX IX_MarketplaceItem_SellerID 
  ON MarketplaceItem (SellerID);
CREATE INDEX IX_MarketplaceItem_IsActive_StatusID 
  ON MarketplaceItem (IsActive, StatusID);
CREATE INDEX IX_TeacherAbsence_TeacherID 
  ON TeacherAbsence (TeacherID);
CREATE INDEX IX_TeacherAbsence_Dates 
  ON TeacherAbsence (StartDate, EndDate);
CREATE INDEX IX_CoachingJoinRequest_SessionID 
  ON CoachingJoinRequest (SessionID);
CREATE INDEX IX_CoachingJoinRequest_StudentAccountID 
  ON CoachingJoinRequest (StudentAccountID);
CREATE INDEX IX_CoachingJoinRequest_StatusID 
  ON CoachingJoinRequest (StatusID);
CREATE INDEX IX_SessionValidation_SessionID 
  ON SessionValidation (SessionID);
CREATE INDEX IX_FinancialEntry_SessionID 
  ON FinancialEntry (SessionID);
CREATE INDEX IX_FinancialEntry_FinancialSummaryID 
  ON FinancialEntry (FinancialSummaryID);
CREATE INDEX IX_FinancialEntry_IsExported 
  ON FinancialEntry (IsExported);
CREATE UNIQUE INDEX UIX_AcademicYear_OneActive 
  ON AcademicYear (IsActive) WHERE IsActive = 1;
CREATE INDEX IX_SchoolEvent_AcademicYearID_StartsAt 
  ON SchoolEvent (AcademicYearID, StartsAt);
CREATE INDEX IX_SchoolSchedule_AcademicYearID_StartsAt 
  ON SchoolSchedule (AcademicYearID, StartsAt);
CREATE INDEX IX_SchoolSchedule_StudioID 
  ON SchoolSchedule (StudioID);
CREATE INDEX IX_TeacherAvailabilityRecurring_DayOfWeek 
  ON TeacherAvailabilityRecurring (DayOfWeek);
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
ALTER TABLE CoachingJoinRequest ADD CONSTRAINT FKCoachingJo493731 FOREIGN KEY (StatusID) REFERENCES CoachingJoinRequestStatus (StatusID);
ALTER TABLE UserRole ADD CONSTRAINT FKUserRole396295 FOREIGN KEY (UserID) REFERENCES [User] (UserID);
ALTER TABLE UserRole ADD CONSTRAINT FKUserRole532117 FOREIGN KEY (RoleID) REFERENCES Role (RoleID);
ALTER TABLE TeacherAbsence ADD CONSTRAINT FKTeacherAbs72313 FOREIGN KEY (StatusID) REFERENCES TeacherAbsenceStatus (StatusID);
ALTER TABLE TeacherAbsence ADD CONSTRAINT FKTeacherAbs338533 FOREIGN KEY (ReviewedByUserID) REFERENCES [User] (UserID);
ALTER TABLE TeacherAvailability ADD CONSTRAINT FKTeacherAva2587 FOREIGN KEY (ReviewedByUserID) REFERENCES [User] (UserID);
ALTER TABLE TeacherAvailability ADD CONSTRAINT FKTeacherAva771431 FOREIGN KEY (StatusID) REFERENCES TeacherAvailabilityStatus (StatusID);
ALTER TABLE TeacherAvailabilityRecurring ADD CONSTRAINT FKTeacherAva690103 FOREIGN KEY (AcademicYearID) REFERENCES AcademicYear (AcademicYearID);
ALTER TABLE TeacherAvailabilityPunctual ADD CONSTRAINT FKTeacherAva895352 FOREIGN KEY (AvailabilityID) REFERENCES TeacherAvailability (AvailabilityID);
ALTER TABLE TeacherAvailabilityRecurring ADD CONSTRAINT FKTeacherAva485916 FOREIGN KEY (AvailabilityID) REFERENCES TeacherAvailability (AvailabilityID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe122574 FOREIGN KEY (ReviewedByUserID) REFERENCES [User] (UserID);
ALTER TABLE CoachingSession ADD CONSTRAINT FKCoachingSe330299 FOREIGN KEY (PricingRateID) REFERENCES SessionPricingRate (PricingRateID);
ALTER TABLE MarketplaceItem ADD CONSTRAINT FKMarketplac420996 FOREIGN KEY (CategoryID) REFERENCES ItemCategory (CategoryID);
