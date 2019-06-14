# Conditionally Styling Components and Host Elements in Angular 7

## Conditionally Set a Style Value Depending On a Property

Let's say I added some new features to an application and didn't think too much about spacing. And consequently I discover that two types of customized dropdown components I have are now jutting out beyond the page. Having the dropdowns all drop upwards doesn't make me feel happy, so I would like to make some changes to these components so that the maximum height on the window that opens up when the component is clicked can be customized by its `@Input`. 

Right now the parent component looks like:

```
	<dropdown [formControlName]="myControlKey"
			  [items]="awesomeDropdownItems"
			  [placeholderLabel]="Select Awesome Type">
	</dropdown>
```

And I want to be able to provide it an extra input of height:

```
	<dropdown [formControlName]="myControlKey"
			  [items]="awesomeDropdownItems"
			  [placeholderLabel]="Select Awesome Type"
			  [height]="'150px'">
	</dropdown>
```

In my class, I consequently add a new @Input with a default of whatever the CSS was previously:

```
export class DropdownComponent implements OnInit, OnChanges, AfterViewInit, ControlValueAccessor {

    @Input() items: DropdownItem[];
    @Input() placeholderLabel?: string;
    @Input() height = '200px'; // <--- my new input!
	
```

Then in my list that pops open when the dropdown component is clicked, I want to bind to the style property of that element. 

Previously, it had an ngClass applying an expanded or a collapsed class depending on whether the variable `expanded` was present. 

```
<ul [ngClass]="{'dropdown-expanded': expanded, 'dropdown-collapsed': !expanded, 'dropUp': dropUp}">
```

Since this is all nicely set up, all I have to add is:

```
<ul [style.max-height]="expanded ? height : '0'" [ngClass]="{'dropdown-expanded': expanded, 'dropdown-collapsed': !expanded, 'dropUp': dropUp}">
```

This ternary conditional expression then applies the max-height that I want from the input onto this element. I then remove the previous CSS styling that was in the dropdown-expanded and dropdown-collapsed class that affected the max-height, since it is now redundant and will always be overridden. 

## Conditionally Set a Style Value on a Host Element

I mentioned that I had two custom dropdown components! The second one is a fancier one--it's a a typeahead input that allows multiple selection. So a user can type part of what they're looking for, and it has checkboxes that permit selection of multiple items. Because of the way the component was consequently written, the element that I was looking to enable a `height` customization on was actually a host element of the actual component (which was also split into several parts and a directive itself).

Instead of adding a ternary conditional into HTML markup, I had to add in the Angular style property binding into the @Component decorator.

```
@Component({
    selector: 'typeahead-window',
    exportAs: 'TypeaheadWindow',
    styleUrls: ['../typeahead-directive/typeahead.scss'],
    host: {
		'class': 'typeahead-dropdown-menu', 
		'role': 'listbox', 
		'[id]': 'id', 
		'[style.max-height]': 'height'}, // right here is where I add in the height variable
	... // ng-template removed to focus on the above
  `
})
export class TypeaheadWindow implements OnInit {
...
```

Then, like for the previous dropdown component, I connected the plumbing as appropriate to enable the component to take a new @Input. 

Finally, don't forget to update the mocks! Otherwise you can be like me and see 55 tests fail with some variant of 

```
    [ERROR ->][height]="'150px'">
			</dropdown>
		</div>
		Error: Template parse errors:
		Can't bind to 'windowMaxHeight' since it isn't a known property of 'dropdown'. 
```