CREATE TABLE [dbo].[PacingPerformanceAttributes] (
    [AttributeID] VARCHAR (50)   NOT NULL,
    [Value]       VARCHAR (MAX)  NOT NULL,
    [Description] VARCHAR (MAX)  NOT NULL,
    [CreatedOn]   DATETIME       NOT NULL,
    [CreatedBy]   NVARCHAR (255) NOT NULL,
    [UpdatedOn]   DATETIME       NULL,
    [UpdatedBy]   NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([AttributeID] ASC)
);

