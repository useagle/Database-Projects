USE USEagle;
GO


CREATE PROCEDURE dbo.USEagle_rpt_PARAM0003_UserCategory
AS

-- =============================================
-- Author:		<Chris Hyde>
-- Create date: <09/21/2017>    
-- Modify Date: 
-- Description:	<Lists privilege groups for report parameters> 
-- =============================================

BEGIN

	SELECT
		Cat.UserCategory1,
		Cat.UserCategory2,
		Cat.UserCategory3,
		UserCategoryName =	CASE
								WHEN Cat.UserCategory3 = '40 - Manager'  			THEN 'Teller Managers'
								WHEN Cat.UserCategory3 = '40 - Full-Time'  			THEN 'Tellers FT'
								WHEN Cat.UserCategory3 = '30 - Three-Quarter Time'  THEN 'Tellers TQT'
								WHEN Cat.UserCategory3 = '20 - Part-Time'  			THEN 'Tellers PT'
								WHEN Cat.UserCategory3 = 'Managers'  				THEN 'eServices Managers'
								WHEN Cat.UserCategory3 = 'eLender'  				THEN 'eLender'
								WHEN Cat.UserCategory3 = 'Call Center Rep I'  		THEN 'Call Center Rep I'
								WHEN Cat.UserCategory3 = 'Call Center Rep II' 		THEN 'Call Center Rep II'
								WHEN Cat.UserCategory3 = 'eServies SME'  			THEN 'eServies SME'
								WHEN Cat.UserCategory3 = 'Universal Associate'		THEN 'Universal Associate'
								WHEN Cat.UserCategory3 = 'Receptionist/Greeter'		THEN 'Receptionist/Greeter'
								ELSE Cat.UserCategory2
							END,
		UserCategoryNameSort =	CASE
									WHEN Cat.UserCategory3 = '40 - Manager'  			THEN 0
									WHEN Cat.UserCategory3 = '40 - Full-Time'  			THEN 1
									WHEN Cat.UserCategory3 = '30 - Three-Quarter Time'  THEN 2
									WHEN Cat.UserCategory3 = '20 - Part-Time'  			THEN 3
									WHEN Cat.UserCategory2 = 'FSR'  					THEN 4
									WHEN Cat.UserCategory3 = 'Managers'  				THEN 5
									WHEN Cat.UserCategory3 = 'eLender'  				THEN 6
									WHEN Cat.UserCategory3 = 'Call Center Rep I'  		THEN 7
									WHEN Cat.UserCategory3 = 'Call Center Rep II' 		THEN 8
									WHEN Cat.UserCategory3 = 'eServies SME'  			THEN 9
									WHEN Cat.UserCategory3 = 'Universal Associate'  	THEN 10
									WHEN Cat.UserCategory3 = 'Receptionist/Greeter'  	THEN 11
									ELSE 12
								END
	FROM
		ARCUSYM000.arcu.vwARCUUserCategory Cat
	WHERE
		Cat.UserCategory1 = 'Employees'
		AND
		Cat.UserCategory2 IN ('Tellers', 'FSR', 'Inactive', 'eServices', 'Member Services')
	GROUP BY 
		Cat.UserCategory1,
		Cat.UserCategory2,
		Cat.UserCategory3
	ORDER BY 
		UserCategoryNameSort,
		UserCategoryName;

END;
GO
