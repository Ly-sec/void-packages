# linux-orbit notes

## What this kernel changes
- **Clang ThinLTO toolchain** for smaller, faster binaries without relying on GCC plugins.
- **Scheduler tuning**: shorter CFS slice, lower migration cost, and hrtick/next-buddy enabled to keep interactive tasks responsive.
- **Autogroup enabled** so desktop workloads stay smooth even with heavy background jobs.
- **RT runtime throttle disabled** (sysctl defaults to `-1`), so audio/game threads aren’t clipped; restore with `sudo sysctl kernel.sched_rt_runtime_us=950000` if needed.

Everything else stays close to upstream so future updates remain simple.

## Building and installing
1. Build the package inside the `void-packages` tree:
   ```
   ./xbps-src pkg linux-orbit
   ```
2. Install the built package on your system:
   ```
   sudo xbps-install -R hostdir/binpkgs linux-orbit
   ```

## Post-install steps
After installing, regenerate initramfs and bootloader entries for the new kernel release (kernelrelease appears as `6.17.7-orbit`):

```
sudo xbps-reconfigure -f linux-orbit
sudo dracut --force --kver 6.17.7-orbit
sudo grub-mkconfig -o /boot/grub/grub.cfg   # or your bootloader’s equivalent
```

Adjust the dracut/grub commands if you use a different init system or bootloader. Reboot and pick the `*-orbit` kernel to test.

## Optional: AutoFDO / Propeller pipeline
If you want to squeeze a few more percent out of your exact workload, you can feed AutoFDO and Propeller profiles back into the build. The high-level flow is:

1. Build and boot the default kernel (no profiles yet).
2. Collect samples while running your workload, e.g.
   ```
   sudo perf record -e cycles:u -j any,u -o perf.data -- sleep 0  # keep perf running while you play/work
   sudo perf record -e cycles:u -j any,u -o perf.data --command ...
   ```
   Make sure `vmlinux` with symbols is available (use the one in `hostdir` or `/usr/lib/debug`).
3. Convert the perf data to an AutoFDO profile:
   ```
   llvm-profgen --binary /path/to/vmlinux --perfdata perf.data --output kernel.afdo
   ```
4. (Optional) Generate Propeller layout files (requires the Propeller tools):
   ```
   propeller-opt --binary /path/to/vmlinux --sample-profile kernel.afdo \
     --config-out kernel.prop.cfg --profile-out kernel.prop.data
   ```
5. Rebuild the kernel with the profiles:
   ```
   AFDO_PROFILE=/path/to/kernel.afdo \
   PROPELLER_CFG=/path/to/kernel.prop.cfg \
   PROPELLER_PROFILE=/path/to/kernel.prop.data \
   ./xbps-src pkg linux-orbit
   ```
   Omit `PROPELLER_CFG/PROFILE` if you only use AutoFDO. The template will pass the right flags when these environment variables are set.

Install and reboot as usual. Re-run profiling whenever you significantly change workloads; stale profiles can hurt performance. For details on the tools see the LLVM AutoFDO docs and the Google Propeller project.
