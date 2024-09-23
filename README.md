# RESAA: Removal and Structural Analysis Attack Against Compound Logic Locking

RESAA is a novel framework designed to classify CLL-locked designs, identify critical gates, and execute various attacks to uncover secret keys. It is a versatile tool that is agnostic to specific logic locking (LL) techniques, offering comprehensive insights into the security scenarios of compound logic locking (CLL). 

## Features

- **Classification of CLL-locked designs**: Automatically classifies designs protected by various CLL techniques.
- **Critical gate identification**: Pinpoints gates crucial for the security of the CLL-locked design.
- **Execution of diverse attacks**: Implements several structural analysis attacks to reveal secret keys, regardless of the logic locking technique used.
- **Threat model-based analysis**: Adapts to different threat models, providing flexible and tailored attack strategies.
- **Agnostic to specific LL techniques**: Can work with a variety of logic locking schemes without requiring any specific approach.

## Experimental Results

Experimental evaluations have shown that RESAA is highly effective in:
- Identifying critical gates in CLL-locked circuits.
- Differentiating between segments associated with various logic locking techniques.
- Accurately determining the keys based on different threat models.

## Usage

RESAA is designed to be flexible and can be applied to different types of logic locking scenarios. Here's an example of how to use the tool:

```bash
python3 compound_tool.py locked_circuit.v
