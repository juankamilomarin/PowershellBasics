CREATE TABLE [dbo].[tblPerson](
	[PersonId] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED ,
	[OriginalName] [nvarchar](max) NOT NULL,
	[KnownAs] [nvarchar](max) NULL,
	[ProfessionId] [int] NOT NULL,
	[Birthdate] [date] NULL,
	[Sex] [char](1) NULL,
	CONSTRAINT [FK_tblPerson_tblProfession] FOREIGN KEY([ProfessionId]) REFERENCES [dbo].[tblProfession] ([ProfessionId])
)

INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'Ronaldo de Assis Moreira', N'Ronaldinho Gaúcho', 2, CAST(N'1980-03-21' AS Date), N'M')
INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'Natalie Portman', N'Natalie Portman', 3, CAST(N'1981-06-09' AS Date), N'F')
INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'George Walton Lucas Jr.', N'George Lucas', 5, CAST(N'1944-05-14' AS Date), N'M')
INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'小島 秀夫', N'Hideo Kojima', 1, CAST(N'1963-08-24' AS Date), N'M')
INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'宮本茂', N'Shigeru Miyamoto', 1, CAST(N'1952-11-16' AS Date), N'M')
INSERT [dbo].[tblPerson] ([OriginalName], [KnownAs], [ProfessionId], [Birthdate], [Sex]) VALUES (N'Stephen Edwin King', N'Stephen King', 4, CAST(N'1947-09-21' AS Date), N'M')
