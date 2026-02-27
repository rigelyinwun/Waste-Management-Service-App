# 🌱 SmartWaste  
## Waste Management Service Platform  

AI-powered waste routing and reuse platform  
Supporting SDG 11 (Sustainable Cities & Communities) & SDG 12 (Responsible Consumption & Production)

---

## Overview

SmartWaste is an AI-powered platform that connects:

- Households
- Volunteers
- Waste Management Companies

The system classifies household waste using AI, matches it with suitable service providers, enables public reuse for still-usable items, estimates collection cost for bulky items, and tracks environmental impact.

Instead of unmanaged disposal, SmartWaste enables intelligent routing, reuse-first logic, and a closed-loop waste lifecycle.

---

## Tech Stack

- **Flutter** – Cross-platform mobile development
- **Firebase Authentication** – Google login
- **Firebase Firestore** – Real-time database
- **Firebase Cloud Functions** – Automation & smart matching
- **Gemini API (Google AI Studio)** – AI waste classification & estimation
- **Google Maps API** – Location-based services & visualization

---

## Problem Statement

Households often struggle with:

- Disposing bulky items (sofas, furniture, appliances)
- Identifying the correct waste management company
- Estimating disposal cost
- Reusing still-usable items efficiently

Waste management companies receive unstructured, inefficient requests.

Reusable items frequently end up in landfills due to lack of coordination.

---

## 🎯 Our Solution

SmartWaste provides:

### AI Waste Classification
- Identifies waste type (clothes / metal / furniture / e-waste)
- Estimates size / volume
- Determines recyclability level
- Suggests pickup priority
- Estimates collection effort / cost

### Smart Matching Engine
- Matches users with companies based on:
  - Waste type
  - Service region
- Supports automatic rematching if companies decline

### Public Reuse Mode
- Users can allow public visibility for reusable items
- Volunteers can request collection
- Real address revealed only after confirmation

### Geo-Intelligent Mapping
- Waste locations
- Dumping stations
- Service coverage
- Privacy-aware rough location masking

### Environmental Impact Dashboard
- Total reports
- Total collected
- Collection trends
- Waste diverted from landfill
- Estimated recycling benefit

---

## User Features

- Google login
- Waste reporting with image & description
- AI-generated waste profile
- Estimated cost display
- Public reuse option
- Map-based browsing
- Volunteer request system
- Notifications
- Feedback after collection

---

## Company (Admin) Features

- Company registration (waste types, service region)
- Matched report dashboard
- AI waste profile view
- Request collection flow
- Controlled “Mark as Collected” system
- Summary analytics & trends
- Dumping station management

---

## Core Workflow

1. User submits waste report
2. AI analyzes image & description
3. System matches suitable company
4. Item appears on map (public or company-only)
5. Volunteer/company requests pickup
6. User confirms
7. Item collected
8. Feedback recorded
9. Environmental impact calculated

## To Run This Project:

### 1. Configure Environment Variable
Create an environment variable for your Gemini API key:
```bash
AI_API_KEY=YOUR_API_KEY
```
Alternatively, you can pass it directly using Dart define (recommended for Flutter).

### 2. Install Dependencies
```bash
flutter pub get
```
### 3. Run the Application
```bash
flutter run --dart-define=AI_API_KEY=YOUR_API_KEY
```

---

## Key Innovations

- AI-powered waste classification
- Smart service matching engine
- Reuse-first circular model
- Privacy-preserving location logic
- Closed-loop lifecycle tracking
- Environmental impact analytics

---
## Challenges Faced

- AI Accuracy Limitations: Estimating weight, size, and recyclability from images requires prompt tuning and testing.

- Real-time Synchronization: Preventing duplicate collection requests using Firebase concurrency handling.

- Location Precision: Handling GPS inconsistencies and ensuring accurate Malaysia-only mapping.

- API Key Security: Managing environment variables securely without exposing credentials.

---

## Future Roadmap

- Improved AI Accuracy: Fine-tune prompts and integrate structured output validation.

- Carbon Impact Dashboard: More advanced environmental impact analytics (CO₂ saved, landfill diversion rate).

- NGO & Municipal Integration: Partner with local councils for official waste coordination.

- Gamification System: Reward points and leaderboard for volunteers.

- Scalability Expansion: Extend coverage beyond Malaysia to regional Southeast Asia.

---

## Conclusion

SmartWaste is an AI-powered waste management platform that intelligently connects households, volunteers, and waste companies to enable reuse-first waste routing and create a smarter, cleaner urban ecosystem.
