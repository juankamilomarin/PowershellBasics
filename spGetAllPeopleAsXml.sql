CREATE PROCEDURE [dbo].[spGetAllPeopleAsXml]
AS
BEGIN
	SET NOCOUNT ON

    SELECT(
		SELECT per.OriginalName, per.KnownAs, pro.Name AS Profession, per.Birthdate, per.Sex
		FROM tblPerson per
		INNER JOIN tblProfession pro ON pro.ProfessionId = per.ProfessionId
		FOR XML RAW('People'), ROOT('Person')
	) AS Xml
END