CREATE TABLE [dbo].[MasterBudgetSourcePivotMobile] (
    [rId]                     INT             IDENTITY (1, 1) NOT NULL,
    [AssociateIDTactic]       NVARCHAR (255)  NULL,
    [TargetDemo]              NVARCHAR (255)  NULL,
    [AssociateID]             NVARCHAR (255)  NULL,
    [Radius]                  INT             NULL,
    [TerminationDate]         DATETIME        NULL,
    [Tactic]                  NVARCHAR (255)  NULL,
    [SumOfSbms]               DECIMAL (18, 2) NULL,
    [PaymentDeactivationDate] DATETIME        NULL,
    [CreatedOn]               DATETIME        NOT NULL,
    [CreatedBy]               NVARCHAR (100)  NOT NULL,
    PRIMARY KEY CLUSTERED ([rId] ASC)
);

