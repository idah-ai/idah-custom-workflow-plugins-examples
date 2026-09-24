# IDAH Custom Workflow Plugins — Examples

This repository provides working examples of **custom workflow plugins** for the [IDAH](https://idah.ai) platform. These plugins demonstrate how to extend the IDAH dataset service with custom annotation workflows that go beyond the built-in default workflow.

## Overview

IDAH supports a plugin system that allows you to define custom state machines for your annotation projects. Instead of the standard one-step annotation pipeline, you can create workflows with multiple review stages, external quality checks, and any number of custom states and transitions.

This repository contains three projects that build on each other:

| Project | Description |
|---|---|
| [`double-review-workflow/`](./double-review-workflow) | A minimal example plugin that adds an extra review step to the annotation pipeline. Best starting point for learning the plugin API. |
| [`qc-workflow/`](./qc-workflow) | A more advanced plugin that integrates an automatic external **Quality Control (QC)** step between annotation and human review. |
| [`mock-qc-app/`](./mock-qc-app) | A lightweight Sinatra application that simulates an external QC service for end-to-end testing of the `qc-workflow` plugin.
---

## Repository Structure

```
idah-custom-workflow-plugins-examples/
├── double-review-workflow/        # Basic custom-workflow example (start here)
│   ├── manifest.json              # Plugin manifest — declares workflows
│   ├── backends/dataset/          # Backend code loaded by the dataset service
│   └── README.md
├── qc-workflow/                   # External-QC integration example
│   ├── manifest.json
│   ├── backends/dataset/
│   ├── config/
│   └── README.md
├── mock-qc-app/                   # Test harness for the QC workflow
│   ├── app.rb                     # Sinatra app
│   ├── Gemfile
│   └── README.md
└── README.md                      # This file
```

---

## Getting Started

### 1. Understand the Plugin System

A custom workflow plugin consists of two parts:

- **Plugin Manifest** (`manifest.json`) — Declares metadata, available workflows, and the backend entry point.
- **Backend Module** (`backends/dataset/`) — Ruby code that registers workflows with the IDAH dataset service and implements the custom state machine using [AASM](https://github.com/aasm/aasm).

Workflows are **discoverable** via the API (`GET /dataset/workflows`) and **selectable per dataset** when creating a new dataset (via `workflow_name`).

### 2. Explore the Examples

Start with the **[double-review-workflow](./double-review-workflow)** to see the minimal plugin structure. It defines a workflow with five states (`start → annotate → review → final_check → done`) and demonstrates:

- Writing a plugin manifest
- Registering a workflow in the dataset backend
- Defining states and transitions with AASM
- Exposing step definitions to the frontend

Then move to the **[qc-workflow](./qc-workflow)** to see how to integrate an external service into the workflow lifecycle. It adds a `qc` state where the entry is locked until an external application calls back.

### 3. Test with the Mock QC App

The **[mock-qc-app](./mock-qc-app)** lets you run the full QC workflow end-to-end without a real external service. It:

- Receives annotation data from IDAH
- Simulates processing (e.g., a model inference or manual QC)
- Calls back to IDAH to advance the workflow and update annotations

---

## How Custom Workflows Work

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     IDAH Dataset Service                                     │
│                                                                              │
│   Plugin Manager           Workflow Registry    Dataset Model                │
│   ┌──────────┐             ┌───────────────┐    ┌───────────┐                │
│   │ Load     │ ──register─▶│ custom-       │    │ workflow  │                │
│   │ plugins  │             │ annotation    │    │ _name     │                │
│   └──────────┘             │ workflow      │    │ (per      │                │
│                            └───────┬───────┘    │  dataset) │                │
│                                    │            └───────────┘                │
│                            ┌───────▼──────┐                                  │
│                            │ AASM State   │     Entry Submission             │
│                            │ Machine      │     ┌──────────────┐             │
│                            │              │────▶│ Look up      │             │
│                            │ start        │     │ workflow by  │             │
│                            │  ↓           │     │ workflow_name│             │
│                            │ annotate     │     └──────┬───────┘             │
│                            │  ↓           │            │                     │
│                            │ review       │     ┌──────▼──────┐              │
│                            │  ↓           │     │ Execute     │              │
│                            │ done         │     │ transitions │              │
│                            └──────────────┘     └─────────────┘              │
└──────────────────────────────────────────────────────────────────────────────┘
```

1. **Plugin Loading** — On startup, the dataset service loads all plugins from the configured directory.
2. **Workflow Registration** — Each plugin's backend `init` method registers its workflows in the `Workflow::Registry`.
3. **Workflow Discovery** — The frontend queries available workflows via the API and lets users pick one.
4. **Dataset Creation** — The user explicitly selects a `workflow_name` when creating a dataset.
5. **Entry Submission** — When an entry transitions between states, the dataset service looks up the registered workflow class and executes the appropriate AASM events.

---

## Creating Your Own Workflow Plugin

1. **Copy an example** — Use `double-review-workflow/` as a template.
2. **Edit the manifest** — Set your plugin name and declare your workflows in the `workflows` array.
3. **Implement the state machine** — Create a class that extends `Workflow::Base` and define states/transitions with AASM.
4. **Define frontend steps** — Provide step configuration (names, labels, actions) so the UI knows what to render.
5. **Register the workflow** — Call `context.register_workflow(...)` in your backend init method.
6. **Deploy** — Place the plugin directory in the dataset service's `plugins/` path and restart.

See the **[double-review-workflow README](./double-review-workflow/README.md)** for a detailed walkthrough.

---

## Requirements

- IDAH platform (version supporting the plugin system)
- Ruby 3.x (for backend plugin development)
- AASM gem (included in the IDAH dataset service)

---

## License

This project is provided as open-source examples under the [MIT License](LICENSE) (or your preferred license).
