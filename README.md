# VR Mini Project

## Overview

In this VR mini-project I demonstrate basic locomotion and object interaction in a Unity XR environment. The project features an Old Sea Port/Pirate themed scene where users can explore a pirate ship and interact with various harbor objects.

## Objectives

My basic objectives were:

- Set up a Unity project with XR Interaction Toolkit and OpenXR
- Implement teleportation and smooth locomotion
- Create an interactive VR scene using XR grab interactions and sockets

## Technical Requirements

- **Unity Version**: 6000.2.6f2
- **XR Packages**:
  - XR Interaction Toolkit (3.2.1)
  - OpenXR (1.15.1)
  - Android XR OpenXR (1.0.1)
  - Unity Input System (1.14.2)
- **Target Platform**: Android (Meta Quest 3)
- **Rendering Pipeline**: Universal Render Pipeline (URP)

## Assets Used

  - "Old Sea Port" asset pack (buildings, docks, water, environmental objects)
  - "Stylized Pirate Ship" asset pack (ship, barrels, cannons, cargo)
  - Flashlight asset (3d model)

## Scene Objectives

- **Mesh Count**: 20+ placed meshes including buildings, ship, cargo containers, barrels, and environmental props
- **Textures**: All objects have albedo/diffuse textures
- **PBR Textures**: 10+ objects with metallic, normal, and ambient occlusion maps
- **Lighting**: 5+ realtime lights (1 directional light, multiple spot lights for atmosphere)

## Interaction Objectives

- **Flashlight**: Grabbable rigidbody with hand pose interaction (similar to tennis racket example)
- **Cargo Barrels**: Physics-based objects that can be moved and stacked
- **Crates**: Physics-based objects that can be moved and stacked
- **Planks**: Physics-based objects that can be moved and stacked
- **Bottles**: Physics-based objects that can be moved and stacked
- **Hammers**: Physics-based objects that can be moved and stacked
- **Chairs**: Physics-based objects that can be moved and stacked
- **Ship Wheel**: Removable pirate ship wheel

## Sockets

- **Cargo Hold Sockets**: Easy positioning for barrels and cargo in ship hold
- **Bonfire Seat Sockets**: Easy positioning for chairs around a bonfire
- **Pirate Ship Wheel Socket**: For JDM-like steering wheel removal

## Optional Stretch Goals

- **Baked Lighting**: Directional light is baked on a single lightmap
- **Spatial Audio**: 3D positional audio for the ocean wave sounds
- **Height Map**: The tree trunk bark textures have height maps
- **Shader Graph Effect**: Not implemented
- **Visual Feedback**: Not implemented

## Demo Video

Included in repository.

There are two demo videos:
- A Unity demo showcasing the project.
- A quick demo on Quest 3 showing the interactions.
    - I had last second issues with the XR interaction simulator.