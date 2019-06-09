# Daylight Savings Bug, and Check Your Network Requests

So let's say we have a date picker component. Using it, we can select a date range on a calendar of up to 180 days to pull up workouts belonging to different lifters with possible form issues in their squats and benches and deadlifts. These form issues get determined by some algorithm on the videos (like for bar path deviating significantly from an ideal path, knees buckling in til they nearly touch, lumbar spine curvature, etc). 

In this application we limit the date selection to 181 days, which is the 180 days plus today. Both the front end and the backend validate on this. The validator in the backend checks the start and end date and subtracts them to make sure that the difference is not more than 181 days. 

Our front end is written in Angular 2+ and the backend is C#. Here is the backend validation:

```
RuleFor(request => request.StartDate).NotEmpty().WithMessage(StartDateRequiredMessage);
RuleFor(request => request.EndDate).NotEmpty().WithMessage(EndDateRequiredMessage);
RuleFor(request => request).Must(req => req.StartDate <= req.EndDate).WithMessage(StartDateLaterThanEndDateMessage);
RuleFor(request => request).Must(req => (req.EndDate - req.StartDate).TotalDays <= 181).WithMessage(LessThan181DaysMessage);

```

We have another datepicker in another section of the application that does the same exact thing, but instead of looking at workouts with form tips it looked at special meetings that lifters would have with their coaches that would record information about what they discussed. Let's call the first one the Workout List Datepicker and the second one the Coaching Datepicker. 

A bug was reported for the Coaching Datepicker where the user could select the max range of dates allowed by this datepicker and yet get an error. Looking into the error revealed that it was failing at the `req.EndDate - req.StartDate.TotalDays <= 181.`

Playing around with the date range showed that it had to do with daylight savings time--specifically when one hour was added to a day in November. This meant that originally, subtracting the start date from the end date would always result in something 181 or less, because it would be 180 days permitted and including the current day. When DST was added to the picture, this meant that it would be 181 days plus an extra hour, and so it would fail to validate the model there. 

I was confused at why the first one was fine and the second one was having issues, since they do the same thing. 

I compared code in different areas of the application and was having quite a hard time finding out what was different. The validation was exactly the same. In the front end, it stored the date as an `ngbDateStruct` in both. 

I opened up Chrome's network tab and compared the requests. 

The failing one's query params: 
```
?groupIds=2bb2d9b4-c801-e111-81ce-e61f13277aab&selfGroupIds=&formIds=&lifterIds=&coachIds=&pageNumber=1&pageSize=10&startDate=2018-09-04T07:00:00.000Z&endDate=2019-03-04T08:00:00.000Z&sortDirection=desc
```

The working one's query params:
```
?videoGroupIds=2bb2d9b4-c801-e111-81ce-e61f13277aab&selfVideoGroupIds=&startDate=2018-9-4&endDate=2019-3-4&pageNumber=1&pageSize=10&triggerIds=&statusIds=&formIds=&gymIds=&lifterIds=&includeAllLifterAndCoachVideos=true&sortField=RecordDateLocal&sortDirection=desc
```

Wait a second...
The format of the date on the requests is different! 

In our failing one, the date format in the GET request query params looked like this:
```
&startDate=2018-09-04T07:00:00.000Z&endDate=2019-03-04T08:00:00.000Z
```

In the working one, the date format looked like this:
```
&startDate=2018-9-4&endDate=2019-3-4
```

So the failing one is in ISO format, and the working one truncates it to the day. If I had taken a couple more steps in investigating the front-end code, I would have seen that before the request was sent out, it does go through a conversion in a different component. 

```
const startDate = NgbDateHelper.ngbDateToISOString(req.startDate);
```

I had to get some history about how this came about. Turns out that the working one was written purposefully inaccurately because users would be viewing information for someone else potentially in another timezone, and they'd select the day that the person told them they had worked out, but not get the information because the timezone was off and technically it was an earlier or later day in the viewer's timezone. So implementing it inaccurately on purpose resulted in easier usability. When this inaccurate request gets to the backend, it's assumed to be at midnight by the validator so subtracting them always stays below 181 days. 

The accurate one would fail because 1 hour does get added to a day from daylight savings time. Our solution, then, was simply to edit the validator to 182 days. 

Helpful points for debugging:

1. Daylight savings time with adding and subtracting an hour in November and in March is something to keep in mind!
2. Look at the network tab in Chrome to check what the requests look like. Can also use Fiddler for more information. 
3. In a large codebase, check the services being called as well. Understand what happens at the interface between the front-end and the back-end. 