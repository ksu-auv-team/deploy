# Deployment Automation
## Goal:
Provide automation scripts for:
- Making dev environment setup straightforward for new team members
- Making deployment to machines (including subs) more automated
- Ensuring that the software on the bot can survive critical hardware failures
  without requiring a stage-1 install to get back to performance.

## TODO:
 - System integration scripts (daemonizing ROS, auto-patching, symver for the control software)
 - Prod environment optimization and image trimming.
 - Auto-packaging of the control system as a single functional unit (using rospack).
