# Browser Behavior Discrepancy on Checkboxes in Angular Reactive Forms

Chrome and Firefox versus IE and Edge. 

I noticed a discrepancy on how these browsers treat checkboxes when using Angular's reactive forms. 

I had a form, inside which was a label linked to a checkbox input. The starting state of the checkbox was checked. There was an input number box that would be disabled if the checkbox was checked, and when the checkbox was unchecked, it would be enabled. 

```
CHECKED?   Value inside criteria to call writeValue with

True           Empty array [] 

False         { id: LibraryKey.Awesome, awesomeValue: '0'}

```

```
<form [formGroup]="formGroup" class="awesome-control">
    <label for="awesomeCheckBox" *ngIf="!formGroup.disabled">
        <input style="display: none;"
               id="awesomeCheckBox"
               type="checkbox"
               formControlName="awesomeCheckBox"
               (click)="toggleInput()">
```

Initially we had it set up like so:

```
    toggleInput(): void {
        const newValue: AwesomeFormValue[] = [{
            criteria: this.awesomeCheckBox.value
                ? [ { id: LibraryKey.Awesome, awesomeValue: '0'} ]
                : [],
        }];
        this.writeValue(newValue);
    }
```

That when this.awesomeCheckBox.value was true, we would show that value 0 because the check for whether it was true or not was happening prior to the click. So if the checkbox was currently checked (true) and we clicked it to set it to false, it seemed to check prior to the click and set the value to value 0 and then the checkbox would appear false. Hence we would have the correct correspondence of "False" checkbox with awesomeValue: 0. 

Then we discovered that in IE and Edge, this failed because it was checking the truth status after the click. So if the checkbox was currently checked and we clicked it to set to false, it checked after the click and would see that checkbox was false, and would incorrectly choose to writeValue the criteria with empty array. 

IE and Edge's behavior here seems a bit more sensible than Chrome and Firefox but either way there was a discrepancy. 

So I found that wrapping it in a setTimeout of 0 would make Chrome and Firefox have the same behavior as IE and Edge. 

```
    toggleInput(): void {
		setTimeout(() => {
			const newValue: AwesomeFormValue[] = [{
				criteria: this.awesomeCheckBox.value
					? [ { id: LibraryKey.Awesome, awesomeValue: '0'} ]
					: [],
			}];
			this.writeValue(newValue);
		}, 0);
    }

```

However, this looks hacky. 

Looking over at some official Angular code, you can see that Angular passes the $event into the function that's handling the change. 

https://github.com/angular/angular/blob/master/packages/forms/src/directives/checkbox_value_accessor.ts

That's so much nicer-looking. It's reminiscent of vanilla JS and some common React code in passing in the event (or the SyntheticEvent in the case of React). Let's do that. 

The markup:

```
<form [formGroup]="formGroup" class="awesome-control">
    <label for="awesomeCheckBox" *ngIf="!formGroup.disabled">
        <input style="display: none;"
               id="awesomeCheckBox"
               type="checkbox"
               formControlName="awesomeCheckBox"
               (click)="toggleInput($event.target.checked)">
```

The TypeScript file:

```
    toggleInput(isChecked: boolean): void {
        const newValue: AlertSubscriptionFormValue[] = [{
            alertTypeId: AlertType.Idle,
            subscriptionCriteria: isChecked
                ? []
                : [ { alertOptionKeyId: AlertOptionKey.IdleDuration, alertValue: '0' } ],
        }];

        this.writeValue(newValue);
    }
```

Now we have the desired functionality, with a much less hackier-looking fix.