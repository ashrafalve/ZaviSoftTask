# Daraz Clone

A Flutter e-commerce app with Daraz-style product listing.

## Features
- Login & Profile screens
- Product listing with categories (All, Electronics, Jewelery, Men's Clothing)
- Auto-sliding banner (every 2 seconds)
- Search functionality
- Pull-to-refresh

## Architecture

Horizontal Swipe: TabBarView with NeverScrollableScrollPhysics - handles horizontal gestures separately from vertical scroll.

Vertical Scroll: CustomScrollView owns the single vertical scroll. All nested widgets use NeverScrollableScrollPhysics to prevent conflicts.

Trade-offs: 
- Tab content GridViews cannot scroll independently (all scroll goes to parent)
- Single scroll maintains position when switching tabs

## Run
```bash
cd task
flutter pub get
flutter run
```
