# 🎨 Admin Dashboard - UI Design Guide

This document describes the visual design and user interface of the admin dashboard.

## 🖥️ Dashboard Layout

### App Bar (Navy Blue Background)
```
┌─────────────────────────────────────────────────────────────┐
│  [🔷 Icon] Admin Dashboard              [Logout Button]     │
│             Manage Approvals                                 │
│  ┌─────────────────┬─────────────────┐                      │
│  │   🏢 Startups   │  🏦 Investors   │  (Tabs)             │
└──┴─────────────────┴─────────────────┴──────────────────────┘
```

### Statistics Row (White Background)
```
┌────────────────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ ⏱️  Pending  │  │ ✅ Approved  │  │ ❌ Rejected  │     │
│  │      5       │  │      23      │  │      2       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────────────────────────────────────────┘
```
- **Pending**: Yellow/Orange background
- **Approved**: Green background  
- **Rejected**: Red background

### Profile List (Scrollable)

#### Collapsed Card
```
┌─────────────────────────────────────────────────────────────┐
│  ┌──────┐                                                    │
│  │ 🏢   │  TechCorp Solutions                           ▼   │
│  │ Logo │  [Startup] • Aug 19, 2026                         │
│  └──────┘                                                    │
│  [📦 Technology] [📍 Addis Ababa] [📈 Seed Stage]           │
└─────────────────────────────────────────────────────────────┘
```

#### Expanded Card
```
┌─────────────────────────────────────────────────────────────┐
│  ┌──────┐                                                    │
│  │ 🏢   │  TechCorp Solutions                           ▲   │
│  │ Logo │  [Startup] • Aug 19, 2026                         │
│  └──────┘                                                    │
│  [📦 Technology] [📍 Addis Ababa] [📈 Seed Stage]           │
│ ─────────────────────────────────────────────────────────── │
│  👤 Contact Person                                           │
│     John Doe                                                 │
│                                                              │
│  📧 Email                                                    │
│     john@techcorp.com                                        │
│                                                              │
│  💰 Funding Sought                                           │
│     $500,000                                                 │
│                                                              │
│  📄 Description                                              │
│     We are building an AI-powered platform that...          │
│     (full description text here)                             │
│                                                              │
│  ┌──────────────┐    ┌──────────────────────────────┐      │
│  │  ❌ Reject   │    │    ✅ Approve                │      │
│  └──────────────┘    └──────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 🎨 Color Palette

### Primary Colors
- **Action Cyan**: `#00D1FF` - Primary CTAs, highlights, active states
- **Trust Navy**: `#0A2540` - App bar, headers, structural elements
- **White**: `#FFFFFF` - Cards, backgrounds

### Status Colors
- **Success Green**: `#11845B` - Approved state, approve button
- **Warning Orange**: `#9A6700` - Pending state, pending badge
- **Error Red**: `#BA1A1A` - Rejected state, reject button

### Role Colors
- **Primary (Cyan)**: Startup-related elements
- **Violet**: `#7F77DD` - Investor-related elements

### Neutral Colors
- **Ink**: `#2C2C2A` - Primary text
- **Slate**: `#5F5E5A` - Secondary text
- **Hairline**: `#D3D1C7` - Borders, dividers
- **Fog**: `#F1EFE8` - Page background

## 📐 Component Specifications

### Stats Card
```dart
Container(
  padding: 16px,
  borderRadius: 12px,
  border: 1px (color with opacity),
  backgroundColor: (status color with 10% opacity)
)
```

- **Icon Size**: 20px
- **Count Size**: 24px, bold (700)
- **Label Size**: 12px, semi-bold (600)

### Profile Card

#### Dimensions
- **Logo/Icon**: 56x56px
- **Border Radius**: 16px
- **Padding**: 16px
- **Border**: 1px (cyan when expanded, hairline when collapsed)

#### Typography
- **Business Name**: 18px, bold (700)
- **Badge Text**: 11px, semi-bold (600)
- **Date**: 12px, regular
- **Chip Labels**: 12px, medium (500)
- **Detail Labels**: 12px, medium (500)
- **Detail Values**: 14px, semi-bold (600)
- **Description**: 14px, regular, line-height 1.5

