# Invalid React Hook Call with Enzyme Tests

`Hooks can only be called inside the body of a function component.`

I was getting this error with my enzyme unit tests after I had changed a React functional component to have some useMemo and useCallback functions wrapping a few variables.

Let's say my component looked like this:

```
export function SpecialIcon(props: IconProps): JSX.Element {
  const { origin, tooltipStyle, contentClass } = props;

  const iconTooltip = (
    <div className={contentClass}>Example Icon Very Cool</div>
  );

  return (
    <IconWithTooltip
      renderButton={showTooltip => (
        <ButtonWidget
          testId='special-icon'
          onMouseOver={showTooltip}
        >
          <SvgSpecialIcon />
        </ButtonWidget>
      )}
      tooltipContent={iconTooltip}
      tooltipDelay={0}
      tooltipStyle={tooltipStyle}
      origin={origin}
    />
  );
}
```

And I wanted to memoize and only render when changes have occurred, so I changed it to:

```
export function SpecialIcon(props: IconProps): JSX.Element {
  const { origin, tooltipStyle, contentClass } = props;

  const iconTooltip = React.useMemo(
    () => {
      return (
        <div className={contentClass}>Example Icon Very Cool</div>
      );
    },
    [contentClass]);

  const renderButton = React.useCallback(
    (showTooltip: () => void) => {
      return (
        <ButtonWidget
          testId='special-icon'
          onMouseOver={showTooltip}
        >
          <SvgSpecialIcon />
        </ButtonWidget>
      );
    },
    []
  );

  return (
    <IconWithTooltip
      renderButton={renderButton}
      tooltipContent={iconTooltip}
      tooltipDelay={0}
      tooltipStyle={tooltipStyle}
      origin={origin}
    />
  );
}
```

Pretty straightforward usage of useMemo and useCallback. Worked fine when manually testing.

My tests looked something like this:

```
describe('SpecialIcon Tests', () => {
  const props: ChangeTypeDisplayIconProps = {
    [other prop stuff omitted]
    contentClass = 'testClass'
  };

  it('mounts', () => {
    withComponent(SpecialIcon(props), wrapper => {
      expect(wrapper.find(SvgSpecialIcon).length).toBe(1);
    });
  });

  it('displays the tooltip when hovered over', () => {
    withComponent(SpecialIcon(props), wrapper => {
      const buttonWrapper = wrapper.find(ButtonWidget);
      const tooltipBeforeHover = wrapper.find('.testClass');
      expect(tooltipBeforeHover.exists()).toBe(false);
      buttonWrapper.simulate('mouseover');
      const tooltip = wrapper.find('.testClass');
      expect(tooltip.exists()).toBe(true);
    });
  });

  it('displays information about the icon in the tooltip', () => {
    withComponent(SpecialIcon(props), wrapper => {
      const buttonWrapper = wrapper.find(ButtonWidget);
      buttonWrapper.simulate('mouseover');
      const tooltip = wrapper.find('.testClass');
      expect(tooltip.exists()).toBe(true);
      expect(tooltip.text().includes('Example Icon Very Cool')).toBe(true);
    });
  });
});
```

withComponent uses Enzyme's mount on the first parameter and runs the tests in the second parameter then unmounts at the end.

When I ran my unit tests the tests failed with `Invariant Violation: Invalid hook call. Hooks can only be called inside of the body of a function component.`
React documentation is kind enough to give three possible reasons why this error has occurred.

```
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
```

So what's going on here? In my tests, I was passing as the first parameter the component as a function that takes props. Hooks are supposed to be called at the top level of a function component or
in the body of a custom hook. Because my test then calls that function, it's trying to do hook things within a function that isn't a functional component and that throws an error since it breaks
the [Rules of Hooks](https://reactjs.org/docs/hooks-rules.html). To fix it, I've got to use SpecialIcon as a React functional component like this: `<SpecialIcon {...props} />`

```
describe('SpecialIcon Tests', () => {
  const props: ChangeTypeDisplayIconProps = {
    [other prop stuff omitted]
    contentClass = 'testClass'
  };

  it('mounts', () => {
    withComponent(<SpecialIcon {...props} />, wrapper => {
      expect(wrapper.find(SvgSpecialIcon).length).toBe(1);
    });
  });

  it('displays the tooltip when hovered over', () => {
    withComponent(<SpecialIcon {...props} />, wrapper => {
      const buttonWrapper = wrapper.find(ButtonWidget);
      const tooltipBeforeHover = wrapper.find('.testClass');
      expect(tooltipBeforeHover.exists()).toBe(false);
      buttonWrapper.simulate('mouseover');
      const tooltip = wrapper.find('.testClass');
      expect(tooltip.exists()).toBe(true);
    });
  });

  it('displays information about the icon in the tooltip', () => {
    withComponent(<SpecialIcon {...props} />, wrapper => {
      const buttonWrapper = wrapper.find(ButtonWidget);
      buttonWrapper.simulate('mouseover');
      const tooltip = wrapper.find('.testClass');
      expect(tooltip.exists()).toBe(true);
      expect(tooltip.text().includes('Example Icon Very Cool')).toBe(true);
    });
  });
});
```

React enforces these rules around hooks in order to keep hooks called in the same order when a component renders, and also to make it obvious that there is stateful logic that can happen (with a React functional component vs a TypeScript function). I guess that's fair enough.

Glad it was something simple and not gnarly!
