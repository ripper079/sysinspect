# sysinspect
A Linux system introspection toolkit that collects and analyzes low-level hardware and kernel information, delivering comprehensive reports for debugging, profiling, and system auditin

<h1>Features</h1>
<ul>
<li>Performs deep system inspection of hardware devices using native Linux interfaces.</li>
  <li>Collects and reports CPU, memory, storage, GPU, and input device information.</li>
  <li>Detects and classifies storage devices (SATA, NVMe) with interface identification.</li>
  <li>Extracts detailed hardware metadata (model, capacity, topology).</li>
  <li>Supports GPU inspection, including VRAM detection (where supported).</li>
  <li>Enumerates input devices (keyboard, mouse, touchpad) via kernel and udev data.</li>
  <li>Filters out virtual and non-physical devices (e.g., loop devices, optical drives).</li>
  <li>Outputs a structured, human-readable system report to standard output.</li>
  <li>Designed for low-level environments with minimal abstraction layers.</li>
</ul>
