CREATE TABLE [dbo].[tblProfession](
	[ProfessionId] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED ,
	[Name] [nvarchar](max) NOT NULL
)

INSERT [dbo].[tblProfession] ([Name]) VALUES (N'Game designer')
INSERT [dbo].[tblProfession] ([Name]) VALUES (N'Football player')
INSERT [dbo].[tblProfession] ([Name]) VALUES (N'Actor/Actress')
INSERT [dbo].[tblProfession] ([Name]) VALUES (N'Writer')
INSERT [dbo].[tblProfession] ([Name]) VALUES (N'Filmmaker')
