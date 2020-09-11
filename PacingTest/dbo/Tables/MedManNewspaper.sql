﻿CREATE TABLE [dbo].[MedManNewspaper] (
    [rID]                        INT             IDENTITY (1, 1) NOT NULL,
    [ReportingTactic]            NVARCHAR (255)  NULL,
    [BudgetLookup]               NVARCHAR (255)  NULL,
    [NewspaperSegment]           NVARCHAR (255)  NULL,
    [AssociateID]                NVARCHAR (255)  NULL,
    [AgentName]                  NVARCHAR (255)  NULL,
    [PackageID]                  NVARCHAR (255)  NULL,
    [Publication]                NVARCHAR (255)  NULL,
    [PlannedInsertions]          INT             NULL,
    [AdSizeAndColor]             NVARCHAR (255)  NULL,
    [Year]                       NVARCHAR (255)  NULL,
    [Month]                      NVARCHAR (255)  NULL,
    [MonthNum]                   NVARCHAR (255)  NULL,
    [InsertionDate]              DATETIME        NULL,
    [EstimatedImpressions]       NVARCHAR (255)  NULL,
    [CreativeLabel1]             NVARCHAR (255)  NULL,
    [CreativeLabel2]             NVARCHAR (255)  NULL,
    [CreativeLabel3]             NVARCHAR (255)  NULL,
    [CreativeFile1]              NVARCHAR (255)  NULL,
    [CreativeFile2]              NVARCHAR (255)  NULL,
    [CreativeFile3]              NVARCHAR (255)  NULL,
    [Url]                        NVARCHAR (255)  NULL,
    [DataType]                   NVARCHAR (255)  NULL,
    [Vendor]                     NVARCHAR (255)  NULL,
    [Spend]                      DECIMAL (18, 4) NULL,
    [PlannedClicks]              DECIMAL (18, 2) NULL,
    [Clicks]                     DECIMAL (18, 2) NULL,
    [PlannedImpressions]         DECIMAL (18, 2) NULL,
    [DeliveredImpressionsToDate] DECIMAL (18, 2) NULL,
    [CreatedOn]                  DATETIME        NOT NULL,
    [CreatedBy]                  VARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dbo.MedManNewspaper] PRIMARY KEY CLUSTERED ([rID] ASC)
);

