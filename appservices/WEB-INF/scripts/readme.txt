-----------------------------------------------------------------------------------------
GOAL: To aid in the task of creating a large number new users (for commercial use)
      by calling Regpro /user URL by leveraging webtest URL invoke mechanism
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ENVIRONMENT SETUP
	INSTALLATION:  Download Canoo webtest http://webtest.canoo.com/webtest/manual/Downloads.html
				   Extract to a local folder (e.g C:\webtest)
				   
	ECOMM CODE:    Grad webtest_ecomm from P4

TESTS SETUP
	ADD USERS ACCOUNT:  Open webtest_ecomm/properties/createusers.properties file
						For each new account add the following line with request numerated from 0 to the number of accounts we wish to create
							
						user_request0={"firstName":"Webtest","lastName":"User", "email":"lnguyen_92112_1@e.com", "password":"Test1234", "passwordConfirm":"Test1234","countryId":"10", "zipCode":"94403",  "occupationId":"1", "specialtyGroupId":"43", "primarySpecialtyId":"214"}
						
	UPDATE COUNT IN TEST FILE:  Open webtest_ecomm/issue/user.xml.  We need to update the loop count to reflect the number of users we specified in the createusers.properties file

						For example, the below example is trying to create 2 users.  We need to have user_request0 and user_request1 in createusers.properties.
						<repeat count="2">
							<invoke url="${user_url}" method="POST" content="${user_request#{count}}" />	
							<storeResponseCode property="status_code"/>
							<verifyProperty property="status_code"  text="${user_status_code}"/>		
						</repeat>
					
TESTS EXECUTE  
	Go to webtest_ecomm in the command prompt
	Execute:  webtest
	
	Webtest should automatically launch the results in the web browser after it's done.  Alternatively one can also see the results by going to webtest_ecomm/results/index.html
	