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

<h1>Notes</h1>
This program prioritizes the use of standard, widely available Linux utilities wherever possible to minimize external dependencies. Optional tools are only used when available, with fallback methods implemented using core system interfaces.


<h2>Dependencies</h2>
<ul>
  <li>dmidecode</li>
  <li>lshw</li>
  <li>hdparm</li>
  <li>sed</li>
  <li>awk</li>
</ul>
These packages are commonly included in default installations or available through official package repositories. The script relies on these utilities and must be installed/present before running the script

<h1>Installation</h1>
Clone or download the script, then make it executable:

```bash
git clone https://github.com/ripper079/sysinspect.git
cd <your-repo-folder>
chmod +x sysinspect.sh  
```
And then run the script

```bash
sudo ./sysinspect.sh
```