#### Badges
```
┌──────────┐
│ Startup  │  Background: Cyan 10%, Text: Cyan
└──────────┘

┌──────────┐
│ Investor │  Background: Violet 10%, Text: Violet
└──────────┘
```

### Info Chips
```
┌──────────────────┐
│ 📦 Technology    │  Light gray background
└──────────────────┘
```
- **Padding**: 8px horizontal, 6px vertical
- **Border Radius**: 8px
- **Background**: Fog color
- **Border**: 1px hairline

### Action Buttons

#### Reject Button (Outlined)
- **Height**: 48px
- **Border**: 1px red
- **Text Color**: Red
- **Border Radius**: 12px
- **Icon**: ❌ close icon

#### Approve Button (Filled)
- **Height**: 48px
- **Background**: Success green
- **Text Color**: White
- **Border Radius**: 12px
- **Icon**: ✅ check_circle icon

## 📱 Responsive Behavior

### Mobile Portrait
- Full-width cards
- Statistics cards stack if needed
- Comfortable touch targets (min 48px height)

### Tablet/Desktop
- Maximum content width: 720px
- Centered layout
- Larger horizontal spacing

## 🎭 States & Animations

### Loading State
```
┌─────────────────────────────────────────┐
│                                         │
│          ⭕ Loading spinner             │
│          (Cyan colored)                 │
│                                         │
└─────────────────────────────────────────┘
```

### Empty State
```
┌─────────────────────────────────────────┐
│                                         │
│          📭 Large inbox icon            │
│          (Gray/hairline color)          │
│                                         │
│       No pending startups               │
│  All applications have been reviewed    │
│                                         │
└─────────────────────────────────────────┘
```

### Error State
```
┌─────────────────────────────────────────┐
│                                         │
│          ⚠️ Error icon (64px)           │
│                                         │
│       Failed to load profiles           │
│                                         │
│      ┌──────────────────┐               │
│      │  🔄 Retry        │               │
│      └──────────────────┘               │
└─────────────────────────────────────────┘
```

### Snackbar Notifications

#### Success
```
┌─────────────────────────────────────────┐
│ ✅ Profile approved successfully        │
└─────────────────────────────────────────┘
```
- Background: Green
- Icon: Check circle
- Position: Bottom, floating

#### Error
```
┌─────────────────────────────────────────┐
│ ❌ Failed to approve profile            │
└─────────────────────────────────────────┘
```
- Background: Red
- Icon: Error circle
- Position: Bottom, floating

## 🔄 Interactions

### Tap Card Header
- Expands/collapses card
- Icon changes: ▼ (collapsed) ↔ ▲ (expanded)
- Border highlights with cyan color
- Smooth animation

### Pull to Refresh
- Pull down gesture
- Circular progress indicator appears
- Reloads all profile data
- Shows success feedback

### Approve Action
1. User taps "Approve" button
2. Button shows loading state
3. Request sent to backend
4. Success snackbar appears
5. Card removed from list
6. Stats update automatically

### Reject Action
1. User taps "Reject" button
2. Button shows loading state
3. Request sent to backend
4. Success snackbar appears
5. Card removed from list
6. Stats update automatically

## 🎯 Accessibility Features

- **Touch Targets**: Minimum 48x48px
- **Contrast**: WCAG AA compliant
- **Icons**: Paired with text labels
- **Colors**: Not sole indicator of status
- **Loading States**: Clear visual feedback
- **Error Messages**: Descriptive and actionable

## 📏 Spacing System

- **XS**: 4px
- **SM**: 8px
- **MD**: 16px (most common)
- **LG**: 24px
- **XL**: 32px
- **XXL**: 48px

## 🎨 Typography Scale

- **Display Large**: For page titles
- **Headline Medium**: For section headers
- **Title Large**: For card headers (18px, bold)
- **Body Large**: For primary content
- **Body Medium**: For secondary content
- **Body Small**: For captions (12px, slate color)

## 🌈 Visual Hierarchy

1. **App Bar** - Navy, highest contrast
2. **Stats Cards** - Color-coded, attention-grabbing
3. **Profile Cards** - White, clean, organized
4. **Action Buttons** - Green (approve) draws more attention than red (reject)

---

This design creates a **professional, efficient, and beautiful** admin experience that aligns perfectly with your existing app design while providing all the functionality needed for effective profile management.
