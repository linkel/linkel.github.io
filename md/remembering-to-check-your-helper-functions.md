## Remembering to check your helper functions. 

Let's say I have an app that displays bundles of lifting session videos. Lifters who lift in this special power cage in the gym will have automated video taken of their lifts. Each training session of video will go into these bundles of videos. Each video can have the lifter reassigned (if identification of the lifter was mistaken), or can have the club reassigned (if the lifter is in a specific team or club) if the user has edit permissions for those actions. 

Now, a new feature has been added where coaches can notify lifters to check out bundles of video here to see what aspects of their form could be improved. 

In a specific view of this app, there's a menu for each of these bundles that has the options for reassigning the lifter or the club--and now, I've added the ability to notify a lifter here too in the same menu.

Previously my hypothetical app only allowed any of these functionalities if there was a single video. That is, a bundle contained only one video. If a bundle contained multiple videos of different lifts, the reassigning lifter or club button was not present in a menu (let's be vague and chalk it up to specific permissions edge cases). Since we're adding this new feature for notifying, we want to make it so that lifters can be notified to watch every single video on the bundle, so bundles with multiple videos now will have the notify button (assuming they have the permission to notify them). 

Here we are writing tests in TypeScript, making use of Jasmine and Karma.

While I was writing tests, we already had this describe:

```
describe('When LiftingVideoContentComponent is initialized', () => {

        beforeEach(async () => {
            setupStubData();
            setupMocks();

            await createTestFixture(expectedBundle);
        });
```
		
where setupStubData() had:

```
function setupStubData(): void {
        expectedSingleVideo = new LiftingVideoViewModelStub({
            videoId: 'SQUAT_1_ID',
            recordDateUtc: '2019-04-19T21:22:41.379Z',
            recordDateTz: 'PST',
            groupName: 'West Coast Powerlifting Club',
        });

        expectedSingleVideoBundle = new LiftingVideoBundleStub({videos: [expectedSingleVideo]});
		
// in this example, our LiftingVideoBundleStub contains by default five lifting videos
        expectedMultipleVideosBundle = new LiftingVideoBundleStub({});
    }
```

And inside the while LiftingVideoContentComponent is initialized describe block, we write testing code meant for if the bundle has a single video:

```
describe('And the bundle has a single video', () => {
```

Since previously when the bundle had multiple videos, there weren't any available buttons in the menu, there weren't any tests for checking combinations of buttons present in the menu. Now we do want multiple videos to have the one button to "Notify Lifter". 

In my tests, I am using a mock of our permissions service. We have permissions to control who gets to reassign lifters or clubs, and now a new permission that controls whether a user can notify a specific lifter. 

```
function setPermissions(reassignLifterPermission: boolean, reassignClubPermission: boolean, notifyLifterPermission: boolean): void {
	mockPermissionsService
		.hasPermission.and.callFake((permission: PermissionKeys, groupId: string) => {
			switch (permission) {
				case PermissionKeys.VIDEO_LIFTER.EDIT:
					return reassignLifterPermission;
				case PermissionKeys.VIDEO_CLUB.EDIT:
					return reassignClubPermission;
				case PermissionKeys.VIDEO_LIFTER.NOTIFY:
					return notifyLifterPermission;
				default:
					throw new Error('No valid permissions passed in');
			}
	});
	createFixtureAndDetectChanges(expectedSingleVideoBundle);
}
```

We use this createFixtureAndDetectChanges function to set up the test fixture after changes have been made that will affect which menu options will display. 

Basically, after configuring the testing module, setting up declarations and providers and imports at the start for the testing, this function would usually be called. 

```
function createFixtureAndDetectChanges(bundle: LiftingVideoBundle) {
	fixture = TestBed.createComponent(LiftingVideoContentComponent);
	fixture.componentInstance.bundle = bundle;
	// displayOptions controls whether any options would be displayed at all, since these components are reused elsewhere in contexts where it wouldn't make sense to be able to edit properties
	fixture.componentInstance.displayOptions = true; 

	componentElement = fixture.debugElement;

	fixture.autoDetectChanges(true);
}
```
	
where componentElement is described in the top describe block as:

```
	let fixture: ComponentFixture<LiftingVideoContentComponent>,
	componentElement: DebugElement;
```

So createFixtureAndDetectChanges sat at the end of setPermissions so that it wouldn't need to be rewritten repeatedly inside the testing code, since the testing code would constantly be changing the permissions to make sure the right menu options were displaying. 

When I set up my describe block for testing when the bundle had multiple videos...

```
describe('And the bundle has multiple videos', () => {
	beforeEach(async () => {
		await resetTestFixture();
		await createTestFixture(expectedMultipleVideosBundle);
	});
	
	describe('And the user has reassign lifter and reassign club permissions and notify lifter permission', () => {

		beforeEach( () => {
			setPermissions(true, true, true);
		});
		
		it('should only show notify lifter button', () => {
					expect(filterDisplayedMenuItemByLabel(contextMenu, 'Reassign Lifter').length).toBe(0);
					expect(filterDisplayedMenuItemByLabel(contextMenu, 'Reassign Club').length).toBe(0);
					expect(filterDisplayedMenuItemByLabel(contextMenu, 'Notify Lifter').length).toBe(1);
		});
		
	)};
});
```	
		
My test failed! 

I was pretty puzzled. I set breakpoints in Chrome. I stepped through and the check occurring in my code that looked at if the bundle's elements length was 1 to toggle the showing of the option was working. But I did notice that it was flipping through the check multiple times. I expected it to go through the check for an element length equal to 1 one time because of the top level describe block, then go into a check where the element length would be equal to 5 (my default multiple video stub). Instead it was hitting a length 1 check, my length 3 check, and then a length 1 again before actually running the test, and would then promptly fail. 


It turned out that it was this line here, in my setPermissions.

```
createFixtureAndDetectChanges(expectedSingleVideoBundle);
```

It would always restart the fixture using a single video bundle instead of the multiple one. 

It took me too long to catch it because I had assumed my helpers were functioning the way I envisioned them to be, and was looking in the describe blocks incessantly thinking there was something mysterious about await fixture.whenStable() or any of the other await functions sitting around. 

So it seems like these are a few useful heuristics when debugging code in a large codebase:

1. Breakpoint through your component and the spec file.
2. If you have booleans that are calculated from many ANDs that rely on function results, set them to const variables to be able to hover over them in Chrome and see their value. 
3. If an action is happening more times than you expect, think about why it is! Don't ignore it and chalk it up to vague thoughts on asynchronous flow.
4. Double check your helper functions. Don't get suckered into thinking it does what it says on the label. 
5. Make sure you're await-ing something that needs to get awaited, if you're working with async processes.