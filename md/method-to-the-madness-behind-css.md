# There's Method To the Madness Behind CSS

I made a new Angular component whose SCSS file ended up looking like so:

```
.super-button {

  cursor: pointer;

  &__content {
    display: flex;
    align-items: center;
    transition: opacity .5s linear;
  }

  &__active-description {
    color: $dark-text;
    font-weight: $bold-font;
    padding-left: 8px;
  }

  &__inactive-description {
    color: $dark-text;
    padding-left: 8px;
  }
}

.active {
  color: $input-selected;
}

.inactive {
  color: $input-selected;
  background-color: $input-background;
  border-radius: 100px;
}
```

The html file for this component consisted of a label tag wrapping some goodies inside.

```
<label class="super-button" for="{{SuperButtonId}}">
GOODIES INSIDE
</label>
```

Happy with this, I pushed this to our repo for UI components (a repo for general and reusable components) and then used it in a different repository for an application. I saw that there was an 8px margin-bottom for label tags that was caused by Reboot. This was undesirable because it did not match with the mockup that the UX team had come up with. 

So I slapped a quick 

```
label {
	margin: 0;
}
```

into that super-button CSS, since Angular separates out CSS for components by appending an `_ngcontent-something` to the class. But that didn't work, and I should have thought about that more! Why doesn't it work? 

The answer is...

CSS specificity! Using label like that was using a type selector, and Reboot was also using a type selector and apparently getting applied after my component so it'd overwrite what I had. 

Easy for me to say this now. At the time I was googling with phrases like `"margin css not getting overidden angular"` and looking at articles on Stack Overflow with names like `"How can I override Bootstrap CSS styles?"` and `"Can't override the angular theme with my css properties"`. I actually left off working on it on a Friday and worked on other components until I came back to it on Tuesday with a clearer head. 

So the solution was to use a more specific selector to apply my `margin: 0` desires. 

Conveniently, I had made a class selector already for that label! By adding:

```
.super-button {

  cursor: pointer;
  margin: 0; <------------------- right here

  &__content {
    display: flex;
    align-items: center;
    transition: opacity .5s linear;
  }

  &__active-description {
    color: $dark-text;
    font-weight: $bold-font;
    padding-left: 8px;
  }

  &__inactive-description {
    color: $dark-text;
    padding-left: 8px;
  }
}
```

I was able to get rid of that `8px margin-bottom`. 

There's a couple of takeaways for me here. 

First, I ought to do better with remembering selectors.

From weaker to stronger:

1. Type Selectors
2. Class Selectors
3. ID Selectors

Second, anything that seems unreasonable or insane in CSS is often just me not knowing the peculiarities of CSS sufficiently. It's therapeutic to throw my hands up and bemoan how illogical CSS looks, but I should keep in mind that most of the time it's a failure of understanding on my end. CSS is a many-tentacled beast because it's had to support a lot over the decades that it's existed. I'm merely a few years older than CSS myself.

That said, there's certainly times when libraries like Bootstrap, etc. will inadvertently clash with what a developer is trying to do due to naming or use of !important. In conclusion--it's complicated. 