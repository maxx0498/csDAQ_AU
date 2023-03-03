using Conda
Conda.pip_interop(true)
Conda.pip("install", "/usr/local/share/ids/bindings/python/wheel/ids_peak_ipl-1.4.0.0-cp310-cp310-linux_x86_64.whl")
Conda.pip("install", "/usr/local/share/ids/bindings/python/wheel/ids_peak-1.4.2.2-cp310-cp310-linux_x86_64.whl")