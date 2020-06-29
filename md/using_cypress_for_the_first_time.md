# Using Cypress for the first time

Cypress is a front-end e2e/e2m (end-to-end, end-to-middle) and integration testing framework. It lets you write tests that mimic user interaction with your web application running in a browser.
It shows information about GET and POST requests made at each point of interaction and you can stub what response should come back from a particular request type to a matching url.

In the application I've been working on there are ways for users to connect to different types of databases with credentials and save/load specific data from them. We use Cypress to
do some of these user action sequences and make sure the UI is displaying the stub data as expected.

The main benefit of Cypress is that you can dictate what ideal or edge case scenarios might be by laying out the user interaction steps and controlling network responses, and test that the UI outcome is as expected.
For example, after someone clicks a button on the UI to kick off a process, maybe that button should get grayed out.

```
describe('When button is clicked', function() {

  it('Sends the foo and grays out the button', function() {
    setUpRoutes();
    cy.visit('/');

    // open menu, verify button is enabled
    selectors.getMenu().click();
    selectors.getButton().not('.aria-disabled').should('exist');

    // click button
    selectors.getButton().click();

    // complete dialog
    selectors.getDialog().click();

    // verify button is disabled afterwards
    selectors.getMenu().click();
    // see [should syntax](https://docs.cypress.io/api/commands/should.html#Syntax)
    selectors.getButton().should('have.attr', 'aria-disabled', 'true');
  });
});

// Selectors file
export const selectors = {
  getMenu: () => cy.get('[test-id="Process-Menu"]'),
  getButton: () => cy.get('[test-id="Process-Button"]'),
  getDialog: () => cy.get('[test-id="Process-Dialog"]'),

}
```

## Cypress Routes

So the previous example was pretty simple--it was just some UI behavior, no http requests changing display of data on the UI.

But like I mentioned one of the big benefits from Cypress is the stubbing out of responses that should come from APIs that are called.
Let's say the application makes a call to `https://localhost:8080/loc/efb57/proj` where `efb57` could be any string. We can first start the Cypress server by calling `cy.server()`, then we can specify the route matching with
`cy.route('GET', 'loc/**/proj', 'fixture:common/projects.json')`.

The first parameter is the type of request, the second is the url matching, and the third is the response, connected via cy.fixture() in a string format where I have a folder /common/ that contains a file called projects.json that has my response.

Now when the application makes a call to the url that matches the second parameter, it'll get back the json file I put in and I can test what I expect to occur if it gets that file (UI should display data accordingly, error message for sad cases, etc).

## Cypress resets cy.server() after each test case

So the codebase I was in had a function that would set up some routes like so:

```
const serviceX = 'coolService/api/';
const serviceY = 'api/anotherService/info';

export function setUpRoutes() {
  cy.server();
  cy.route('GET', serviceX + 'userSession/current', 'fixture:common/sessions.current.json').as('currentUserSession');
  cy.route('GET', serviceY + 'loc/**/proj', 'fixture:common/projects.json').as('projects');
}
```

I thought if I just slapped my route for my test in there that I'd be good to go.
I was not good to go.

Somehow I assumed I just had to run the function once in a before block like

```
before(() => {
  setupRoutes();
  // other stuff
});
```

And then I'd have all my routes set up so that I could run my tests. Instead, what happened was that watching my Cypress run, I saw the real XHR (XmlHttpRequest) show up instead of the XHR stub from Cypress.

So I struggled around with my tests for a little while reordering things until I realized I have to start `cy.server()` and set up routes again. So putting it inside of a beforeEach solved my confusion.
[Cypress documentation](https://docs.cypress.io/api/commands/server.html#Notes) says this here:

```
Server persists until the next test runs
Cypress automatically continues to persist the server and routing configuration even after a test ends. This means you can continue to use your application and still benefit from stubbing or other server configuration.

However between tests, when a new test runs, the previous configuration is restored to a clean state. No configuration leaks between tests.
```

Could have saved myself some time if I'd scrolled down more.
