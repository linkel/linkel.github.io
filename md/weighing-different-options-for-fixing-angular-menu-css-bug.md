Journeying all over the place

Bug where the context menu in Spanish had a line that was much longer than the English variant, so it fell off the screen on mobile. 

Possible options:

1. Dynamically style it
2. Keep menu right aligned and move the button over to be closer
3. Word wrap

The first option appealed to me on a fun technical level. 

I looked at the dynamic styling, had to look into Breakpoint observer, but found out we had a UserDeviceService that had an isMobile() function to check if it matched our application. 

Initial edit of the HTML:

```
<div *ngIf="showMoreActionsContextMenu" [ngStyle]="{'left' : pixelsStyleLeft}" class="action-bar-item__more-actions__context-menu">
        <context-menu [menuItems]="actionMenuItems"
                      [textAlign]="ContextMenuTextAlign.LEFT"
                      [placement]="ContextMenuPlacement.BOTTOM_RIGHT">
        </context-menu>
</div>
```

```
 private calculateContextMenuPosition(): void {
        this.breakpointObserver
            .observe(['(max-width: 415px)', '(orientation: portrait)', '(max-width: 813px)', '(orientation: landscape)'])
            .subscribe((state: BreakpointState) => {
                if (state.breakpoints['(max-width: 415px)'] && state.breakpoints['(orientation: portrait)']
                || state.breakpoints['(max-width: 813px)'] && state.breakpoints['(orientation: landscape)']) {
                    const lengthArray = this.actionMenuItems.map(item => item.label.length);
                    const longest = Math.max(...lengthArray);
                    const result = this.leftPixelsStartingFromZero - longest * this.pixelsPerCharacter;

                    this.pixelsStyleLeft = result + 'px';
                } else {
                    this.pixelsStyleLeft = 'none';
                }
            });
    }
```

Refactored to use UserDeviceService and early return from the if:

```
    private calculateContextMenuPosition(): void {
        if (!this.userDeviceService.isMobile()) {
            this.pixelsStyleLeft = 'none';
            return;
        }
        const lengthArray = this.actionMenuItems.map(item => item.label.length);
        const longest = Math.max(...lengthArray);
        const result = this.pixelLeftWhenZeroCharacters - longest * this.pixelsPerCharacter;

        this.pixelsStyleLeft = result + 'px';
    }
```

Now it dynamically decides its width based on how many characters are inside the item! 

[pic of dynamic sizing doodle]

But thinking about it, it felt like a solution that was troublesome to maintain. We didn't really do this anywhere else in our services much. Furthermore, I really should not be looking at the character number, but the actual width of it once it is rendered on the DOM, since text size would make a difference. That would require rendering the element, hiding it, measuring its width, then adjusting the width and then displaying it. Now it's starting to look like too much code for a visual defect. If I could treat all languages exactly the same instead of making some calculation out of the length, that'd be preferable. 

So instead, the second option was to move the action bar item button so that it's more centered/to the right, and keep the context menu always right aligned. Then everything gets the same treatment. One of the senior engineers thought this was the best for maintainability, and I agreed. Easy peasy, just add a justify-content: center!

[picture here of the action bar buttons now centered]

But the excitement didn't end. Another team member was working on a new feature that would add an extra button to the menu. With the item button now set to be centered instead of left aligned, it caused the buttons to look misaligned on mobile, since there was only space for two buttons per line. The original left-alignment looked much better on mobile, so my change was suboptimal. I went back to try the third option: word wrapping the context menu items. 

In the action-bar, which uses the context menu, the important change would be passing in a string value that would indicate the maximum width before wrapping. Once we hit this width we would want to activate wrapping styling.

```
            <div *ngIf="showMoreActionsContextMenu" class="action-bar-item__more-actions__context-menu">
                <context-menu [menuItems]="actionMenuItems"
                              [textAlign]="ContextMenuTextAlign.LEFT"
                              [placement]="ContextMenuPlacement.BOTTOM_RIGHT"
                              [maxWidthBeforeWrap]="contextMenuMaxWidth">  <---- the new bit
                </context-menu>
            </div>
```

I wandered over to the project where the context menu lived. In the context menu's html, I added a line where the ngStyle would apply a max-width if it got a maxWidthBeforeWrap, and would apply normal or nowrap of white-space if there was a maxWidth provided. 

```
        <ng-container *ngFor="let item of menuItems">
            <li class="context-menu__list__item"
                *ngIf="item.show"
                [ngStyle]="{'max-width': maxWidthBeforeWrap, 'white-space': maxWidthBeforeWrap ? 'normal' : 'nowrap'}"
                [ngClass]="{
                    'context-menu__list__item--disabled': !item.enabled,
                    'context-menu__list__item--selected': item.selected,
                    'context-menu__list__item--dark': colorScheme === ContextMenuColorScheme.DARK,
                    'context-menu__list__item--selected--dark': item.selected && colorScheme === ContextMenuColorScheme.DARK}"
                (click)="item.enabled && item.action()">
                {{item.label}}
            </li>
        </ng-container>
```

This meant that I would add a new @Input() that was the maxWidthBeforeWrap to the class.

```
export class ContextMenuComponent implements OnInit {
    @Input() menuItems: ContextMenuItem[];
    @Input() textAlign: ContextMenuTextAlign;
    @Input() placement: ContextMenuPlacement;
    @Input() colorScheme: ContextMenuColorScheme = ContextMenuColorScheme.LIGHT;
    @Input() maxWidthBeforeWrap?: string;
```

Also added some new tests--for when there was a maxWidthBeforeWrap and when there wasn't. 

```
    describe('When context menu component is initialized with a maxWidthBeforeWrap value', () => {
        beforeEach(() => {
		// we have some other things going on in the context menu being tested, which needs what the function below is setting up
            setComponentValues(expectedMenuItems, 'left', undefined, undefined, expectedMaxWidthString); 
        });

        it('sets the max-width on the context menu items to the provided value', () => {
            TestHelper.assertElementHasStyle(componentElement, '.context-menu__list__item', 'max-width', '200px');
        });

        it('sets the white-space on the context menu items to normal', () => {
            TestHelper.assertElementHasStyle(componentElement, '.context-menu__list__item', 'white-space', 'normal');
        });
    });
```

Now we consume the changes in our front-end, action bar component!

```
            <div *ngIf="showMoreActionsContextMenu" class="action-bar-item__more-actions__context-menu">
                <context-menu [menuItems]="actionMenuItems"
                              [textAlign]="ContextMenuTextAlign.LEFT"
                              [placement]="ContextMenuPlacement.BOTTOM_RIGHT"
                              [maxWidthBeforeWrap]="contextMenuMaxWidth">
                </context-menu>
            </div>
```

And make sure to update our mock for the context menu. 

```
export class ContextMenuComponentMock {

    @Input() menuItems: ContextMenuItem[];
    @Input() textAlign: ContextMenuTextAlign;
    @Input() placement: ContextMenuPlacement;
    @Input() colorScheme: ContextMenuColorScheme;
    @Input() maxWidthBeforeWrap: string;

    constructor() {}
}
```

And now the items inside of the context menu wrap. 

Conclusion: sometimes the most preferred solution changes if teammates are working in areas that are affected by the solution, and one must accept that sometimes work will have to be redone. There's a balance between maintainability and how a decision affects other areas of an application. 

