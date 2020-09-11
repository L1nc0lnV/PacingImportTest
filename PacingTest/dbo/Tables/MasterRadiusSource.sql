CREATE TABLE [dbo].[MasterRadiusSource] (
    [rId]                           INT            IDENTITY (1, 1) NOT NULL,
    [AssociateID]                   NVARCHAR (255) NOT NULL,
    [DigitalMediaTargetingZips]     NVARCHAR (MAX) NULL,
    [DigitalMediaTargetingRadius]   INT            NOT NULL,
    [DigitalMediaRadiusPopulation]  INT            NOT NULL,
    [DigitalMediaCountTargetedZips] INT            NOT NULL,
    [Tactic]                        NVARCHAR (255) NOT NULL,
    [CreatedOn]                     DATETIME       NOT NULL,
    [CreatedBy]                     NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([rId] ASC)
);

