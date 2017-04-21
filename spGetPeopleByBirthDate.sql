CREATE PROCEDURE [dbo].[spGetPeopleByBirthDate]
	@Initial DATE,
	@End	 DATE
AS
BEGIN
	SET NOCOUNT ON

    SELECT per.OriginalName, per.KnownAs, pro.Name AS Profession, per.Birthdate, per.Sex
	FROM tblPerson per
	INNER JOIN tblProfession pro ON pro.ProfessionId = per.ProfessionId
	WHERE Birthdate BETWEEN @Initial AND @End
END