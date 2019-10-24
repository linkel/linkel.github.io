This one's a small tidbit of a mistake I made.

I was using NUnit for testing a data access layer in my application. This area of interest makes a database update to a row after a different service finishes a process and gives me back the id via a message (brokered by RabbitMQ). 

I quickly wrote up the data access test since it was just going to be a matter of:

1. Make a new row in the decision table on the database with an known Guid that I generate
2. That row's evalId is NULL at first
3. Use the real system's UpdateDecisionWithEvalId to update it
4. Check that the row with the known Guid now has the new evalId

At this point the code looked like this:
	
```
	[TestFixture]
    public class EvalBackfillDataAccessTests
    {
        private IEvalBackfillDataAccess _sut;
        private Guid _expectedDecisionId;

        [SetUp]
        public void Setup()
        {
            _expectedDecisionId = Guid.NewGuid();
            AddDecision(_expectedDecisionId); // A function that creates a new row in our decision table in the database
            _sut = TestBootstrapper.Container.GetService<IEvalBackfillDataAccess>();
        }

        public class WhenUpdateDecisionWithEvalIdIsCalled : EvalBackfillDataAccessTests
        {
            [Test]
            public void Task It_updates_the_decision_with_the_eval_id()
            {
                var evalId = Guid.NewGuid();
                _sut.UpdateDecisionWithEvalId(_expectedDecisionId, evalId);
                var expectedEvalId = GetEvalIdByDecisionId(_expectedDecisionId);
                Assert.AreEqual(expectedEvalId, evalId);
            }
        }

        [TearDown]
        public void Cleanup()
        {
            DeleteDecision(_expectedDecisionId);
        }
```

Where the Add and DeleteDecision methods look like:

```
	internal static int AddDecision(Guid decisionId)
	{
		using (var conn = new SqlConnection(TestBootstrapper.DBConnectionString))
		{
			conn.Open();
			using (var cmd = new SqlCommand(string.Format(AddDecisionSql, decisionId), conn))
			{
				return cmd.ExecuteNonQuery();
			}
		}
	}

	internal static int DeleteDecision(Guid decisionId)
	{
		using (var conn = new SqlConnection(TestBootstrapper.DBConnectionString))
		{
			conn.Open();
			using (var cmd = new SqlCommand(string.Format(DeleteDecisionSql, decisionId), conn))
			{
				return cmd.ExecuteNonQuery();
			}
		}
	}
```

And the sql is pretty straightforward. Won't show the add since there's a lot of different data that gets added but the delete was like:

```
	private const string DeleteDecisionSql = @"
		delete from [myschema].[Decision] where DecisionId = '{0}'";
```
		
I ran the test and it failed with a:

```
System.InvalidCastException : Unable to cast object of type 'System.DBNull' to type 'System.Guid'
```

Why? 

I had a brain fart and forgot to await the system under test's call! It's making a database call and needs to update that row, but since I forgot to wait around for that update to finish my sql query in the next line immediately runs and of course it's null. A simple asynchronous mistake.

Glad it wasn't anything more complicated than that. 

End result:

```
	[Test]
	public async Task It_updates_the_decision_with_the_eval_id()
	{
		var evalId = Guid.NewGuid();
		await _sut.UpdateDecisionWithEvalId(_expectedDecisionId, evalId);
		var expectedEvalId = GetEvalIdByDecisionId(_expectedDecisionId);
		Assert.AreEqual(expectedEvalId, evalId);
	}

```