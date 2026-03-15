# Project Name: ZenSpace
# Core Concept
ZenSpace is an iOS application that combines Apple's RoomPlan (LiDAR scanning), RealityKit (3D rendering), and Claude 3.5 Sonnet (LLM Spatial Reasoning). It uses a "Freemium" business model to diagnose room layouts (Feng Shui / Environmental Psychology) and provide gamified, "The Sims" style 3D automated layout optimizations.

# Tech Stack
- Frontend: SwiftUI, Swift 5.9+
- AR/3D Engine: RealityKit, RoomPlan API
- Backend/Auth: Supabase (PostgreSQL, Edge Functions)
- Monetization: RevenueCat

# UI/UX Vision (The "Sims" Style)
We DO NOT want a standard first-person AR view. 
After scanning, the app must switch to an **Orthographic Projection (Isometric God View)**. Real scanned meshes should be replaced with stylized, Low-Poly `.usdz` 3D models (e.g., a real bed is replaced by a cartoon `sims_bed.usdz`).

# Business Logic (Freemium Flow)
1. **Free Tier (Diagnosis)**: The app scans the room, extracts static structures (walls/doors) and dynamic objects (furniture). It sends this JSON to the AI. The UI displays the current score and shows red warning indicators over poorly placed furniture.
2. **Premium Tier (Solution & Animation)**: Once the user subscribes, the app unlocks the AI's `new_position` data. Using RealityKit's `FromToByAnimation`, the bad furniture smoothly floats and snaps into the optimized "good" position automatically.

# Development Milestones
- [ ] Milestone 1: Core RoomPlan Scanning & Data Extraction (JSON).
- [ ] Milestone 2: RealityKit Isometric Rendering & Asset Swapping.
- [ ] Milestone 3: AI Prompting & JSON Data Communication.
- [ ] Milestone 4: State Management (Free/Premium) & Smooth 3D Animations.
- [ ] Milestone 5: Supabase Auth & RevenueCat Integration.

# AI Coding Guidelines
- Always write thread-safe Swift code.
- Prioritize modularity: Keep scanning logic, 3D rendering logic, and state management in separate managers.
- When generating UI, use modern, minimalist, "Zen" design principles.
