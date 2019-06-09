# Initial Impressions Of My First Dev Job

## Technical Side

There's a few technical process-oriented bits I have learned while interacting with a big codebase that I did not use when I was solo developing small projects. I'll be using the coding academy that I attended, Lambda School, as a basis of comparison.

### IDE Shortcuts

Webstorm and Visual Studio (Resharper) has a shortcut CTRL-SHIFT-N to find files in a project. Been doing a lot of that to track down which file is responsible for a piece I am working on in the application. CTRL-B finds the declaration of a function, and I have been making a lot of use of that! I believe in VS Code it's F12 for going to the declaration.

It seems that because most of Lambda's projects were small codebases that I knew in and out, that there was little necessity for those shortcuts. Now that the codebase is enormous and nearly all of it was not written by me, it's extremely helpful to be able to jump around and find declaration and usages.

Likewise, shortcuts for refactoring and bulk renaming have been useful. 

### Breakpoints in Dev Tools

Breakpoints in Dev Tools to debug problems. Extremely helpful to walk through the program flow. Despite using breakpoints frequently when programming in Python, I ended up using a lot of console.log() for projects at Lambda School. It seems like it might just have been my cohort--other cohorts seem to use a mix of them.

### Network Tab in Dev Tools

Looking in the network tab would have helped a lot for the Build Week that I participated in. Can look at tokens being sent out, POST requests, compare POSTs of logins to websites with how a different microservice handles Single Sign On (SSO) to debug, intercept requests being sent out. Very helpful for certain kinds of debugging tasks.

There's also a free tool called Fiddler for looking at network traffic in-depth. 

### Observables

Rxjs observables. We did a lot of work with promises at Lambda but never talked about the concept of an observable, or a publish-subscribe pattern. I doubt that it would have been helpful to go over design patterns at Lambda, since design patterns mostly come in through one ear and fall out the other for me if I am not actively working on something where I can see them repeatedly.

Lambda's curriculum is already pretty extensive so I don't know that it's necessary to extend it, but it was interesting that observables are so frequently used in the codebase at my job and I'd never even heard of the term.  

## Non-Technical Side

There's probably a thousand Medium articles on how important soft skills are, so I won't rehash any of that here. 

Instead, I'd like to point out the few things I've noticed that are unique to software engineering (at least in my experience).

### Hands-Off Manager

I'm part of a team of 7 people and we have a sister team of another 6 people. Both teams report to one manager. He's never told me what to do so far that I've worked here, which is extremely different to my experience as a chemist in pharma. 

Our team meets with the product managers every two weeks during our retrospective and planning to add user stories to our current sprint. We discuss requirements and clarify as a team, and work on those user stories and defects throughout the two weeks. We can pull things in from the backlog if we finish up faster than expected. 

It's very cool to see how efficient and autonomous the software developers are. I imagine there is a lot of work and cultivation that goes into crafting a team like this. At my vantage point, it is unclear whether this is a product more of the process or of the excellence of the team members, but I have a few ideas...

### Meetings Stay Focused

I've noticed that during standups or other meetings, my manager or a more senior software engineer will make sure the meeting stays on task. Discussions that start drifting off-task get politely shut down and scheduled for a later time between the relevant individuals. I think that keeping this culture is extremely important to avoiding the dredge and drone of an overly long meeting where 75% of the folk there are aching to get back to work. 

### Code Review

Different companies may all do code review differently. At this company, it is done through a daily meeting where developers with code to show will project it and then go through it. Other developers ask questions and make comments about the code. 

Some developers are more likely to chime in than others, and it's interesting to see how different folks have different preferences. For example, preferences for reducing nesting, putting return statements into if conditionals, when to break out a piece of logic into a separate function, static methods, structure of the unit test file, smart vs dumb components, variable naming, and it goes on. 

I really appreciate getting to see a wider range of opinions that can all be translated into pretty good code. 

### The Balance Between Addressing Tech Debt vs New Features

New features are shiny and keep both the company leaders and the customers excited and happy. Tech debt in the form of confusing code and defects are mostly an invisible work unless it is something breaking. 

It seems like a 100% focus on new features usually accumulates suffering in regards to the codebase's maintainability long-term, and likewise a strict focus on cleaning up all tech debt before writing new features results in stagnation and the sense that nothing's being done. 

So then, what's the right middle ground? 

At my current place, there's a goal of 20% to 40% time spent on addressing bugs and tech debt, while still building new features to stay ahead of the competition. I picture that if a business was a startup, they'd want to focus mostly or even entirely on new features, and if a business was wrapping up a product and no longer supporting it, maybe a final push on the bugs then stopping additional code-cleaning would make sense. So different stages of a company's growth affects the balance between this. 

### Conclusion

I am excited for more work involving a large codebase. It's been a lot of fun getting exposed to so many concepts and preferences. 

I'm very curious to see how the team dynamics at my current job change as we grow. There's a lot out there to learn and I hope to keep up. 