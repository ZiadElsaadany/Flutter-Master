# Responsive & Adaptive UI — Interview Questions

## 1. Responsive vs Adaptive

### Question

> Phones go from 5 to 8 inches, and some fold. If you use `MediaQuery` or a sizer
> package, is the app responsive or adaptive? If on a big tablet you replace the bottom
> navigation bar with a side bar, is that responsive or adaptive?

### Answer

- **Responsive:** the **same UI fits the available space**. Sizes, spacing, number of
  columns and wrapping adjust to the width. No overflow, nothing broken.
- **Adaptive:** the UI **changes to be usable on that device**: different components,
  navigation patterns or interactions depending on form factor, platform or input
  (touch, mouse, keyboard).

So scaling with `MediaQuery` is responsive. Swapping a `NavigationBar` for a
`NavigationRail`/side bar on tablets, or Cupertino vs Material widgets, is adaptive.
Flutter's docs summarize it as: responsive is about **fitting** the space, adaptive is
about being **usable** in the space.

```dart
// Responsive: same widgets, layout depends on the space.
LayoutBuilder(builder: (context, constraints) {
  final columns = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 3 : 2;
  return GridView.count(crossAxisCount: columns, children: products);
});

// Adaptive: different navigation component per form factor.
final isWide = MediaQuery.sizeOf(context).width >= 840;
return isWide
    ? Row(children: [NavigationRail(/* ... */), Expanded(child: body)])
    : Scaffold(body: body, bottomNavigationBar: NavigationBar(/* ... */));
```

Prefer `LayoutBuilder` (the space the widget actually gets) or `MediaQuery.sizeOf`
(rebuilds only on size changes) over `MediaQuery.of(context).size`.

### Mental model

Responsive = stretch. Adaptive = swap.

### Common mistake

The candidate first said "responsive is about different platforms". That's backwards:
platform and device differences are the adaptive side.

### Quick revision

Responsive: the same UI resizes to fit. Adaptive: different UI or behavior per device,
platform or input.

## 2. Handling Many Layouts Without Breaking Open/Closed

### Question

> On each platform you don't only scale components, you change *where* they are
> displayed. Do you handle that with `switch`/`if` inside every component? Can OOP and
> SOLID help, so adding a new platform later doesn't mean editing existing code?

### Answer

Scattering `if (isTablet)` through every widget is hard to maintain, and every new form
factor means editing many files. That violates **Open/Closed**.

Better:

1. Decide the form factor in **one place** (breakpoints → an enum or sealed type).
2. Give each form factor its own layout class (a **Strategy**). Screens receive the
   layout or build through it, and feature widgets stay layout-agnostic.
3. A new platform means a new layout class plus one registration line. Existing
   layouts don't change.

```dart
enum FormFactor { phone, tablet, desktop }

FormFactor formFactorOf(double width) => switch (width) {
      < 600 => FormFactor.phone,
      < 1200 => FormFactor.tablet,
      _ => FormFactor.desktop,
    };

abstract interface class AppLayout {
  Widget build(Widget body, List<NavItem> items);
}

final layouts = <FormFactor, AppLayout>{
  FormFactor.phone: BottomNavLayout(),
  FormFactor.tablet: RailLayout(),
  FormFactor.desktop: SidebarLayout(),
};

// Used once, at the shell:
layouts[formFactorOf(MediaQuery.sizeOf(context).width)]!.build(body, items);
```

A single **exhaustive `switch`** over a sealed type or enum, in one place, is also
fine. The compiler then forces you to handle every new case. The problem is the
same `switch` repeated across many widgets.

### Mental model

Decide once, at the top. Everything below just builds.

### Common mistake

The candidate said adding new `if` conditions "doesn't break SOLID". One central
condition is pragmatic, but conditions copied into every component do break
Open/Closed: each new platform forces edits in many files.

### Quick revision

Centralize breakpoint logic and use one layout strategy per form factor. New platform
= new class, not edits everywhere.
