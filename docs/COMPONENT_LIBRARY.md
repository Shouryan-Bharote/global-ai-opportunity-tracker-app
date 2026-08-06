# Component Library

This document outlines the standard, reusable UI components extracted from Figma that will be built for the AI Event Tracker. 

*Note: This is the specification. Implementation will happen progressively in feature phases.*

## 1. Buttons

### `PrimaryButton`
- **Height:** 56px
- **Radius:** 16px (large)
- **Background:** `AppColors.primary`
- **Text:** White, `AppTypography.button`
- **Use:** Main CTA, Submit forms, Registration.

### `SecondaryButton`
- **Use:** Cancel actions, secondary options.

### `GradientButton`
- **Background:** `primaryGradient`
- **Text:** White
- **Use:** Premium features, highly promoted actions.

## 2. Inputs

### `SearchField`
- **Height:** 56px
- **Radius:** 16px (large)
- **Background:** White
- **Border:** `AppColors.border`
- **Prefix:** Search Icon (Gray)

### `PasswordField` & `OTPField`
- **Use:** Authentication screens.

## 3. Navigation

### `BottomNavigation`
- **Height:** 80px
- **Background:** `#111111`
- **Items:** Inactive (gray), Active (white/blue).

### `FloatingNavigationButton`
- **Style:** Circular (pill radius).
- **Background:** `AppColors.primary`
- **Shadow:** FAB Shadow (Y:12, Blur:32, Opacity:0.12)
- **Position:** Center of bottom navigation.

## 4. Cards

**Global Card Rules:**
- **Radius:** 24px
- **Padding:** 16px
- **Background:** White
- **Shadow:** Card Shadow (Y:8, Blur:24, Opacity:0.08)

### Types of Cards to Implement:
- `EventCard`: Standard event listing.
- `TrendingCard`: Featured events (possibly horizontal scroll).
- `ScheduleCard`: For the user's agenda.
- `SpeakerCard`: Profile of a speaker.
- `CategoryCard`: Browse by category.

## 5. Chips & Tags

**Global Chip Rules:**
- **Height:** 40px
- **Radius:** Pill (999px)

### `CategoryChip` / `FilterChip`
- **Inactive State:** White background, Gray border, Gray text.
- **Active State:** Gradient background (Pink → Purple), No border, White text.

### `StatusBadge` & `DateBadge`
- Small pills indicating "Live", "Online", or dates. Use `labelSmall` text.

## 6. Miscellaneous

- `BookmarkButton`: Toggle state (filled/outline icon).
- `Avatar`: Circular user profile image.
- `HeroBanner`: Large top image for event details.
- `SectionHeader`: Row with `headlineMedium` title and optional "See All" text button.
- `LoadingState` / `EmptyState` / `ErrorState`: Standardized placeholder views.
