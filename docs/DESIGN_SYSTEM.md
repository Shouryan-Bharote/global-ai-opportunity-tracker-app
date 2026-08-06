# Design System

This document outlines the core visual foundation of the AI Event Tracker, extracted from Figma. All values are represented in `lib/core/theme/`.

## 1. Typography

- **Primary Font:** Poppins
- **Fallback:** sans-serif

### Type Scale

| Role | Size | Weight | Use Case |
|------|------|--------|----------|
| `displayLarge` | 40 | Bold (700) | Hero sections |
| `displayMedium` | 36 | Bold (700) | Main onboarding headers |
| `displaySmall` | 32 | Bold (700) | Large metrics |
| `headlineLarge` | 28 | SemiBold (600) | Screen titles |
| `headlineMedium` | 24 | SemiBold (600) | Section titles |
| `headlineSmall` | 20 | SemiBold (600) | Card titles |
| `titleLarge` | 18 | Medium (500) | Prominent titles |
| `titleMedium` | 16 | Medium (500) | Default list titles |
| `titleSmall` | 14 | Medium (500) | Small list titles |
| `bodyLarge` | 18 | Regular (400) | Large body text |
| `bodyMedium` | 16 | Regular (400) | Default body text |
| `bodySmall` | 14 | Regular (400) | Secondary body text |
| `labelLarge` | 16 | Medium (500) | Large labels |
| `labelMedium` | 14 | Medium (500) | Default labels |
| `labelSmall` | 12 | Medium (500) | Badges, small labels |
| `button` | 16 | SemiBold (600) | Standard buttons |
| `caption` | 12 | Regular (400) | Dates, microcopy |

---

## 2. Color System

| Role | Hex | Variable | Use Case |
|------|-----|----------|----------|
| Primary | `#3E63F5` | `AppColors.primary` | Main buttons, active states, links |
| Secondary | `#5D7BFF` | `AppColors.secondary` | Secondary actions |
| Accent Pink | `#FF4D94` | `AppColors.accentPink` | Chips, gradients |
| Accent Purple | `#8A4DFF` | `AppColors.accentPurple` | Gradients |
| Accent Cyan | `#5BE7FF` | `AppColors.accentCyan` | Badges, highlights |
| Background | `#FAF8FF` | `AppColors.background` | Scaffold background |
| Surface | `#FFFFFF` | `AppColors.surface` | App bar, bottom sheets |
| Card | `#FFFFFF` | `AppColors.card` | Elevated cards |
| Bottom Nav | `#111111` | `AppColors.bottomNavigation` | Bottom navigation bar |
| Text Primary | `#111111` | `AppColors.textPrimary` | Default text |
| Text Secondary | `#6E6E73` | `AppColors.textSecondary` | Subtitles, body |
| Hint Text | `#A1A1AA` | `AppColors.textHint` | Text field hints |
| Border | `#E5E7EB` | `AppColors.border` | Input borders, card borders |
| Divider | `#ECECEC` | `AppColors.divider` | List dividers |
| Success | `#39D353` | `AppColors.success` | Success states |
| Warning | `#F59E0B` | `AppColors.warning` | Warning states |
| Error | `#EF4444` | `AppColors.error` | Error states, validation |
| Live Badge | `#FF2D2D` | `AppColors.liveBadge` | Live event badges |
| Online | `#30D158` | `AppColors.onlineIndicator` | Online status |

**Gradients:**
- `primaryGradient`: `accentPink` → `accentPurple` → `primary`

---

## 3. Spacing Scale

| Value (px) | Variable | Semantic Mapping | Use Case |
|------------|----------|------------------|----------|
| 4 | `s4` | - | Micro spacing |
| 8 | `s8` | - | Icon spacing |
| 12 | `s12` | - | Small gap |
| 16 | `s16` | `cardPadding`, `listGap` | Card content, lists |
| 20 | `s20` | - | Medium gap |
| 24 | `s24` | `screenPadding`, `sectionGap`| Screen edges, sections |
| 32 | `s32` | - | Large sections |
| 40 | `s40` | - | Grouping |
| 48 | `s48` | - | Grouping |
| 56 | `s56` | - | Button heights |
| 64 | `s64` | - | Bottom padding |

---

## 4. Radius

| Value (px) | Variable | Use Case |
|------------|----------|----------|
| 4 | `extraSmall` | Checkboxes, small tags |
| 8 | `small` | Small images |
| 12 | `medium` | Default containers |
| 16 | `large` | Buttons, Inputs |
| 20 | `extraLarge` | Large images |
| 24 | `card` | All event/schedule cards |
| 999 | `pill` | Chips, Badges, FAB |

---

## 5. Shadows

| Type | Offset | Blur | Opacity | Use Case |
|------|--------|------|---------|----------|
| Card | Y: 8 | 24 | 0.08 | Default cards |
| FAB | Y: 12 | 32 | 0.12 | Floating Action Buttons |

---

## 6. Implementation Rules

1. **No hardcoding:** Use `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`, `AppShadows`.
2. **Material 3:** Leverage `Theme.of(context)` for standardized values where applicable.
3. **Responsive:** Use `AppSpacing.screenPadding` to dynamically pad main views.
